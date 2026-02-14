/*
===========================================
DEEPAK'S RETURN_FAILED_ONLY PRACTICE
===========================================
Topic: Focusing on Failed Records Only
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- RETURN_FAILED_ONLY shows only error records
- Default: FALSE (shows all records)
- TRUE: Returns only failed records
- Useful for troubleshooting specific errors
- Combines well with ON_ERROR = CONTINUE
===========================================
*/

-- Deepak's Note: RETURN_FAILED_ONLY filters output to show only errors
-- Perfect for focusing on what went wrong!


-- ========================================
-- SETUP: CREATE TABLE
-- ========================================

-- Deepak's scenario: Orders table for testing failed records
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_failed_test (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Table for testing RETURN_FAILED_ONLY';


-- ========================================
-- CREATE STAGE WITH ERROR FILES
-- ========================================

-- Deepak's scenario: Stage with files containing errors
CREATE OR REPLACE STAGE deepak_sales_db.public.deepak_failed_stage
    URL = 's3://deepak-snowflake-data/failed-records/'
    COMMENT = 'Deepak - Stage with mixed good and bad records';

LIST @deepak_sales_db.public.deepak_failed_stage;

-- Deepak's observation: Files have mix of valid and invalid records


-- ========================================
-- TEST 1: RETURN_FAILED_ONLY = TRUE (ALONE)
-- ========================================

-- Deepak's experiment: Use RETURN_FAILED_ONLY without ON_ERROR
COPY INTO deepak_sales_db.public.orders_failed_test
    FROM @deepak_sales_db.public.deepak_failed_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    RETURN_FAILED_ONLY = TRUE;

-- Deepak's observation: Load FAILS on first error (default ON_ERROR = ABORT_STATEMENT)
-- But output shows only the failed record
-- Not very useful alone - load still aborts


-- ========================================
-- TEST 2: RETURN_FAILED_ONLY WITH ON_ERROR
-- ========================================

-- Deepak's scenario: Combine with ON_ERROR = CONTINUE
COPY INTO deepak_sales_db.public.orders_failed_test
    FROM @deepak_sales_db.public.deepak_failed_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    ON_ERROR = CONTINUE
    RETURN_FAILED_ONLY = TRUE;

-- Deepak's learning: Load succeeds! Good records loaded
-- Output shows ONLY failed records (not successful ones)
-- Perfect for troubleshooting!

-- Deepak's observation: Output shows:
-- - File name
-- - Row number
-- - Error message
-- - Rejected record
-- Only for FAILED records


-- ========================================
-- TEST 3: DEFAULT BEHAVIOR (FALSE)
-- ========================================

-- Deepak's scenario: Compare with default behavior
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_failed_test (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Reset table for comparison';


-- Deepak's experiment: Load without RETURN_FAILED_ONLY
COPY INTO deepak_sales_db.public.orders_failed_test
    FROM @deepak_sales_db.public.deepak_failed_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    ON_ERROR = CONTINUE;

-- Deepak's observation: Load succeeds
-- Output shows ALL records (both successful and failed)
-- More verbose output


/*
DEEPAK'S RETURN_FAILED_ONLY INSIGHTS:
======================================

What is RETURN_FAILED_ONLY?
- COPY option to filter output
- Shows only failed records
- Default: FALSE (shows all records)
- Set to TRUE to see only errors

Behavior Comparison:

RETURN_FAILED_ONLY = FALSE (Default):
✅ Shows all records processed
✅ Shows successful loads
✅ Shows failed loads
✅ More verbose output
✅ Good for: Complete audit trail

RETURN_FAILED_ONLY = TRUE:
✅ Shows only failed records
✅ Hides successful loads
✅ Focused error output
✅ Less verbose
✅ Good for: Troubleshooting

Output Comparison:

With RETURN_FAILED_ONLY = FALSE:
┌──────────────┬────────┬──────────────┐
│ File         │ Status │ Rows         │
├──────────────┼────────┼──────────────┤
│ orders1.csv  │ ✅ OK  │ 1000 loaded  │
│ orders2.csv  │ ❌ ERR │ 5 failed     │
│ orders3.csv  │ ✅ OK  │ 2000 loaded  │
└──────────────┴────────┴──────────────┘

With RETURN_FAILED_ONLY = TRUE:
┌──────────────┬────────┬──────────────┐
│ File         │ Status │ Rows         │
├──────────────┼────────┼──────────────┤
│ orders2.csv  │ ❌ ERR │ 5 failed     │
└──────────────┴────────┴──────────────┘

When to Use RETURN_FAILED_ONLY = TRUE:
✅ Troubleshooting specific errors
✅ Large files with few errors
✅ Focus on what went wrong
✅ Reduce output verbosity
✅ Error analysis only

When to Use RETURN_FAILED_ONLY = FALSE:
✅ Complete audit trail needed
✅ Track successful loads
✅ Compliance/logging requirements
✅ Full load statistics
✅ Default behavior

Combining with Other Options:

Best Practice Combination:
COPY INTO table
    FROM @stage
    FILE_FORMAT = (...)
    ON_ERROR = CONTINUE          -- Allow partial load
    RETURN_FAILED_ONLY = TRUE;   -- Show only errors

Why this works:
1. ON_ERROR = CONTINUE allows load to proceed
2. Good records get loaded
3. Bad records are skipped
4. Output shows only bad records
5. Easy to focus on fixing errors

Alternative Combinations:

1. Validation Mode:
COPY INTO table
    FROM @stage
    VALIDATION_MODE = RETURN_ERRORS  -- Already returns only errors
    RETURN_FAILED_ONLY = TRUE;       -- Redundant

2. Abort on Error:
COPY INTO table
    FROM @stage
    ON_ERROR = ABORT_STATEMENT       -- Stops on first error
    RETURN_FAILED_ONLY = TRUE;       -- Shows that one error

3. Skip File:
COPY INTO table
    FROM @stage
    ON_ERROR = SKIP_FILE             -- Skip entire file on error
    RETURN_FAILED_ONLY = TRUE;       -- Shows errors from skipped files

Real-World Use Cases:

1. Daily Load with Error Focus:
-- Load daily files, focus on errors
COPY INTO daily_orders
    FROM @daily_stage
    FILE_FORMAT = (FORMAT_NAME = csv_format)
    PATTERN = '.*2026-02-14.*'
    ON_ERROR = CONTINUE
    RETURN_FAILED_ONLY = TRUE;

-- Output shows only errors
-- Good records loaded silently

2. Large File Troubleshooting:
-- Loading 1M row file with ~100 errors
-- Don't want to see 999,900 success messages
COPY INTO large_table
    FROM @stage
    FILES = ('huge_file.csv')
    ON_ERROR = CONTINUE
    RETURN_FAILED_ONLY = TRUE;

-- Output: Only 100 error records
-- Much easier to review!

3. Error Reporting:
-- Capture only errors for reporting
COPY INTO orders
    FROM @stage
    ON_ERROR = CONTINUE
    RETURN_FAILED_ONLY = TRUE;

-- Save errors to table
CREATE TABLE load_errors AS
SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

Analyzing Output:

-- With RETURN_FAILED_ONLY = TRUE, output includes:
-- - file: Source file name
-- - row_number: Line in file
-- - error: Error message
-- - rejected_record: The bad record

-- Save and analyze
CREATE TABLE error_analysis AS
SELECT
    file,
    COUNT(*) AS error_count,
    COUNT(DISTINCT error) AS unique_errors
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
GROUP BY file;

Comparison Table:
┌─────────────────────┬──────────┬─────────┐
│ Aspect              │ FALSE    │ TRUE    │
├─────────────────────┼──────────┼─────────┤
│ Shows success       │ Yes      │ No      │
│ Shows failures      │ Yes      │ Yes     │
│ Output volume       │ High     │ Low     │
│ Use case            │ Audit    │ Debug   │
│ Default             │ Yes      │ No      │
└─────────────────────┴──────────┴─────────┘

Best Practices:
1. Use TRUE for troubleshooting
2. Use FALSE for audit trails
3. Combine with ON_ERROR = CONTINUE
4. Save error output to table
5. Analyze error patterns
6. Document error handling strategy

Production Pattern:

-- Step 1: Load with error focus
COPY INTO production_table
    FROM @production_stage
    FILE_FORMAT = (FORMAT_NAME = prod_csv)
    ON_ERROR = CONTINUE
    RETURN_FAILED_ONLY = TRUE;

-- Step 2: Check if errors occurred
SET error_count = (
    SELECT COUNT(*)
    FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
);

-- Step 3: Alert if errors found
IF (error_count > 0) THEN
    -- Save errors
    CREATE TABLE IF NOT EXISTS error_log (...);
    INSERT INTO error_log
    SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

    -- Send alert
    -- Notify team
END IF;

Monitoring Query:

-- After load with RETURN_FAILED_ONLY = TRUE
SELECT
    file,
    error,
    COUNT(*) AS occurrences
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
GROUP BY file, error
ORDER BY occurrences DESC;

Complete Example:

-- Scenario: Daily ETL with error tracking

-- 1. Load data
COPY INTO deepak_sales_db.public.daily_orders
    FROM @deepak_sales_db.public.daily_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*orders_2026_02_14.*'
    ON_ERROR = CONTINUE
    RETURN_FAILED_ONLY = TRUE;

-- 2. Capture errors (if any)
CREATE TABLE IF NOT EXISTS deepak_sales_db.public.daily_errors (
    load_date DATE,
    file VARCHAR,
    row_number NUMBER,
    error VARCHAR,
    rejected_record VARCHAR,
    captured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO deepak_sales_db.public.daily_errors
    (load_date, file, row_number, error, rejected_record)
SELECT
    CURRENT_DATE(),
    file,
    row_number,
    error,
    rejected_record
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- 3. Check error count
SELECT COUNT(*) AS errors_today
FROM deepak_sales_db.public.daily_errors
WHERE load_date = CURRENT_DATE();

-- 4. Analyze error types
SELECT
    error,
    COUNT(*) AS count
FROM deepak_sales_db.public.daily_errors
WHERE load_date = CURRENT_DATE()
GROUP BY error
ORDER BY count DESC;

Deepak's Recommendations:
✅ Use RETURN_FAILED_ONLY = TRUE for troubleshooting
✅ Combine with ON_ERROR = CONTINUE
✅ Save error output for analysis
✅ Monitor error trends
✅ Use FALSE for complete audit trails
✅ Document your choice in code comments

Key Takeaway:
RETURN_FAILED_ONLY = TRUE is like a filter that shows
only what went wrong. Perfect for troubleshooting, but
remember to use FALSE when you need complete load history!

Practiced: February 2026
Status: ✅ Completed - Understanding error output filtering
*/