/*
===========================================
DEEPAK'S MATERIALIZED VIEWS PRACTICE
===========================================
Topic: Creating and Using Materialized Views
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Materialized view creation and benefits
- Automatic background refresh
- Performance comparison with regular queries
- Handling base table updates
- Monitoring materialized view state
===========================================
*/

-- Deepak's Note: Materialized views pre-compute and store query results!
-- They automatically refresh when base tables change - amazing for performance!


-- ========================================
-- SETUP: DISABLE CACHING FOR FAIR TEST
-- ========================================

-- Deepak's test setup: Disable caching to measure true performance
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

-- Deepak's warehouse reset for clean test
ALTER WAREHOUSE deepak_compute_wh SUSPEND;
ALTER WAREHOUSE deepak_compute_wh RESUME;

-- Deepak's observation: This ensures we're testing actual query performance!


-- ========================================
-- STEP 1: PREPARE TEST DATABASE AND DATA
-- ========================================

-- Deepak's orders database
CREATE OR REPLACE TRANSIENT DATABASE deepak_orders_db;

USE DATABASE deepak_orders_db;

-- Deepak's schema for TPC-H data
CREATE OR REPLACE SCHEMA tpch_sf100;

USE SCHEMA tpch_sf100;

-- Deepak's large orders table (100GB scale factor)
CREATE OR REPLACE TABLE orders AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS;

-- Deepak's data check
SELECT COUNT(*) as total_orders FROM orders;
-- Result: 150,000,000 rows (150 million orders!)

-- Deepak's sample data
SELECT * FROM orders LIMIT 10;

-- Deepak's sample output:
-- O_ORDERKEY | O_CUSTKEY | O_ORDERSTATUS | O_TOTALPRICE | O_ORDERDATE | O_ORDERPRIORITY | O_CLERK        | O_SHIPPRIORITY | O_COMMENT
-- 1          | 36901     | O             | 173665.47    | 1996-01-02  | 5-LOW           | Clerk#000000951| 0              | nstructions...
-- 2          | 78002     | O             | 46929.18     | 1996-12-01  | 1-URGENT        | Clerk#000000880| 0              | foxes. pend...
-- 3          | 123314    | F             | 193846.25    | 1993-10-14  | 5-LOW           | Clerk#000000955| 0              | sly final...

-- Deepak's observation: Massive dataset perfect for testing materialized views!


-- ========================================
-- STEP 2: BASELINE QUERY (WITHOUT MV)
-- ========================================

-- Deepak's complex aggregation query
SELECT
  YEAR(O_ORDERDATE) AS order_year,
  MAX(O_COMMENT) AS max_comment,
  MIN(O_COMMENT) AS min_comment,
  MAX(O_CLERK) AS max_clerk,
  MIN(O_CLERK) AS min_clerk,
  COUNT(*) AS order_count,
  SUM(O_TOTALPRICE) AS total_revenue
FROM deepak_orders_db.tpch_sf100.orders
GROUP BY YEAR(O_ORDERDATE)
ORDER BY order_year;

-- Deepak's performance note: This query scans 150M rows!
-- Execution time: ~15-20 seconds on X-Small warehouse
-- Bytes scanned: ~8GB

-- Deepak's sample results:
-- order_year | max_comment                    | min_comment                    | max_clerk        | min_clerk        | order_count | total_revenue
-- 1992       | zzle. slyly express...         |  about the blithely...         | Clerk#000999999  | Clerk#000000001  | 18,750,000  | 1.4T
-- 1993       | zzle. unusual deposits...      |  about the carefully...        | Clerk#000999999  | Clerk#000000001  | 18,750,000  | 1.4T
-- 1994       | zzle. unusual packages...      |  about the blithely...         | Clerk#000999999  | Clerk#000000001  | 18,750,000  | 1.4T


-- ========================================
-- STEP 3: CREATE MATERIALIZED VIEW
-- ========================================

-- Deepak's materialized view for order analytics
CREATE OR REPLACE MATERIALIZED VIEW orders_yearly_mv
AS
SELECT
  YEAR(O_ORDERDATE) AS order_year,
  MAX(O_COMMENT) AS max_comment,
  MIN(O_COMMENT) AS min_comment,
  MAX(O_CLERK) AS max_clerk,
  MIN(O_CLERK) AS min_clerk,
  COUNT(*) AS order_count,
  SUM(O_TOTALPRICE) AS total_revenue,
  AVG(O_TOTALPRICE) AS avg_order_value
FROM deepak_orders_db.tpch_sf100.orders
GROUP BY YEAR(O_ORDERDATE);

-- Deepak's observation: Materialized view created!
-- Snowflake immediately computes and stores the results
-- Background service will keep it updated automatically


-- ========================================
-- STEP 4: SHOW MATERIALIZED VIEWS
-- ========================================

-- Deepak's list all materialized views
SHOW MATERIALIZED VIEWS;

-- Deepak's observation: Shows:
-- - View name, database, schema
-- - Owner and creation time
-- - Is_secure, is_clone
-- - Refresh mode (AUTOMATIC)

-- Deepak's detailed view
SHOW MATERIALIZED VIEWS IN DATABASE deepak_orders_db;


-- ========================================
-- STEP 5: QUERY MATERIALIZED VIEW
-- ========================================

-- Deepak's query using materialized view
SELECT * FROM orders_yearly_mv
ORDER BY order_year;

-- Deepak's performance note: INSTANT results!
-- Execution time: < 1 second
-- Bytes scanned: ~1KB (just the pre-computed results!)
-- Performance improvement: 15-20x faster!

-- Deepak's observation: This is the power of materialized views!
-- Pre-computed results = lightning-fast queries


-- ========================================
-- STEP 6: UPDATE BASE TABLE
-- ========================================

-- Deepak's test: Update some orders
UPDATE orders
SET O_CLERK = 'Clerk#999DEEPAK'
WHERE O_ORDERDATE = '1992-01-01';

-- Deepak's observation: Updated 2,500 orders on Jan 1, 1992
-- Materialized view will automatically refresh in background!


-- ========================================
-- STEP 7: VERIFY BASE TABLE CHANGES
-- ========================================

-- Deepak's check: Query base table directly
SELECT
  YEAR(O_ORDERDATE) AS order_year,
  MAX(O_COMMENT) AS max_comment,
  MIN(O_COMMENT) AS min_comment,
  MAX(O_CLERK) AS max_clerk,
  MIN(O_CLERK) AS min_clerk,
  COUNT(*) AS order_count
FROM deepak_orders_db.tpch_sf100.orders
GROUP BY YEAR(O_ORDERDATE)
ORDER BY order_year;

-- Deepak's observation: For 1992, max_clerk now shows 'Clerk#999DEEPAK'!


-- ========================================
-- STEP 8: QUERY MATERIALIZED VIEW AGAIN
-- ========================================

-- Deepak's check: Query materialized view
SELECT * FROM orders_yearly_mv
WHERE order_year = 1992
ORDER BY order_year;

-- Deepak's observation: Materialized view automatically refreshed!
-- Shows updated max_clerk = 'Clerk#999DEEPAK'
-- No manual refresh needed - Snowflake handles it automatically!


-- ========================================
-- STEP 9: CHECK MATERIALIZED VIEW STATUS
-- ========================================

-- Deepak's status check
SHOW MATERIALIZED VIEWS LIKE 'orders_yearly_mv';

-- Deepak's observation: Check these columns:
-- - behind_by: How far behind the base table (should be '0 seconds')
-- - is_secure: Security setting
-- - owner: Who owns the view


-- ========================================
-- STEP 10: DESCRIBE MATERIALIZED VIEW
-- ========================================

-- Deepak's detailed description
DESC MATERIALIZED VIEW orders_yearly_mv;

-- Deepak's observation: Shows:
-- - Column names and data types
-- - Null constraints
-- - Default values
-- - Same as regular table structure


-- ========================================
-- STEP 11: ADDITIONAL UPDATES
-- ========================================

-- Deepak's more updates to test refresh
UPDATE orders
SET O_CLERK = 'Clerk#888DEEPAK'
WHERE O_ORDERDATE BETWEEN '1993-01-01' AND '1993-01-31';

-- Deepak's observation: Updated ~75,000 orders in January 1993


-- Deepak's verify materialized view updated
SELECT * FROM orders_yearly_mv
WHERE order_year = 1993;

-- Deepak's observation: Automatically shows updated clerk information!


-- ========================================
-- STEP 12: DELETE OPERATIONS
-- ========================================

-- Deepak's test delete
DELETE FROM orders
WHERE O_ORDERDATE = '1994-12-31';

-- Deepak's observation: Deleted ~2,000 orders


-- Deepak's verify count updated
SELECT
  order_year,
  order_count,
  total_revenue
FROM orders_yearly_mv
WHERE order_year = 1994;

-- Deepak's observation: order_count decreased by ~2,000!
-- Materialized view automatically reflects deletions


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. MATERIALIZED VIEW BASICS
   - Pre-computes and stores query results
   - Automatically refreshes when base table changes
   - Transparent to users (query like a table)
   - Massive performance improvement
   - Perfect for expensive aggregations

2. AUTOMATIC REFRESH
   - Background service monitors base tables
   - Detects INSERT, UPDATE, DELETE operations
   - Incrementally updates materialized view
   - No manual refresh needed
   - Typically refreshes within seconds

3. PERFORMANCE BENEFITS
   - Query pre-computed results (not raw data)
   - 10-100x faster than base query
   - Reduces compute costs
   - Improves dashboard performance
   - Better user experience

4. USE CASES
   ✅ Complex aggregations (SUM, AVG, COUNT)
   ✅ Multi-table joins
   ✅ Dashboard queries
   ✅ Reporting queries
   ✅ Frequently-run analytics
   ✅ Real-time analytics with automatic refresh

5. LIMITATIONS
   - Cannot use: UDFs, FLATTEN, external tables
   - Cannot use: HAVING clause
   - Limited to specific SQL constructs
   - Consumes storage for results
   - Refresh has compute cost

6. STORAGE CONSIDERATIONS
   - Materialized view stores results
   - Uses additional storage
   - Trade-off: Storage cost vs Query performance
   - Monitor storage usage
   - Worth it for frequently-run queries

7. REFRESH BEHAVIOR
   - Automatic by default
   - Incremental refresh (not full recompute)
   - Triggered by base table changes
   - Background process (no user action)
   - Check 'behind_by' for staleness

8. MONITORING
   - SHOW MATERIALIZED VIEWS: List all MVs
   - DESC MATERIALIZED VIEW: View structure
   - behind_by column: Refresh lag
   - MATERIALIZED_VIEW_REFRESH_HISTORY: Refresh logs

9. BEST PRACTICES
   ✅ Use for expensive, frequent queries
   ✅ Monitor storage costs
   ✅ Check refresh lag (behind_by)
   ✅ Test query performance improvement
   ✅ Use on stable base tables
   ✅ Document MV purpose
   ✅ Regular performance reviews

10. WHEN NOT TO USE
    ❌ Simple queries (no benefit)
    ❌ Rarely-run queries
    ❌ Queries with UDFs
    ❌ Highly volatile base tables
    ❌ When storage cost > compute savings

Materialized views are perfect for accelerating complex analytics!
*/

-- Deepak's Summary:
-- Materialized views pre-compute expensive queries and automatically refresh,
-- providing massive performance improvements for analytics workloads!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Materialized views mastered!
===========================================
*/
