/*
===========================================
DEEPAK'S REJECTED RECORDS PRACTICE
===========================================
Topic: Capturing and Analyzing Failed Records
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Can save rejected records for analysis
- Use RESULT_SCAN to capture validation errors
- VALIDATE function shows errors from actual loads
- Parse rejected records with SPLIT_PART
- Critical for data quality troubleshooting
===========================================
*/

-- Deepak's Note: Don't just skip errors - capture and analyze them!
-- Rejected records contain valuable data quality insights


-- ========================================
-- SETUP: CREATE STAGE WITH ERROR FILES
-- ========================================

-- Deepak's scenario: Stage with files containing errors
CREATE OR REPLACE STAGE deepak_sales_db.public.deepak_error_stage
    URL = 's3://deepak-snowflake-data/error-files/'
    COMMENT = 'Deepak - Stage with files containing data errors';

LIST @deepak_sales_db.public.deepak_error_stage;

-- Deepak's observation: Files have various data quality issues


-- ========================================
-- INITIAL VALIDATION TESTS
-- ========================================

-- Deepak's experiment: Validate to see all errors
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_sales_db.public.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;

-- Deepak's learning: Shows all error records without loading


-- Deepak's scenario: Validate just first row
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_sales_db.public.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    VALIDATION_MODE = RETURN_1_ROWS;

-- Deepak's observation: Quick check of data structure


-- ========================================
-- METHOD 1: SAVE REJECTED RECORDS (VALIDATION_MODE)
-- ========================================

-- Deepak's scenario: Create table to store rejected records
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_error_test (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Orders table for error testing';


-- Deepak's experiment: Run validation to get errors
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_sales_db.public.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;

-- Deepak's learning: Validation returns error details


-- Deepak's key technique: Save rejected records to table
CREATE OR REPLACE TABLE deepak_sales_db.public.rejected_records AS
SELECT
    rejected_record,
    error,
    file,
    line,
    character,
    byte_offset,
    category AS error_category,
    code AS error_code
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- Deepak's observation: Captured all rejected records for analysis!

SELECT * FROM deepak_sales_db.public.rejected_records;


-- Deepak's scenario: Add more rejected records from another validation
-- (Run another validation first)
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_sales_db.public.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;

-- Append to existing rejected records table
INSERT INTO deepak_sales_db.public.rejected_records
SELECT
    rejected_record,
    error,
    file,
    line,
    character,
    byte_offset,
    category,
    code
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

SELECT * FROM deepak_sales_db.public.rejected_records;


-- ========================================
-- METHOD 2: SAVE REJECTED RECORDS (ACTUAL LOAD)
-- ========================================

-- Deepak's scenario: Load with ON_ERROR=CONTINUE (allows partial load)
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_sales_db.public.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    ON_ERROR = CONTINUE;

-- Deepak's learning: Good records loaded, bad records skipped


-- Deepak's technique: Use VALIDATE function to see what failed
SELECT * FROM TABLE(
    VALIDATE(deepak_sales_db.public.orders_error_test, JOB_ID => '_last')
);

-- Deepak's observation: Shows errors from the actual load (not validation)


-- ========================================
-- METHOD 3: PARSE REJECTED RECORDS
-- ========================================

-- Deepak's scenario: Extract individual fields from rejected records
SELECT REJECTED_RECORD FROM deepak_sales_db.public.rejected_records;

-- Deepak's observation: Rejected records are stored as single strings


-- Deepak's key technique: Parse CSV string into columns
CREATE OR REPLACE TABLE deepak_sales_db.public.rejected_records_parsed AS
SELECT
    SPLIT_PART(rejected_record, ',', 1) AS order_id,
    SPLIT_PART(rejected_record, ',', 2) AS amount,
    SPLIT_PART(rejected_record, ',', 3) AS profit,
    SPLIT_PART(rejected_record, ',', 4) AS quantity,
    SPLIT_PART(rejected_record, ',', 5) AS category,
    SPLIT_PART(rejected_record, ',', 6) AS subcategory,
    error AS error_message,
    file AS source_file,
    line AS line_number
FROM deepak_sales_db.public.rejected_records;

-- Deepak's learning: Now can analyze rejected data by column!

SELECT * FROM deepak_sales_db.public.rejected_records_parsed;


/*
DEEPAK'S REJECTED RECORDS INSIGHTS:
====================================

Why Capture Rejected Records?
✅ Understand data quality issues
✅ Identify patterns in errors
✅ Fix source data problems
✅ Report to data providers
✅ Track error trends over time
✅ Improve data pipelines

Three Methods to Capture Errors:

1. VALIDATION_MODE + RESULT_SCAN:
   - Run VALIDATION_MODE = RETURN_ERRORS
   - Capture results with RESULT_SCAN(LAST_QUERY_ID())
   - No data loaded (dry run)
   - Best for: Pre-load validation

2. ON_ERROR=CONTINUE + VALIDATE:
   - Load with ON_ERROR = CONTINUE
   - Use VALIDATE function to see errors
   - Partial data loaded
   - Best for: Production loads with error tracking

3. RETURN_FAILED_ONLY:
   - Returns only failed records
   - Combined with ON_ERROR
   - Best for: Focusing on errors only

RESULT_SCAN Function:
- Retrieves results from previous query
- Use LAST_QUERY_ID() for most recent
- Can save to table for analysis
- Available for 24 hours

Syntax:
SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

VALIDATE Function:
- Shows errors from actual COPY loads
- Use JOB_ID => '_last' for most recent
- Returns error details
- Works after ON_ERROR = CONTINUE

Syntax:
SELECT * FROM TABLE(
    VALIDATE(table_name, JOB_ID => '_last')
);

Error Information Available:
✅ rejected_record (full CSV row)
✅ error (error message)
✅ file (source file name)
✅ line (line number in file)
✅ character (character position)
✅ byte_offset (byte position)
✅ category (error category)
✅ code (error code)

Parsing Rejected Records:

SPLIT_PART Function:
SPLIT_PART(string, delimiter, position)

Example:
SPLIT_PART('A,B,C', ',', 1) → 'A'
SPLIT_PART('A,B,C', ',', 2) → 'B'
SPLIT_PART('A,B,C', ',', 3) → 'C'

For CSV parsing:
SELECT
    SPLIT_PART(rejected_record, ',', 1) AS col1,
    SPLIT_PART(rejected_record, ',', 2) AS col2,
    SPLIT_PART(rejected_record, ',', 3) AS col3
FROM rejected_records;

Analyzing Rejected Records:

-- Count errors by type
SELECT
    error,
    COUNT(*) AS error_count
FROM deepak_sales_db.public.rejected_records
GROUP BY error
ORDER BY error_count DESC;

-- Count errors by file
SELECT
    file,
    COUNT(*) AS error_count
FROM deepak_sales_db.public.rejected_records
GROUP BY file
ORDER BY error_count DESC;

-- Find most common bad values
SELECT
    SPLIT_PART(rejected_record, ',', 2) AS bad_amount,
    COUNT(*) AS occurrences
FROM deepak_sales_db.public.rejected_records
WHERE error LIKE '%number%'
GROUP BY bad_amount
ORDER BY occurrences DESC;

-- Analyze error patterns by column
SELECT
    CASE
        WHEN error LIKE '%ORDER_ID%' THEN 'Order ID'
        WHEN error LIKE '%AMOUNT%' THEN 'Amount'
        WHEN error LIKE '%PROFIT%' THEN 'Profit'
        WHEN error LIKE '%QUANTITY%' THEN 'Quantity'
        ELSE 'Other'
    END AS problem_column,
    COUNT(*) AS error_count
FROM deepak_sales_db.public.rejected_records
GROUP BY problem_column
ORDER BY error_count DESC;

Complete Workflow:

-- Step 1: Validate and capture errors
COPY INTO orders
    FROM @stage
    VALIDATION_MODE = RETURN_ERRORS;

-- Step 2: Save rejected records
CREATE OR REPLACE TABLE rejected_records AS
SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- Step 3: Parse rejected records
CREATE OR REPLACE TABLE rejected_parsed AS
SELECT
    SPLIT_PART(rejected_record, ',', 1) AS order_id,
    SPLIT_PART(rejected_record, ',', 2) AS amount,
    error,
    file,
    line
FROM rejected_records;

-- Step 4: Analyze patterns
SELECT
    error,
    COUNT(*) AS count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS pct
FROM rejected_records
GROUP BY error
ORDER BY count DESC;

-- Step 5: Fix source data or schema
-- Step 6: Retry load

Real-World Example:

-- Daily error tracking
CREATE TABLE IF NOT EXISTS error_log (
    load_date DATE,
    rejected_record VARCHAR,
    error VARCHAR,
    file VARCHAR,
    line NUMBER,
    captured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- After each load, append errors
INSERT INTO error_log (load_date, rejected_record, error, file, line)
SELECT
    CURRENT_DATE(),
    rejected_record,
    error,
    file,
    line
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

-- Weekly error report
SELECT
    load_date,
    COUNT(*) AS total_errors,
    COUNT(DISTINCT file) AS files_with_errors,
    COUNT(DISTINCT error) AS unique_error_types
FROM error_log
WHERE load_date >= DATEADD(DAY, -7, CURRENT_DATE())
GROUP BY load_date
ORDER BY load_date DESC;

Fixing Rejected Records:

-- Option 1: Fix at source
-- Contact data provider with error report

-- Option 2: Manual correction
-- Export rejected records, fix, reload

-- Option 3: Transform during load
COPY INTO orders
FROM (
    SELECT
        s.$1,
        TRY_CAST(s.$2 AS NUMBER) AS amount,  -- Handle bad numbers
        COALESCE(s.$3, 0) AS profit,         -- Handle NULLs
        s.$4
    FROM @stage s
)
ON_ERROR = CONTINUE;

-- Option 4: Load to staging, clean, then merge
COPY INTO staging_orders
    FROM @stage
    ON_ERROR = CONTINUE;

-- Clean data
UPDATE staging_orders
SET amount = 0 WHERE TRY_CAST(amount AS NUMBER) IS NULL;

-- Merge to production
MERGE INTO orders ...;

Best Practices:
1. Always capture rejected records
2. Analyze error patterns regularly
3. Track errors over time
4. Report issues to data providers
5. Document common errors
6. Automate error reporting
7. Set up alerts for high error rates
8. Keep error history for auditing

Error Reporting Template:

-- Generate error report for data provider
SELECT
    file AS "File Name",
    line AS "Line Number",
    rejected_record AS "Rejected Record",
    error AS "Error Message",
    CASE
        WHEN error LIKE '%number%' THEN 'Invalid Number Format'
        WHEN error LIKE '%NULL%' THEN 'Missing Required Value'
        WHEN error LIKE '%date%' THEN 'Invalid Date Format'
        ELSE 'Other'
    END AS "Error Category"
FROM deepak_sales_db.public.rejected_records
ORDER BY file, line;

Monitoring Dashboard Queries:

-- Error rate by day
SELECT
    DATE(captured_at) AS error_date,
    COUNT(*) AS error_count
FROM error_log
GROUP BY error_date
ORDER BY error_date DESC;

-- Top 10 error types
SELECT
    error,
    COUNT(*) AS occurrences,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM error_log
WHERE captured_at >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
GROUP BY error
ORDER BY occurrences DESC
LIMIT 10;

-- Files with highest error rates
SELECT
    file,
    COUNT(*) AS error_count,
    COUNT(DISTINCT error) AS unique_errors
FROM error_log
WHERE captured_at >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())
GROUP BY file
ORDER BY error_count DESC;

Deepak's Error Handling Checklist:
✅ Capture all rejected records
✅ Parse into structured format
✅ Analyze error patterns
✅ Track errors over time
✅ Report to data providers
✅ Fix root causes
✅ Document common issues
✅ Automate error monitoring
✅ Set up alerts
✅ Keep audit trail

Key Takeaway:
Rejected records are not just errors to ignore - they're
valuable data quality signals. Capture, analyze, and act
on them to improve your data pipelines!

Practiced: February 2026
Status: ✅ Completed - Mastering rejected record analysis
*/