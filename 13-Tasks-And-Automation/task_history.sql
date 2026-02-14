/*
===========================================
DEEPAK'S TASK MONITORING PRACTICE
===========================================
Topic: Monitoring Task Execution History
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- TASK_HISTORY() shows task execution details
- Can filter by time range and task name
- Shows success/failure status
- Includes error messages
- Essential for troubleshooting
===========================================
*/

-- Deepak's Note: Task history is your execution log
-- Like checking security camera footage to see what happened!


-- ========================================
-- SETUP: VIEW EXISTING TASKS
-- ========================================

-- Deepak's check: See all tasks in database
SHOW TASKS IN deepak_task_db.public;

-- Deepak's observation: Lists all tasks and their states


USE DATABASE deepak_task_db;







-- ========================================
-- VIEW ALL TASK EXECUTION HISTORY
-- ========================================

-- Deepak's monitoring: See all recent task executions
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY scheduled_time DESC;

-- Deepak's learning: Shows all task runs across database
-- Columns include:
-- - name: Task name
-- - database_name, schema_name: Location
-- - query_id: Unique execution ID
-- - scheduled_time: When task was scheduled
-- - completed_time: When task finished
-- - state: SUCCESS, FAILED, SKIPPED
-- - error_code, error_message: If failed
-- - query_text: SQL that ran


-- ========================================
-- FILTER BY SPECIFIC TASK
-- ========================================

-- Deepak's scenario: Check history for specific task
-- Last 4 hours, limit to 5 results
SELECT
    name,
    scheduled_time,
    completed_time,
    state,
    DATEDIFF('second', scheduled_time, completed_time) AS duration_seconds,
    error_code,
    error_message,
    query_id
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => DATEADD('hour', -4, CURRENT_TIMESTAMP()),
    RESULT_LIMIT => 5,
    TASK_NAME => 'DEEPAK_CUSTOMER_CLEAN'
))
ORDER BY scheduled_time DESC;

-- Deepak's learning: Filters to specific task
-- Shows last 5 executions in past 4 hours
-- Calculates execution duration


-- ========================================
-- FILTER BY TIME RANGE
-- ========================================

-- Deepak's scenario: Check all tasks in specific time window
SELECT
    name,
    scheduled_time,
    completed_time,
    state,
    error_message
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => TO_TIMESTAMP_LTZ('2026-02-14 10:00:00.000 -0800'),
    SCHEDULED_TIME_RANGE_END => TO_TIMESTAMP_LTZ('2026-02-14 12:00:00.000 -0800')
))
ORDER BY scheduled_time DESC;

-- Deepak's observation: Shows all task executions in 2-hour window
-- Useful for troubleshooting specific time periods


-- ========================================
-- CHECK CURRENT TIMESTAMP
-- ========================================

-- Deepak's utility: Get current timestamp in LTZ format
SELECT TO_TIMESTAMP_LTZ(CURRENT_TIMESTAMP()) AS current_time_ltz;

-- Deepak's note: Useful for constructing time range queries


-- ========================================
-- MONITOR TASK SUCCESS/FAILURE
-- ========================================

-- Deepak's monitoring: See only failed tasks
SELECT
    name,
    scheduled_time,
    state,
    error_code,
    error_message,
    query_text
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => DATEADD('day', -1, CURRENT_TIMESTAMP())
))
WHERE state = 'FAILED'
ORDER BY scheduled_time DESC;

-- Deepak's learning: Quickly identify problems
-- Shows what went wrong and when


-- Deepak's monitoring: Task success rate
SELECT
    name,
    COUNT(*) AS total_runs,
    SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 ELSE 0 END) AS successful_runs,
    SUM(CASE WHEN state = 'FAILED' THEN 1 ELSE 0 END) AS failed_runs,
    ROUND(100.0 * SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP())
))
GROUP BY name
ORDER BY failed_runs DESC;

-- Deepak's observation: Shows reliability of each task
-- Helps identify problematic tasks


-- ========================================
-- ANALYZE TASK PERFORMANCE
-- ========================================

-- Deepak's analysis: Average execution time per task
SELECT
    name,
    COUNT(*) AS execution_count,
    AVG(DATEDIFF('second', scheduled_time, completed_time)) AS avg_duration_seconds,
    MIN(DATEDIFF('second', scheduled_time, completed_time)) AS min_duration_seconds,
    MAX(DATEDIFF('second', scheduled_time, completed_time)) AS max_duration_seconds
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP())
))
WHERE state = 'SUCCEEDED'
GROUP BY name
ORDER BY avg_duration_seconds DESC;

-- Deepak's learning: Identify slow tasks
-- Helps optimize warehouse sizing


/*
DEEPAK'S TASK MONITORING INSIGHTS:
===================================

TASK_HISTORY() Function:

Purpose:
- View execution history of tasks
- Monitor success/failure rates
- Troubleshoot errors
- Analyze performance

Key Parameters:

1. SCHEDULED_TIME_RANGE_START:
   - Start of time window
   - Required for filtering
   - Use DATEADD() for relative times

2. SCHEDULED_TIME_RANGE_END:
   - End of time window
   - Optional (defaults to current time)

3. RESULT_LIMIT:
   - Max number of results
   - Default: 10,000
   - Max: 10,000

4. TASK_NAME:
   - Filter to specific task
   - Case-sensitive
   - Exact match required

Important Columns:

- NAME: Task name
- STATE: SUCCEEDED, FAILED, SKIPPED, CANCELLED
- SCHEDULED_TIME: When task was scheduled to run
- COMPLETED_TIME: When task finished
- QUERY_ID: Unique execution identifier
- ERROR_CODE: Error code if failed
- ERROR_MESSAGE: Error description
- QUERY_TEXT: SQL that was executed
- DATABASE_NAME, SCHEMA_NAME: Task location

Task States:

✅ SUCCEEDED: Task completed successfully
❌ FAILED: Task encountered error
⏭️ SKIPPED: Task skipped (condition not met)
🚫 CANCELLED: Task manually cancelled

Common Monitoring Queries:

1. Recent Executions:
   SELECT * FROM TABLE(TASK_HISTORY())
   ORDER BY scheduled_time DESC LIMIT 10;

2. Failed Tasks Today:
   SELECT * FROM TABLE(TASK_HISTORY(
       SCHEDULED_TIME_RANGE_START => CURRENT_DATE()
   ))
   WHERE state = 'FAILED';

3. Specific Task Last Hour:
   SELECT * FROM TABLE(TASK_HISTORY(
       SCHEDULED_TIME_RANGE_START => DATEADD('hour', -1, CURRENT_TIMESTAMP()),
       TASK_NAME => 'MY_TASK'
   ));

4. Success Rate:
   SELECT
       name,
       COUNT(*) AS total,
       SUM(IFF(state = 'SUCCEEDED', 1, 0)) AS success
   FROM TABLE(TASK_HISTORY(...))
   GROUP BY name;

Best Practices:

1. Regular Monitoring:
   - Check task history daily
   - Set up alerts for failures
   - Track success rates

2. Performance Analysis:
   - Monitor execution times
   - Identify slow tasks
   - Optimize warehouse sizing

3. Error Handling:
   - Review error messages
   - Fix root causes
   - Implement retry logic

4. Time Range Selection:
   - Use appropriate time windows
   - Don't query too far back
   - Balance detail vs performance

5. Documentation:
   - Document expected behavior
   - Note normal execution times
   - Track changes over time

Troubleshooting Workflow:

1. Identify Problem:
   - Check for failed tasks
   - Review error messages
   - Note when failures started

2. Analyze Context:
   - Check task dependencies
   - Review recent changes
   - Verify data availability

3. Fix Issue:
   - Correct SQL errors
   - Adjust warehouse size
   - Fix data quality issues

4. Verify Fix:
   - Monitor next execution
   - Check success rate
   - Validate results

Real-World Example:

-- Daily monitoring dashboard
SELECT
    name,
    COUNT(*) AS runs_today,
    SUM(IFF(state = 'SUCCEEDED', 1, 0)) AS successful,
    SUM(IFF(state = 'FAILED', 1, 0)) AS failed,
    AVG(DATEDIFF('second', scheduled_time, completed_time)) AS avg_seconds,
    MAX(completed_time) AS last_run
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => CURRENT_DATE()
))
GROUP BY name
ORDER BY failed DESC, name;

Common Issues:

❌ Task not appearing in history
   → Task never ran (check if RESUMED)
   → Check correct database/schema

❌ Too many results
   → Add RESULT_LIMIT parameter
   → Narrow time range
   → Filter by task name

❌ Missing recent executions
   → History may have delay
   → Wait a few minutes
   → Refresh query

Key Takeaway:
TASK_HISTORY() is essential for monitoring
automated workflows. Use it to track success
rates, identify failures, and optimize
performance. Regular monitoring prevents
issues and ensures reliable automation!

Practiced: February 2026
Status: ✅ Completed - Task monitoring mastered
*/
  
  
 
