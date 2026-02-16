/*
===========================================
DEEPAK'S ADVANCED SNOWPIPE PRACTICE
===========================================
Topic: Creating Snowpipe with Happiness Dataset
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Complete Snowpipe setup from scratch
- Auto-ingest with Azure Event Grid
- Happiness dataset loading example
- Pipe status monitoring
- Real-world data loading scenario
===========================================
*/

-- Deepak's Note: This is a complete end-to-end Snowpipe example!
-- Loading World Happiness Report data automatically from Azure


-- ========================================
-- SETUP: CREATE DATABASE AND SCHEMA
-- ========================================

-- Deepak's setup: Create dedicated database for Snowpipe
CREATE OR REPLACE DATABASE deepak_snowpipe_db;

USE DATABASE deepak_snowpipe_db;

CREATE OR REPLACE SCHEMA public;

USE SCHEMA public;


-- ========================================
-- STEP 1: CREATE DESTINATION TABLE
-- ========================================

-- Deepak's happiness table with comprehensive columns
CREATE OR REPLACE TABLE happiness (
  country_name VARCHAR(100),
  regional_indicator VARCHAR(100),
  ladder_score NUMBER(4,3),
  standard_error NUMBER(4,3),
  upperwhisker NUMBER(4,3),
  lowerwhisker NUMBER(4,3),
  logged_gdp NUMBER(5,3),
  social_support NUMBER(5,3),
  healthy_life_expectancy NUMBER(5,2),
  freedom_to_make_life_choices NUMBER(5,3),
  generosity NUMBER(6,3),
  perceptions_of_corruption NUMBER(5,3),
  ladder_score_in_dystopia NUMBER(5,3),
  explained_by_log_gdp NUMBER(5,3),
  explained_by_social_support NUMBER(5,3),
  explained_by_healthy_life_expectancy NUMBER(5,3),
  explained_by_freedom_to_make_life_choices NUMBER(5,3),
  explained_by_generosity NUMBER(5,3),
  explained_by_perceptions_of_corruption NUMBER(5,3),
  dystopia_residual NUMBER(5,3),
  load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Deepak's observation: Comprehensive happiness metrics table ready!


-- ========================================
-- STEP 2: CREATE STORAGE INTEGRATION
-- ========================================

-- Deepak's Azure storage integration
CREATE OR REPLACE STORAGE INTEGRATION deepak_azure_happiness_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE
  AZURE_TENANT_ID = 'your-tenant-id-here'
  STORAGE_ALLOWED_LOCATIONS = ('azure://deepakstorageaccount.blob.core.windows.net/happiness-data/');

-- Deepak's check: Get integration details
DESC STORAGE INTEGRATION deepak_azure_happiness_int;


-- ========================================
-- STEP 3: CREATE NOTIFICATION INTEGRATION
-- ========================================

-- Deepak's notification integration for auto-ingest
CREATE OR REPLACE NOTIFICATION INTEGRATION deepak_happiness_event_int
  ENABLED = TRUE
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
  AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://deepakstorageaccount.queue.core.windows.net/happiness-queue'
  AZURE_TENANT_ID = 'your-tenant-id-here';

-- Deepak's check: Verify notification integration
DESC NOTIFICATION INTEGRATION deepak_happiness_event_int;


-- ========================================
-- STEP 4: CREATE FILE FORMAT
-- ========================================

-- Deepak's CSV file format for happiness data
CREATE OR REPLACE FILE FORMAT deepak_snowpipe_db.public.csv_happiness_format
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  COMPRESSION = AUTO;

-- Deepak's observation: File format configured for happiness CSV files


-- ========================================
-- STEP 5: CREATE EXTERNAL STAGE
-- ========================================

-- Deepak's Azure stage for happiness data
CREATE OR REPLACE STAGE deepak_snowpipe_db.public.stage_azure_happiness
  STORAGE_INTEGRATION = deepak_azure_happiness_int
  URL = 'azure://deepakstorageaccount.blob.core.windows.net/happiness-data/'
  FILE_FORMAT = deepak_snowpipe_db.public.csv_happiness_format;

-- Deepak's check: List files in stage
LIST @deepak_snowpipe_db.public.stage_azure_happiness;


-- ========================================
-- STEP 6: CREATE SNOWPIPE
-- ========================================

-- Deepak's Snowpipe with auto-ingest enabled
CREATE OR REPLACE PIPE deepak_snowpipe_db.public.azure_happiness_pipe
  AUTO_INGEST = TRUE
  INTEGRATION = 'deepak_happiness_event_int'
  COMMENT = 'Deepak: Auto-loading happiness data from Azure'
  AS
  COPY INTO deepak_snowpipe_db.public.happiness
  FROM @deepak_snowpipe_db.public.stage_azure_happiness
  FILE_FORMAT = (FORMAT_NAME = deepak_snowpipe_db.public.csv_happiness_format)
  ON_ERROR = 'CONTINUE';

-- Deepak's observation: Pipe created and listening for Azure events!


-- ========================================
-- STEP 7: MONITOR PIPE STATUS
-- ========================================

-- Deepak's pipe status check
SELECT SYSTEM$PIPE_STATUS('deepak_snowpipe_db.public.azure_happiness_pipe');

-- Deepak's observation: Returns JSON like:
/*
{
  "executionState": "RUNNING",
  "pendingFileCount": 0,
  "notificationChannelName": "queue-url",
  "lastReceivedMessageTimestamp": "timestamp",
  "lastForwardedMessageTimestamp": "timestamp"
}
*/


-- ========================================
-- STEP 8: CHECK COPY HISTORY
-- ========================================

-- Deepak's copy history for this pipe
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'HAPPINESS',
  START_TIME => DATEADD(HOURS, -24, CURRENT_TIMESTAMP())
))
ORDER BY LAST_LOAD_TIME DESC;

-- Deepak's observation: Shows files loaded, rows inserted, errors


-- ========================================
-- STEP 9: VERIFY LOADED DATA
-- ========================================

-- Deepak's data verification
SELECT * FROM deepak_snowpipe_db.public.happiness
ORDER BY load_timestamp DESC
LIMIT 10;

-- Deepak's sample happiness data:
-- country_name | regional_indicator    | ladder_score | logged_gdp | social_support | healthy_life_expectancy
-- Finland      | Western Europe        | 7.842        | 10.775     | 0.954          | 72.0
-- Denmark      | Western Europe        | 7.620        | 10.933     | 0.954          | 72.7
-- Switzerland  | Western Europe        | 7.571        | 11.117     | 0.942          | 74.4
-- Iceland      | Western Europe        | 7.554        | 10.878     | 0.983          | 73.0
-- Netherlands  | Western Europe        | 7.464        | 10.932     | 0.942          | 72.4
-- Norway       | Western Europe        | 7.392        | 11.053     | 0.954          | 73.3
-- Sweden       | Western Europe        | 7.363        | 10.867     | 0.934          | 72.7
-- Luxembourg   | Western Europe        | 7.324        | 11.647     | 0.908          | 72.6
-- New Zealand  | North America/ANZ     | 7.277        | 10.643     | 0.948          | 73.2
-- Austria      | Western Europe        | 7.268        | 10.906     | 0.934          | 72.4

-- Deepak's observation: World Happiness data loaded successfully!


-- ========================================
-- STEP 10: ANALYZE HAPPINESS TRENDS
-- ========================================

-- Deepak's analysis: Top 10 happiest countries
SELECT
  country_name,
  regional_indicator,
  ladder_score,
  logged_gdp,
  social_support,
  healthy_life_expectancy,
  freedom_to_make_life_choices
FROM deepak_snowpipe_db.public.happiness
ORDER BY ladder_score DESC
LIMIT 10;

-- Deepak's analysis: Happiness by region
SELECT
  regional_indicator,
  COUNT(*) as country_count,
  ROUND(AVG(ladder_score), 3) as avg_happiness,
  ROUND(AVG(logged_gdp), 3) as avg_gdp,
  ROUND(AVG(social_support), 3) as avg_social_support
FROM deepak_snowpipe_db.public.happiness
GROUP BY regional_indicator
ORDER BY avg_happiness DESC;

-- Deepak's observation: Western Europe has highest average happiness!


-- ========================================
-- STEP 11: REFRESH PIPE MANUALLY
-- ========================================

-- Deepak's manual refresh (if needed)
ALTER PIPE deepak_snowpipe_db.public.azure_happiness_pipe REFRESH;

-- Deepak's observation: Forces pipe to check for new files


-- ========================================
-- STEP 12: PAUSE AND RESUME PIPE
-- ========================================

-- Deepak's pause pipe
ALTER PIPE deepak_snowpipe_db.public.azure_happiness_pipe
  SET PIPE_EXECUTION_PAUSED = TRUE;

-- Deepak's check: Verify paused
SELECT SYSTEM$PIPE_STATUS('deepak_snowpipe_db.public.azure_happiness_pipe');

-- Deepak's resume pipe
ALTER PIPE deepak_snowpipe_db.public.azure_happiness_pipe
  SET PIPE_EXECUTION_PAUSED = FALSE;


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. COMPLETE SNOWPIPE WORKFLOW
   - Create destination table
   - Set up storage integration
   - Configure notification integration
   - Define file format
   - Create external stage
   - Build pipe with AUTO_INGEST
   - Monitor and verify

2. AZURE INTEGRATION COMPONENTS
   - Storage Integration: Secure access to Azure Blob
   - Notification Integration: Azure Event Grid events
   - Storage Queue: Event notification channel
   - Tenant ID: Azure AD authentication

3. AUTO-INGEST MECHANISM
   - Azure Event Grid detects new files
   - Sends notification to Storage Queue
   - Snowpipe receives event
   - Triggers COPY INTO automatically
   - No manual intervention needed

4. PIPE STATUS MONITORING
   - executionState: RUNNING/PAUSED
   - pendingFileCount: Files waiting
   - notificationChannelName: Event queue
   - lastReceivedMessageTimestamp: Last event
   - lastForwardedMessageTimestamp: Last processed

5. FILE FORMAT CONSIDERATIONS
   - SKIP_HEADER: Skip CSV header row
   - NULL_IF: Define null values
   - FIELD_OPTIONALLY_ENCLOSED_BY: Handle quotes
   - COMPRESSION: Auto-detect compression
   - EMPTY_FIELD_AS_NULL: Treat empty as null

6. ERROR HANDLING
   - ON_ERROR = 'CONTINUE': Skip bad files
   - ON_ERROR = 'SKIP_FILE': Skip entire file on error
   - ON_ERROR = 'ABORT_STATEMENT': Stop on first error
   - Check COPY_HISTORY for error details

7. COPY HISTORY ANALYSIS
   - Track files loaded
   - Monitor row counts
   - Identify errors
   - Analyze load timestamps
   - Measure processing duration

8. PERFORMANCE OPTIMIZATION
   - Snowpipe uses serverless compute
   - No warehouse required
   - Charged per file loaded
   - Latency typically < 1 minute
   - Scales automatically

9. REAL-WORLD USE CASE
   - Research organizations upload happiness reports
   - Files automatically detected and loaded
   - Data available for immediate analysis
   - Analysts query latest metrics
   - Dashboards update in real-time

10. BEST PRACTICES
    ✅ Use descriptive names for all objects
    ✅ Add comments to pipes
    ✅ Monitor pipe status regularly
    ✅ Check COPY_HISTORY for errors
    ✅ Test with small files first
    ✅ Set appropriate ON_ERROR behavior
    ✅ Use file format objects for reusability
    ✅ Implement proper error handling
    ✅ Document integration setup
    ✅ Monitor costs (per-file charges)

This example demonstrates a complete end-to-end Snowpipe implementation
for loading World Happiness Report data automatically from Azure.
*/


-- ========================================
-- CLEANUP (OPTIONAL - FOR SAFETY)
-- ========================================

-- Deepak's cleanup commands (commented for safety)
-- DROP PIPE IF EXISTS azure_happiness_pipe;
-- DROP STAGE IF EXISTS stage_azure_happiness;
-- DROP FILE FORMAT IF EXISTS csv_happiness_format;
-- DROP NOTIFICATION INTEGRATION IF EXISTS deepak_happiness_event_int;
-- DROP STORAGE INTEGRATION IF EXISTS deepak_azure_happiness_int;
-- DROP TABLE IF EXISTS happiness;
-- DROP DATABASE IF EXISTS deepak_snowpipe_db;


-- ========================================
-- DEEPAK'S FINAL SUMMARY
-- ========================================

/*
This comprehensive example demonstrates:
✅ Complete Snowpipe setup from scratch
✅ Azure cloud integration
✅ Auto-ingest with event notifications
✅ Real-world dataset (World Happiness Report)
✅ Monitoring and troubleshooting
✅ Data analysis queries
✅ Best practices and error handling

Key Steps:
1. Create destination table with appropriate schema
2. Set up storage integration for Azure access
3. Configure notification integration for auto-ingest
4. Create file format for CSV parsing
5. Create external stage pointing to cloud storage
6. Create pipe with AUTO_INGEST = TRUE
7. Monitor pipe status and copy history
8. Query loaded data for insights

Key Learnings:
✅ Snowpipe enables continuous, automated loading
✅ Auto-ingest requires notification integration
✅ Serverless compute (no warehouse needed)
✅ Minimal latency (typically < 1 minute)
✅ Scales automatically
✅ Simplifies data pipelines
✅ Reduces operational overhead

Snowpipe transforms batch loading into continuous streaming,
making data available for analysis within minutes of arrival!

Practiced: February 14, 2026
Status: ✅ Completed - Advanced Snowpipe mastered!
===========================================
*/

