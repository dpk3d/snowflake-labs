/*
===========================================
DEEPAK'S COMPLETE SNOWPIPE SETUP
===========================================
Topic: End-to-End Stage and Pipe Configuration
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Complete pipeline setup from scratch
- Table, format, stage, and pipe creation
- S3 integration with Snowpipe
- Organized schema structure
- Production-ready configuration
===========================================
*/

-- Deepak's Note: This is a complete end-to-end setup!
-- From table creation to automated loading with Snowpipe


-- ========================================
-- SETUP: PREPARE DATABASES
-- ========================================

-- Deepak's data database
CREATE OR REPLACE DATABASE deepak_analytics_db;

-- Deepak's management database for reusable objects
CREATE OR REPLACE DATABASE deepak_manage_db;


-- ========================================
-- STEP 1: CREATE DESTINATION TABLE
-- ========================================

-- Deepak's employee table
CREATE OR REPLACE TABLE deepak_analytics_db.public.employees (
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

-- Deepak's observation: Table ready to receive data!


-- ========================================
-- STEP 2: CREATE FILE FORMAT
-- ========================================

-- Deepak's schema for file formats
CREATE OR REPLACE SCHEMA deepak_manage_db.file_formats;

-- Deepak's CSV file format
CREATE OR REPLACE FILE FORMAT deepak_manage_db.file_formats.csv_standard
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TRIM_SPACE = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  COMPRESSION = AUTO;

-- Deepak's observation: Reusable file format for all CSV files!


-- ========================================
-- STEP 3: CREATE STORAGE INTEGRATION
-- ========================================

-- Deepak's S3 storage integration (assuming already created)
-- CREATE OR REPLACE STORAGE INTEGRATION deepak_s3_int
--   TYPE = EXTERNAL_STAGE
--   STORAGE_PROVIDER = S3
--   ENABLED = TRUE
--   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/deepak-snowflake-role'
--   STORAGE_ALLOWED_LOCATIONS = ('s3://deepak-data-bucket/');

-- Deepak's note: Storage integration created separately (see Create+Storage+integration.txt)


-- ========================================
-- STEP 4: CREATE EXTERNAL STAGE
-- ========================================

-- Deepak's schema for external stages
CREATE OR REPLACE SCHEMA deepak_manage_db.external_stages;

-- Deepak's S3 stage for employee data
CREATE OR REPLACE STAGE deepak_manage_db.external_stages.s3_employee_folder
  URL = 's3://deepak-data-bucket/employees/raw/'
  STORAGE_INTEGRATION = deepak_s3_int
  FILE_FORMAT = deepak_manage_db.file_formats.csv_standard
  COMMENT = 'Deepak: S3 stage for employee CSV files';

-- Deepak's observation: Stage configured with integration and format!


-- ========================================
-- STEP 5: LIST FILES IN STAGE
-- ========================================

-- Deepak's file listing
LIST @deepak_manage_db.external_stages.s3_employee_folder;

-- Deepak's sample output:
-- name                                    | size  | md5                              | last_modified
-- employees/raw/emp_jan_2024.csv          | 15234 | abc123def456...                  | 2024-01-15 10:30:00
-- employees/raw/emp_feb_2024.csv          | 18456 | def789ghi012...                  | 2024-02-01 14:20:00
-- employees/raw/emp_feb_update_2024.csv   | 12789 | ghi345jkl678...                  | 2024-02-14 09:15:00

-- Deepak's observation: Files detected in S3!


-- ========================================
-- STEP 6: TEST MANUAL COPY
-- ========================================

-- Deepak's test load (before creating pipe)
COPY INTO deepak_analytics_db.public.employees
FROM @deepak_manage_db.external_stages.s3_employee_folder
FILE_FORMAT = deepak_manage_db.file_formats.csv_standard
PATTERN = '.*emp_jan.*csv'
ON_ERROR = 'CONTINUE';

-- Deepak's verification
SELECT COUNT(*) as row_count FROM deepak_analytics_db.public.employees;

-- Deepak's sample data check
SELECT * FROM deepak_analytics_db.public.employees LIMIT 5;

-- Deepak's sample output:
-- employee_id | first_name | last_name | email                    | location   | department  | hire_date  | salary
-- 1001        | Rajesh     | Kumar     | rajesh.k@company.com     | Mumbai     | Engineering | 2024-01-10 | 95000.00
-- 1002        | Priya      | Sharma    | priya.s@company.com      | Bangalore  | Marketing   | 2024-01-12 | 78000.00
-- 1003        | Michael    | Chen      | michael.c@company.com    | Singapore  | Sales       | 2024-01-15 | 85000.00
-- 1004        | Sarah      | Johnson   | sarah.j@company.com      | New York   | HR          | 2024-01-18 | 72000.00
-- 1005        | Ahmed      | Hassan    | ahmed.h@company.com      | Dubai      | Finance     | 2024-01-20 | 92000.00

-- Deepak's observation: Manual COPY works! Ready for Snowpipe!


-- ========================================
-- STEP 7: CREATE SCHEMA FOR PIPES
-- ========================================

-- Deepak's dedicated schema for pipes
CREATE OR REPLACE SCHEMA deepak_manage_db.pipes;

-- Deepak's observation: Organized structure for pipe objects!


-- ========================================
-- STEP 8: CREATE SNOWPIPE
-- ========================================

-- Deepak's Snowpipe for automated loading
CREATE OR REPLACE PIPE deepak_manage_db.pipes.employee_auto_pipe
  AUTO_INGEST = TRUE
  COMMENT = 'Deepak: Auto-loading employee data from S3'
  AS
  COPY INTO deepak_analytics_db.public.employees
  FROM @deepak_manage_db.external_stages.s3_employee_folder
  FILE_FORMAT = deepak_manage_db.file_formats.csv_standard
  ON_ERROR = 'CONTINUE';

-- Deepak's observation: Pipe created with AUTO_INGEST enabled!


-- ========================================
-- STEP 9: DESCRIBE PIPE
-- ========================================

-- Deepak's pipe details
DESC PIPE deepak_manage_db.pipes.employee_auto_pipe;

-- Deepak's observation: DESC shows:
-- - Pipe definition
-- - Notification channel (SQS queue ARN)
-- - AUTO_INGEST setting
-- - COPY INTO statement

-- Deepak's important: Copy the notification_channel value!
-- Configure this in AWS S3 bucket event notifications


-- ========================================
-- STEP 10: CHECK PIPE STATUS
-- ========================================

-- Deepak's status check
SELECT SYSTEM$PIPE_STATUS('deepak_manage_db.pipes.employee_auto_pipe');

-- Deepak's sample output:
/*
{
  "executionState": "RUNNING",
  "pendingFileCount": 2,
  "notificationChannelName": "arn:aws:sqs:us-east-1:123456789:sf-snowpipe-...",
  "lastReceivedMessageTimestamp": "2024-02-14T10:30:00.000Z",
  "lastForwardedMessageTimestamp": "2024-02-14T10:29:55.000Z"
}
*/


-- ========================================
-- STEP 11: VERIFY AUTOMATED LOADING
-- ========================================

-- Deepak's wait for auto-ingest (files uploaded after pipe creation)
-- New files in S3 trigger automatic loading!

-- Deepak's check loaded data
SELECT * FROM deepak_analytics_db.public.employees
ORDER BY load_timestamp DESC
LIMIT 10;

-- Deepak's observation: New files loaded automatically!


-- ========================================
-- STEP 12: MONITOR COPY HISTORY
-- ========================================

-- Deepak's copy history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'EMPLOYEES',
  START_TIME => DATEADD(HOURS, -24, CURRENT_TIMESTAMP())
))
WHERE PIPE_NAME = 'EMPLOYEE_AUTO_PIPE'
ORDER BY LAST_LOAD_TIME DESC;

-- Deepak's observation: Track all files loaded by pipe!


-- ========================================
-- STEP 13: SHOW ALL PIPES
-- ========================================

-- Deepak's pipe listing
SHOW PIPES IN SCHEMA deepak_manage_db.pipes;

-- Deepak's observation: All pipes in organized schema!


-- ========================================
-- AWS S3 EVENT NOTIFICATION SETUP
-- ========================================

/*
Deepak's AWS Configuration Steps:

1. GET NOTIFICATION CHANNEL:
   - Run DESC PIPE command
   - Copy notification_channel value (SQS ARN)

2. CONFIGURE S3 BUCKET:
   - Go to S3 bucket properties
   - Navigate to Event notifications
   - Create new event notification

3. EVENT NOTIFICATION SETTINGS:
   - Name: snowpipe-employee-events
   - Prefix: employees/raw/
   - Events: All object create events (s3:ObjectCreated:*)
   - Destination: SQS queue
   - SQS queue ARN: <paste notification_channel from DESC PIPE>

4. TEST:
   - Upload new file to S3
   - Wait 1-2 minutes
   - Check SYSTEM$PIPE_STATUS
   - Verify data in table
*/


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. COMPLETE PIPELINE ARCHITECTURE
   - Source: S3 bucket
   - Integration: Storage integration (secure access)
   - Stage: External stage (file location)
   - Format: File format (parsing rules)
   - Pipe: Snowpipe (automation)
   - Target: Snowflake table

2. ORGANIZED SCHEMA STRUCTURE
   - Data DB: Contains business tables
   - Manage DB: Contains reusable objects
   - file_formats schema: File format objects
   - external_stages schema: Stage objects
   - pipes schema: Pipe objects
   - Benefits: Organization, reusability, governance

3. STORAGE INTEGRATION BENEFITS
   - No embedded credentials
   - Centralized access control
   - IAM role-based security
   - Easier credential rotation
   - Audit trail

4. FILE FORMAT REUSABILITY
   - Create once, use many times
   - Consistent parsing rules
   - Easier maintenance
   - Centralized updates
   - Best practice for production

5. STAGE CONFIGURATION
   - URL: S3 bucket path
   - STORAGE_INTEGRATION: Security
   - FILE_FORMAT: Parsing rules
   - COMMENT: Documentation
   - Reusable across pipes

6. AUTO_INGEST WORKFLOW
   - File uploaded to S3
   - S3 sends event to SQS
   - Snowpipe receives notification
   - COPY INTO executes automatically
   - Data available in seconds

7. TESTING STRATEGY
   - Test manual COPY first
   - Verify file format works
   - Check data quality
   - Then create pipe
   - Monitor initial loads

8. MONITORING AND TROUBLESHOOTING
   - SYSTEM$PIPE_STATUS: Real-time status
   - COPY_HISTORY: Historical loads
   - DESC PIPE: Configuration details
   - SHOW PIPES: All pipes overview
   - Regular monitoring essential

9. PRODUCTION BEST PRACTICES
   ✅ Use storage integrations (no credentials)
   ✅ Organize objects in schemas
   ✅ Use named file formats
   ✅ Test before creating pipe
   ✅ Document all objects (COMMENT)
   ✅ Monitor pipe status
   ✅ Set up error alerts
   ✅ Regular performance reviews

10. COMMON PITFALLS TO AVOID
    ❌ Creating pipe before testing COPY
    ❌ Not configuring S3 event notifications
    ❌ Embedding credentials in stages
    ❌ Using inline file formats
    ❌ Not monitoring pipe status
    ❌ Ignoring COPY_HISTORY errors
    ❌ Poor schema organization

This complete setup demonstrates production-ready Snowpipe configuration!
*/

-- Deepak's Summary:
-- A well-organized Snowpipe setup includes proper schema structure,
-- reusable objects, security integrations, and comprehensive monitoring!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Complete Snowpipe setup mastered!
===========================================
*/