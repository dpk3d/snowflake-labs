/*
===========================================
DEEPAK'S ON_ERROR OPTIONS PRACTICE
===========================================
Topic: Error Handling in COPY Commands
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- ON_ERROR controls how COPY handles bad records
- Options: ABORT_STATEMENT, CONTINUE, SKIP_FILE, SKIP_FILE_N
- Default is ABORT_STATEMENT (stops on first error)
- CONTINUE loads good records, skips bad ones
- SKIP_FILE skips entire file if any error found
===========================================
*/

-- Deepak's Note: Error handling is critical for production data pipelines
-- Choose the right strategy based on data quality requirements


-- ========================================
-- SETUP: CREATE STAGE WITH ERROR FILES
-- ========================================

-- Deepak's scenario: Stage with files containing errors
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.deepak_error_stage
    URL = 's3://deepak-snowflake-data/error-files/'
    COMMENT = 'Deepak - Stage with files containing data errors';

-- List files in stage
LIST @deepak_mgmt_db.external_stages.deepak_error_stage;

-- Deepak's observation: Files have various data quality issues


-- ========================================
-- CREATE TEST TABLE
-- ========================================

CREATE OR REPLACE TABLE deepak_sales_db.public.orders_error_test (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Table for testing error handling';


-- ========================================
-- TEST 1: DEFAULT BEHAVIOR (ABORT_STATEMENT)
-- ========================================

-- Deepak's experiment: Load file with errors (no ON_ERROR specified)
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_mgmt_db.external_stages.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_error_2026.csv');

-- Deepak's observation: ERROR! Load aborted on first bad record
-- This is the default behavior (ON_ERROR = 'ABORT_STATEMENT')


-- Verify table is empty
SELECT * FROM deepak_sales_db.public.orders_error_test;
-- Deepak's note: No records loaded due to error


-- ========================================
-- TEST 2: ON_ERROR = 'CONTINUE'
-- ========================================

-- Deepak's scenario: Load good records, skip bad ones
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_mgmt_db.external_stages.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_error_2026.csv')
    ON_ERROR = 'CONTINUE';

-- Deepak's learning: Load succeeded! Good records loaded, bad ones skipped

-- Validate results
SELECT * FROM deepak_sales_db.public.orders_error_test;
SELECT COUNT(*) AS records_loaded FROM deepak_sales_db.public.orders_error_test;

-- Deepak's observation: Partial load successful

-- Clean up for next test
TRUNCATE TABLE deepak_sales_db.public.orders_error_test;


-- ========================================
-- TEST 3: ON_ERROR = 'ABORT_STATEMENT' (EXPLICIT)
-- ========================================

-- Deepak's experiment: Explicitly set default behavior with multiple files
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_mgmt_db.external_stages.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_error_2026.csv', 'OrderDetails_error2_2026.csv')
    ON_ERROR = 'ABORT_STATEMENT';

-- Deepak's observation: ERROR! Entire load aborted, no files processed

-- Verify no records loaded
SELECT COUNT(*) FROM deepak_sales_db.public.orders_error_test;

TRUNCATE TABLE deepak_sales_db.public.orders_error_test;


-- ========================================
-- TEST 4: ON_ERROR = 'SKIP_FILE'
-- ========================================

-- Deepak's scenario: Skip entire file if ANY error found
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_mgmt_db.external_stages.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_error_2026.csv', 'OrderDetails_error2_2026.csv')
    ON_ERROR = 'SKIP_FILE';

-- Deepak's learning: Files with errors skipped entirely, clean files loaded

-- Validate results
SELECT * FROM deepak_sales_db.public.orders_error_test;
SELECT COUNT(*) AS records_from_clean_files FROM deepak_sales_db.public.orders_error_test;

-- Deepak's observation: Only clean files loaded

TRUNCATE TABLE deepak_sales_db.public.orders_error_test;


-- ========================================
-- TEST 5: ON_ERROR = 'SKIP_FILE_N'
-- ========================================

-- Deepak's scenario: Skip file if more than N errors
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_mgmt_db.external_stages.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_error_2026.csv', 'OrderDetails_error2_2026.csv')
    ON_ERROR = 'SKIP_FILE_2';

-- Deepak's learning: Skip file if more than 2 errors found
-- Allows some errors but not too many

-- Validate results
SELECT * FROM deepak_sales_db.public.orders_error_test;
SELECT COUNT(*) FROM deepak_sales_db.public.orders_error_test;

TRUNCATE TABLE deepak_sales_db.public.orders_error_test;


-- ========================================
-- TEST 6: ON_ERROR = 'SKIP_FILE_N%'
-- ========================================

-- Deepak's scenario: Skip file if more than N% of records have errors
COPY INTO deepak_sales_db.public.orders_error_test
    FROM @deepak_mgmt_db.external_stages.deepak_error_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_error_2026.csv', 'OrderDetails_error2_2026.csv')
    ON_ERROR = 'SKIP_FILE_3%';

-- Deepak's learning: Skip file if more than 3% of records are bad
-- Percentage-based threshold

SELECT * FROM deepak_sales_db.public.orders_error_test;


/*
DEEPAK'S ERROR HANDLING INSIGHTS:
=================================

ON_ERROR Options:

1. ABORT_STATEMENT (Default):
   - Stops on first error
   - No records loaded
   - Safest option
   - Use when: Data quality is critical

2. CONTINUE:
   - Loads good records, skips bad ones
   - Partial load succeeds
   - Use when: Some data loss acceptable

3. SKIP_FILE:
   - Skips entire file if ANY error
   - All-or-nothing per file
   - Use when: File-level quality required

4. SKIP_FILE_N:
   - Skip file if more than N errors
   - Example: SKIP_FILE_5 (skip if >5 errors)
   - Use when: Tolerate few errors per file

5. SKIP_FILE_N%:
   - Skip file if more than N% errors
   - Example: SKIP_FILE_10% (skip if >10% bad)
   - Use when: Percentage threshold needed

Decision Matrix:
┌──────────────────────┬─────────────────┬──────────────┐
│ Scenario             │ ON_ERROR        │ Result       │
├──────────────────────┼─────────────────┼──────────────┤
│ Zero tolerance       │ ABORT_STATEMENT │ All or none  │
│ Best effort load     │ CONTINUE        │ Partial OK   │
│ File quality check   │ SKIP_FILE       │ Clean files  │
│ Allow few errors     │ SKIP_FILE_5     │ Threshold    │
│ Percentage based     │ SKIP_FILE_10%   │ % threshold  │
└──────────────────────┴─────────────────┴──────────────┘

Best Practices:
1. Use ABORT_STATEMENT for critical data
2. Use CONTINUE for best-effort loads
3. Monitor error logs after CONTINUE
4. Set appropriate thresholds for SKIP_FILE_N
5. Test error handling before production
6. Document error handling strategy
7. Set up alerts for high error rates

Monitoring Errors:
-- Check load history
SELECT * FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ORDERS_ERROR_TEST',
        START_TIME => DATEADD(HOURS, -1, CURRENT_TIMESTAMP())
    )
);

-- View error details
SELECT
    file_name,
    row_number,
    error_message
FROM TABLE(VALIDATE(orders_error_test, JOB_ID => '_last'));

Production Strategy:
1. Development: Use ABORT_STATEMENT (catch all errors)
2. Testing: Use CONTINUE (identify error patterns)
3. Production: Choose based on requirements
4. Monitor: Track error rates and patterns
5. Alert: Set up notifications for high error rates

Combining with Other Options:
COPY INTO table
    FROM @stage
    FILE_FORMAT = (...)
    ON_ERROR = 'CONTINUE'
    SIZE_LIMIT = 1000000
    RETURN_FAILED_ONLY = TRUE;

Practiced: February 2026
Status: ✅ Completed - Understanding error handling strategies
*/



