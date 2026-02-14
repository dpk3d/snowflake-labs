/*
===========================================
DEEPAK'S WAREHOUSE CACHING PRACTICE
===========================================
Topic: Understanding Warehouse Cache vs Result Cache
Date Practiced: February 11, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Warehouse cache stores raw data in SSD
- Different from result cache (query results)
- Warehouse cache persists while warehouse is running
- Cleared when warehouse suspends
- Local to specific warehouse
- Speeds up queries on same data
===========================================
*/

-- Deepak's Note: Snowflake has TWO types of caching!
-- 1. Result Cache (account-wide, 24 hours)
-- 2. Warehouse Cache (per warehouse, while running)


-- ========================================
-- TEST WAREHOUSE CACHE
-- ========================================

-- Deepak's experiment: Query large dataset
-- First run: Reads from cloud storage (slower)
SELECT AVG(c_birth_year) AS avg_birth_year
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Deepak's observation: Query scanned data from cloud storage
-- Check query profile: "Bytes scanned from remote storage"


-- Deepak's technique: Modify query slightly to bypass result cache
-- This tests warehouse cache, not result cache
SELECT AVG(c_birth_year) AS average_birth_year  -- Different alias!
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Deepak's learning: Faster than first run!
-- Warehouse cached the raw data in SSD
-- Check query profile: "Bytes scanned from local cache"


-- ========================================
-- DEMONSTRATE CACHE SHARING ACROSS USERS
-- ========================================

-- Deepak's scenario: Create data scientist role and user
CREATE OR REPLACE ROLE deepak_data_scientist
COMMENT = 'Deepak - Role for data science team';

-- Grant warehouse usage (same warehouse = shared cache!)
GRANT USAGE ON WAREHOUSE deepak_compute_wh TO ROLE deepak_data_scientist;

-- Grant database access
GRANT USAGE ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE deepak_data_scientist;
GRANT USAGE ON ALL SCHEMAS IN DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE deepak_data_scientist;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL TO ROLE deepak_data_scientist;


-- Create data scientist user
CREATE OR REPLACE USER deepak_ds1
    PASSWORD = 'DataSci2026!'
    LOGIN_NAME = 'deepak_ds1'
    DEFAULT_ROLE = 'deepak_data_scientist'
    DEFAULT_WAREHOUSE = 'deepak_compute_wh'
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Deepak - Data Scientist 1';

-- Grant role to user
GRANT ROLE deepak_data_scientist TO USER deepak_ds1;

-- Deepak's learning: deepak_ds1 will benefit from warehouse cache!
-- Same warehouse = shared cache across users


-- ========================================
-- TEST DIFFERENT QUERIES ON SAME DATA
-- ========================================

-- Deepak's experiment: Different aggregations on same table
-- All benefit from warehouse cache

-- Query 1: Average birth year
SELECT AVG(c_birth_year) AS avg_year
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Query 2: Count customers
SELECT COUNT(*) AS customer_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Query 3: Min/Max birth year
SELECT
    MIN(c_birth_year) AS min_year,
    MAX(c_birth_year) AS max_year
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Deepak's observation: All queries fast!
-- Warehouse cache has the raw data in SSD
-- Different queries, same underlying data = cache hit


-- ========================================
-- COMPARE CACHE TYPES
-- ========================================

-- Deepak's analysis: Run exact same query twice
-- First time: Uses warehouse cache (if data cached)
-- Second time: Uses result cache (exact query match)

SELECT AVG(c_birth_year) AS birth_year_avg
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Run again (exact same query)
SELECT AVG(c_birth_year) AS birth_year_avg
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Deepak's learning: Second run uses RESULT cache (instant, free)
-- Check query profile: "Query result reused"


/*
DEEPAK'S WAREHOUSE CACHING INSIGHTS:
=====================================

Two Types of Caching in Snowflake:

1. Result Cache:
   - Stores query RESULTS
   - Account-wide (shared by all)
   - 24-hour duration
   - Requires exact same query
   - FREE (no warehouse needed)

2. Warehouse Cache:
   - Stores raw DATA in SSD
   - Per warehouse (local)
   - While warehouse running
   - Benefits similar queries
   - FREE (no extra cost)

How Warehouse Cache Works:

1. Query runs first time
2. Data read from cloud storage
3. Data cached in warehouse SSD
4. Warehouse stays running
5. Next query on same data
6. Reads from SSD (faster!)
7. Warehouse suspends
8. Cache cleared

Warehouse Cache vs Result Cache:

┌──────────────────────┬──────────────┬──────────────┐
│ Feature              │ Result Cache │ Warehouse    │
├──────────────────────┼──────────────┼──────────────┤
│ What's Cached        │ Query results│ Raw data     │
│ Scope                │ Account-wide │ Per warehouse│
│ Duration             │ 24 hours     │ While running│
│ Sharing              │ All users    │ Same WH users│
│ Requirement          │ Exact query  │ Same data    │
│ Invalidation         │ Data change  │ Suspend/resize│
│ Cost                 │ FREE         │ FREE         │
│ Speed                │ Instant      │ Very fast    │
└──────────────────────┴──────────────┴──────────────┘

Best Practices:

1. Keep Warehouse Running:
   - During active hours
   - Auto-suspend after inactivity
   - Balance cost vs performance

2. Use Same Warehouse:
   - For related queries
   - Share cache across team
   - Group similar workloads

3. Monitor Cache Hits:
   - Check query profiles
   - Track "bytes from cache"
   - Optimize warehouse usage

Deepak's Caching Checklist:

✅ Understand both cache types
✅ Monitor cache hit rates
✅ Keep warehouse running when needed
✅ Group similar queries
✅ Avoid unnecessary resizes
✅ Use same warehouse for team
✅ Check query profiles

Key Takeaway:
Snowflake has TWO caches: Result Cache (query
results, 24h, account-wide) and Warehouse Cache
(raw data, while running, per warehouse). Both
are FREE! Result cache needs exact query match,
warehouse cache benefits similar queries on same
data. Keep warehouse running to maximize cache!

Practiced: February 2026
Status: ✅ Completed - Warehouse caching mastered
*/
