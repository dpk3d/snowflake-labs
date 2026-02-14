/*
===========================================
DEEPAK'S QUERY RESULT CACHING PRACTICE
===========================================
Topic: Understanding Snowflake's Result Cache
Date Practiced: February 11, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Result cache stores query results for 24 hours
- Exact same query returns cached results instantly
- No warehouse needed for cached results (FREE!)
- Cache invalidated when underlying data changes
- Shared across all users in account
===========================================
*/

-- Deepak's Note: Result caching is Snowflake's secret weapon for performance
-- Same query runs instantly the second time with ZERO compute cost!


-- ========================================
-- TEST QUERY RESULT CACHING
-- ========================================

-- Deepak's experiment: Run expensive aggregation query
-- First run: Uses warehouse compute
SELECT
    AVG(C_BIRTH_YEAR) AS avg_birth_year,
    COUNT(*) AS total_customers,
    MIN(C_BIRTH_YEAR) AS oldest_birth_year,
    MAX(C_BIRTH_YEAR) AS youngest_birth_year
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Deepak's observation: Query took several seconds, used warehouse credits

-- Run EXACT same query again
SELECT
    AVG(C_BIRTH_YEAR) AS avg_birth_year,
    COUNT(*) AS total_customers,
    MIN(C_BIRTH_YEAR) AS oldest_birth_year,
    MAX(C_BIRTH_YEAR) AS youngest_birth_year
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER;

-- Deepak's learning: Second run is INSTANT! Result came from cache
-- Check query profile: "Query result reused" ✅


-- ========================================
-- SETUP: CREATE DATA SCIENTIST ROLE
-- ========================================

-- Deepak's scenario: Create role for data science team
CREATE OR REPLACE ROLE deepak_data_scientist
COMMENT = 'Deepak - Role for data science team members';

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE deepak_compute_wh TO ROLE deepak_data_scientist;

-- Grant database access
GRANT USAGE ON DATABASE deepak_analytics_db TO ROLE deepak_data_scientist;
GRANT USAGE ON ALL SCHEMAS IN DATABASE deepak_analytics_db TO ROLE deepak_data_scientist;
GRANT SELECT ON ALL TABLES IN SCHEMA deepak_analytics_db.public TO ROLE deepak_data_scientist;


-- Create data scientist user
CREATE OR REPLACE USER priya_datascientist
    PASSWORD = 'DataSci2026!'
    LOGIN_NAME = 'priya_datascientist'
    DEFAULT_ROLE = 'deepak_data_scientist'
    DEFAULT_WAREHOUSE = 'deepak_compute_wh'
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Deepak - Priya, Data Scientist';

-- Grant role to user
GRANT ROLE deepak_data_scientist TO USER priya_datascientist;

-- Deepak's note: Priya can now benefit from result cache too!


/*
DEEPAK'S RESULT CACHING INSIGHTS:
=================================

What is Result Cache?
- Stores query results for 24 hours
- Automatically used when same query runs again
- No warehouse compute needed (FREE!)
- Shared across all users in account
- Invalidated when underlying data changes

How It Works:
1. User runs query → Uses warehouse compute
2. Results stored in result cache
3. Same query runs again → Returns from cache (instant, free)
4. Cache valid for 24 hours or until data changes

Cache Requirements (ALL must be true):
✅ Exact same SQL text (case-sensitive)
✅ Same role and permissions
✅ Underlying data hasn't changed
✅ Within 24-hour window
✅ Tables still exist
✅ No non-deterministic functions (CURRENT_TIME, RANDOM, etc.)

Performance Benefits:
- Query time: Seconds → Milliseconds
- Compute cost: Credits → FREE
- Warehouse: Required → Not needed
- Network: Full data → Cached result

Example Performance:
┌─────────────┬──────────────┬──────────────┬──────────┐
│ Run         │ Time         │ Warehouse    │ Cost     │
├─────────────┼──────────────┼──────────────┼──────────┤
│ First       │ 5.2 seconds  │ Used         │ Credits  │
│ Second      │ 0.1 seconds  │ Not used     │ FREE     │
│ Third       │ 0.1 seconds  │ Not used     │ FREE     │
└─────────────┴──────────────┴──────────────┴──────────┘

Cache Invalidation:
- Data in source tables changes (INSERT, UPDATE, DELETE)
- 24 hours elapsed
- Table dropped and recreated
- Clustering changes
- Micro-partitions reorganized

Non-Deterministic Functions (Break Cache):
❌ CURRENT_TIME()
❌ CURRENT_TIMESTAMP()
❌ CURRENT_DATE()
❌ RANDOM()
❌ UUID_STRING()
❌ SYSDATE()

Deterministic Functions (Cache Works):
✅ DATE('2026-02-12')
✅ SUM(), AVG(), COUNT()
✅ UPPER(), LOWER()
✅ Mathematical functions
✅ String functions

Checking if Query Used Cache:
1. Query Profile → "Query result reused"
2. Warehouse usage → 0 seconds
3. Bytes scanned → 0

Best Practices:
1. Write consistent SQL (same formatting)
2. Avoid non-deterministic functions when possible
3. Use views for common queries
4. Educate users about cache benefits
5. Monitor cache hit rates
6. Use result cache for dashboards

Real-World Use Cases:
✅ Dashboard queries (same queries repeatedly)
✅ Report generation
✅ Data exploration (analysts re-running queries)
✅ API endpoints (same data requests)
✅ Scheduled reports
✅ Data validation queries

Cache Sharing Example:
-- Deepak runs query at 9:00 AM
SELECT COUNT(*) FROM customers;  -- Uses warehouse

-- Priya runs same query at 9:05 AM
SELECT COUNT(*) FROM customers;  -- Uses cache (FREE!)

-- Rahul runs same query at 9:10 AM
SELECT COUNT(*) FROM customers;  -- Uses cache (FREE!)

Cost Savings:
- 100 users running same query
- Without cache: 100x warehouse cost
- With cache: 1x warehouse cost (99% savings!)

Monitoring Cache Usage:
SELECT
    query_text,
    execution_time,
    warehouse_name,
    bytes_scanned,
    query_result_reused
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE user_name = 'DEEPAK'
ORDER BY start_time DESC
LIMIT 10;

Tips for Maximizing Cache Hits:
1. Standardize query formatting
2. Use query templates
3. Create views for common patterns
4. Avoid unnecessary CURRENT_TIMESTAMP
5. Use parameters instead of hardcoded dates
6. Educate team on cache behavior

Cache vs Warehouse Cache:
┌──────────────────────┬──────────────┬──────────────┐
│ Feature              │ Result Cache │ Warehouse    │
├──────────────────────┼──────────────┼──────────────┤
│ Scope                │ Account-wide │ Per warehouse│
│ Duration             │ 24 hours     │ Until suspend│
│ Invalidation         │ Data change  │ Warehouse off│
│ Requirement          │ Exact query  │ Same data    │
│ Cost                 │ FREE         │ FREE         │
└──────────────────────┴──────────────┴──────────────┘

Disabling Result Cache (if needed):
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

-- Run query without cache
SELECT * FROM customers;

-- Re-enable cache
ALTER SESSION SET USE_CACHED_RESULT = TRUE;

Practiced: February 2026
Status: ✅ Completed - Understanding result caching for performance
*/
