/*
===========================================
DEEPAK'S RETENTION PERIOD PRACTICE
===========================================
Topic: Managing Time Travel Retention Periods
Date Practiced: February 13, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Set retention period per table
- Default: 1 day (Standard), up to 90 days (Enterprise)
- Retention affects time travel and storage costs
- Can set at creation or alter later
- Retention = 0 disables time travel
===========================================
*/

-- Deepak's Note: Retention period controls how far back you can time travel!
-- Longer retention = more protection but higher storage costs


-- ========================================
-- VIEW CURRENT RETENTION SETTINGS
-- ========================================

-- Deepak's technique: Show tables with retention info
SHOW TABLES LIKE '%CUSTOMERS%';

-- Deepak's observation: Check DATA_RETENTION_TIME_IN_DAYS column


-- ========================================
-- ALTER RETENTION PERIOD (EXISTING TABLE)
-- ========================================

-- Deepak's scenario: Change retention for existing customers table
ALTER TABLE deepak_analytics_db.public.customers
SET DATA_RETENTION_TIME_IN_DAYS = 7;

-- Deepak's learning: Can modify retention period anytime
-- 7 days = 1 week of time travel protection


-- ========================================
-- SET RETENTION AT TABLE CREATION
-- ========================================

-- Deepak's scenario: Create table with specific retention period
CREATE OR REPLACE TABLE deepak_analytics_db.public.retention_example (
    id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    gender STRING,
    job STRING,
    phone STRING
)
DATA_RETENTION_TIME_IN_DAYS = 14
COMMENT = 'Deepak - Example table with 14-day retention';

-- Deepak's observation: Retention set at creation time
-- 14 days = 2 weeks of time travel


-- ========================================
-- VERIFY RETENTION SETTINGS
-- ========================================

-- Deepak's verification: Check retention for example tables
SHOW TABLES LIKE '%RETENTION%';

-- Deepak's note: Look at DATA_RETENTION_TIME_IN_DAYS column


-- ========================================
-- TEST UNDROP WITH RETENTION
-- ========================================

-- Deepak's experiment: Drop and undrop table
DROP TABLE deepak_analytics_db.public.retention_example;

-- Deepak's observation: Table dropped

-- Deepak's recovery: Undrop the table
UNDROP TABLE deepak_analytics_db.public.retention_example;

-- Deepak's learning: UNDROP works within retention period!
-- Can recover dropped tables


-- ========================================
-- DISABLE TIME TRAVEL (RETENTION = 0)
-- ========================================

-- Deepak's scenario: Disable time travel for temporary data
ALTER TABLE deepak_analytics_db.public.retention_example
SET DATA_RETENTION_TIME_IN_DAYS = 0;

-- Deepak's observation: Retention = 0 means NO time travel
-- ⚠️ Can't recover from mistakes!
-- ⚠️ Can't undrop table!
-- ⚠️ Use only for truly temporary data


-- Deepak's verification: Check updated retention
SHOW TABLES LIKE '%RETENTION%';


/*
DEEPAK'S RETENTION PERIOD INSIGHTS:
====================================

What is Retention Period?

- Number of days Snowflake keeps historical data
- Enables time travel queries
- Allows UNDROP operations
- Affects storage costs
- Configurable per table

Retention Period Limits:

Edition          | Min | Max | Default
-----------------|-----|-----|--------
Standard         | 0   | 1   | 1 day
Enterprise       | 0   | 90  | 1 day
Business Critical| 0   | 90  | 1 day

Transient Tables:
- Max retention: 1 day
- Lower storage costs
- No Fail-Safe

Temporary Tables:
- Max retention: 1 day
- Session-scoped
- No Fail-Safe

Setting Retention Period:

Method 1: At Table Creation
CREATE TABLE table_name (...)
DATA_RETENTION_TIME_IN_DAYS = 7;

Method 2: Alter Existing Table
ALTER TABLE table_name
SET DATA_RETENTION_TIME_IN_DAYS = 14;

Method 3: At Schema Level
CREATE SCHEMA schema_name
DATA_RETENTION_TIME_IN_DAYS = 30;
-- All tables inherit this

Method 4: At Database Level
CREATE DATABASE db_name
DATA_RETENTION_TIME_IN_DAYS = 60;
-- All schemas/tables inherit

Inheritance Hierarchy:
Database → Schema → Table

Table setting overrides schema
Schema setting overrides database

Retention Period Values:

0 Days:
- No time travel
- No UNDROP
- Lowest storage cost
- Use for: Temporary data, staging tables

1 Day (Default):
- 24 hours of time travel
- Can undrop within 24 hours
- Moderate storage cost
- Use for: Most tables

7 Days:
- 1 week of time travel
- Good for weekly processes
- Higher storage cost
- Use for: Important tables

30 Days:
- 1 month of time travel
- Good for monthly processes
- High storage cost
- Use for: Critical tables

90 Days (Max):
- 3 months of time travel
- Maximum protection
- Highest storage cost
- Use for: Compliance, audit tables

Storage Impact:

Retention Period × Data Changes = Storage Cost

Example:
- Table size: 100 GB
- Daily changes: 10 GB
- Retention: 7 days
- Time travel storage: ~70 GB
- Total storage: 170 GB

Cost Considerations:

Short Retention (0-1 days):
✅ Lower storage costs
✅ Faster operations
❌ Less protection
❌ Limited recovery window

Long Retention (30-90 days):
✅ Maximum protection
✅ Long recovery window
✅ Compliance friendly
❌ Higher storage costs
❌ More storage management

Best Practices:

1. Match Retention to Business Needs:
   - Critical data: 30-90 days
   - Important data: 7-14 days
   - Regular data: 1-3 days
   - Temporary data: 0 days

2. Consider Data Change Rate:
   - High change rate → shorter retention
   - Low change rate → longer retention

3. Balance Cost vs Protection:
   - Don't over-retain
   - Don't under-protect

4. Set at Schema/Database Level:
   - Consistent defaults
   - Override for specific tables

5. Document Retention Policies:
   - Why each retention period
   - Review periodically

6. Monitor Storage Costs:
   - Track time travel storage
   - Adjust retention as needed

Retention Period by Use Case:

Use Case                    | Recommended Retention
----------------------------|----------------------
Staging tables              | 0-1 days
ETL intermediate tables     | 1-3 days
Fact tables                 | 7-14 days
Dimension tables            | 14-30 days
Financial data              | 30-90 days
Compliance/audit tables     | 90 days
Temporary analysis          | 0 days
Production tables           | 7-30 days

Real-World Examples:

-- Staging table (no retention needed)
CREATE TABLE staging_orders (...)
DATA_RETENTION_TIME_IN_DAYS = 0;

-- Fact table (1 week retention)
CREATE TABLE fact_sales (...)
DATA_RETENTION_TIME_IN_DAYS = 7;

-- Dimension table (2 weeks retention)
CREATE TABLE dim_customer (...)
DATA_RETENTION_TIME_IN_DAYS = 14;

-- Financial table (90 days for compliance)
CREATE TABLE financial_transactions (...)
DATA_RETENTION_TIME_IN_DAYS = 90;

Checking Retention Settings:

-- Show all tables with retention
SHOW TABLES;

-- Query retention from information schema
SELECT
    table_name,
    retention_time
FROM information_schema.tables
WHERE table_schema = 'PUBLIC'
ORDER BY retention_time DESC;

-- Account-level retention usage
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE time_travel_bytes > 0;

Changing Retention:

-- Increase retention (immediate effect)
ALTER TABLE orders
SET DATA_RETENTION_TIME_IN_DAYS = 30;

-- Decrease retention (gradual effect)
ALTER TABLE orders
SET DATA_RETENTION_TIME_IN_DAYS = 7;
-- Old data beyond 7 days gradually purged

-- Disable time travel
ALTER TABLE temp_table
SET DATA_RETENTION_TIME_IN_DAYS = 0;
-- ⚠️ Immediate effect, can't undo!

UNDROP and Retention:

-- Table can be undropped within retention period
DROP TABLE important_table;

-- Can undrop if within retention period
UNDROP TABLE important_table;

-- After retention period expires
-- ❌ Can't undrop
-- ❌ Data is gone

Retention Period = UNDROP window

Time Travel vs Fail-Safe:

Time Travel:
- User-controlled
- Configurable (0-90 days)
- Can query historical data
- Can restore data
- Costs storage

Fail-Safe:
- Snowflake-controlled
- Fixed 7 days (after time travel)
- Can't query directly
- Snowflake support only
- Costs storage

Total Protection:
Time Travel (90 days) + Fail-Safe (7 days) = 97 days

Monitoring Retention Storage:

-- Time travel storage by table
SELECT
    table_name,
    active_bytes / (1024*1024*1024) AS active_gb,
    time_travel_bytes / (1024*1024*1024) AS time_travel_gb,
    failsafe_bytes / (1024*1024*1024) AS failsafe_gb
FROM snowflake.account_usage.table_storage_metrics
WHERE time_travel_bytes > 0
ORDER BY time_travel_gb DESC;

-- Total time travel storage
SELECT
    SUM(time_travel_bytes) / (1024*1024*1024) AS total_time_travel_gb
FROM snowflake.account_usage.table_storage_metrics;

Deepak's Retention Strategy:

1. Default: 7 days for most tables
2. Critical tables: 30 days
3. Compliance tables: 90 days
4. Staging tables: 0 days
5. Review quarterly
6. Monitor storage costs
7. Adjust as needed

Deepak's Retention Checklist:
✅ Identify table criticality
✅ Set appropriate retention
✅ Document retention policy
✅ Monitor storage costs
✅ Review periodically
✅ Adjust based on usage
✅ Balance cost vs protection

Key Takeaway:
Set retention period based on business needs and
data criticality. Balance protection (longer retention)
with cost (storage). Monitor and adjust regularly!

Practiced: February 2026
Status: ✅ Completed - Retention period management mastered
*/