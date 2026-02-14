/*
===========================================
DEEPAK'S TIME TRAVEL PRACTICE
===========================================
Topic: Time Travel for Data Recovery
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Time Travel allows querying historical data
- Three methods: OFFSET, TIMESTAMP, QUERY_ID
- Can recover from accidental updates/deletes
- Retention period: 0-90 days (Enterprise)
===========================================
*/

-- Deepak's Note: Time Travel is Snowflake's "undo" feature
-- Incredibly useful for recovering from mistakes!


-- ========================================
-- SETUP: CREATE TABLE AND LOAD DATA
-- ========================================

CREATE OR REPLACE TABLE deepak_analytics_db.public.employee_data (
   employee_id INT,
   first_name STRING,
   last_name STRING,
   email STRING,
   department STRING,
   job_title STRING,
   phone STRING,
   salary NUMBER(10,2)
)
COMMENT = 'Deepak - Employee data for time travel testing';


-- Create file format for CSV
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.file_formats.employee_csv
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    COMMENT = 'Deepak - Employee data CSV format';

-- Create stage for employee data
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.employee_stage
    URL = 's3://deepak-snowflake-data/employees/'
    FILE_FORMAT = deepak_mgmt_db.file_formats.employee_csv
    COMMENT = 'Deepak - Stage for employee data files';


-- List files in stage
LIST @deepak_mgmt_db.external_stages.employee_stage;


-- Load employee data
COPY INTO deepak_analytics_db.public.employee_data
FROM @deepak_mgmt_db.external_stages.employee_stage
FILES = ('employees.csv');


-- Verify loaded data
SELECT * FROM deepak_analytics_db.public.employee_data
ORDER BY employee_id
LIMIT 10;


-- ========================================
-- SCENARIO 1: ACCIDENTAL UPDATE
-- ========================================

-- Deepak's mistake: Accidentally updated all first names!
UPDATE deepak_analytics_db.public.employee_data
SET first_name = 'MISTAKE';

-- Deepak's panic: Oh no! All names are now 'MISTAKE'
SELECT * FROM deepak_analytics_db.public.employee_data LIMIT 5;


-- ========================================
-- TIME TRAVEL METHOD 1: OFFSET (Minutes Back)
-- ========================================

-- Deepak's recovery: Query data from 2 minutes ago
SELECT * FROM deepak_analytics_db.public.employee_data
AT (OFFSET => -60*2)  -- 2 minutes = 120 seconds
LIMIT 10;

-- Deepak's relief: Original data is still accessible! ✅






-- ========================================
-- TIME TRAVEL METHOD 2: BEFORE TIMESTAMP
-- ========================================

-- Deepak's learning: Query data as it existed at specific timestamp
SELECT * FROM deepak_analytics_db.public.employee_data
BEFORE (TIMESTAMP => '2026-02-12 10:30:00'::TIMESTAMP)
LIMIT 10;

-- Deepak's note: More precise than OFFSET, use when you know exact time


-- ========================================
-- SCENARIO 2: ANOTHER ACCIDENTAL UPDATE
-- ========================================

-- Reset table for next example
CREATE OR REPLACE TABLE deepak_analytics_db.public.employee_data (
   employee_id INT,
   first_name STRING,
   last_name STRING,
   email STRING,
   department STRING,
   job_title STRING,
   phone STRING,
   salary NUMBER(10,2)
)
COMMENT = 'Deepak - Employee data for time travel testing';

-- Reload data
COPY INTO deepak_analytics_db.public.employee_data
FROM @deepak_mgmt_db.external_stages.employee_stage
FILES = ('employees.csv');

SELECT * FROM deepak_analytics_db.public.employee_data LIMIT 5;


-- Deepak's tip: Set timezone to UTC for consistency
ALTER SESSION SET TIMEZONE = 'UTC';
SELECT CURRENT_TIMESTAMP() AS current_utc_time;


-- Deepak's second mistake: Updated all job titles
UPDATE deepak_analytics_db.public.employee_data
SET job_title = 'Data Scientist';

-- Check current (wrong) data
SELECT employee_id, first_name, last_name, job_title
FROM deepak_analytics_db.public.employee_data
LIMIT 10;


-- Deepak's recovery: Query before the update timestamp
SELECT employee_id, first_name, last_name, job_title
FROM deepak_analytics_db.public.employee_data
BEFORE (TIMESTAMP => '2026-02-12 11:00:00'::TIMESTAMP)
LIMIT 10;

-- Deepak's observation: Original job titles are preserved!






-- ========================================
-- TIME TRAVEL METHOD 3: BEFORE QUERY ID
-- ========================================

-- Deepak's learning: Most precise method using query ID
-- Useful when you know exactly which query caused the problem

-- Prepare fresh table
CREATE OR REPLACE TABLE deepak_analytics_db.public.employee_data (
   employee_id INT,
   first_name STRING,
   last_name STRING,
   email STRING,
   department STRING,
   phone STRING,
   job_title STRING,
   salary NUMBER(10,2)
)
COMMENT = 'Deepak - Employee data for query ID time travel';

-- Load data
COPY INTO deepak_analytics_db.public.employee_data
FROM @deepak_mgmt_db.external_stages.employee_stage
FILES = ('employees.csv');

-- Verify data
SELECT * FROM deepak_analytics_db.public.employee_data LIMIT 5;


-- Deepak's third mistake: Accidentally nullified all emails!
UPDATE deepak_analytics_db.public.employee_data
SET email = NULL;

-- Deepak's note: Copy the query ID from the UPDATE statement above
-- Query ID format: 01ab9ee5-0500-8473-0043-4d8300073062


-- Check damaged data
SELECT employee_id, first_name, email
FROM deepak_analytics_db.public.employee_data
LIMIT 10;


-- Deepak's recovery: Query before the problematic statement
SELECT employee_id, first_name, email
FROM deepak_analytics_db.public.employee_data
BEFORE (STATEMENT => '01ab9ee5-0500-8473-0043-4d8300073062')
LIMIT 10;

-- Deepak's observation: Emails are back! This is the most precise method


/*
DEEPAK'S TIME TRAVEL SUMMARY:
=============================

Three Time Travel Methods:

1. OFFSET (Relative Time):
   AT (OFFSET => -60*5)  -- 5 minutes ago
   - Simple and quick
   - Good for recent mistakes
   - Less precise

2. TIMESTAMP (Absolute Time):
   BEFORE (TIMESTAMP => '2026-02-12 10:30:00'::TIMESTAMP)
   - Precise point in time
   - Good when you know when data was correct
   - Requires timestamp tracking

3. QUERY_ID (Statement-Based):
   BEFORE (STATEMENT => 'query-id-here')
   - Most precise method
   - Perfect when you know which query caused issue
   - Get query ID from query history

Common Use Cases:
✅ Recover from accidental DELETE
✅ Undo incorrect UPDATE statements
✅ Restore dropped tables (with UNDROP)
✅ Compare data changes over time
✅ Audit data modifications
✅ Create point-in-time reports

Retention Periods:
- Standard: 1 day (default)
- Enterprise: Up to 90 days
- Transient tables: 0-1 day
- Temporary tables: 0-1 day

Best Practices:
1. Set appropriate retention period for critical tables
2. Use UTC timezone for consistency
3. Document query IDs for important operations
4. Test time travel queries before restoring
5. Monitor storage costs (time travel uses storage)

Recovery Workflow:
1. Identify the problem (wrong data)
2. Find when data was correct (timestamp/query ID)
3. Query historical data with time travel
4. Verify correct data
5. Restore using CREATE TABLE AS SELECT or INSERT

Real-World Example:
-- Accidentally deleted customer orders
DELETE FROM orders WHERE order_date = '2026-02-12';

-- Recover using time travel
CREATE TABLE orders_recovered AS
SELECT * FROM orders
BEFORE (STATEMENT => 'delete-query-id');

-- Verify and restore
INSERT INTO orders SELECT * FROM orders_recovered;

Practiced: February 2026
Status: ✅ Completed - Time Travel mastered!
*/


