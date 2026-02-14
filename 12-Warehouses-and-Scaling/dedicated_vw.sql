/*
===========================================
DEEPAK'S DEDICATED WAREHOUSES PRACTICE
===========================================
Topic: Creating Dedicated Virtual Warehouses for Teams
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Dedicated warehouses isolate workloads
- Prevents resource contention between teams
- Each team gets predictable performance
- Independent auto-suspend/resume settings
- Better cost tracking per team
- Warehouse size based on workload needs
===========================================
*/

-- Deepak's Note: Dedicated warehouses are like giving each team their own car
-- No fighting over resources, everyone gets where they need to go!


-- ========================================
-- CREATE DEDICATED WAREHOUSES
-- ========================================

-- Deepak's scenario: Create warehouse for Data Science team
-- SMALL size for analytical workloads
CREATE OR REPLACE WAREHOUSE deepak_ds_wh
WITH
    WAREHOUSE_SIZE = 'SMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300              -- 5 minutes idle time
    AUTO_RESUME = TRUE              -- Auto-start on query
    MIN_CLUSTER_COUNT = 1           -- Single cluster
    MAX_CLUSTER_COUNT = 1           -- No multi-cluster
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'Deepak - Dedicated warehouse for Data Scientists';

-- Deepak's learning: SMALL warehouse = 2 credits/hour
-- AUTO_SUSPEND = 300 seconds (5 min) saves costs
-- AUTO_RESUME = TRUE for convenience


-- Deepak's scenario: Create warehouse for DBA team
-- XSMALL size for administrative tasks
CREATE OR REPLACE WAREHOUSE deepak_dba_wh
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300              -- 5 minutes idle time
    AUTO_RESUME = TRUE              -- Auto-start on query
    MIN_CLUSTER_COUNT = 1           -- Single cluster
    MAX_CLUSTER_COUNT = 1           -- No multi-cluster
    SCALING_POLICY = 'STANDARD'
    COMMENT = 'Deepak - Dedicated warehouse for DBAs';

-- Deepak's learning: XSMALL warehouse = 1 credit/hour
-- Smaller size for lightweight admin tasks
-- Separate from data science workloads


-- Deepak's observation: Two dedicated warehouses created
-- Data Scientists won't impact DBA performance and vice versa


-- ========================================
-- CREATE ROLES FOR TEAMS
-- ========================================

-- Deepak's scenario: Create role for Data Science team
CREATE OR REPLACE ROLE deepak_data_scientist
COMMENT = 'Deepak - Role for Data Science team members';

-- Grant warehouse usage to Data Scientists
GRANT USAGE ON WAREHOUSE deepak_ds_wh TO ROLE deepak_data_scientist;

-- Deepak's learning: USAGE privilege allows running queries on warehouse


-- Deepak's scenario: Create role for DBA team
CREATE OR REPLACE ROLE deepak_dba
COMMENT = 'Deepak - Role for Database Administrators';

-- Grant warehouse usage to DBAs
GRANT USAGE ON WAREHOUSE deepak_dba_wh TO ROLE deepak_dba;

-- Deepak's observation: Each role has access to their dedicated warehouse


-- ========================================
-- CREATE USERS FOR DATA SCIENCE TEAM
-- ========================================

-- Deepak's scenario: Create Data Scientists
CREATE OR REPLACE USER priya_ds
    PASSWORD = 'DataSci2026!'
    LOGIN_NAME = 'priya_ds'
    DEFAULT_ROLE = 'deepak_data_scientist'
    DEFAULT_WAREHOUSE = 'deepak_ds_wh'
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Deepak - Priya, Data Scientist';

CREATE OR REPLACE USER rahul_ds
    PASSWORD = 'DataSci2026!'
    LOGIN_NAME = 'rahul_ds'
    DEFAULT_ROLE = 'deepak_data_scientist'
    DEFAULT_WAREHOUSE = 'deepak_ds_wh'
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Deepak - Rahul, Data Scientist';

CREATE OR REPLACE USER amit_ds
    PASSWORD = 'DataSci2026!'
    LOGIN_NAME = 'amit_ds'
    DEFAULT_ROLE = 'deepak_data_scientist'
    DEFAULT_WAREHOUSE = 'deepak_ds_wh'
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Deepak - Amit, Data Scientist';

-- Deepak's observation: 3 Data Scientists created


-- Grant role to Data Scientists
GRANT ROLE deepak_data_scientist TO USER priya_ds;
GRANT ROLE deepak_data_scientist TO USER rahul_ds;
GRANT ROLE deepak_data_scientist TO USER amit_ds;

-- Deepak's learning: All Data Scientists share deepak_ds_wh warehouse


-- ========================================
-- CREATE USERS FOR DBA TEAM
-- ========================================

-- Deepak's scenario: Create DBAs
CREATE OR REPLACE USER sarah_dba
    PASSWORD = 'DBA2026!'
    LOGIN_NAME = 'sarah_dba'
    DEFAULT_ROLE = 'deepak_dba'
    DEFAULT_WAREHOUSE = 'deepak_dba_wh'
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Deepak - Sarah, Database Administrator';

CREATE OR REPLACE USER michael_dba
    PASSWORD = 'DBA2026!'
    LOGIN_NAME = 'michael_dba'
    DEFAULT_ROLE = 'deepak_dba'
    DEFAULT_WAREHOUSE = 'deepak_dba_wh'
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Deepak - Michael, Database Administrator';

-- Deepak's observation: 2 DBAs created


-- Grant role to DBAs
GRANT ROLE deepak_dba TO USER sarah_dba;
GRANT ROLE deepak_dba TO USER michael_dba;

-- Deepak's learning: All DBAs share deepak_dba_wh warehouse


-- ========================================
-- VERIFY SETUP
-- ========================================

-- Deepak's check: View all warehouses
SHOW WAREHOUSES LIKE 'deepak_%';

-- Deepak's check: View all roles
SHOW ROLES LIKE 'deepak_%';

-- Deepak's check: View all users
SHOW USERS LIKE '%_ds';
SHOW USERS LIKE '%_dba';


-- ========================================
-- TEST WAREHOUSE ISOLATION
-- ========================================

-- Deepak's experiment: Simulate Data Scientist query
-- (Would run as priya_ds user)
USE WAREHOUSE deepak_ds_wh;

SELECT
    'Data Science Team' AS team,
    CURRENT_WAREHOUSE() AS warehouse,
    CURRENT_ROLE() AS role;

-- Deepak's observation: Uses deepak_ds_wh


-- Deepak's experiment: Simulate DBA query
-- (Would run as sarah_dba user)
USE WAREHOUSE deepak_dba_wh;

SELECT
    'DBA Team' AS team,
    CURRENT_WAREHOUSE() AS warehouse,
    CURRENT_ROLE() AS role;

-- Deepak's observation: Uses deepak_dba_wh
-- Complete isolation between teams!


-- ========================================
-- CLEANUP (OPTIONAL)
-- ========================================

-- Deepak's note: Uncomment to clean up demo objects

/*
-- Drop users
DROP USER IF EXISTS sarah_dba;
DROP USER IF EXISTS michael_dba;

DROP USER IF EXISTS priya_ds;
DROP USER IF EXISTS rahul_ds;
DROP USER IF EXISTS amit_ds;

-- Drop roles
DROP ROLE IF EXISTS deepak_data_scientist;
DROP ROLE IF EXISTS deepak_dba;

-- Drop warehouses
DROP WAREHOUSE IF EXISTS deepak_ds_wh;
DROP WAREHOUSE IF EXISTS deepak_dba_wh;
*/

-- Deepak's learning: Always clean up demo objects to save costs


/*
DEEPAK'S DEDICATED WAREHOUSES INSIGHTS:
========================================

What are Dedicated Warehouses?

- Separate virtual warehouses for different teams/workloads
- Complete resource isolation
- Independent sizing and configuration
- Prevents resource contention
- Better cost tracking and accountability

Why Use Dedicated Warehouses?

1. Performance Isolation:
   - Heavy queries don't impact other teams
   - Predictable performance
   - No "noisy neighbor" problem

2. Cost Tracking:
   - See exactly what each team spends
   - Charge back to departments
   - Budget management

3. Custom Configuration:
   - Different sizes per workload
   - Different auto-suspend times
   - Different scaling policies

4. Security:
   - Role-based access control
   - Team can't use other warehouses
   - Audit trail per team

Warehouse Sizing Guide:

┌────────────┬──────────────┬─────────────┬──────────────┐
│ Size       │ Credits/Hour │ Use Case    │ Team Size    │
├────────────┼──────────────┼─────────────┼──────────────┤
│ XSMALL     │ 1            │ Admin tasks │ 1-2 users    │
│ SMALL      │ 2            │ Analytics   │ 3-5 users    │
│ MEDIUM     │ 4            │ Heavy ETL   │ 5-10 users   │
│ LARGE      │ 8            │ Data Sci    │ 10-20 users  │
│ XLARGE     │ 16           │ ML training │ 20+ users    │
│ 2XLARGE    │ 32           │ Enterprise  │ Large teams  │
└────────────┴──────────────┴─────────────┴──────────────┘

Common Warehouse Patterns:

1. By Team:
   - Data Science warehouse
   - Analytics warehouse
   - DBA warehouse
   - ETL warehouse

2. By Workload:
   - Ad-hoc queries warehouse
   - Reporting warehouse
   - Data loading warehouse
   - ML training warehouse

3. By Priority:
   - Production warehouse (large, always on)
   - Development warehouse (small, auto-suspend)
   - Testing warehouse (xsmall, auto-suspend)

4. By Department:
   - Finance warehouse
   - Marketing warehouse
   - Sales warehouse
   - Operations warehouse

Auto-Suspend Best Practices:

Development/Testing:
- AUTO_SUSPEND = 60-300 seconds (1-5 min)
- Aggressive cost savings
- Users tolerate brief startup

Production/Analytics:
- AUTO_SUSPEND = 600-1800 seconds (10-30 min)
- Balance cost vs convenience
- Reduce startup delays

Always-On (Critical):
- AUTO_SUSPEND = NULL (never suspend)
- 24/7 availability
- Highest cost, best performance

Cost Comparison Example:

Shared Warehouse (Bad):
- 1 LARGE warehouse for all teams
- 8 credits/hour × 24 hours = 192 credits/day
- Always running (someone always working)
- Cost: $384/day (at $2/credit)

Dedicated Warehouses (Good):
- Data Science: SMALL, 8 hours/day = 16 credits
- Analytics: SMALL, 6 hours/day = 12 credits
- DBA: XSMALL, 2 hours/day = 2 credits
- ETL: MEDIUM, 4 hours/day = 16 credits
- Total: 46 credits/day
- Cost: $92/day (at $2/credit)
- Savings: 76%!

Monitoring Warehouse Usage:

-- Check warehouse usage by team
SELECT
    warehouse_name,
    SUM(credits_used) AS total_credits,
    SUM(credits_used) * 2 AS estimated_cost_usd,
    COUNT(DISTINCT user_name) AS unique_users,
    COUNT(*) AS query_count
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name IN ('DEEPAK_DS_WH', 'DEEPAK_DBA_WH')
AND start_time >= DATEADD('day', -7, CURRENT_TIMESTAMP())
GROUP BY warehouse_name
ORDER BY total_credits DESC;

-- Check which users use which warehouses
SELECT
    user_name,
    warehouse_name,
    COUNT(*) AS query_count,
    SUM(execution_time) / 1000 AS total_seconds
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE warehouse_name IN ('DEEPAK_DS_WH', 'DEEPAK_DBA_WH')
AND start_time >= DATEADD('day', -1, CURRENT_TIMESTAMP())
GROUP BY user_name, warehouse_name
ORDER BY warehouse_name, query_count DESC;

Resource Monitors:

-- Create resource monitor for Data Science team
CREATE OR REPLACE RESOURCE MONITOR deepak_ds_monitor
WITH
    CREDIT_QUOTA = 100              -- 100 credits per month
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 75 PERCENT DO NOTIFY     -- Alert at 75%
        ON 90 PERCENT DO SUSPEND    -- Suspend at 90%
        ON 100 PERCENT DO SUSPEND_IMMEDIATE;  -- Hard stop at 100%

-- Assign monitor to warehouse
ALTER WAREHOUSE deepak_ds_wh
SET RESOURCE_MONITOR = deepak_ds_monitor;

Best Practices:

1. Right-Size Warehouses:
   - Start small, scale up if needed
   - Monitor query performance
   - Avoid over-provisioning

2. Set Appropriate Auto-Suspend:
   - Balance cost vs convenience
   - Shorter for dev/test
   - Longer for production

3. Use Resource Monitors:
   - Prevent runaway costs
   - Alert before limits
   - Automatic suspension

4. Grant Minimal Privileges:
   - USAGE only (not MODIFY)
   - Users can't resize
   - Admins control sizing

5. Monitor and Optimize:
   - Review usage weekly
   - Identify idle warehouses
   - Consolidate if possible

6. Document Warehouse Purpose:
   - Clear naming convention
   - Comment on intended use
   - Communicate to teams

Common Mistakes:

❌ One warehouse for everything (contention)
❌ Warehouses too large (wasted credits)
❌ No auto-suspend (24/7 costs)
❌ No resource monitors (runaway costs)
❌ Users can modify warehouses (chaos)
❌ No usage tracking (no accountability)

Real-World Example:

Company: E-commerce with 50 employees

Warehouses:
1. deepak_etl_wh (MEDIUM)
   - Nightly data loads
   - 4 hours/night
   - 16 credits/day

2. deepak_analytics_wh (SMALL)
   - Business analysts
   - 8 hours/day
   - 16 credits/day

3. deepak_ds_wh (LARGE)
   - Data scientists
   - 6 hours/day
   - 48 credits/day

4. deepak_reporting_wh (SMALL)
   - Dashboard queries
   - 12 hours/day
   - 24 credits/day

5. deepak_adhoc_wh (XSMALL)
   - Ad-hoc queries
   - 4 hours/day
   - 4 credits/day

Total: 108 credits/day = $216/day
vs Single XLARGE 24/7: 384 credits/day = $768/day
Savings: 72%!

Deepak's Warehouse Strategy:

1. Identify distinct workloads
2. Create dedicated warehouse per workload
3. Size appropriately (start small)
4. Set aggressive auto-suspend
5. Create resource monitors
6. Grant USAGE only to users
7. Monitor usage weekly
8. Optimize and consolidate

Deepak's Warehouse Checklist:

✅ Workloads identified
✅ Warehouses created and sized
✅ Auto-suspend configured
✅ Auto-resume enabled
✅ Roles created per team
✅ Users assigned to roles
✅ Resource monitors set
✅ Usage tracking enabled
✅ Documentation complete

Key Takeaway:
Dedicated warehouses provide performance isolation,
cost tracking, and custom configuration per team.
Right-size warehouses, set aggressive auto-suspend,
use resource monitors, and track usage. Can save
50-75% on compute costs vs shared warehouse!

Practiced: February 2026
Status: ✅ Completed - Dedicated warehouses mastered
*/
