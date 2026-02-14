/*
===========================================
DEEPAK'S CRON SCHEDULING PRACTICE
===========================================
Topic: Using CRON Expressions for Task Scheduling
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- CRON expressions provide flexible scheduling
- Can schedule tasks at specific times/days
- Supports timezones (UTC, America/Los_Angeles, etc.)
- Use 'L' for last day of month/week
- More powerful than simple intervals
===========================================
*/

-- Deepak's Note: CRON is like a calendar for your tasks
-- Schedule anything from "every minute" to "last Friday of month at 7 AM"


-- ========================================
-- SETUP: CREATE DATABASE AND TABLE
-- ========================================

USE DATABASE deepak_task_db;

-- Deepak's scenario: Track customer activity
CREATE OR REPLACE TABLE deepak_task_db.public.customers (
    customer_id INT AUTOINCREMENT START = 1 INCREMENT = 1,
    first_name VARCHAR(40) DEFAULT 'Customer',
    create_date TIMESTAMP,
    PRIMARY KEY (customer_id)
)
COMMENT = 'Deepak - Customer tracking table';


-- ========================================
-- SIMPLE INTERVAL SCHEDULING
-- ========================================

-- Deepak's example: Task with simple interval (every 60 minutes)
CREATE OR REPLACE TASK deepak_task_db.public.deepak_customer_insert_interval
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = '60 MINUTE'
    COMMENT = 'Deepak - Simple interval scheduling (every hour)'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's observation: Simple but limited
-- Can't specify "run at 9 AM" or "run on Fridays only"


-- ========================================
-- CRON EXPRESSION SCHEDULING
-- ========================================

-- Deepak's example: Task with CRON expression
-- Runs at 7 AM and 10 AM on the last Friday of every month
CREATE OR REPLACE TASK deepak_task_db.public.deepak_customer_insert_cron
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON 0 7,10 * * 5L UTC'
    COMMENT = 'Deepak - CRON scheduling (7 AM & 10 AM on last Friday)'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's learning: Much more flexible!
-- 0 = minute (0)
-- 7,10 = hours (7 AM and 10 AM)
-- * = any day of month
-- * = any month
-- 5L = last Friday (5 = Friday, L = last)


-- ========================================
-- CRON EXPRESSION FORMAT
-- ========================================

/*
Deepak's CRON Cheat Sheet:

# __________ minute (0-59)
# | ________ hour (0-23)
# | | ______ day of month (1-31, or L)
# | | | ____ month (1-12, JAN-DEC)
# | | | | __ day of week (0-6, SUN-SAT, or L)
# | | | | |
# | | | | |
# * * * * *

Special Characters:
* = any value
, = list of values (e.g., 1,3,5)
- = range of values (e.g., 1-5)
/ = step values (e.g., */15 = every 15)
L = last (day of month or week)

Examples:
'0 9 * * *' = Every day at 9 AM
'0 */2 * * *' = Every 2 hours
'0 9-17 * * MON-FRI' = Business hours (9 AM-5 PM, Mon-Fri)
'0 0 1 * *' = First day of every month at midnight
'0 0 * * 0' = Every Sunday at midnight
*/


-- ========================================
-- COMMON CRON PATTERNS
-- ========================================

-- Deepak's example 1: Every minute
CREATE OR REPLACE TASK deepak_task_db.public.deepak_every_minute
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON * * * * * UTC'
    COMMENT = 'Deepak - Runs every minute'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's note: Good for testing, expensive for production!


-- Deepak's example 2: Every day at 6 AM UTC
CREATE OR REPLACE TASK deepak_task_db.public.deepak_daily_6am
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON 0 6 * * * UTC'
    COMMENT = 'Deepak - Daily at 6 AM UTC'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's learning: Perfect for daily ETL jobs


-- Deepak's example 3: Every hour from 9 AM to 5 PM on Sundays (LA time)
CREATE OR REPLACE TASK deepak_task_db.public.deepak_sunday_business_hours
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON 0 9-17 * * SUN America/Los_Angeles'
    COMMENT = 'Deepak - Sundays 9 AM-5 PM Pacific time'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's observation: Timezone support is powerful!
-- Can schedule for specific regions


-- Deepak's example 4: Twice daily (9 AM and 5 PM UTC)
CREATE OR REPLACE TASK deepak_task_db.public.deepak_twice_daily
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON 0 9,17 * * * UTC'
    COMMENT = 'Deepak - Twice daily at 9 AM and 5 PM'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's learning: Comma separates multiple values


-- ========================================
-- ADVANCED CRON PATTERNS
-- ========================================

-- Deepak's example 5: Every 15 minutes during business hours
CREATE OR REPLACE TASK deepak_task_db.public.deepak_every_15min_business
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON */15 9-17 * * MON-FRI UTC'
    COMMENT = 'Deepak - Every 15 min, 9 AM-5 PM, Mon-Fri'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's observation: */15 = every 15 minutes
-- 9-17 = 9 AM to 5 PM
-- MON-FRI = weekdays only


-- Deepak's example 6: First day of every month at midnight
CREATE OR REPLACE TASK deepak_task_db.public.deepak_monthly_first
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON 0 0 1 * * UTC'
    COMMENT = 'Deepak - First day of month at midnight'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's learning: Perfect for monthly reports


-- Deepak's example 7: Last day of every month at 11 PM
CREATE OR REPLACE TASK deepak_task_db.public.deepak_monthly_last
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON 0 23 L * * UTC'
    COMMENT = 'Deepak - Last day of month at 11 PM'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's observation: L = last day of month


-- Deepak's example 8: Every weekday at 8 AM
CREATE OR REPLACE TASK deepak_task_db.public.deepak_weekday_morning
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = 'USING CRON 0 8 * * MON-FRI America/New_York'
    COMMENT = 'Deepak - Weekdays at 8 AM Eastern time'
    AS
    INSERT INTO deepak_task_db.public.customers (create_date)
    VALUES (CURRENT_TIMESTAMP());

-- Deepak's learning: Great for business day processing


-- ========================================
-- VIEW ALL TASKS
-- ========================================

-- Deepak's check: See all created tasks
SHOW TASKS IN deepak_task_db.public;

-- Deepak's observation: All tasks created in SUSPENDED state


/*
DEEPAK'S CRON SCHEDULING INSIGHTS:
===================================

CRON vs Simple Intervals:

Simple Intervals:
✅ Easy to understand
✅ Good for regular intervals
❌ Can't specify exact times
❌ Can't specify days of week
❌ No timezone support

CRON Expressions:
✅ Precise scheduling
✅ Day/time control
✅ Timezone support
✅ Complex patterns
❌ Steeper learning curve

Common CRON Patterns:

┌─────────────────────────┬──────────────────────────────┐
│ Pattern                 │ CRON Expression              │
├─────────────────────────┼──────────────────────────────┤
│ Every minute            │ * * * * * UTC                │
│ Every hour              │ 0 * * * * UTC                │
│ Every day at 2 AM       │ 0 2 * * * UTC                │
│ Every Monday at 9 AM    │ 0 9 * * MON UTC              │
│ Weekdays at 8 AM        │ 0 8 * * MON-FRI UTC          │
│ Every 15 minutes        │ */15 * * * * UTC             │
│ Twice daily (9 AM, 5 PM)│ 0 9,17 * * * UTC             │
│ First of month          │ 0 0 1 * * UTC                │
│ Last Friday at 5 PM     │ 0 17 * * 5L UTC              │
│ Business hours          │ 0 9-17 * * MON-FRI UTC       │
└─────────────────────────┴──────────────────────────────┘

Timezone Examples:

UTC (Universal):
SCHEDULE = 'USING CRON 0 9 * * * UTC'

US Pacific:
SCHEDULE = 'USING CRON 0 9 * * * America/Los_Angeles'

US Eastern:
SCHEDULE = 'USING CRON 0 9 * * * America/New_York'

India:
SCHEDULE = 'USING CRON 0 9 * * * Asia/Kolkata'

London:
SCHEDULE = 'USING CRON 0 9 * * * Europe/London'

Real-World Examples:

1. Daily ETL (2 AM UTC):
   SCHEDULE = 'USING CRON 0 2 * * * UTC'

2. Hourly Data Refresh (Business Hours):
   SCHEDULE = 'USING CRON 0 9-17 * * MON-FRI UTC'

3. Weekly Report (Monday 8 AM):
   SCHEDULE = 'USING CRON 0 8 * * MON UTC'

4. Monthly Cleanup (Last day, 11 PM):
   SCHEDULE = 'USING CRON 0 23 L * * UTC'

5. Quarterly Report (First day of Jan/Apr/Jul/Oct):
   SCHEDULE = 'USING CRON 0 0 1 1,4,7,10 * UTC'

Best Practices:

1. Use UTC for Consistency:
   - Avoids daylight saving issues
   - Clear for global teams
   - Convert to local time in queries

2. Avoid Peak Hours:
   - Schedule heavy jobs at night
   - Spread out tasks
   - Avoid resource contention

3. Test with Frequent Schedule:
   - Start with '1 MINUTE'
   - Verify task works
   - Change to production schedule

4. Document Schedule:
   - Use COMMENT to explain
   - Note timezone
   - Explain business reason

5. Monitor Execution:
   - Check task history
   - Verify expected timing
   - Alert on failures

Common Mistakes:

❌ Forgetting timezone (defaults to UTC)
❌ Using 24 for midnight (use 0)
❌ Confusing day of month vs day of week
❌ Not testing CRON expression
❌ Scheduling too frequently
❌ No error handling

Testing CRON Expressions:

-- Test with frequent schedule first
CREATE TASK test_task
    WAREHOUSE = wh
    SCHEDULE = '1 MINUTE'  -- Test every minute
    AS SELECT 1;

-- Verify it works
ALTER TASK test_task RESUME;

-- Wait and check
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE NAME = 'TEST_TASK'
ORDER BY SCHEDULED_TIME DESC;

-- Change to production schedule
ALTER TASK test_task SUSPEND;
ALTER TASK test_task SET SCHEDULE = 'USING CRON 0 2 * * * UTC';
ALTER TASK test_task RESUME;

Deepak's CRON Workflow:

1. Identify business requirement
2. Choose appropriate CRON pattern
3. Select timezone
4. Create task with test schedule
5. Resume and verify execution
6. Suspend and update to production schedule
7. Resume for production
8. Monitor and adjust

Deepak's CRON Checklist:

✅ Business requirement clear
✅ CRON expression tested
✅ Timezone specified
✅ Schedule documented in COMMENT
✅ Task tested before production
✅ Monitoring enabled
✅ Error handling implemented

Key Takeaway:
CRON expressions provide powerful, flexible
scheduling for Snowflake tasks. Use them for
precise timing, day-of-week control, and timezone
support. Always test with frequent schedule first,
then switch to production schedule. Document
timezone and business reason in COMMENT!

Practiced: February 2026
Status: ✅ Completed - CRON scheduling mastered
*/