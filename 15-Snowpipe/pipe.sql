/*
===========================================
DEEPAK'S BASIC SNOWPIPE CREATION
===========================================
Topic: Creating a Simple Snowpipe
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Basic pipe syntax and structure
- AUTO_INGEST parameter
- Pipe description and verification
- Simple COPY INTO with pipe
===========================================
*/

-- Deepak's Note: This is my first simple Snowpipe!
-- Learning the basics before moving to advanced scenarios


-- ========================================
-- SETUP: PREPARE DATABASE AND TABLE
-- ========================================

-- Deepak's database setup
USE DATABASE deepak_analytics_db;
USE SCHEMA public;

-- Deepak's employee table for pipe loading
CREATE OR REPLACE TABLE employees (
  employee_id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING,
  hire_date DATE,
  load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Deepak's observation: Table ready for automated loading!


-- ========================================
-- STEP 1: CREATE BASIC SNOWPIPE
-- ========================================

-- Deepak's first pipe with auto-ingest
CREATE OR REPLACE PIPE deepak_analytics_db.public.employee_data_pipe
  AUTO_INGEST = TRUE
  COMMENT = 'Deepak: Auto-loading employee data from S3'
  AS
  COPY INTO deepak_analytics_db.public.employees
  FROM @deepak_analytics_db.public.s3_employee_stage
  FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
  ON_ERROR = 'CONTINUE';

-- Deepak's observation: Pipe created with AUTO_INGEST enabled!
-- This means files will be loaded automatically when detected


-- ========================================
-- STEP 2: DESCRIBE AND VERIFY PIPE
-- ========================================

-- Deepak's check: View pipe details
DESC PIPE deepak_analytics_db.public.employee_data_pipe;

-- Deepak's observation: DESC shows:
-- - Pipe name and definition
-- - COPY INTO statement
-- - AUTO_INGEST setting
-- - Notification channel (for cloud events)


-- ========================================
-- STEP 3: CHECK PIPE STATUS
-- ========================================

-- Deepak's status check
SELECT SYSTEM$PIPE_STATUS('deepak_analytics_db.public.employee_data_pipe');

-- Deepak's observation: Returns JSON with:
-- - executionState: RUNNING or PAUSED
-- - pendingFileCount: Files waiting to be loaded
-- - notificationChannelName: Event queue name


-- ========================================
-- STEP 4: VERIFY DATA LOADED
-- ========================================

-- Deepak's data check
SELECT * FROM deepak_analytics_db.public.employees
ORDER BY load_timestamp DESC
LIMIT 10;

-- Deepak's sample data loaded:
-- employee_id | first_name | last_name | email                    | location      | department | hire_date
-- 1001        | Rajesh     | Kumar     | rajesh.kumar@company.com | Mumbai        | Engineering| 2024-01-15
-- 1002        | Priya      | Sharma    | priya.sharma@company.com | Bangalore     | Marketing  | 2024-02-01
-- 1003        | Michael    | Chen      | michael.chen@company.com | Singapore     | Sales      | 2024-02-10
-- 1004        | Sarah      | Johnson   | sarah.j@company.com      | New York      | HR         | 2024-03-05
-- 1005        | Ahmed      | Hassan    | ahmed.h@company.com      | Dubai         | Finance    | 2024-03-20

-- Deepak's observation: Data loaded automatically via Snowpipe!


-- ========================================
-- STEP 5: SHOW ALL PIPES
-- ========================================

-- Deepak's pipe listing
SHOW PIPES IN DATABASE deepak_analytics_db;

-- Deepak's filtered view
SHOW PIPES LIKE '%employee%' IN DATABASE deepak_analytics_db;


-- ========================================
-- DEEPAK'S KEY INSIGHTS
-- ========================================

/*
1. PIPE BASICS
   - Pipe = Automated COPY INTO statement
   - Runs continuously in background
   - No warehouse required (serverless)
   - Charged per file loaded

2. AUTO_INGEST PARAMETER
   - TRUE: Automatic file detection
   - Requires notification integration
   - Cloud events trigger loading
   - FALSE: Manual refresh only

3. PIPE DEFINITION
   - Contains COPY INTO statement
   - Specifies source stage
   - Defines file format
   - Sets error handling

4. SYSTEM$PIPE_STATUS()
   - Check if pipe is running
   - View pending file count
   - Monitor notification channel
   - Troubleshoot issues

5. SERVERLESS COMPUTE
   - No warehouse needed
   - Snowflake manages resources
   - Automatic scaling
   - Pay per file loaded

6. REAL-WORLD USE CASE
   - HR uploads employee files to S3
   - Snowpipe detects new files
   - Data loaded automatically
   - Available for queries immediately

7. BEST PRACTICES
   ✅ Use meaningful pipe names
   ✅ Add descriptive comments
   ✅ Set ON_ERROR appropriately
   ✅ Monitor pipe status regularly
   ✅ Test with small files first

This simple pipe demonstrates the power of automated data loading!
*/

-- Deepak's Summary:
-- Snowpipe transforms manual batch loading into continuous streaming.
-- Perfect for real-time data pipelines and event-driven architectures!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Basic pipe creation mastered!
===========================================
*/
