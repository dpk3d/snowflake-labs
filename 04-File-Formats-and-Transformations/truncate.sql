/*
===========================================
DEEPAK'S TRUNCATECOLUMNS PRACTICE
===========================================
Topic: Handling Oversized Column Values
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- TRUNCATECOLUMNS handles values longer than column width
- Default behavior: Error on oversized values
- TRUNCATECOLUMNS = TRUE: Silently truncate to fit
- Use carefully - data loss possible
- Useful for known data quality issues
===========================================
*/

-- Deepak's Note: TRUNCATECOLUMNS prevents errors when data exceeds column length
-- But be careful - you're losing data!


-- ========================================
-- SETUP: CREATE TABLE WITH SMALL COLUMNS
-- ========================================

-- Deepak's scenario: Table with intentionally small CATEGORY column
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_truncate_test (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(10),  -- Deepak's note: Only 10 characters!
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Table for testing TRUNCATECOLUMNS';

-- Deepak's observation: Category column is VARCHAR(10)
-- If data has longer category names, it will fail


-- ========================================
-- CREATE STAGE WITH DATA
-- ========================================

-- Deepak's scenario: Stage with files containing long category names
CREATE OR REPLACE STAGE deepak_sales_db.public.deepak_truncate_stage
    URL = 's3://deepak-snowflake-data/truncate-test/'
    COMMENT = 'Deepak - Stage with oversized column values';

LIST @deepak_sales_db.public.deepak_truncate_stage;

-- Deepak's observation: Files contain category names longer than 10 characters


-- ========================================
-- TEST 1: DEFAULT BEHAVIOR (ERROR)
-- ========================================

-- Deepak's experiment: Load without TRUNCATECOLUMNS
COPY INTO deepak_sales_db.public.orders_truncate_test
    FROM @deepak_sales_db.public.deepak_truncate_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*';

-- Deepak's observation: ERROR!
-- "String 'Electronics' is too long and would be truncated"
-- Default behavior is to fail on oversized values


-- ========================================
-- TEST 2: WITH TRUNCATECOLUMNS = TRUE
-- ========================================

-- Deepak's scenario: Allow truncation to prevent errors
COPY INTO deepak_sales_db.public.orders_truncate_test
    FROM @deepak_sales_db.public.deepak_truncate_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    TRUNCATECOLUMNS = TRUE;

-- Deepak's learning: Load succeeded!
-- Values longer than 10 chars were truncated

-- Verify results
SELECT * FROM deepak_sales_db.public.orders_truncate_test;

-- Deepak's observation: Category values are truncated
-- "Electronics" became "Electronic" (10 chars)
-- "Furniture" stayed "Furniture" (9 chars - fits)


/*
DEEPAK'S TRUNCATECOLUMNS INSIGHTS:
==================================

What is TRUNCATECOLUMNS?
- COPY option to handle oversized values
- Truncates strings to fit column width
- Prevents errors from long values
- Default: FALSE (error on oversized)
- Set to TRUE to allow truncation

Behavior:

Default (TRUNCATECOLUMNS = FALSE):
❌ Error if value exceeds column width
❌ Load fails
❌ No data loaded
✅ Data integrity preserved

With TRUNCATECOLUMNS = TRUE:
✅ Load succeeds
✅ Oversized values truncated
⚠️  Data loss occurs
⚠️  Silent truncation (no warning)

Example:
Column: VARCHAR(10)
Value: "Electronics"
Result: "Electronic" (truncated to 10 chars)

When to Use:
✅ Known data quality issues
✅ Non-critical columns
✅ Legacy data migration
✅ Quick fixes for testing
✅ When truncation is acceptable

When NOT to Use:
❌ Critical business data
❌ IDs or keys
❌ Financial amounts
❌ When data accuracy matters
❌ Production loads (usually)

Best Practices:
1. Prefer fixing source data
2. Or increase column width
3. Use TRUNCATECOLUMNS as last resort
4. Document when used
5. Monitor truncated values
6. Consider data quality impact
7. Test before production

Better Alternatives:

1. Fix Column Width:
ALTER TABLE orders_truncate_test
MODIFY COLUMN category VARCHAR(50);

2. Fix Source Data:
-- Clean data before loading

3. Use Validation:
COPY INTO table
    FROM @stage
    VALIDATION_MODE = RETURN_ERRORS;
-- Then fix issues

4. Transform During Load:
COPY INTO table
FROM (
    SELECT
        s.$1,
        SUBSTRING(s.$5, 1, 10) AS category
    FROM @stage s
);

Comparison:
┌──────────────────────┬─────────────┬──────────────┐
│ Approach             │ Data Loss   │ Recommended  │
├──────────────────────┼─────────────┼──────────────┤
│ Increase column size │ No          │ ✅ Best      │
│ Fix source data      │ No          │ ✅ Best      │
│ TRUNCATECOLUMNS      │ Yes         │ ⚠️  Caution  │
│ Error and skip       │ Entire row  │ ❌ Worst     │
└──────────────────────┴─────────────┴──────────────┘

Real-World Example:

-- Scenario: Loading customer comments
-- Column: comment VARCHAR(100)
-- Data: Some comments exceed 100 chars

-- Option 1: Truncate (quick fix)
COPY INTO customer_feedback
    FROM @feedback_stage
    FILE_FORMAT = (FORMAT_NAME = csv_format)
    TRUNCATECOLUMNS = TRUE;

-- Option 2: Increase column (better)
ALTER TABLE customer_feedback
MODIFY COLUMN comment VARCHAR(500);

COPY INTO customer_feedback
    FROM @feedback_stage
    FILE_FORMAT = (FORMAT_NAME = csv_format);

-- Option 3: Transform (controlled)
COPY INTO customer_feedback
FROM (
    SELECT
        s.$1,
        CASE
            WHEN LENGTH(s.$2) > 100
            THEN SUBSTRING(s.$2, 1, 97) || '...'
            ELSE s.$2
        END AS comment
    FROM @feedback_stage s
);

Monitoring Truncation:

-- Check for potential truncation issues
SELECT
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'ORDERS_TRUNCATE_TEST'
AND character_maximum_length IS NOT NULL;

-- Validate data before loading
COPY INTO orders_truncate_test
    FROM @deepak_truncate_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    VALIDATION_MODE = RETURN_ERRORS;

Common Scenarios:

1. Legacy Data Migration:
-- Old system had no length limits
-- New system has VARCHAR(50)
-- Use TRUNCATECOLUMNS temporarily

2. Third-Party Data:
-- External data source
-- Inconsistent lengths
-- Quick load for analysis

3. Testing/Development:
-- Prototype with small columns
-- Use TRUNCATECOLUMNS for testing
-- Fix properly for production

Security Considerations:
⚠️  Truncated data may lose meaning
⚠️  Could affect compliance (GDPR, etc.)
⚠️  Audit trails may be incomplete
⚠️  Financial data should NEVER be truncated

Decision Tree:
┌─────────────────────────────┐
│ Value exceeds column width? │
└──────────┬──────────────────┘
           │
           ├─ Critical data? ──> Increase column width
           │
           ├─ Can fix source? ──> Fix source data
           │
           ├─ One-time load? ──> Consider TRUNCATECOLUMNS
           │
           └─ Production? ──> DO NOT use TRUNCATECOLUMNS

Combining with Other Options:
COPY INTO table
    FROM @stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',')
    TRUNCATECOLUMNS = TRUE
    ON_ERROR = 'CONTINUE'
    VALIDATION_MODE = RETURN_ERRORS;  -- Test first!

Alternative: Use TRY_CAST
-- Instead of truncating, handle in transform
COPY INTO table
FROM (
    SELECT
        s.$1,
        TRY_CAST(s.$2 AS VARCHAR(10)) AS category
    FROM @stage s
);

Summary:
✅ TRUNCATECOLUMNS prevents errors from oversized values
⚠️  Causes silent data loss
⚠️  Use only when acceptable
✅ Better to fix column width or source data
✅ Document usage and rationale
✅ Monitor for data quality impact

Deepak's Recommendation:
1. First choice: Increase column width
2. Second choice: Fix source data
3. Third choice: Transform during load
4. Last resort: TRUNCATECOLUMNS (with documentation)

Practiced: February 2026
Status: ✅ Completed - Understanding truncation trade-offs
*/