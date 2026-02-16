/*
===========================================
DEEPAK'S PIPE MANAGEMENT GUIDE
===========================================
Topic: Managing and Controlling Snowpipes
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Pipe lifecycle management
- Pausing and resuming pipes
- Modifying pipe definitions
- Pipe status monitoring
- Refresh operations
===========================================
*/

-- Deepak's Note: Managing pipes is crucial for production pipelines!
-- Learn to pause, modify, refresh, and monitor pipes effectively


-- ========================================
-- SETUP: PREPARE ENVIRONMENT
-- ========================================

-- Deepak's database setup
USE DATABASE deepak_analytics_db;
USE SCHEMA public;


-- ========================================
-- STEP 1: DESCRIBE EXISTING PIPE
-- ========================================

-- Deepak's pipe inspection
DESC PIPE deepak_analytics_db.public.employee_data_pipe;

-- Deepak's observation: DESC shows:
-- - Pipe name and owner
-- - COPY INTO definition
-- - AUTO_INGEST setting
-- - Notification channel
-- - Creation timestamp


-- ========================================
-- STEP 2: SHOW PIPES
-- ========================================

-- Deepak's list all pipes
SHOW PIPES;

-- Deepak's filter by pattern
SHOW PIPES LIKE '%employee%';

-- Deepak's filter by database
SHOW PIPES IN DATABASE deepak_analytics_db;

-- Deepak's filter by schema
SHOW PIPES IN SCHEMA deepak_analytics_db.public;

-- Deepak's combined filter
SHOW PIPES LIKE '%employee%' IN DATABASE deepak_analytics_db;

-- Deepak's observation: SHOW PIPES displays:
-- - Pipe name, database, schema
-- - Owner and notification channel
-- - Definition (COPY INTO statement)


-- ========================================
-- STEP 3: CHECK PIPE STATUS
-- ========================================

-- Deepak's status check
SELECT SYSTEM$PIPE_STATUS('deepak_analytics_db.public.employee_data_pipe');

-- Deepak's sample output:
/*
{
  "executionState": "RUNNING",
  "pendingFileCount": 3,
  "notificationChannelName": "arn:aws:sqs:us-east-1:123456789:sf-snowpipe-...",
  "lastReceivedMessageTimestamp": "2024-02-14T10:30:00.000Z",
  "lastForwardedMessageTimestamp": "2024-02-14T10:29:55.000Z"
}
*/

-- Deepak's observation: Key status indicators!


-- ========================================
-- STEP 4: PAUSE PIPE
-- ========================================

-- Deepak's pause operation
ALTER PIPE deepak_analytics_db.public.employee_data_pipe 
  SET PIPE_EXECUTION_PAUSED = TRUE;

-- Deepak's observation: Pipe stops processing new files
-- Useful for maintenance or troubleshooting!

-- Deepak's verify paused state
SELECT SYSTEM$PIPE_STATUS('deepak_analytics_db.public.employee_data_pipe');

-- Deepak's expected output:
-- "executionState": "PAUSED"
-- "pendingFileCount": 0 (should be 0 before pausing)


-- ========================================
-- STEP 5: MODIFY PIPE DEFINITION
-- ========================================

-- Deepak's scenario: Need to change target table

-- Step 5a: Create new target table
CREATE OR REPLACE TABLE deepak_analytics_db.public.employees_v2 (
  employee_id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING,
  hire_date DATE,
  salary NUMBER(10,2),
  load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Deepak's observation: New table with additional salary column!

-- Step 5b: Recreate pipe with new definition
CREATE OR REPLACE PIPE deepak_analytics_db.public.employee_data_pipe
  AUTO_INGEST = TRUE
  COMMENT = 'Deepak: Updated pipe loading to employees_v2'
  AS
  COPY INTO deepak_analytics_db.public.employees_v2
  FROM @deepak_analytics_db.public.s3_employee_stage
  FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
  ON_ERROR = 'CONTINUE';

-- Deepak's observation: Pipe definition updated!
-- Now loads to employees_v2 instead of employees


-- ========================================
-- STEP 6: REFRESH PIPE
-- ========================================

-- Deepak's manual refresh
ALTER PIPE deepak_analytics_db.public.employee_data_pipe REFRESH;

-- Deepak's observation: REFRESH forces pipe to:
-- - Check for new files in stage
-- - Load files that haven't been processed
-- - Useful after recreating pipe

-- Deepak's alternative: Refresh specific path
ALTER PIPE deepak_analytics_db.public.employee_data_pipe
  REFRESH PREFIX='2024/02/';

-- Deepak's observation: Only refreshes files in 2024/02/ path!


-- ========================================
-- STEP 7: LIST FILES IN STAGE
-- ========================================

-- Deepak's check what files are available
LIST @deepak_analytics_db.public.s3_employee_stage;

-- Deepak's sample output:
-- name                                    | size  | md5        | last_modified
-- employees_jan_2024.csv                  | 12456 | abc123...  | 2024-01-15
-- employees_feb_2024.csv                  | 15234 | def456...  | 2024-02-01
-- employees_feb_update_2024.csv           | 8901  | ghi789...  | 2024-02-14


-- ========================================
-- STEP 8: MANUALLY LOAD FILES
-- ========================================

-- Deepak's scenario: Need to reload files that were already processed

-- Deepak's manual COPY (bypasses pipe)
COPY INTO deepak_analytics_db.public.employees_v2
FROM @deepak_analytics_db.public.s3_employee_stage
FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
PATTERN = '.*employees_feb.*csv'
ON_ERROR = 'CONTINUE';

-- Deepak's observation: Manual COPY for historical files
-- Pipe only processes NEW files after it was created!


-- ========================================
-- STEP 9: RESUME PIPE
-- ========================================

-- Deepak's resume operation
ALTER PIPE deepak_analytics_db.public.employee_data_pipe
  SET PIPE_EXECUTION_PAUSED = FALSE;

-- Deepak's observation: Pipe resumes processing!

-- Deepak's verify running state
SELECT SYSTEM$PIPE_STATUS('deepak_analytics_db.public.employee_data_pipe');

-- Deepak's expected output:
-- "executionState": "RUNNING"


-- ========================================
-- STEP 10: VERIFY DATA LOADED
-- ========================================

-- Deepak's data verification
SELECT * FROM deepak_analytics_db.public.employees_v2
ORDER BY load_timestamp DESC
LIMIT 10;

-- Deepak's sample data:
-- employee_id | first_name | last_name | email                    | location   | department  | hire_date  | salary
-- 2001        | Amit       | Patel     | amit.patel@company.com   | Mumbai     | Engineering | 2024-02-10 | 95000.00
-- 2002        | Priya      | Sharma    | priya.s@company.com      | Bangalore  | Marketing   | 2024-02-12 | 78000.00
-- 2003        | John       | Smith     | john.smith@company.com   | New York   | Sales       | 2024-02-13 | 85000.00
-- 2004        | Li         | Wei       | li.wei@company.com       | Singapore  | Finance     | 2024-02-14 | 92000.00

-- Deepak's observation: New data loaded successfully!


-- ========================================
-- STEP 11: CHECK COPY HISTORY
-- ========================================

-- Deepak's copy history for pipe
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'EMPLOYEES_V2',
  START_TIME => DATEADD(HOURS, -24, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME = 'EMPLOYEE_DATA_PIPE'
ORDER BY LAST_LOAD_TIME DESC;

-- Deepak's observation: Shows:
-- - Files loaded by pipe
-- - Row counts and file sizes
-- - Load timestamps
-- - Any errors encountered


-- ========================================
-- STEP 12: MONITOR PIPE PERFORMANCE
-- ========================================

-- Deepak's performance query
SELECT
  FILE_NAME,
  ROW_COUNT,
  ROW_PARSED,
  FILE_SIZE,
  LAST_LOAD_TIME,
  ERROR_COUNT,
  ERROR_LIMIT,
  STATUS
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'EMPLOYEES_V2',
  START_TIME => DATEADD(DAYS, -7, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME = 'EMPLOYEE_DATA_PIPE'
ORDER BY LAST_LOAD_TIME DESC;

-- Deepak's observation: Track pipe performance over time!


-- ========================================
-- STEP 13: HANDLE PIPE ERRORS
-- ========================================

-- Deepak's error investigation
SELECT
  FILE_NAME,
  ERROR_COUNT,
  FIRST_ERROR_MESSAGE,
  FIRST_ERROR_LINE_NUMBER,
  FIRST_ERROR_CHARACTER_POS,
  FIRST_ERROR_COLUMN_NAME
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'EMPLOYEES_V2',
  START_TIME => DATEADD(DAYS, -1, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME = 'EMPLOYEE_DATA_PIPE'
  AND STATUS = 'LOAD_FAILED'
ORDER BY LAST_LOAD_TIME DESC;

-- Deepak's observation: Identify and fix data quality issues!


-- ========================================
-- STEP 14: ALTER PIPE PROPERTIES
-- ========================================

-- Deepak's update pipe comment
ALTER PIPE deepak_analytics_db.public.employee_data_pipe
  SET COMMENT = 'Deepak: Production employee data pipeline - Updated Feb 2024';

-- Deepak's observation: Can update metadata without recreating pipe!


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. PIPE LIFECYCLE MANAGEMENT
   - Create: Define pipe with COPY INTO
   - Monitor: Check status and performance
   - Pause: Stop processing temporarily
   - Modify: Recreate with new definition
   - Resume: Restart processing
   - Drop: Remove when no longer needed

2. PAUSE VS STOP
   - PAUSE: Temporary suspension
   - Pipe still exists
   - Can resume anytime
   - Pending files remain queued
   - Use for maintenance

3. MODIFYING PIPES
   - Cannot ALTER pipe definition
   - Must use CREATE OR REPLACE
   - Pause pipe first (best practice)
   - Verify pendingFileCount = 0
   - Then recreate pipe
   - Resume after verification

4. REFRESH OPERATIONS
   - REFRESH: Reprocess all files
   - REFRESH PREFIX: Reprocess specific path
   - Useful after pipe recreation
   - Loads files that arrived before pipe
   - Does NOT reload already-processed files

5. MANUAL VS AUTOMATIC LOADING
   - Pipe: Automatic, continuous
   - COPY INTO: Manual, one-time
   - Use COPY for historical data
   - Use pipe for ongoing ingestion
   - Combine both for complete solution

6. SYSTEM$PIPE_STATUS FIELDS
   - executionState: RUNNING/PAUSED
   - pendingFileCount: Files in queue
   - notificationChannelName: Event queue
   - lastReceivedMessageTimestamp: Last event
   - lastForwardedMessageTimestamp: Last processed

7. COPY_HISTORY ANALYSIS
   - Track files loaded
   - Monitor row counts
   - Identify errors
   - Measure performance
   - Audit data lineage

8. ERROR HANDLING STRATEGIES
   - ON_ERROR = 'CONTINUE': Skip bad rows
   - ON_ERROR = 'SKIP_FILE': Skip bad files
   - ON_ERROR = 'ABORT_STATEMENT': Stop on error
   - Check COPY_HISTORY for details
   - Fix data quality issues

9. BEST PRACTICES
   ✅ Pause before modifying pipes
   ✅ Verify pendingFileCount = 0
   ✅ Test changes in dev first
   ✅ Monitor COPY_HISTORY regularly
   ✅ Set up alerts for failures
   ✅ Document pipe purposes
   ✅ Use meaningful names
   ✅ Regular performance reviews

10. TROUBLESHOOTING CHECKLIST
    - Check pipe status (RUNNING/PAUSED)
    - Verify pendingFileCount
    - Review COPY_HISTORY for errors
    - Confirm stage accessibility
    - Check file format compatibility
    - Verify target table schema
    - Test with manual COPY
    - Review notification channel

Effective pipe management ensures reliable, continuous data loading!
*/

-- Deepak's Summary:
-- Managing pipes involves monitoring, pausing, modifying, and troubleshooting.
-- Master these operations for production-ready data pipelines!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Pipe management mastered!
===========================================
*/

