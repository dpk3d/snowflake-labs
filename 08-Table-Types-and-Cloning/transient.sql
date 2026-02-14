/*
===========================================
DEEPAK'S TRANSIENT TABLES PRACTICE
===========================================
Topic: Transient Tables and Storage Optimization
Date Practiced: February 13, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Transient tables have NO fail-safe protection
- Lower storage costs than permanent tables
- Time travel: 0-1 day (configurable)
- Perfect for staging and temporary data
- Can be cloned (unlike temporary tables)
===========================================
*/

-- Deepak's Note: Transient tables balance cost and functionality
-- No fail-safe = lower costs, but less data protection


-- ========================================
-- CREATE TRANSIENT DATABASE
-- ========================================

CREATE OR REPLACE TRANSIENT DATABASE deepak_transient_db
COMMENT = 'Deepak - Database for transient table testing';

USE DATABASE deepak_transient_db;


-- ========================================
-- CREATE TRANSIENT TABLE
-- ========================================

-- Deepak's scenario: Large staging table for ETL processing
CREATE OR REPLACE TRANSIENT TABLE deepak_transient_db.public.staging_customers (
   customer_id INT,
   first_name STRING,
   last_name STRING,
   email STRING,
   region STRING,
   job_title STRING,
   phone STRING
)
COMMENT = 'Deepak - Transient staging table for customer data';

-- Deepak's learning: Transient tables are great for large temporary datasets


-- Load data with CROSS JOIN to create large dataset
INSERT INTO deepak_transient_db.public.staging_customers
SELECT
    t1.customer_id,
    t1.full_name AS first_name,
    'TestLast' AS last_name,
    t1.email,
    t1.region,
    'Staging' AS job_title,
    t1.phone
FROM deepak_sales_db.public.customers t1
CROSS JOIN (SELECT customer_id FROM deepak_sales_db.public.customers LIMIT 10) t2;

-- Deepak's observation: Created large dataset for storage testing

SHOW TABLES;


-- ========================================
-- MONITOR STORAGE METRICS
-- ========================================

-- Deepak's learning: Query storage usage across all tables
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'DEEPAK_TRANSIENT_DB'
ORDER BY active_bytes DESC;


-- Detailed storage analysis
SELECT
    ID,
    TABLE_NAME,
    TABLE_SCHEMA,
    TABLE_CATALOG,
    ACTIVE_BYTES / (1024*1024*1024) AS ACTIVE_STORAGE_GB,
    TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_STORAGE_GB,
    FAILSAFE_BYTES / (1024*1024*1024) AS FAILSAFE_STORAGE_GB,
    IS_TRANSIENT,
    DELETED,
    TABLE_CREATED,
    TABLE_DROPPED,
    TABLE_ENTERED_FAILSAFE
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG = 'DEEPAK_TRANSIENT_DB'
ORDER BY TABLE_CREATED DESC;

-- Deepak's observation: FAILSAFE_BYTES = 0 for transient tables!
-- This is where cost savings come from


-- ========================================
-- RETENTION TIME MANAGEMENT
-- ========================================

-- Deepak's experiment: Set retention time to 0 (no time travel)
ALTER TABLE deepak_transient_db.public.staging_customers
SET DATA_RETENTION_TIME_IN_DAYS = 0;

-- Deepak's note: Retention = 0 means no time travel, maximum cost savings


-- Test DROP and UNDROP
DROP TABLE deepak_transient_db.public.staging_customers;

-- Deepak's learning: Can still UNDROP even with 0 retention
UNDROP TABLE deepak_transient_db.public.staging_customers;

SHOW TABLES;


-- ========================================
-- TRANSIENT SCHEMA
-- ========================================

-- Deepak's scenario: Create transient schema for all staging tables
CREATE OR REPLACE TRANSIENT SCHEMA deepak_transient_db.staging_schema
COMMENT = 'Deepak - Transient schema for ETL staging';

SHOW SCHEMAS;


-- Tables in transient schema inherit transient property
CREATE OR REPLACE TABLE deepak_transient_db.staging_schema.etl_staging (
   record_id INT,
   first_name STRING,
   last_name STRING,
   email STRING,
   department STRING,
   job_title STRING,
   phone STRING,
   processed_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Deepak - ETL staging table in transient schema';


-- Deepak's learning: Can still set custom retention for individual tables
ALTER TABLE deepak_transient_db.staging_schema.etl_staging
SET DATA_RETENTION_TIME_IN_DAYS = 2;

-- Deepak's note: 2 days of time travel for debugging ETL issues

SHOW TABLES IN SCHEMA deepak_transient_db.staging_schema;


/*
DEEPAK'S TRANSIENT TABLES INSIGHTS:
===================================

Key Characteristics:
✅ No fail-safe protection (7-day recovery period)
✅ Time travel: 0-1 day (configurable)
✅ Lower storage costs than permanent tables
✅ Can be cloned (unlike temporary tables)
✅ Persist across sessions (unlike temporary tables)
✅ Can be shared
✅ Suitable for staging and ETL

Storage Cost Comparison:
┌──────────────────┬────────────┬────────────┬────────────┐
│ Table Type       │ Active     │ Time Travel│ Fail-Safe  │
├──────────────────┼────────────┼────────────┼────────────┤
│ Permanent        │ ✓ Charged  │ ✓ Charged  │ ✓ Charged  │
│ Transient        │ ✓ Charged  │ ✓ Charged  │ ✗ FREE     │
│ Temporary        │ ✓ Charged  │ ✓ Charged  │ ✗ FREE     │
└──────────────────┴────────────┴────────────┴────────────┘

Fail-Safe Savings:
- Permanent: 7 days fail-safe storage
- Transient: 0 days fail-safe storage
- Savings: ~7 days of storage costs

When to Use Transient Tables:
✅ ETL staging tables
✅ Intermediate processing results
✅ Data that can be recreated
✅ Large temporary datasets
✅ Development and testing
✅ Data with external backups

When NOT to Use:
❌ Critical business data
❌ Data without external backups
❌ Compliance-required data
❌ Data needing fail-safe recovery
❌ Long-term historical data

Transient vs Temporary vs Permanent:
┌─────────────────────┬────────────┬────────────┬────────────┐
│ Feature             │ Temporary  │ Transient  │ Permanent  │
├─────────────────────┼────────────┼────────────┼────────────┤
│ Session Scope       │ Yes        │ No         │ No         │
│ Fail-Safe           │ No         │ No         │ Yes        │
│ Time Travel         │ 0-1 day    │ 0-1 day    │ 0-90 days  │
│ Can Clone           │ No         │ Yes        │ Yes        │
│ Can Share           │ No         │ Yes        │ Yes        │
│ Persist Sessions    │ No         │ Yes        │ Yes        │
│ Storage Cost        │ Lowest     │ Medium     │ Highest    │
└─────────────────────┴────────────┴────────────┴────────────┘

Best Practices:
1. Use for staging and ETL intermediate tables
2. Set retention to 0 for maximum savings
3. Keep retention at 1 day for debugging
4. Monitor storage metrics regularly
5. Document transient table purpose
6. Have external backup strategy
7. Use transient schemas for staging areas

Real-World ETL Pipeline:
-- Stage 1: Load raw data (transient)
CREATE TRANSIENT TABLE raw_data AS
SELECT * FROM external_stage;

-- Stage 2: Clean data (transient)
CREATE TRANSIENT TABLE cleaned_data AS
SELECT * FROM raw_data WHERE is_valid = TRUE;

-- Stage 3: Load to production (permanent)
INSERT INTO production_table
SELECT * FROM cleaned_data;

-- Cleanup staging tables
DROP TABLE raw_data;
DROP TABLE cleaned_data;

Cost Optimization:
- Use transient for staging: Save ~30% on storage
- Set retention = 0: Additional savings
- Drop staging tables after ETL: Free up storage
- Monitor with TABLE_STORAGE_METRICS

Practiced: February 2026
Status: ✅ Completed - Understanding transient tables
*/

