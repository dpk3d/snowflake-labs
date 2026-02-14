/*
===========================================
DEEPAK'S VALIDATION_MODE PRACTICE
===========================================
Topic: Testing Data Loads Before Execution
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- VALIDATION_MODE tests COPY without loading data
- RETURN_ERRORS shows all error records
- RETURN_N_ROWS validates first N rows
- No data loaded in validation mode
- Perfect for testing before production loads
===========================================
*/

-- Deepak's Note: VALIDATION_MODE is like a "dry run" for COPY commands
-- Test your data quality before committing to the load!


-- ========================================
-- SETUP: CREATE DATABASE AND TABLE
-- ========================================

CREATE OR REPLACE DATABASE deepak_validation_db
COMMENT = 'Deepak - Database for testing validation mode';

USE DATABASE deepak_validation_db;


CREATE OR REPLACE TABLE deepak_validation_db.public.orders_validate (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Table for validation testing';


-- ========================================
-- CREATE STAGE WITH TEST FILES
-- ========================================

-- Deepak's scenario: Stage with mixed quality files
CREATE OR REPLACE STAGE deepak_validation_db.public.deepak_validation_stage
    URL = 's3://deepak-snowflake-data/validation-test/'
    COMMENT = 'Deepak - Stage for validation mode testing';

-- List files
LIST @deepak_validation_db.public.deepak_validation_stage;

-- Deepak's observation: Multiple files with varying data quality


-- ========================================
-- TEST 1: VALIDATION_MODE = RETURN_ERRORS
-- ========================================

-- Deepak's experiment: Validate data without loading
COPY INTO deepak_validation_db.public.orders_validate
    FROM @deepak_validation_db.public.deepak_validation_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;

-- Deepak's learning: Returns ALL error records without loading data
-- Shows exactly which records would fail

-- Verify table is still empty
SELECT * FROM deepak_validation_db.public.orders_validate;
-- Deepak's observation: No data loaded! ✅


-- ========================================
-- TEST 2: VALIDATION_MODE = RETURN_N_ROWS
-- ========================================

-- Deepak's scenario: Validate first 5 rows only
COPY INTO deepak_validation_db.public.orders_validate
    FROM @deepak_validation_db.public.deepak_validation_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    VALIDATION_MODE = RETURN_5_ROWS;

-- Deepak's learning: Returns first 5 rows that would be loaded
-- Quick sanity check without full validation

-- Table still empty
SELECT COUNT(*) FROM deepak_validation_db.public.orders_validate;


-- ========================================
-- TEST 3: VALIDATE FILES WITH ERRORS
-- ========================================

-- Deepak's scenario: Point to files known to have errors
CREATE OR REPLACE STAGE deepak_validation_db.public.deepak_error_stage
    URL = 's3://deepak-snowflake-data/error-files/'
    COMMENT = 'Deepak - Stage with known error files';

LIST @deepak_validation_db.public.deepak_error_stage;


-- Show all errors in files
COPY INTO deepak_validation_db.public.orders_validate
    FROM @deepak_validation_db.public.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;

-- Deepak's observation: Detailed error report showing:
-- - File name
-- - Row number
-- - Column name
-- - Error message
-- - Rejected record


-- ========================================
-- TEST 4: VALIDATE SPECIFIC ERROR FILE
-- ========================================

-- Deepak's scenario: Validate just first row of error file
COPY INTO deepak_validation_db.public.orders_validate
    FROM @deepak_validation_db.public.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*error.*'
    VALIDATION_MODE = RETURN_1_ROWS;

-- Deepak's learning: Quick check of first row
-- Useful for large files


/*
DEEPAK'S VALIDATION_MODE INSIGHTS:
==================================

What is VALIDATION_MODE?
- Dry-run mode for COPY commands
- Tests data without loading
- Identifies errors before commit
- No warehouse credits for actual load
- Returns validation results

VALIDATION_MODE Options:

1. RETURN_ERRORS:
   - Shows ALL error records
   - Complete error report
   - File name, row, column, error message
   - Use when: Need full error analysis

2. RETURN_N_ROWS:
   - Returns first N rows that would load
   - Examples: RETURN_1_ROWS, RETURN_10_ROWS
   - Quick sanity check
   - Use when: Verify data format/structure

3. RETURN_ALL_ERRORS:
   - Same as RETURN_ERRORS
   - Shows every error in dataset

Validation Results Include:
✅ File name
✅ Row number
✅ Column name
✅ Error message
✅ Rejected record (full row)
✅ Error category
✅ Line number in file

Benefits:
✅ Test before loading (no data committed)
✅ Identify all errors upfront
✅ No cleanup needed (table unchanged)
✅ Fast feedback on data quality
✅ Save warehouse credits
✅ Plan error handling strategy

Typical Workflow:
1. VALIDATION_MODE = RETURN_ERRORS (find all issues)
2. Fix source data or adjust table schema
3. VALIDATION_MODE = RETURN_10_ROWS (verify fix)
4. Run actual COPY command
5. Monitor load results

Example Validation Output:
┌──────────────┬─────────┬────────────┬──────────────────┐
│ File         │ Row     │ Column     │ Error            │
├──────────────┼─────────┼────────────┼──────────────────┤
│ orders.csv   │ 42      │ AMOUNT     │ Invalid number   │
│ orders.csv   │ 103     │ QUANTITY   │ NULL not allowed │
│ orders2.csv  │ 15      │ DATE       │ Invalid date     │
└──────────────┴─────────┴────────────┴──────────────────┘

Common Error Types:
❌ Data type mismatch
❌ NULL in NOT NULL column
❌ Value too long for column
❌ Invalid date/time format
❌ Number format errors
❌ Column count mismatch
❌ Character encoding issues

Best Practices:
1. Always validate before first production load
2. Use RETURN_ERRORS for new data sources
3. Use RETURN_N_ROWS for quick checks
4. Save validation results for analysis
5. Fix errors at source when possible
6. Document validation findings
7. Automate validation in pipelines

Combining with Other Options:
-- Validate with pattern matching
COPY INTO table
    FROM @stage
    FILE_FORMAT = (...)
    PATTERN = '.*2026.*\\.csv'
    VALIDATION_MODE = RETURN_ERRORS;

-- Validate specific files
COPY INTO table
    FROM @stage
    FILE_FORMAT = (...)
    FILES = ('file1.csv', 'file2.csv')
    VALIDATION_MODE = RETURN_10_ROWS;

Saving Validation Results:
-- Create table from validation results
CREATE TABLE validation_errors AS
SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- Analyze error patterns
SELECT
    error_message,
    COUNT(*) AS error_count
FROM validation_errors
GROUP BY error_message
ORDER BY error_count DESC;

Production Pipeline Example:
-- Step 1: Validate
COPY INTO staging_table
    FROM @daily_stage
    FILE_FORMAT = (FORMAT_NAME = csv_format)
    VALIDATION_MODE = RETURN_ERRORS;

-- Step 2: Check if errors exist
SET error_count = (
    SELECT COUNT(*)
    FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
);

-- Step 3: Decide action
IF (error_count > 0) THEN
    -- Alert team, investigate errors
    -- Don't proceed with load
ELSE
    -- Proceed with actual load
    COPY INTO staging_table
        FROM @daily_stage
        FILE_FORMAT = (FORMAT_NAME = csv_format)
        ON_ERROR = 'ABORT_STATEMENT';
END IF;

Validation vs Actual Load:
┌──────────────────────┬────────────┬──────────────┐
│ Aspect               │ Validation │ Actual Load  │
├──────────────────────┼────────────┼──────────────┤
│ Data loaded          │ No         │ Yes          │
│ Errors shown         │ Yes        │ Depends      │
│ Table modified       │ No         │ Yes          │
│ Warehouse usage      │ Yes        │ Yes          │
│ Load history         │ No         │ Yes          │
└──────────────────────┴────────────┴──────────────┘

Troubleshooting Tips:
1. Start with RETURN_1_ROWS for quick test
2. Use RETURN_ERRORS for full analysis
3. Check file encoding if strange errors
4. Verify column count matches table
5. Test with small file first
6. Check date/time formats
7. Validate NULL handling

Real-World Use Case:
-- Daily ETL validation
-- 1. Validate new files
COPY INTO daily_sales
    FROM @daily_stage
    FILE_FORMAT = (FORMAT_NAME = sales_csv)
    PATTERN = '.*sales_2026.*'
    VALIDATION_MODE = RETURN_ERRORS;

-- 2. If no errors, proceed
COPY INTO daily_sales
    FROM @daily_stage
    FILE_FORMAT = (FORMAT_NAME = sales_csv)
    PATTERN = '.*sales_2026.*'
    ON_ERROR = 'ABORT_STATEMENT';

Practiced: February 2026
Status: ✅ Completed - Mastering validation before loading
*/
    
    