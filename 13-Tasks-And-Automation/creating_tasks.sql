/*
===========================================
DEEPAK'S TASK AUTOMATION PRACTICE
===========================================
Topic: Creating and Managing Snowflake Tasks
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Tasks automate recurring SQL operations
- Can schedule tasks with intervals or CRON
- Tasks must be explicitly RESUMED to run
- Requires EXECUTE TASK privilege
===========================================
*/

-- Deepak's Note: Tasks are Snowflake's job scheduler
-- Perfect for ETL, data refreshes, and automated maintenance


-- ========================================
-- SETUP: CREATE DATABASE AND TABLE
-- ========================================

CREATE OR REPLACE TRANSIENT DATABASE deepak_task_db
COMMENT = 'Deepak - Database for task automation practice';

USE DATABASE deepak_task_db;


-- Deepak's scenario: Track customer signups automatically
CREATE OR REPLACE TABLE customer_signups (
    signup_id INT AUTOINCREMENT START = 1 INCREMENT = 1,
    customer_name VARCHAR(100) DEFAULT 'New Customer',
    signup_timestamp TIMESTAMP,
    source VARCHAR(50) DEFAULT 'Website',
    PRIMARY KEY (signup_id)
)
COMMENT = 'Deepak - Automated customer signup tracking';


-- ========================================
-- CREATE AUTOMATED TASK
-- ========================================

-- Deepak's learning: Create task to insert signup record every minute
CREATE OR REPLACE TASK deepak_signup_tracker
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = '1 MINUTE'
    COMMENT = 'Deepak - Simulates customer signups every minute'
    AS
    INSERT INTO customer_signups (signup_timestamp, customer_name, source)
    VALUES (
        CURRENT_TIMESTAMP(),
        CONCAT('Customer_', FLOOR(RANDOM() * 1000)),
        CASE FLOOR(RANDOM() * 3)
            WHEN 0 THEN 'Website'
            WHEN 1 THEN 'Mobile App'
            ELSE 'Partner Referral'
        END
    );

-- Deepak's observation: Task created but NOT running yet


-- View all tasks
SHOW TASKS;


-- ========================================
-- MANAGE TASK EXECUTION
-- ========================================

-- Deepak's learning: Tasks are created in SUSPENDED state
-- Must explicitly RESUME to start execution
ALTER TASK deepak_signup_tracker RESUME;

-- Deepak's note: Task is now running! Will execute every minute


-- Wait a few minutes, then check results
SELECT * FROM customer_signups
ORDER BY signup_timestamp DESC;

-- Deepak's observation: New records appearing automatically! ✅


-- Pause the task when not needed
ALTER TASK deepak_signup_tracker SUSPEND;

-- Deepak's learning: SUSPEND stops task execution
-- Good practice to suspend tasks when testing or not needed


-- Verify final results
SELECT
    COUNT(*) AS total_signups,
    MIN(signup_timestamp) AS first_signup,
    MAX(signup_timestamp) AS last_signup,
    source,
    COUNT(*) AS signups_by_source
FROM customer_signups
GROUP BY source
ORDER BY signups_by_source DESC;


/*
DEEPAK'S TASK AUTOMATION INSIGHTS:
==================================

Task Lifecycle:
1. CREATE TASK - Define the task (suspended by default)
2. ALTER TASK ... RESUME - Start task execution
3. Task runs on schedule automatically
4. ALTER TASK ... SUSPEND - Stop task execution
5. DROP TASK - Remove task completely

Task Components:
- WAREHOUSE: Compute resources for task execution
- SCHEDULE: When to run (interval or CRON)
- AS: SQL statement(s) to execute
- COMMENT: Documentation

Schedule Options:
- '1 MINUTE' - Every minute
- '5 MINUTES' - Every 5 minutes
- '1 HOUR' - Every hour
- USING CRON '0 9 * * *' - Daily at 9 AM

Task States:
- SUSPENDED: Created but not running
- STARTED: Running on schedule
- EXECUTING: Currently running a statement

Common Use Cases:
✅ Automated data refreshes
✅ Scheduled ETL pipelines
✅ Regular data quality checks
✅ Automated reporting
✅ Data archival and cleanup
✅ Incremental data loads

Best Practices:
1. Start with SUSPENDED state for testing
2. Use appropriate warehouse size
3. Monitor task execution history
4. Set up error notifications
5. Document task purpose in COMMENT
6. Use task dependencies for complex workflows
7. Suspend tasks when not needed to save costs

Monitoring Tasks:
- SHOW TASKS - List all tasks
- TASK_HISTORY() - View execution history
- INFORMATION_SCHEMA.TASK_HISTORY - Detailed logs

Cost Considerations:
- Tasks consume warehouse credits when running
- Suspend unused tasks
- Use smaller warehouses for simple tasks
- Monitor execution frequency

Real-World Example:
-- Daily customer metrics refresh
CREATE TASK daily_metrics_refresh
    WAREHOUSE = etl_wh
    SCHEDULE = 'USING CRON 0 2 * * * UTC'  -- 2 AM daily
    AS
    INSERT INTO customer_metrics
    SELECT
        CURRENT_DATE() AS metric_date,
        COUNT(*) AS total_customers,
        SUM(total_spent) AS revenue
    FROM customers
    WHERE signup_date = CURRENT_DATE() - 1;

Next Steps:
- Learn task dependencies (tree of tasks)
- Explore CRON expressions
- Implement error handling
- Create task monitoring dashboard

Practiced: February 2026
Status: ✅ Completed - Understanding task automation
*/



