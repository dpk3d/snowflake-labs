/*
===========================================
DEEPAK'S WAREHOUSE SCALING PRACTICE
===========================================
Topic: Scaling Up vs Scaling Out (Multi-Cluster Warehouses)
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Scaling UP = Bigger warehouse (more compute per query)
- Scaling OUT = More clusters (more concurrent queries)
- Multi-cluster warehouses handle concurrency
- Auto-scaling adds/removes clusters automatically
- Economy mode minimizes costs
- Standard mode maximizes performance
===========================================
*/

-- Deepak's Note: Scaling is like a restaurant
-- Scaling UP = Bigger kitchen (faster cooking)
-- Scaling OUT = More kitchens (serve more customers at once)


-- ========================================
-- SETUP: CREATE MULTI-CLUSTER WAREHOUSE
-- ========================================

-- Deepak's scenario: Create warehouse that can scale out
CREATE OR REPLACE WAREHOUSE deepak_scaling_wh
WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1           -- Start with 1 cluster
    MAX_CLUSTER_COUNT = 3           -- Scale up to 3 clusters
    SCALING_POLICY = 'STANDARD'     -- Aggressive scaling
    COMMENT = 'Deepak - Multi-cluster warehouse for scaling demo';

-- Deepak's learning: Multi-cluster warehouse (Enterprise Edition)
-- MIN = 1: Starts with 1 cluster
-- MAX = 3: Can scale to 3 clusters for concurrency
-- SCALING_POLICY = STANDARD: Adds clusters quickly


-- ========================================
-- TEST QUERY: HEAVY CROSS JOIN
-- ========================================

-- Deepak's experiment: Run expensive query to test scaling
-- This creates a massive result set using CROSS JOINs
SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T1
CROSS JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T2
CROSS JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T3
CROSS JOIN (SELECT TOP 57 * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE) T4;

-- Deepak's observation: This query is VERY expensive!
-- CROSS JOIN creates cartesian product
-- If WEB_SITE has 30 rows: 30 × 30 × 30 × 57 = ~1.5 million rows

-- Deepak's learning: Check query profile
-- - Execution time
-- - Warehouse size used
-- - Bytes scanned


-- ========================================
-- SIMULATE CONCURRENT QUERIES
-- ========================================

-- Deepak's scenario: Multiple users running queries simultaneously
-- This is where scaling OUT helps!

-- User 1 query
SELECT
    COUNT(*) AS total_rows,
    'User 1 - Priya' AS user_name
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T1
CROSS JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T2
CROSS JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.WEB_SITE T3;

-- User 2 query (run simultaneously)
SELECT
    COUNT(*) AS total_rows,
    'User 2 - Rahul' AS user_name
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER T1
CROSS JOIN (SELECT TOP 100 * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER) T2;

-- User 3 query (run simultaneously)
SELECT
    COUNT(*) AS total_rows,
    'User 3 - Amit' AS user_name
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE T1
CROSS JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE T2
CROSS JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.STORE T3;

-- Deepak's learning: With multi-cluster warehouse
-- - First query uses cluster 1
-- - Second query triggers cluster 2 (if needed)
-- - Third query triggers cluster 3 (if needed)
-- - All queries run in parallel!


-- ========================================
-- COMPARE SCALING POLICIES
-- ========================================

-- Deepak's experiment: Test STANDARD scaling policy
ALTER WAREHOUSE deepak_scaling_wh
SET SCALING_POLICY = 'STANDARD';

-- STANDARD Policy:
-- - Adds clusters quickly (aggressive)
-- - Minimizes query queuing
-- - Higher cost (more clusters running)
-- - Best for performance-critical workloads

-- Deepak's observation: Clusters spin up fast


-- Deepak's experiment: Test ECONOMY scaling policy
ALTER WAREHOUSE deepak_scaling_wh
SET SCALING_POLICY = 'ECONOMY';

-- ECONOMY Policy:
-- - Adds clusters conservatively
-- - Waits longer before scaling
-- - Lower cost (fewer clusters)
-- - Best for cost-sensitive workloads

-- Deepak's observation: Clusters spin up slower


-- ========================================
-- MONITOR WAREHOUSE SCALING
-- ========================================

-- Deepak's monitoring: Check warehouse load
SHOW WAREHOUSES LIKE 'deepak_scaling_wh';

-- Deepak's check: View warehouse history
SELECT
    start_time,
    end_time,
    warehouse_name,
    credits_used,
    credits_used_compute,
    credits_used_cloud_services,
    num_queries
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name = 'DEEPAK_SCALING_WH'
AND start_time >= DATEADD('hour', -1, CURRENT_TIMESTAMP())
ORDER BY start_time DESC;


-- Deepak's check: View query concurrency
SELECT
    start_time,
    query_id,
    query_text,
    warehouse_name,
    warehouse_size,
    execution_status,
    total_elapsed_time / 1000 AS seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE warehouse_name = 'DEEPAK_SCALING_WH'
AND start_time >= DATEADD('hour', -1, CURRENT_TIMESTAMP())
ORDER BY start_time DESC
LIMIT 20;


-- ========================================
-- SCALING UP VS SCALING OUT
-- ========================================

-- Deepak's comparison: When to scale UP vs OUT

-- Scenario 1: Single slow query
-- Solution: Scale UP (bigger warehouse)
ALTER WAREHOUSE deepak_scaling_wh
SET WAREHOUSE_SIZE = 'LARGE';

-- Deepak's learning: Larger warehouse = more compute per query
-- Faster execution for individual queries


-- Scenario 2: Many concurrent queries
-- Solution: Scale OUT (more clusters)
ALTER WAREHOUSE deepak_scaling_wh
SET WAREHOUSE_SIZE = 'MEDIUM'
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 5;

-- Deepak's learning: More clusters = handle more users
-- Each cluster runs queries in parallel


-- ========================================
-- COST ANALYSIS
-- ========================================

-- Deepak's analysis: Compare costs

-- Single LARGE warehouse (scaling UP):
-- - 8 credits/hour
-- - Handles 1 query at a time well
-- - Concurrent queries queue

-- 3 MEDIUM warehouses (scaling OUT):
-- - 4 credits/hour × 3 = 12 credits/hour (when all running)
-- - Handles 3 queries simultaneously
-- - No queuing

-- Deepak's observation: Scaling OUT costs more when all clusters running
-- But provides better concurrency and user experience


-- ========================================
-- CLEANUP
-- ========================================

-- Deepak's cleanup: Reset warehouse to single cluster
ALTER WAREHOUSE deepak_scaling_wh
SET MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1;

-- Deepak's note: Prevents unexpected scaling costs


/*
DEEPAK'S WAREHOUSE SCALING INSIGHTS:
=====================================

Two Types of Scaling:

1. Scaling UP (Vertical):
   - Increase warehouse SIZE
   - More compute per query
   - Faster individual queries
   - Same concurrency limit
   - Example: SMALL → MEDIUM → LARGE

2. Scaling OUT (Horizontal):
   - Add more CLUSTERS
   - Same compute per query
   - More concurrent queries
   - Better for many users
   - Example: 1 cluster → 2 clusters → 3 clusters

Scaling UP (Warehouse Sizes):

┌────────────┬──────────────┬─────────────┬──────────────┐
│ Size       │ Credits/Hour │ Compute     │ Use Case     │
├────────────┼──────────────┼─────────────┼──────────────┤
│ XSMALL     │ 1            │ 1x          │ Light queries│
│ SMALL      │ 2            │ 2x          │ Standard     │
│ MEDIUM     │ 4            │ 4x          │ Analytics    │
│ LARGE      │ 8            │ 8x          │ Heavy ETL    │
│ XLARGE     │ 16           │ 16x         │ ML training  │
│ 2XLARGE    │ 32           │ 32x         │ Massive data │
│ 3XLARGE    │ 64           │ 64x         │ Enterprise   │
│ 4XLARGE    │ 128          │ 128x        │ Extreme      │
└────────────┴──────────────┴─────────────┴──────────────┘

When to Scale UP:
✅ Single query is slow
✅ Complex aggregations
✅ Large data scans
✅ ETL jobs
✅ ML model training
✅ Data transformations

When to Scale OUT:
✅ Many concurrent users
✅ Queries queuing
✅ Dashboard with many users
✅ Peak usage times
✅ Unpredictable workload
✅ SLA requirements

Scaling OUT (Multi-Cluster):

Min/Max Cluster Configuration:
- MIN_CLUSTER_COUNT: Always running
- MAX_CLUSTER_COUNT: Maximum allowed
- Auto-scaling between min and max

Example Configurations:

Development:
MIN = 1, MAX = 1
- No scaling
- Lowest cost
- Queries may queue

Production (Moderate):
MIN = 1, MAX = 3
- Scales as needed
- Balanced cost
- Handles bursts

Production (High Concurrency):
MIN = 2, MAX = 10
- Always 2 clusters ready
- Scales to 10 for peaks
- Highest cost, best performance

Scaling Policies:

STANDARD (Performance-Focused):
- Adds clusters quickly
- Minimizes queuing
- Higher cost
- Best for: Production, SLA-critical

ECONOMY (Cost-Focused):
- Adds clusters conservatively
- Waits 6 minutes before scaling
- Lower cost
- Best for: Development, batch jobs

Scaling Policy Comparison:

┌──────────────────┬──────────────┬──────────────┐
│ Metric           │ STANDARD     │ ECONOMY      │
├──────────────────┼──────────────┼──────────────┤
│ Scale-up trigger │ 1 minute     │ 6 minutes    │
│ Scale-down wait  │ 2-3 minutes  │ 5-6 minutes  │
│ Cost             │ Higher       │ Lower        │
│ Performance      │ Better       │ Good         │
│ Use case         │ Production   │ Development  │
└──────────────────┴──────────────┴──────────────┘

Cost Examples:

Scenario 1: Single User, Slow Query
- Problem: Query takes 10 minutes on SMALL
- Solution: Scale UP to LARGE
- Before: 10 min × 2 credits/hour = 0.33 credits
- After: 2 min × 8 credits/hour = 0.27 credits
- Result: Faster AND cheaper!

Scenario 2: 10 Concurrent Users
- Problem: Queries queuing on single MEDIUM
- Solution: Scale OUT to 3 clusters
- Before: 10 queries × 5 min each = 50 min total
- After: 10 queries / 3 clusters = ~17 min total
- Cost: 3x higher, but 3x faster!

Monitoring Scaling:

-- Check current cluster count
SHOW WAREHOUSES LIKE 'warehouse_name';

-- View scaling history
SELECT
    start_time,
    warehouse_name,
    credits_used,
    AVG(credits_used) OVER (
        PARTITION BY warehouse_name
        ORDER BY start_time
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS avg_credits_7_periods
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name = 'DEEPAK_SCALING_WH'
ORDER BY start_time DESC
LIMIT 100;

-- Check query queuing
SELECT
    start_time,
    query_id,
    queued_provisioning_time,
    queued_repair_time,
    queued_overload_time,
    total_elapsed_time
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE warehouse_name = 'DEEPAK_SCALING_WH'
AND (queued_provisioning_time > 0
     OR queued_repair_time > 0
     OR queued_overload_time > 0)
ORDER BY start_time DESC
LIMIT 20;

Best Practices:

1. Start Small:
   - Begin with SMALL, single cluster
   - Monitor performance
   - Scale up only if needed

2. Use Auto-Scaling:
   - Set reasonable MIN/MAX
   - Let Snowflake handle scaling
   - Review and adjust monthly

3. Choose Right Policy:
   - STANDARD for production
   - ECONOMY for development
   - Test both to compare

4. Monitor Queuing:
   - Check for queued queries
   - If frequent, scale out
   - If rare, keep as is

5. Set Resource Monitors:
   - Prevent runaway costs
   - Alert before limits
   - Automatic suspension

6. Review Regularly:
   - Weekly usage reports
   - Identify patterns
   - Optimize configuration

Common Mistakes:

❌ Over-provisioning (too large, too many clusters)
❌ Under-provisioning (queries queuing, users unhappy)
❌ No auto-suspend (clusters running 24/7)
❌ Wrong scaling policy (STANDARD when ECONOMY better)
❌ No monitoring (don't know if scaling helps)
❌ Scaling when clustering would help more

Decision Matrix:

Problem: Slow Queries
→ Check query profile
→ If scanning too much data: Add clustering
→ If compute-bound: Scale UP

Problem: Queries Queuing
→ Check concurrency
→ If many concurrent users: Scale OUT
→ If occasional spikes: Use auto-scaling

Problem: High Costs
→ Check warehouse usage
→ If idle time: Reduce auto-suspend
→ If over-scaled: Reduce size or clusters

Real-World Example:

Company: SaaS with 200 analysts

Morning (8 AM - 12 PM):
- 150 concurrent users
- Warehouse scales: 1 → 5 clusters
- Cost: 5 × 4 credits/hour × 4 hours = 80 credits

Afternoon (12 PM - 5 PM):
- 50 concurrent users
- Warehouse scales: 5 → 2 clusters
- Cost: 2 × 4 credits/hour × 5 hours = 40 credits

Evening (5 PM - 8 AM):
- 10 concurrent users
- Warehouse scales: 2 → 1 cluster
- Cost: 1 × 4 credits/hour × 15 hours = 60 credits

Total: 180 credits/day = $360/day

vs Fixed 5 clusters 24/7:
5 × 4 × 24 = 480 credits/day = $960/day

Savings: 62%!

Deepak's Scaling Strategy:

1. Identify workload type
2. Start with minimal configuration
3. Monitor performance and queuing
4. Scale UP for slow queries
5. Scale OUT for concurrency
6. Use auto-scaling for variable load
7. Review and optimize monthly

Deepak's Scaling Checklist:

✅ Workload analyzed
✅ Initial size chosen
✅ Auto-suspend configured
✅ Min/max clusters set
✅ Scaling policy selected
✅ Resource monitor created
✅ Monitoring enabled
✅ Regular reviews scheduled

Key Takeaway:
Scale UP (bigger warehouse) for slow queries,
Scale OUT (more clusters) for concurrency. Use
multi-cluster warehouses with auto-scaling for
variable workloads. Choose STANDARD policy for
production, ECONOMY for development. Monitor
queuing and costs, adjust monthly!

Practiced: February 2026
Status: ✅ Completed - Warehouse scaling mastered
*/
