/*
===========================================
DEEPAK'S EXTERNAL STAGES PRACTICE
===========================================
Topic: Creating and Managing External Stages
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- External stages connect to cloud storage (S3, Azure, GCP)
- Can use credentials or storage integrations
- File formats define how to parse data
- Stages enable data loading from external sources
- Support for multi-cloud architecture
===========================================
*/

-- Deepak's Note: Stages are the bridge between Snowflake and external storage
-- Essential for loading data from S3, Azure Blob, or Google Cloud Storage


-- ========================================
-- SETUP: CREATE MANAGEMENT DATABASE
-- ========================================

-- Deepak's scenario: Central database for managing all stage objects
CREATE OR REPLACE DATABASE deepak_mgmt_db
COMMENT = 'Deepak - Database for managing stages, file formats, and integrations';

CREATE OR REPLACE SCHEMA deepak_mgmt_db.external_stages
COMMENT = 'Deepak - Schema for external stage objects';

USE SCHEMA deepak_mgmt_db.external_stages;


-- ========================================
-- AWS S3 EXTERNAL STAGE
-- ========================================

-- Deepak's learning: Create stage with AWS credentials
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.deepak_aws_stage
    URL = 's3://deepak-snowflake-data/raw-files/'
    CREDENTIALS = (
        AWS_KEY_ID = 'AKIAIOSFODNN7EXAMPLE'
        AWS_SECRET_KEY = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
    )
    COMMENT = 'Deepak - AWS S3 stage for raw data files';

-- Deepak's note: In production, use storage integrations instead of hardcoded credentials


-- Describe the stage to see configuration
DESC STAGE deepak_mgmt_db.external_stages.deepak_aws_stage;

-- Deepak's observation: Shows URL, credentials (masked), file format, etc.


-- ========================================
-- UPDATE STAGE CREDENTIALS
-- ========================================

-- Deepak's scenario: Rotate AWS credentials for security
ALTER STAGE deepak_mgmt_db.external_stages.deepak_aws_stage
    SET CREDENTIALS = (
        AWS_KEY_ID = 'AKIAI44QH8DHBEXAMPLE'
        AWS_SECRET_KEY = 'je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY'
    );

-- Deepak's learning: Can update credentials without recreating stage


-- ========================================
-- PUBLIC S3 BUCKET (NO CREDENTIALS)
-- ========================================

-- Deepak's scenario: Access publicly accessible S3 bucket
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.deepak_public_stage
    URL = 's3://deepak-public-datasets/csv-files/'
    COMMENT = 'Deepak - Public S3 bucket, no credentials needed';

-- Deepak's note: Public buckets don't require credentials


-- List files in the stage
LIST @deepak_mgmt_db.external_stages.deepak_public_stage;

-- Deepak's observation: Shows all files available in the S3 bucket


-- ========================================
-- LOAD DATA FROM STAGE
-- ========================================

-- Deepak's scenario: Load order data from S3 stage
COPY INTO deepak_sales_db.public.orders
    FROM @deepak_mgmt_db.external_stages.deepak_public_stage
    FILE_FORMAT = (
        TYPE = CSV
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    )
    PATTERN = '.*[Oo]rder.*\\.csv'
    ON_ERROR = 'CONTINUE';

-- Deepak's learning: PATTERN filters files by regex, ON_ERROR handles bad records


-- ========================================
-- AZURE BLOB STORAGE STAGE
-- ========================================

-- Deepak's scenario: Create file format for Azure data
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.public.deepak_azure_csv
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    COMMENT = 'Deepak - CSV format for Azure blob storage';


-- Create Azure stage with storage integration
CREATE OR REPLACE STAGE deepak_mgmt_db.public.deepak_azure_stage
    STORAGE_INTEGRATION = deepak_azure_integration
    URL = 'azure://deepaksnowstorage.blob.core.windows.net/customer-data/'
    FILE_FORMAT = deepak_mgmt_db.public.deepak_azure_csv
    COMMENT = 'Deepak - Azure Blob Storage stage for customer data';

-- Deepak's note: Storage integrations are more secure than hardcoded credentials
-- They use Azure service principals or AWS IAM roles


-- List files in Azure stage
LIST @deepak_mgmt_db.public.deepak_azure_stage;

-- Deepak's observation: Can access Azure Blob Storage just like S3


-- ========================================
-- GOOGLE CLOUD STORAGE STAGE
-- ========================================

-- Deepak's scenario: Create file format for GCP data
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.public.deepak_gcp_csv
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    COMPRESSION = 'AUTO'
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    COMMENT = 'Deepak - CSV format for Google Cloud Storage';


-- Create GCP stage with storage integration
CREATE OR REPLACE STAGE deepak_mgmt_db.public.deepak_gcp_stage
    STORAGE_INTEGRATION = deepak_gcp_integration
    URL = 'gcs://deepak-snowflake-bucket/analytics-data/'
    FILE_FORMAT = deepak_mgmt_db.public.deepak_gcp_csv
    COMMENT = 'Deepak - Google Cloud Storage stage for analytics data';

-- Deepak's learning: Snowflake supports multi-cloud architecture seamlessly


-- List files in GCP stage
LIST @deepak_mgmt_db.public.deepak_gcp_stage;

-- Deepak's observation: Same LIST command works across all cloud providers


/*
DEEPAK'S EXTERNAL STAGES SUMMARY:
=================================

Stage Types:
1. External Stage - Points to cloud storage (S3, Azure, GCP)
2. Internal Stage - Snowflake-managed storage
3. Table Stage - Automatically created with each table
4. User Stage - Personal stage for each user

Cloud Provider Support:
✅ AWS S3 (s3://)
✅ Azure Blob Storage (azure://)
✅ Google Cloud Storage (gcs://)

Authentication Methods:
1. Credentials (AWS keys, Azure SAS tokens)
2. Storage Integrations (IAM roles, service principals)
3. Public access (no credentials)

Best Practice: Use Storage Integrations
- More secure (no hardcoded credentials)
- Easier credential rotation
- Better access control
- Audit trail

Stage Components:
- URL: Cloud storage location
- CREDENTIALS or STORAGE_INTEGRATION: Authentication
- FILE_FORMAT: How to parse files
- ENCRYPTION: Optional encryption settings
- COMMENT: Documentation

File Format Options:
- TYPE: CSV, JSON, PARQUET, AVRO, ORC, XML
- FIELD_DELIMITER: Column separator
- SKIP_HEADER: Skip header rows
- COMPRESSION: AUTO, GZIP, BZIP2, etc.
- NULL_IF: Define null values
- FIELD_OPTIONALLY_ENCLOSED_BY: Quote character

Common Operations:
✅ CREATE STAGE - Define external stage
✅ ALTER STAGE - Update configuration
✅ DESC STAGE - View stage details
✅ LIST @stage - List files in stage
✅ COPY INTO - Load data from stage
✅ DROP STAGE - Remove stage

Multi-Cloud Architecture Benefits:
✅ Avoid vendor lock-in
✅ Use best services from each provider
✅ Geographic data residency
✅ Disaster recovery across clouds
✅ Cost optimization

Real-World Example:
-- Daily ETL from S3
COPY INTO production_table
FROM @deepak_aws_stage
FILE_FORMAT = deepak_csv_format
PATTERN = '.*daily_export_.*\\.csv'
ON_ERROR = 'SKIP_FILE';

-- Monitor load history
SELECT * FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'PRODUCTION_TABLE',
        START_TIME => DATEADD(HOURS, -24, CURRENT_TIMESTAMP())
    )
);

Security Best Practices:
1. Use storage integrations, not credentials
2. Rotate credentials regularly
3. Use encryption in transit and at rest
4. Implement least privilege access
5. Monitor stage access with query history
6. Use separate stages for dev/test/prod

Cost Optimization:
- Use PATTERN to load only needed files
- Compress files before uploading
- Use Parquet for better compression
- Clean up old files in cloud storage
- Monitor data transfer costs

Troubleshooting:
- LIST @stage - Verify files are accessible
- DESC STAGE - Check configuration
- VALIDATION_MODE = 'RETURN_ERRORS' - Test before loading
- Check cloud provider permissions
- Verify network connectivity

Next Steps:
- Learn about storage integrations
- Explore different file formats
- Implement error handling
- Set up automated data pipelines
- Monitor stage performance

Practiced: February 2026
Status: ✅ Completed - Understanding external stages
*/
