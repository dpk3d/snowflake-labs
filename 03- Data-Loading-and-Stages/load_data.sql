/*
===========================================
DEEPAK'S DATA LOADING PRACTICE
===========================================
Topic: Loading Data from External Stages
Date Practiced: February 1, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Query staged files before loading to validate structure
- Use $1, $2, etc. to reference columns in staged files
- COPY INTO loads data from stages into tables
- Load history helps track and troubleshoot data loads
===========================================
*/

-- Deepak's Note: This demonstrates loading data from Azure Blob Storage
-- First, we query the staged files to understand the structure


-- ========================================
-- STEP 1: QUERY STAGED FILES
-- ========================================

-- Deepak's learning: Preview data in stage before loading
-- $1, $2, etc. represent columns in the CSV file
SELECT
$1 AS country,
$2 AS region,
$3 AS ladder_score,
$4 AS std_error,
$5 AS upper_whisker,
$6 AS lower_whisker,
$7 AS logged_gdp,
$8 AS social_support,
$9 AS life_expectancy,
$10 AS freedom,
$11 AS generosity,
$12 AS corruption,
$13 AS dystopia_score,
$14 AS gdp_explained,
$15 AS social_explained,
$16 AS health_explained,
$17 AS freedom_explained,
$18 AS generosity_explained,
$19 AS corruption_explained,
$20 AS dystopia_residual
FROM @deepak_data_db.public.azure_stage
LIMIT 10;

-- Deepak's observation: This helps validate file structure before loading


-- ========================================
-- STEP 2: CREATE TARGET TABLE
-- ========================================

-- Deepak's scenario: Creating table for World Happiness Report data
CREATE OR REPLACE TABLE deepak_analytics_db.public.world_happiness (
    country_name VARCHAR(100),
    regional_indicator VARCHAR(50),
    ladder_score NUMBER(4,3),
    standard_error NUMBER(4,3),
    upper_whisker NUMBER(4,3),
    lower_whisker NUMBER(4,3),
    logged_gdp NUMBER(5,3),
    social_support NUMBER(4,3),
    healthy_life_expectancy NUMBER(5,3),
    freedom_to_make_life_choices NUMBER(4,3),
    generosity NUMBER(4,3),
    perceptions_of_corruption NUMBER(4,3),
    ladder_score_in_dystopia NUMBER(4,3),
    explained_by_log_gdp_per_capita NUMBER(4,3),
    explained_by_social_support NUMBER(4,3),
    explained_by_healthy_life_expectancy NUMBER(4,3),
    explained_by_freedom_to_make_life_choices NUMBER(4,3),
    explained_by_generosity NUMBER(4,3),
    explained_by_perceptions_of_corruption NUMBER(4,3),
    dystopia_residual NUMBER(4,3),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Deepak - World Happiness Report data for analytics';

-- Deepak's note: Added load_timestamp to track when data was loaded


-- ========================================
-- STEP 3: LOAD DATA INTO TABLE
-- ========================================

-- Deepak's learning: COPY INTO loads data from stage to table
COPY INTO deepak_analytics_db.public.world_happiness
FROM @deepak_data_db.public.azure_stage
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Deepak's observation: ON_ERROR = 'CONTINUE' skips bad records
-- Alternative: 'ABORT_STATEMENT' stops on first error


-- Verify loaded data
SELECT * FROM deepak_analytics_db.public.world_happiness
ORDER BY ladder_score DESC
LIMIT 20;

-- Deepak's analysis: Top 20 happiest countries loaded successfully!


-- ========================================
-- EXAMPLE 2: LOADING MOVIE DATA FROM S3
-- ========================================

-- Deepak's scenario: Loading Netflix movie catalog from AWS S3
CREATE OR REPLACE TABLE deepak_analytics_db.public.streaming_content (
  show_id STRING,
  content_type STRING,
  title STRING,
  director STRING,
  cast_members STRING,
  country STRING,
  date_added STRING,
  release_year STRING,
  rating STRING,
  duration STRING,
  genre STRING,
  description STRING,
  loaded_by STRING DEFAULT 'Deepak',
  load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Deepak - Streaming platform content catalog';


-- Deepak's learning: Create reusable file format object
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.file_formats.csv_standard
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    COMMENT = 'Deepak - Standard CSV format for data loading';

-- Deepak's note: File format objects are reusable across multiple stages


-- Create external stage pointing to S3 bucket
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.s3_movies
    URL = 's3://deepak-snowflake-data/movies/'
    STORAGE_INTEGRATION = deepak_s3_integration
    FILE_FORMAT = deepak_mgmt_db.file_formats.csv_standard
    COMMENT = 'Deepak - S3 stage for movie data';

-- Deepak's observation: Stage combines storage location + file format


-- Load data from S3 stage into table
COPY INTO deepak_analytics_db.public.streaming_content
    FROM @deepak_mgmt_db.external_stages.s3_movies
    PATTERN = '.*movies.*[.]csv';

-- Deepak's learning: PATTERN filters which files to load


-- Deepak's experiment: Handling quoted fields in CSV
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.file_formats.csv_with_quotes
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    COMMENT = 'Deepak - CSV format for fields with quotes';

-- Deepak's note: FIELD_OPTIONALLY_ENCLOSED_BY handles quoted strings
-- Useful when data contains commas within fields


-- Verify loaded movie data
SELECT * FROM deepak_analytics_db.public.streaming_content
WHERE content_type = 'Movie'
ORDER BY release_year DESC
LIMIT 50;

-- Deepak's analysis: Recent movies loaded successfully!



-- ========================================
-- MONITORING: QUERY LOAD HISTORY
-- ========================================

-- Deepak's learning: Track all data loads within current database
USE deepak_analytics_db;

SELECT * FROM information_schema.load_history
ORDER BY last_load_time DESC;

-- Deepak's observation: Shows recent loads, row counts, and errors


-- Query global load history across all databases
SELECT
    table_catalog_name AS database_name,
    table_schema_name AS schema_name,
    table_name,
    file_name,
    row_count,
    row_parsed,
    error_count,
    error_limit,
    status,
    last_load_time
FROM snowflake.account_usage.load_history
ORDER BY last_load_time DESC
LIMIT 100;

-- Deepak's note: account_usage provides account-wide visibility


-- Filter load history for specific table
SELECT * FROM snowflake.account_usage.load_history
WHERE schema_name = 'PUBLIC'
  AND table_name = 'WORLD_HAPPINESS'
ORDER BY last_load_time DESC;

-- Deepak's use case: Troubleshooting specific table loads


-- Find failed loads with errors
SELECT
    table_name,
    file_name,
    row_count,
    error_count,
    first_error_message,
    last_load_time
FROM snowflake.account_usage.load_history
WHERE schema_name = 'PUBLIC'
  AND table_name = 'STREAMING_CONTENT'
  AND error_count > 0
ORDER BY last_load_time DESC;

-- Deepak's learning: Identify and fix data quality issues


-- Find loads from previous days
SELECT
    table_name,
    SUM(row_count) AS total_rows_loaded,
    COUNT(*) AS number_of_loads,
    MAX(last_load_time) AS most_recent_load
FROM snowflake.account_usage.load_history
WHERE DATE(last_load_time) <= DATEADD(days, -1, CURRENT_DATE)
GROUP BY table_name
ORDER BY total_rows_loaded DESC;

-- Deepak's analysis: Historical load patterns and volumes

-- ========================================
-- EXAMPLE 3: LOADING FROM GOOGLE CLOUD STORAGE
-- ========================================

-- Deepak's scenario: Loading data from GCP bucket
SELECT
$1 AS country, $2 AS region, $3 AS ladder_score, $4 AS std_error,
$5 AS upper_whisker, $6 AS lower_whisker, $7 AS logged_gdp,
$8 AS social_support, $9 AS life_expectancy, $10 AS freedom,
$11 AS generosity, $12 AS corruption, $13 AS dystopia_score,
$14 AS gdp_explained, $15 AS social_explained, $16 AS health_explained,
$17 AS freedom_explained, $18 AS generosity_explained,
$19 AS corruption_explained, $20 AS dystopia_residual
FROM @deepak_data_db.public.gcp_stage
LIMIT 10;

-- Deepak's note: Same data, different cloud provider


-- Create table for GCP data load
CREATE OR REPLACE TABLE deepak_analytics_db.public.happiness_gcp (
    country_name VARCHAR(100),
    regional_indicator VARCHAR(50),
    ladder_score NUMBER(4,3),
    standard_error NUMBER(4,3),
    upper_whisker NUMBER(4,3),
    lower_whisker NUMBER(4,3),
    logged_gdp NUMBER(5,3),
    social_support NUMBER(4,3),
    healthy_life_expectancy NUMBER(5,3),
    freedom_to_make_life_choices NUMBER(4,3),
    generosity NUMBER(4,3),
    perceptions_of_corruption NUMBER(4,3),
    ladder_score_in_dystopia NUMBER(4,3),
    explained_by_log_gdp_per_capita NUMBER(4,3),
    explained_by_social_support NUMBER(4,3),
    explained_by_healthy_life_expectancy NUMBER(4,3),
    explained_by_freedom_to_make_life_choices NUMBER(4,3),
    explained_by_generosity NUMBER(4,3),
    explained_by_perceptions_of_corruption NUMBER(4,3),
    dystopia_residual NUMBER(4,3)
)
COMMENT = 'Deepak - Happiness data loaded from GCP';


-- Load from GCP stage
COPY INTO deepak_analytics_db.public.happiness_gcp
FROM @deepak_data_db.public.gcp_stage;

SELECT * FROM deepak_analytics_db.public.happiness_gcp
ORDER BY ladder_score DESC;


-- ========================================
-- DATA UNLOADING: EXPORT TO CLOUD STORAGE
-- ========================================

-- Deepak's learning: Unload data from Snowflake to external storage
USE ROLE ACCOUNTADMIN;
USE DATABASE deepak_data_db;


-- Create GCP storage integration
CREATE OR REPLACE STORAGE INTEGRATION deepak_gcp_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = GCS
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://deepak-snowflake-bucket/exports',
                                'gcs://deepak-snowflake-bucket/backups')
  COMMENT = 'Deepak - GCP integration for data exports';

-- Deepak's note: Storage integration secures cloud storage access


-- Create file format for exports
CREATE OR REPLACE FILE FORMAT deepak_data_db.public.export_csv_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    COMPRESSION = GZIP
    COMMENT = 'Deepak - Compressed CSV format for exports';

-- Deepak's observation: GZIP compression reduces storage costs


-- Create stage for exports
CREATE OR REPLACE STAGE deepak_data_db.public.gcp_export_stage
    STORAGE_INTEGRATION = deepak_gcp_integration
    URL = 'gcs://deepak-snowflake-bucket/exports/happiness'
    FILE_FORMAT = export_csv_format
    COMMENT = 'Deepak - GCP stage for exporting data';


-- Update allowed locations if needed
ALTER STORAGE INTEGRATION deepak_gcp_integration
SET STORAGE_ALLOWED_LOCATIONS = ('gcs://deepak-snowflake-bucket/exports',
                                  'gcs://deepak-snowflake-bucket/backups',
                                  'gcs://deepak-snowflake-bucket/archives');

-- Deepak's learning: Can modify integration after creation


-- Verify data before export
SELECT COUNT(*) AS total_records,
       MIN(ladder_score) AS min_happiness,
       MAX(ladder_score) AS max_happiness,
       AVG(ladder_score) AS avg_happiness
FROM deepak_analytics_db.public.happiness_gcp;


-- Unload data to GCP bucket
COPY INTO @deepak_data_db.public.gcp_export_stage
FROM deepak_analytics_db.public.happiness_gcp
OVERWRITE = TRUE
SINGLE = FALSE
MAX_FILE_SIZE = 104857600;  -- 100 MB per file

-- Deepak's observation: Data exported to GCP for sharing or archival


/*
DEEPAK'S DATA LOADING SUMMARY:
==============================

Multi-Cloud Data Loading:
✅ Azure Blob Storage - world_happiness table
✅ AWS S3 - streaming_content table
✅ Google Cloud Storage - happiness_gcp table

Key Concepts Mastered:
1. Query staged files before loading ($1, $2 notation)
2. Create reusable file format objects
3. Create external stages with storage integrations
4. Use COPY INTO to load data
5. Monitor loads with load_history
6. Unload data back to cloud storage

File Format Options:
- SKIP_HEADER: Skip header row
- NULL_IF: Define null value representations
- EMPTY_FIELD_AS_NULL: Treat empty fields as NULL
- FIELD_OPTIONALLY_ENCLOSED_BY: Handle quoted fields
- COMPRESSION: Reduce storage costs

Load Monitoring Best Practices:
- Check information_schema.load_history for recent loads
- Use account_usage.load_history for historical analysis
- Filter by error_count > 0 to find failed loads
- Track row counts and load times

Data Unloading Use Cases:
- Export for external analytics tools
- Archive historical data
- Share data with partners
- Backup to cloud storage

Practiced: February 2026
Status: ✅ Completed - Multi-cloud data loading mastered
*/