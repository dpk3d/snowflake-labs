/*
===========================================
DEEPAK'S FAIL-SAFE STORAGE MONITORING
===========================================
Topic: Monitoring Storage Usage (Time Travel & Fail-Safe)
Date Practiced: February 13, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Monitor storage at account and table level
- Track Time Travel storage costs
- Track Fail-Safe storage costs
- Understand storage breakdown
- Optimize storage usage
===========================================
*/

-- Deepak's Note: Storage costs money - monitor it!
-- Time Travel and Fail-Safe add to storage costs


-- ========================================
-- ACCOUNT-LEVEL STORAGE USAGE
-- ========================================

-- Deepak's query: View raw storage usage
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
ORDER BY USAGE_DATE DESC;

-- Deepak's observation: Shows daily storage usage for entire account


-- Deepak's technique: Format storage in GB for readability
SELECT
    USAGE_DATE,
    STORAGE_BYTES / (1024*1024*1024) AS storage_gb,
    STAGE_BYTES / (1024*1024*1024) AS stage_gb,
    FAILSAFE_BYTES / (1024*1024*1024) AS failsafe_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
ORDER BY USAGE_DATE DESC;

-- Deepak's learning: Can see storage trends over time
-- STORAGE_BYTES: Active table data
-- STAGE_BYTES: Files in stages
-- FAILSAFE_BYTES: Fail-Safe storage


-- ========================================
-- TABLE-LEVEL STORAGE USAGE
-- ========================================

-- Deepak's query: View raw table storage metrics
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

-- Deepak's observation: Shows storage breakdown per table


-- Deepak's technique: Format table storage in GB
SELECT
    ID,
    TABLE_NAME,
    TABLE_SCHEMA,
    TABLE_CATALOG,
    ACTIVE_BYTES / (1024*1024*1024) AS active_storage_gb,
    TIME_TRAVEL_BYTES / (1024*1024*1024) AS time_travel_storage_gb,
    FAILSAFE_BYTES / (1024*1024*1024) AS failsafe_storage_gb,
    (ACTIVE_BYTES + TIME_TRAVEL_BYTES + FAILSAFE_BYTES) / (1024*1024*1024) AS total_storage_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
ORDER BY failsafe_storage_gb DESC;

-- Deepak's learning: Can identify which tables use most storage
-- ACTIVE_BYTES: Current table data
-- TIME_TRAVEL_BYTES: Historical data (retention period)
-- FAILSAFE_BYTES: Fail-Safe data (7 days after retention)


-- ========================================
-- DEEPAK'S STORAGE ANALYSIS QUERIES
-- ========================================

-- Deepak's analysis: Top 10 tables by total storage
SELECT
    TABLE_CATALOG || '.' || TABLE_SCHEMA || '.' || TABLE_NAME AS full_table_name,
    ACTIVE_BYTES / (1024*1024*1024) AS active_gb,
    TIME_TRAVEL_BYTES / (1024*1024*1024) AS time_travel_gb,
    FAILSAFE_BYTES / (1024*1024*1024) AS failsafe_gb,
    (ACTIVE_BYTES + TIME_TRAVEL_BYTES + FAILSAFE_BYTES) / (1024*1024*1024) AS total_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE DELETED IS NULL  -- Only active tables
ORDER BY total_gb DESC
LIMIT 10;

-- Deepak's observation: Identify storage hogs!


-- Deepak's analysis: Tables with high Time Travel storage
SELECT
    TABLE_NAME,
    TABLE_SCHEMA,
    ACTIVE_BYTES / (1024*1024*1024) AS active_gb,
    TIME_TRAVEL_BYTES / (1024*1024*1024) AS time_travel_gb,
    ROUND(TIME_TRAVEL_BYTES / NULLIF(ACTIVE_BYTES, 0) * 100, 2) AS time_travel_percentage
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TIME_TRAVEL_BYTES > 0
ORDER BY time_travel_percentage DESC
LIMIT 20;

-- Deepak's learning: Some tables have Time Travel > Active data!
-- Consider reducing retention period


-- Deepak's analysis: Storage trend over last 30 days
SELECT
    USAGE_DATE,
    STORAGE_BYTES / (1024*1024*1024) AS total_storage_gb,
    STAGE_BYTES / (1024*1024*1024) AS stage_gb,
    FAILSAFE_BYTES / (1024*1024*1024) AS failsafe_gb,
    (STORAGE_BYTES - STAGE_BYTES - FAILSAFE_BYTES) / (1024*1024*1024) AS active_and_time_travel_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
WHERE USAGE_DATE >= DATEADD(day, -30, CURRENT_DATE())
ORDER BY USAGE_DATE DESC;

-- Deepak's observation: Can see storage growth trends


-- Deepak's analysis: Storage by database
SELECT
    TABLE_CATALOG AS database_name,
    COUNT(DISTINCT TABLE_NAME) AS table_count,
    SUM(ACTIVE_BYTES) / (1024*1024*1024) AS active_gb,
    SUM(TIME_TRAVEL_BYTES) / (1024*1024*1024) AS time_travel_gb,
    SUM(FAILSAFE_BYTES) / (1024*1024*1024) AS failsafe_gb,
    SUM(ACTIVE_BYTES + TIME_TRAVEL_BYTES + FAILSAFE_BYTES) / (1024*1024*1024) AS total_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE DELETED IS NULL
GROUP BY TABLE_CATALOG
ORDER BY total_gb DESC;

-- Deepak's learning: Identify which databases use most storage


/*
DEEPAK'S FAIL-SAFE & STORAGE INSIGHTS:
========================================

Storage Components:

1. Active Storage:
   - Current table data
   - What you actively query
   - Compressed and optimized

2. Time Travel Storage:
   - Historical data
   - Retention period (0-90 days)
   - User-controlled
   - Can query and restore

3. Fail-Safe Storage:
   - Disaster recovery
   - Fixed 7 days (after Time Travel)
   - Snowflake-controlled
   - Can't query directly
   - Snowflake support only

4. Stage Storage:
   - Files in stages
   - Unloaded data
   - Temporary files

Total Storage = Active + Time Travel + Fail-Safe + Stage

Storage Timeline:

Day 0: Data created
├─ Active Storage

Day 1-90: Time Travel Period
├─ Active Storage
├─ Time Travel Storage (changes)

After Time Travel: Fail-Safe Period
├─ Active Storage
├─ Fail-Safe Storage (7 days)

After Fail-Safe: Purged
├─ Active Storage only

Example with 90-day retention:
- Day 0-90: Time Travel available
- Day 91-97: Fail-Safe only
- Day 98+: Data purged

Fail-Safe Details:

What is Fail-Safe?
- Disaster recovery feature
- 7-day period after Time Travel
- Snowflake-managed
- Last resort recovery
- Costs storage

When Fail-Safe Activates:
- After Time Travel period ends
- After table is dropped
- After database is dropped
- Automatic, no user action

Fail-Safe Limitations:
❌ Can't query Fail-Safe data
❌ Can't restore yourself
❌ Must contact Snowflake support
❌ Recovery not guaranteed
❌ May take time to recover
❌ Costs apply

Fail-Safe vs Time Travel:

Feature          | Time Travel      | Fail-Safe
-----------------|------------------|------------------
Duration         | 0-90 days        | 7 days
Control          | User             | Snowflake
Query Data       | Yes ✅           | No ❌
Restore Data     | Yes ✅           | Support only
Cost             | Storage          | Storage
Purpose          | User recovery    | Disaster recovery

Storage Cost Optimization:

1. Reduce Retention Period:
   - Lower retention = less Time Travel storage
   - Only keep what you need
   - Review periodically

2. Use Transient Tables:
   - Max 1 day retention
   - No Fail-Safe
   - Lower cost
   - Good for staging

3. Use Temporary Tables:
   - Session-scoped
   - No Fail-Safe
   - Lowest cost
   - Good for temp work

4. Clean Up Stages:
   - Remove old files
   - Don't accumulate data
   - Use REMOVE command

5. Drop Unused Tables:
   - Don't keep old tables
   - Clean up regularly
   - Monitor usage

6. Cluster Large Tables:
   - Better compression
   - Less storage
   - Faster queries

Storage Monitoring Queries:

-- Daily storage cost estimate
SELECT
    USAGE_DATE,
    (STORAGE_BYTES + STAGE_BYTES + FAILSAFE_BYTES) / (1024*1024*1024) AS total_gb,
    (STORAGE_BYTES + STAGE_BYTES + FAILSAFE_BYTES) / (1024*1024*1024) * 23 AS estimated_monthly_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
ORDER BY USAGE_DATE DESC
LIMIT 30;
-- Assuming $23/TB/month

-- Tables with high Fail-Safe
SELECT
    TABLE_NAME,
    FAILSAFE_BYTES / (1024*1024*1024) AS failsafe_gb,
    FAILSAFE_BYTES / (1024*1024*1024) * 23 / 1024 AS estimated_monthly_cost_usd
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE FAILSAFE_BYTES > 0
ORDER BY failsafe_gb DESC
LIMIT 20;

-- Storage growth rate
SELECT
    USAGE_DATE,
    STORAGE_BYTES / (1024*1024*1024) AS storage_gb,
    LAG(STORAGE_BYTES) OVER (ORDER BY USAGE_DATE) / (1024*1024*1024) AS prev_day_gb,
    (STORAGE_BYTES - LAG(STORAGE_BYTES) OVER (ORDER BY USAGE_DATE)) / (1024*1024*1024) AS daily_growth_gb
FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
WHERE USAGE_DATE >= DATEADD(day, -30, CURRENT_DATE())
ORDER BY USAGE_DATE DESC;

Best Practices:

1. Monitor Regularly:
   - Check storage weekly
   - Track trends
   - Set alerts

2. Optimize Retention:
   - Match business needs
   - Don't over-retain
   - Review quarterly

3. Use Appropriate Table Types:
   - Permanent: Critical data
   - Transient: Staging data
   - Temporary: Session data

4. Clean Up:
   - Drop unused tables
   - Remove old stage files
   - Archive old data

5. Document Policies:
   - Retention policies
   - Storage limits
   - Review process

Real-World Example:

-- Identify optimization opportunities
WITH storage_analysis AS (
    SELECT
        TABLE_NAME,
        TABLE_SCHEMA,
        ACTIVE_BYTES / (1024*1024*1024) AS active_gb,
        TIME_TRAVEL_BYTES / (1024*1024*1024) AS time_travel_gb,
        FAILSAFE_BYTES / (1024*1024*1024) AS failsafe_gb,
        CASE
            WHEN TIME_TRAVEL_BYTES > ACTIVE_BYTES * 2
            THEN 'Reduce retention'
            WHEN FAILSAFE_BYTES > ACTIVE_BYTES
            THEN 'Consider transient'
            WHEN ACTIVE_BYTES < 0.1
            THEN 'Consider dropping'
            ELSE 'OK'
        END AS recommendation
    FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
    WHERE DELETED IS NULL
)
SELECT *
FROM storage_analysis
WHERE recommendation != 'OK'
ORDER BY (active_gb + time_travel_gb + failsafe_gb) DESC;

Deepak's Storage Monitoring Workflow:
1. Check account-level storage weekly
2. Identify top storage consumers
3. Analyze Time Travel vs Active ratio
4. Review Fail-Safe storage
5. Optimize retention periods
6. Clean up unused objects
7. Document changes
8. Track cost savings

Deepak's Storage Checklist:
✅ Monitor storage weekly
✅ Track storage trends
✅ Identify large tables
✅ Optimize retention periods
✅ Use appropriate table types
✅ Clean up regularly
✅ Document policies
✅ Review quarterly

Key Takeaway:
Monitor storage at account and table level. Optimize
Time Travel retention to balance protection vs cost.
Fail-Safe adds 7 days of disaster recovery but costs
storage. Use transient tables for staging data!

Practiced: February 2026
Status: ✅ Completed - Storage monitoring mastered
*/