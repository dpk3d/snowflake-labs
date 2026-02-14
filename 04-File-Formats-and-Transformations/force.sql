/*
===========================================
DEEPAK'S FORCE OPTION PRACTICE
===========================================
Topic: Reloading Files with FORCE
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Snowflake tracks loaded files to prevent duplicates
- Cannot reload same file unless data changed
- FORCE = TRUE bypasses this protection
- Use carefully - can create duplicate data
- Useful for testing and specific scenarios
===========================================
*/

-- Deepak's Note: FORCE option allows reloading files that were already loaded
-- Be careful - this can create duplicate records!


-- ========================================
-- SETUP: CREATE TABLE
-- ========================================

-- Deepak's scenario: Orders table for testing FORCE option
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_force_test (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Table for testing FORCE option';


-- ========================================
-- CREATE STAGE
-- ========================================

-- Deepak's scenario: Stage with order files
CREATE OR REPLACE STAGE deepak_sales_db.public.deepak_force_stage
    URL = 's3://deepak-snowflake-data/force-test/'
    COMMENT = 'Deepak - Stage for FORCE option testing';

-- List files in stage
LIST @deepak_sales_db.public.deepak_force_stage;

-- Deepak's observation: Multiple order files available


-- ========================================
-- TEST 1: INITIAL LOAD (NORMAL)
-- ========================================

-- Deepak's experiment: Load files normally (first time)
COPY INTO deepak_sales_db.public.orders_force_test
    FROM @deepak_sales_db.public.deepak_force_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*';

-- Deepak's learning: Load succeeded! Files loaded for first time

-- Check loaded data
SELECT * FROM deepak_sales_db.public.orders_force_test;

-- Deepak's observation: Data loaded successfully


-- ========================================
-- TEST 2: ATTEMPT RELOAD (WITHOUT FORCE)
-- ========================================

-- Deepak's scenario: Try to load same files again
COPY INTO deepak_sales_db.public.orders_force_test
    FROM @deepak_sales_db.public.deepak_force_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*';

-- Deepak's observation: No error, but NO NEW DATA loaded!
-- Snowflake says: "File already loaded, skipping"
-- This prevents accidental duplicates

-- Verify row count unchanged
SELECT COUNT(*) AS row_count FROM deepak_sales_db.public.orders_force_test;

-- Deepak's learning: Snowflake tracks loaded files and skips them


-- ========================================
-- TEST 3: RELOAD WITH FORCE = TRUE
-- ========================================

-- Deepak's scenario: Force reload of same files
COPY INTO deepak_sales_db.public.orders_force_test
    FROM @deepak_sales_db.public.deepak_force_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    FORCE = TRUE;

-- Deepak's learning: Load succeeded! Files reloaded
-- ⚠️ WARNING: This creates DUPLICATE records!

-- Check row count - should be DOUBLED
SELECT COUNT(*) AS row_count FROM deepak_sales_db.public.orders_force_test;

-- Deepak's observation: Row count doubled! Duplicates created

-- Verify duplicates exist
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM deepak_sales_db.public.orders_force_test
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- Deepak's note: Every record appears twice now!


/*
DEEPAK'S FORCE OPTION INSIGHTS:
================================

What is FORCE?
- COPY option to reload already-loaded files
- Bypasses Snowflake's duplicate prevention
- Default: FALSE (prevents duplicates)
- Set to TRUE to allow reloading

How Snowflake Tracks Files:
✅ Stores file name
✅ Stores file size
✅ Stores last modified timestamp
✅ Stores checksum/hash
✅ Prevents reloading unchanged files

Default Behavior (FORCE = FALSE):
✅ Prevents duplicate loads
✅ Skips already-loaded files
✅ Safe for production
✅ Idempotent operations
✅ No accidental duplicates

With FORCE = TRUE:
⚠️  Reloads files regardless of history
⚠️  Creates duplicate records
⚠️  Bypasses safety checks
⚠️  Use with extreme caution
⚠️  Can cause data quality issues

When to Use FORCE:
✅ Testing/development
✅ File content changed but metadata didn't
✅ Recovering from failed loads
✅ Intentional reprocessing
✅ After TRUNCATE table
✅ Backfilling historical data

When NOT to Use FORCE:
❌ Production loads (usually)
❌ When duplicates are unacceptable
❌ Automated pipelines
❌ Without duplicate handling
❌ Financial/critical data

File Tracking Example:
┌──────────────────┬──────────┬─────────────┬──────────┐
│ File Name        │ Size     │ Modified    │ Loaded?  │
├──────────────────┼──────────┼─────────────┼──────────┤
│ orders_jan.csv   │ 1.2 MB   │ 2026-01-15  │ ✅ Yes   │
│ orders_feb.csv   │ 1.5 MB   │ 2026-02-14  │ ✅ Yes   │
│ orders_mar.csv   │ 1.3 MB   │ 2026-03-01  │ ❌ No    │
└──────────────────┴──────────┴─────────────┴──────────┘

Without FORCE:
- orders_jan.csv → Skipped (already loaded)
- orders_feb.csv → Skipped (already loaded)
- orders_mar.csv → Loaded (new file)

With FORCE = TRUE:
- orders_jan.csv → Loaded again (duplicates!)
- orders_feb.csv → Loaded again (duplicates!)
- orders_mar.csv → Loaded (new file)

Checking Load History:
-- See what files were loaded
SELECT
    file_name,
    file_size,
    row_count,
    first_error_message,
    last_load_time
FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'deepak_sales_db.public.orders_force_test',
        START_TIME => DATEADD(DAY, -7, CURRENT_TIMESTAMP())
    )
)
ORDER BY last_load_time DESC;

Preventing Duplicates with FORCE:

Method 1: TRUNCATE before reload
TRUNCATE TABLE deepak_sales_db.public.orders_force_test;
COPY INTO deepak_sales_db.public.orders_force_test
    FROM @stage
    FORCE = TRUE;

Method 2: Use staging table
CREATE OR REPLACE TABLE staging_orders AS
SELECT * FROM orders_force_test WHERE 1=0;

COPY INTO staging_orders FROM @stage FORCE = TRUE;

-- Deduplicate before merging
MERGE INTO orders_force_test t
USING (SELECT DISTINCT * FROM staging_orders) s
ON t.order_id = s.order_id
WHEN NOT MATCHED THEN INSERT VALUES (...);

Method 3: Use MERGE instead of COPY
-- Load to temp table, then MERGE
COPY INTO temp_orders FROM @stage FORCE = TRUE;

MERGE INTO orders_force_test t
USING temp_orders s
ON t.order_id = s.order_id
WHEN MATCHED THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT ...;

Real-World Use Cases:

1. File Content Changed:
-- File modified but timestamp/size same
-- Snowflake won't detect change
-- Use FORCE to reload

2. Recovery Scenario:
-- Load failed midway
-- Table was truncated
-- Use FORCE to reload all files

3. Testing:
-- Load test data
-- Truncate and reload
-- Use FORCE for quick iterations

4. Backfill:
-- Need to reprocess historical files
-- Use FORCE with proper deduplication

Best Practices:
1. Avoid FORCE in production
2. If using FORCE, handle duplicates
3. Document why FORCE is needed
4. Use staging tables
5. Implement deduplication logic
6. Monitor for duplicate records
7. Test thoroughly before production

Safer Alternatives:

Instead of FORCE, consider:
1. TRUNCATE table first
2. Use different table
3. Fix file metadata
4. Use MERGE pattern
5. Implement upsert logic

Deduplication Query:
-- Remove duplicates after FORCE load
CREATE OR REPLACE TABLE orders_deduped AS
SELECT DISTINCT *
FROM deepak_sales_db.public.orders_force_test;

-- Or with ROW_NUMBER
CREATE OR REPLACE TABLE orders_deduped AS
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY order_id
        ) AS rn
    FROM deepak_sales_db.public.orders_force_test
)
WHERE rn = 1;

Monitoring for Duplicates:
-- Check for duplicate records
SELECT
    order_id,
    COUNT(*) AS occurrences
FROM deepak_sales_db.public.orders_force_test
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Count total duplicates
SELECT
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_count
FROM deepak_sales_db.public.orders_force_test;

Production Pattern (Safe):
-- 1. Load to staging
CREATE OR REPLACE TABLE staging_orders LIKE orders_force_test;

COPY INTO staging_orders
    FROM @stage
    FORCE = TRUE;  -- OK in staging

-- 2. Deduplicate
CREATE OR REPLACE TABLE staging_orders_clean AS
SELECT DISTINCT * FROM staging_orders;

-- 3. Merge to production
MERGE INTO orders_force_test t
USING staging_orders_clean s
ON t.order_id = s.order_id
WHEN NOT MATCHED THEN INSERT VALUES (...);

-- 4. Clean up
DROP TABLE staging_orders;
DROP TABLE staging_orders_clean;

Comparison:
┌─────────────────┬──────────────┬─────────────────┐
│ Aspect          │ FORCE=FALSE  │ FORCE=TRUE      │
├─────────────────┼──────────────┼─────────────────┤
│ Duplicates      │ Prevented    │ Allowed         │
│ Safety          │ High         │ Low             │
│ Use case        │ Production   │ Testing/Special │
│ File tracking   │ Enforced     │ Bypassed        │
│ Idempotent      │ Yes          │ No              │
└─────────────────┴──────────────┴─────────────────┘

Deepak's Recommendation:
❌ Don't use FORCE in production pipelines
✅ Use FORCE only for testing/development
✅ If FORCE needed, implement deduplication
✅ Document the reason for using FORCE
✅ Consider safer alternatives first
✅ Monitor for duplicate records

Key Takeaway:
FORCE is powerful but dangerous. Like a "safety off" switch,
it should be used rarely and with full understanding of the
consequences. Always prefer safer alternatives when possible.

Practiced: February 2026
Status: ✅ Completed - Understanding FORCE and its risks
*/
    
