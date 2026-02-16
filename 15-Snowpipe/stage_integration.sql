/*
===========================================
DEEPAK'S AZURE STAGE AND INTEGRATION SETUP
===========================================
Topic: Creating Azure Storage Integration and Stage
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Azure storage integration configuration
- Azure Blob Storage connection
- File format creation for CSV
- External stage setup
- Complete Azure pipeline
===========================================
*/

-- Deepak's Note: This demonstrates complete Azure integration setup
-- From storage integration to stage creation!


-- ========================================
-- SETUP: CREATE DATABASE
-- ========================================

-- Deepak's dedicated Snowpipe database
CREATE OR REPLACE DATABASE deepak_snowpipe_db;

USE DATABASE deepak_snowpipe_db;
USE SCHEMA public;


-- ========================================
-- STEP 1: CREATE AZURE STORAGE INTEGRATION
-- ========================================

-- Deepak's Azure storage integration
CREATE OR REPLACE STORAGE INTEGRATION deepak_azure_snowpipe_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE
  AZURE_TENANT_ID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
  STORAGE_ALLOWED_LOCATIONS = (
    'azure://deepakstorageacct.blob.core.windows.net/raw-data/',
    'azure://deepakstorageacct.blob.core.windows.net/processed-data/'
  );

-- Deepak's observation: Integration created for Azure Blob Storage!


-- ========================================
-- STEP 2: DESCRIBE INTEGRATION
-- ========================================

-- Deepak's check: Get Azure consent URL
DESC STORAGE INTEGRATION deepak_azure_snowpipe_int;

-- Deepak's observation: DESC returns:
-- - AZURE_CONSENT_URL: URL to grant Snowflake access
-- - AZURE_MULTI_TENANT_APP_NAME: Snowflake app name
-- Admin must visit consent URL to authorize access!


-- ========================================
-- AZURE SETUP STEPS
-- ========================================

/*
Deepak's Azure Configuration:

1. GET CONSENT URL:
   - Run DESC STORAGE INTEGRATION
   - Copy AZURE_CONSENT_URL value
   - Azure admin must visit this URL

2. GRANT CONSENT:
   - Login as Azure AD admin
   - Review permissions requested
   - Click "Accept" to grant access
   - Snowflake can now access storage

3. VERIFY PERMISSIONS:
   - Storage Blob Data Reader role
   - Applied to storage account
   - Scoped to allowed containers
*/


-- ========================================
-- STEP 3: CREATE FILE FORMAT
-- ========================================

-- Deepak's CSV file format for Azure data
CREATE OR REPLACE FILE FORMAT deepak_snowpipe_db.public.csv_azure_format
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  COMPRESSION = AUTO
  TRIM_SPACE = TRUE;

-- Deepak's observation: Reusable file format for all CSV files!


-- ========================================
-- STEP 4: CREATE EXTERNAL STAGE
-- ========================================

-- Deepak's Azure stage with integration
CREATE OR REPLACE STAGE deepak_snowpipe_db.public.azure_raw_stage
  STORAGE_INTEGRATION = deepak_azure_snowpipe_int
  URL = 'azure://deepakstorageacct.blob.core.windows.net/raw-data/'
  FILE_FORMAT = csv_azure_format;

-- Deepak's observation: Stage uses integration (no embedded credentials!)


-- ========================================
-- STEP 5: LIST FILES IN STAGE
-- ========================================

-- Deepak's file listing
LIST @deepak_snowpipe_db.public.azure_raw_stage;

-- Deepak's sample output:
-- name                          | size  | md5                              | last_modified
-- raw-data/employees_2024.csv   | 15234 | abc123def456...                  | 2024-02-01 10:30:00
-- raw-data/sales_2024.csv       | 28456 | def789ghi012...                  | 2024-02-05 14:20:00
-- raw-data/customers_2024.csv   | 42789 | ghi345jkl678...                  | 2024-02-10 09:15:00


-- ========================================
-- STEP 6: CREATE ADDITIONAL STAGES
-- ========================================

-- Deepak's processed data stage
CREATE OR REPLACE STAGE deepak_snowpipe_db.public.azure_processed_stage
  STORAGE_INTEGRATION = deepak_azure_snowpipe_int
  URL = 'azure://deepakstorageacct.blob.core.windows.net/processed-data/'
  FILE_FORMAT = csv_azure_format;

-- Deepak's observation: Same integration, different container!


-- ========================================
-- STEP 7: TEST DATA LOADING
-- ========================================

-- Deepak's test table
CREATE OR REPLACE TABLE deepak_snowpipe_db.public.test_load (
  id INT,
  name STRING,
  value NUMBER,
  load_date DATE,
  load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Deepak's test COPY
COPY INTO deepak_snowpipe_db.public.test_load
FROM @deepak_snowpipe_db.public.azure_raw_stage/test_data.csv
FILE_FORMAT = csv_azure_format
ON_ERROR = 'CONTINUE';

-- Deepak's verification
SELECT * FROM deepak_snowpipe_db.public.test_load LIMIT 10;


-- ========================================
-- STEP 8: CREATE STAGE WITH INLINE FORMAT
-- ========================================

-- Deepak's stage with inline file format (alternative approach)
CREATE OR REPLACE STAGE deepak_snowpipe_db.public.azure_json_stage
  STORAGE_INTEGRATION = deepak_azure_snowpipe_int
  URL = 'azure://deepakstorageacct.blob.core.windows.net/json-data/'
  FILE_FORMAT = (TYPE = JSON STRIP_OUTER_ARRAY = TRUE);

-- Deepak's observation: Can define format inline or reference named format


-- ========================================
-- STEP 9: SHOW ALL STAGES
-- ========================================

-- Deepak's stage listing
SHOW STAGES IN DATABASE deepak_snowpipe_db;

-- Deepak's filtered view
SHOW STAGES LIKE '%azure%' IN SCHEMA deepak_snowpipe_db.public;


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. AZURE STORAGE INTEGRATION
   - Secure connection to Azure Blob Storage
   - No embedded credentials needed
   - Uses Azure AD authentication
   - Requires admin consent
   - Reusable across stages

2. AZURE TENANT ID
   - Azure Active Directory tenant ID
   - Found in Azure Portal
   - Format: GUID (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
   - Required for authentication
   - Unique per Azure AD instance

3. CONSENT URL WORKFLOW
   - DESC INTEGRATION returns consent URL
   - Azure admin visits URL
   - Reviews permissions requested
   - Grants consent to Snowflake app
   - Snowflake can access storage

4. STORAGE ALLOWED LOCATIONS
   - Whitelist specific containers
   - Security best practice
   - Prevents unauthorized access
   - Supports multiple locations
   - Use full Azure Blob URLs

5. FILE FORMAT OPTIONS
   - Named format: Reusable, centralized
   - Inline format: Quick, one-off usage
   - Named format recommended for production
   - Easier to maintain and update
   - Can be shared across stages

6. STAGE COMPONENTS
   - STORAGE_INTEGRATION: Security credentials
   - URL: Azure Blob container path
   - FILE_FORMAT: How to parse files
   - Optional: DIRECTORY, ENCRYPTION

7. AZURE URL FORMAT
   - azure://storage-account.blob.core.windows.net/container/path/
   - storage-account: Azure storage account name
   - container: Blob container name
   - path: Optional subdirectory

8. TESTING STAGES
   - Use LIST to verify connectivity
   - Test COPY INTO with small file
   - Check error messages carefully
   - Verify Azure permissions
   - Confirm consent was granted

9. MULTIPLE STAGES PATTERN
   - One integration, many stages
   - Different containers/paths
   - Organized by data type
   - Easier access control
   - Simplified management

10. BEST PRACTICES
    ✅ Use descriptive names
    ✅ Document Azure setup steps
    ✅ Test integration before production
    ✅ Use named file formats
    ✅ Limit allowed locations
    ✅ Monitor stage usage
    ✅ Keep Azure credentials secure
    ✅ Regular access reviews

This example shows complete Azure integration from setup to usage!
*/

-- Deepak's Summary:
-- Azure storage integrations provide secure, credential-free access
-- to Azure Blob Storage, perfect for enterprise data pipelines!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Azure integration mastered!
===========================================
*/