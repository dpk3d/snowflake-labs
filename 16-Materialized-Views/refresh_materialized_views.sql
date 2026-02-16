/*
===========================================
DEEPAK'S MATERIALIZED VIEW REFRESH MONITORING
===========================================
Topic: Monitoring Materialized View Refresh Operations
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Automatic refresh mechanism
- Refresh history tracking
- Performance monitoring
- Refresh lag analysis
- Troubleshooting refresh issues
===========================================
*/

-- Deepak's Note: Understanding refresh behavior is crucial for production!
-- Learn to monitor, analyze, and optimize materialized view refreshes


-- ========================================
-- SETUP: DISABLE CACHING FOR TESTING
-- ========================================

-- Deepak's test environment setup
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

-- Deepak's warehouse reset
ALTER WAREHOUSE deepak_compute_wh SUSPEND;
ALTER WAREHOUSE deepak_compute_wh RESUME;

-- Deepak's observation: Clean slate for refresh testing!


-- ========================================
-- STEP 1: PREPARE TEST DATABASE
-- ========================================

-- Deepak's orders database
CREATE OR REPLACE TRANSIENT DATABASE deepak_orders_db;

USE DATABASE deepak_orders_db;

-- Deepak's schema
CREATE OR REPLACE SCHEMA tpch_sf100;

USE SCHEMA tpch_sf100;

-- Deepak's large orders table
CREATE OR REPLACE TABLE orders AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS;

-- Deepak's data verification
SELECT COUNT(*) as total_orders FROM orders;
-- Result: 150,000,000 rows

SELECT * FROM orders LIMIT 10;

-- Deepak's observation: Base table ready for materialized view!


-- ========================================
-- STEP 2: BASELINE AGGREGATION QUERY
-- ========================================

-- Deepak's complex aggregation (before MV)
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

-- Deepak's performance baseline:
-- Execution time: ~18 seconds
-- Bytes scanned: ~8.2GB
-- Rows scanned: 150,000,000


-- ========================================
-- STEP 3: CREATE MATERIALIZED VIEW
-- ========================================

-- Deepak's materialized view
CREATE OR REPLACE MATERIALIZED VIEW orders_yearly_analytics_mv
AS
SELECT
  YEAR(O_ORDERDATE) AS order_year,
  MAX(O_COMMENT) AS max_comment,
  MIN(O_COMMENT) AS min_comment,
  MAX(O_CLERK) AS max_clerk,
  MIN(O_CLERK) AS min_clerk,
  COUNT(*) AS order_count,
  SUM(O_TOTALPRICE) AS total_revenue,
  AVG(O_TOTALPRICE) AS avg_order_value,
  MIN(O_TOTALPRICE) AS min_order_value,
  MAX(O_TOTALPRICE) AS max_order_value
FROM deepak_orders_db.tpch_sf100.orders
GROUP BY YEAR(O_ORDERDATE);

-- Deepak's observation: Initial materialization started!
-- Snowflake computes results in background


-- ========================================
-- STEP 4: SHOW MATERIALIZED VIEWS
-- ========================================

-- Deepak's list materialized views
SHOW MATERIALIZED VIEWS IN DATABASE deepak_orders_db;

-- Deepak's observation: Key columns to check:
-- - name: View name
-- - database_name, schema_name: Location
-- - owner: Who created it
-- - behind_by: Refresh lag (should be '0 seconds' when fresh)
-- - created_on: Creation timestamp


-- ========================================
-- STEP 5: QUERY MATERIALIZED VIEW
-- ========================================

-- Deepak's query using MV
SELECT * FROM orders_yearly_analytics_mv
ORDER BY order_year;

-- Deepak's performance with MV:
-- Execution time: < 1 second
-- Bytes scanned: ~2KB
-- Performance improvement: 18x faster!

-- Deepak's sample results:
-- order_year | max_comment | min_comment | max_clerk        | min_clerk        | order_count | total_revenue
-- 1992       | zzle...     |  about...   | Clerk#000999999  | Clerk#000000001  | 18,750,000  | 1,405,123,456,789
-- 1993       | zzle...     |  about...   | Clerk#000999999  | Clerk#000000001  | 18,750,000  | 1,405,234,567,890


-- ========================================
-- STEP 6: UPDATE BASE TABLE (TRIGGER REFRESH)
-- ========================================

-- Deepak's update to trigger refresh
UPDATE orders
SET O_CLERK = 'Clerk#999DEEPAK2024'
WHERE O_ORDERDATE = '1992-01-01';

-- Deepak's observation: Updated ~2,500 orders
-- This triggers automatic refresh of materialized view!


-- ========================================
-- STEP 7: CHECK REFRESH STATUS
-- ========================================

-- Deepak's immediate status check
SHOW MATERIALIZED VIEWS LIKE 'orders_yearly_analytics_mv';

-- Deepak's observation: Check 'behind_by' column
-- - '0 seconds': Fully refreshed
-- - '5 seconds': 5 seconds behind
-- - Refresh happens automatically in background!


-- ========================================
-- STEP 8: VERIFY BASE TABLE CHANGES
-- ========================================

-- Deepak's query base table directly
SELECT
  YEAR(O_ORDERDATE) AS order_year,
  MAX(O_CLERK) AS max_clerk,
  MIN(O_CLERK) AS min_clerk,
  COUNT(*) AS order_count
FROM deepak_orders_db.tpch_sf100.orders
WHERE YEAR(O_ORDERDATE) = 1992
GROUP BY YEAR(O_ORDERDATE);

-- Deepak's observation: max_clerk shows 'Clerk#999DEEPAK2024'


-- ========================================
-- STEP 9: QUERY MATERIALIZED VIEW AFTER UPDATE
-- ========================================

-- Deepak's query MV to verify refresh
SELECT
  order_year,
  max_clerk,
  min_clerk,
  order_count
FROM orders_yearly_analytics_mv
WHERE order_year = 1992;

-- Deepak's observation: Materialized view automatically updated!
-- Shows max_clerk = 'Clerk#999DEEPAK2024'
-- No manual intervention needed!


-- ========================================
-- STEP 10: MULTIPLE UPDATES FOR TESTING
-- ========================================

-- Deepak's batch update 1
UPDATE orders
SET O_CLERK = 'Clerk#888DEEPAK'
WHERE O_ORDERDATE BETWEEN '1993-01-01' AND '1993-01-31';

-- Deepak's observation: ~75,000 orders updated


-- Deepak's batch update 2
UPDATE orders
SET O_CLERK = 'Clerk#777DEEPAK'
WHERE O_ORDERDATE BETWEEN '1994-06-01' AND '1994-06-30';

-- Deepak's observation: ~75,000 more orders updated


-- Deepak's batch update 3
UPDATE orders
SET O_TOTALPRICE = O_TOTALPRICE * 1.05
WHERE YEAR(O_ORDERDATE) = 1995;

-- Deepak's observation: Price increase for all 1995 orders!


-- ========================================
-- STEP 11: CHECK REFRESH HISTORY
-- ========================================

-- Deepak's refresh history query
SELECT *
FROM TABLE(INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY())
ORDER BY REFRESH_START_TIME DESC;

-- Deepak's observation: Shows all refresh operations!
-- Key columns:
-- - REFRESH_START_TIME: When refresh started
-- - REFRESH_END_TIME: When refresh completed
-- - REFRESH_ACTION: INCREMENTAL or FULL
-- - ROWS_ADDED: Rows inserted
-- - ROWS_UPDATED: Rows modified
-- - ROWS_DELETED: Rows removed
-- - CREDITS_USED: Compute cost


-- ========================================
-- STEP 12: DETAILED REFRESH ANALYSIS
-- ========================================

-- Deepak's detailed refresh analysis
SELECT
  NAME,
  REFRESH_START_TIME,
  REFRESH_END_TIME,
  DATEDIFF('second', REFRESH_START_TIME, REFRESH_END_TIME) AS refresh_duration_seconds,
  REFRESH_ACTION,
  ROWS_ADDED,
  ROWS_UPDATED,
  ROWS_DELETED,
  CREDITS_USED,
  BYTES_SCANNED
FROM TABLE(INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY())
WHERE NAME = 'ORDERS_YEARLY_ANALYTICS_MV'
ORDER BY REFRESH_START_TIME DESC
LIMIT 10;

-- Deepak's sample output:
-- NAME                          | REFRESH_START_TIME      | REFRESH_END_TIME        | refresh_duration_seconds | REFRESH_ACTION | ROWS_ADDED | ROWS_UPDATED | CREDITS_USED
-- ORDERS_YEARLY_ANALYTICS_MV    | 2024-02-14 10:35:22     | 2024-02-14 10:35:25     | 3                        | INCREMENTAL    | 0          | 3            | 0.002
-- ORDERS_YEARLY_ANALYTICS_MV    | 2024-02-14 10:30:15     | 2024-02-14 10:30:18     | 3                        | INCREMENTAL    | 0          | 1            | 0.001
-- ORDERS_YEARLY_ANALYTICS_MV    | 2024-02-14 10:25:00     | 2024-02-14 10:25:45     | 45                       | FULL           | 8          | 0            | 0.125

-- Deepak's observation:
-- - FULL refresh: Initial creation (45 seconds, 0.125 credits)
-- - INCREMENTAL refresh: Updates (3 seconds, 0.001-0.002 credits)
-- - Incremental is much faster and cheaper!


-- ========================================
-- STEP 13: FILTER REFRESH HISTORY
-- ========================================

-- Deepak's filter by time range
SELECT
  NAME,
  REFRESH_START_TIME,
  REFRESH_ACTION,
  ROWS_UPDATED,
  CREDITS_USED
FROM TABLE(INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY(
  DATE_RANGE_START => DATEADD('hour', -24, CURRENT_TIMESTAMP())
))
WHERE NAME = 'ORDERS_YEARLY_ANALYTICS_MV'
ORDER BY REFRESH_START_TIME DESC;

-- Deepak's observation: Last 24 hours of refresh activity!


-- ========================================
-- STEP 14: AGGREGATE REFRESH METRICS
-- ========================================

-- Deepak's refresh summary statistics
SELECT
  NAME,
  COUNT(*) AS total_refreshes,
  SUM(CASE WHEN REFRESH_ACTION = 'FULL' THEN 1 ELSE 0 END) AS full_refreshes,
  SUM(CASE WHEN REFRESH_ACTION = 'INCREMENTAL' THEN 1 ELSE 0 END) AS incremental_refreshes,
  SUM(CREDITS_USED) AS total_credits,
  AVG(DATEDIFF('second', REFRESH_START_TIME, REFRESH_END_TIME)) AS avg_duration_seconds,
  MAX(DATEDIFF('second', REFRESH_START_TIME, REFRESH_END_TIME)) AS max_duration_seconds
FROM TABLE(INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY(
  DATE_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP())
))
WHERE NAME = 'ORDERS_YEARLY_ANALYTICS_MV'
GROUP BY NAME;

-- Deepak's observation: Weekly refresh performance summary!


-- ========================================
-- STEP 15: DELETE OPERATIONS
-- ========================================

-- Deepak's test delete
DELETE FROM orders
WHERE O_ORDERDATE = '1996-12-31';

-- Deepak's observation: Deleted ~2,000 orders
-- Triggers incremental refresh


-- Deepak's verify MV updated
SELECT
  order_year,
  order_count
FROM orders_yearly_analytics_mv
WHERE order_year = 1996;

-- Deepak's observation: order_count decreased!


-- ========================================
-- STEP 16: INSERT OPERATIONS
-- ========================================

-- Deepak's test insert
INSERT INTO orders
SELECT
  O_ORDERKEY + 1000000000,
  O_CUSTKEY,
  O_ORDERSTATUS,
  O_TOTALPRICE,
  '1997-12-31'::DATE,
  O_ORDERPRIORITY,
  'Clerk#DEEPAK_NEW',
  O_SHIPPRIORITY,
  'Deepak test order'
FROM orders
WHERE O_ORDERDATE = '1997-01-01'
LIMIT 1000;

-- Deepak's observation: Inserted 1,000 new orders for 1997
-- Triggers incremental refresh


-- Deepak's verify MV updated
SELECT
  order_year,
  order_count,
  max_clerk
FROM orders_yearly_analytics_mv
WHERE order_year = 1997;

-- Deepak's observation:
-- - order_count increased by 1,000
-- - max_clerk shows 'Clerk#DEEPAK_NEW'


-- ========================================
-- STEP 17: CHECK FINAL REFRESH HISTORY
-- ========================================

-- Deepak's final refresh history
SELECT
  REFRESH_START_TIME,
  REFRESH_END_TIME,
  REFRESH_ACTION,
  ROWS_ADDED,
  ROWS_UPDATED,
  ROWS_DELETED,
  CREDITS_USED
FROM TABLE(INFORMATION_SCHEMA.MATERIALIZED_VIEW_REFRESH_HISTORY())
WHERE NAME = 'ORDERS_YEARLY_ANALYTICS_MV'
ORDER BY REFRESH_START_TIME DESC
LIMIT 5;

-- Deepak's observation: Complete audit trail of all refresh operations!


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. AUTOMATIC REFRESH MECHANISM
   - Background service monitors base tables
   - Detects DML operations (INSERT, UPDATE, DELETE)
   - Triggers incremental refresh automatically
   - No manual intervention required
   - Typically completes within seconds

2. REFRESH TYPES
   - FULL: Complete recomputation (initial creation)
   - INCREMENTAL: Only changed data (subsequent updates)
   - Incremental is much faster and cheaper
   - Snowflake chooses type automatically
   - Most refreshes are incremental

3. REFRESH HISTORY TRACKING
   - MATERIALIZED_VIEW_REFRESH_HISTORY() function
   - Shows all refresh operations
   - Tracks timing, rows affected, credits used
   - Essential for monitoring and optimization
   - Retention: 14 days by default

4. KEY METRICS TO MONITOR
   - Refresh duration: How long refreshes take
   - Credits used: Cost of refreshes
   - Refresh frequency: How often refreshes occur
   - Rows affected: Volume of changes
   - behind_by: Staleness indicator

5. PERFORMANCE CHARACTERISTICS
   - Full refresh: Expensive (minutes, high credits)
   - Incremental refresh: Cheap (seconds, low credits)
   - Refresh cost << Query savings
   - Monitor credit usage trends
   - Optimize base table updates

6. REFRESH TRIGGERS
   - INSERT: Adds new rows to MV
   - UPDATE: Modifies existing MV rows
   - DELETE: Removes rows from MV
   - MERGE: Combination of above
   - Batch updates more efficient

7. STALENESS (behind_by)
   - Measures refresh lag
   - '0 seconds': Fully up-to-date
   - '30 seconds': 30 seconds behind
   - Usually very low (< 1 minute)
   - Check SHOW MATERIALIZED VIEWS

8. TROUBLESHOOTING REFRESH ISSUES
   - Check MATERIALIZED_VIEW_REFRESH_HISTORY for errors
   - Verify base table is not locked
   - Check warehouse availability
   - Review credit limits
   - Monitor refresh duration trends

9. COST OPTIMIZATION
   - Incremental refreshes are cheap
   - Batch base table updates when possible
   - Avoid frequent small updates
   - Monitor credit usage
   - Balance refresh cost vs query savings

10. BEST PRACTICES
    ✅ Monitor refresh history regularly
    ✅ Track credit usage trends
    ✅ Check behind_by for staleness
    ✅ Batch base table updates
    ✅ Set up alerts for long refreshes
    ✅ Document expected refresh patterns
    ✅ Review performance weekly
    ✅ Optimize base table operations

11. REFRESH HISTORY ANALYSIS
    - Identify refresh patterns
    - Detect performance degradation
    - Track cost trends
    - Validate automatic refresh
    - Audit trail for compliance

12. WHEN TO INVESTIGATE
    ❌ behind_by > 5 minutes
    ❌ Refresh duration increasing
    ❌ Credits used spiking
    ❌ Frequent full refreshes
    ❌ Refresh failures

Monitoring refresh operations ensures optimal materialized view performance!
*/

-- Deepak's Summary:
-- Materialized view refresh is automatic, incremental, and efficient.
-- Monitor refresh history to ensure optimal performance and cost!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - MV refresh monitoring mastered!
===========================================
*/
