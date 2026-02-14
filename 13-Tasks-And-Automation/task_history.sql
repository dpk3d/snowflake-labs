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

-- Deepak's monitoring: See all-- Deepak's monitoring: See all-- Deepak'sE(INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY scheduled_time DESC;

-- Deepak's learning: Shows all task runs across database
-- Columns include:
-- - name-- - name-- - name--ab-- - nam, schema_name: Location
-- - query_id: Unique executi-- - query_id: Unique executi-- - queras scheduled
-- - completed_time: -- - completed_time: -- state: SUCCESS, FAILED, SKIPPED
-- - error_code, error_message: If failed
-- - query_text: SQL that ran


-- ==========================-- ==========================-- ==========================-- ========================

-- Deepak's scenario: Check history for specific tas-- Deepak's scenario: Check history for spCT
    name,
    scheduled_time,
    completed_t    completed_t    completed_t    cd',    completed_t    completed_t    completed_t    cd',     error_code,
    error_message,
    query_id
FROM TABLE(INFORMATION_SCHEMA.TASFROM TABLE(INFORMATION_SCHEMA.TASGE_START => DATEADD('hour', -4, CURRENT_TIMESTAMP()),
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
FROM TABLE(INFORMATIONFROM TABLE(INFORMATIONFROM TABLE(INFORMATIONFROM TABLE(INFORMATIONFROM TABLE(INFORMATIONFROM TABLE(INFORMATIONFROHEDULED_TIME_RANGE_END => TO_TIMESTAMP_LTZ('2026-02-14 12:00:00.000 -0800')
))
ORDER BY scheduled_tiOe DESC;


R Deepak's observation: Shows all task executions in 2-hour window
-- Useful for troubleshooting specific time periods


-- ==================-- ================-- ========K CURRENT TIMESTAMP
-- ========================================

-- Deepak's utility: Get current timestamp in LTZ format
-- Deepak's utility: TZ(CURRENT_TIMESTAMP()) AS current_time_ltz;

-- Deepak's note: Useful for constructing time range queries


-- ============-- ============-- ============-- ========AS-- ============-- ============-==============================

-- Deepak's monitoring: See only failed tasks
SELECT
    name,
    scheduled_time,
    state,
    error_code,
    error_message,
    query_text
FROFROFRLE(INFORMATIFROFROFRLE(INFORMATORY(
    SCHEDULED_TI    SCHEDSTART => DATEADD('day', -1, CURRENT_TIMESTAMP())
))
WHERE state = 'FAILED'
ORDER BY scheduled_time DESC;

-- Deepak's learning: Quickly identify problems
-- Shows what went wrong and when


-- Deepak's monitoring: Task success rate-SELECT
    name,
    COUNT(*) AS total_runs,
    SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 ELSE 0 END) AS successful_runs,
    SUM(CASE WHEN state = 'FAILED' THEN 1 ELSE 0 END) AS failed_runs,
    ROUND(100.0 * SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 ELSE 0 END) / COUNT(    ROUND(100.0 * SUM(CASE WHEN state = 'SUCCEEDED' THMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP())
))
GROUP BY name
ORDER BY failed_runs DESC;

-- Deepak's observation: Shows reliability of each task
-- Helps identify problematic tasks


-- =====================-- =====================-- =================NCE
-- ========================================

-- Deepak's analy-- Deepak's analyut-- Deepak's ata-- Deepak's analy-- Deepak's analyut-- Deeion_count,
    AVG(DATEDIFF('second', scheduled_time, completed_time)) AS av _duration_seconds,
    MIN(DATEDIFF('second', scheduled_time, completed_time)) AS min_duration_seconds,
    MAX(DATEDIFF('second', scheduled    MAX(DATEDIFF('second', scheduled    MAX(DAT
FFFM TABLE(INFORMATION_SCHEMA.TASK_HISTFFFM TABLE(INFORMATION_SCHEMA.TASK_HISTFFFM TABLE(INFORMATION_SCHEMA.TASK_H())
))
WHERE state = 'SUCCEEDED'
GROUP BY name
ORDER BY avg_duration_secORDER BY avg_duration_secORDER BY avg_duration_secORDER BY avg_duration_secORDER BY avg_duration_secORDER BY avg_duration_secORDER BY avg_duration_===ORDER BY avg_duration_secORDER BY avg_duration_secORDER BY avg_duration_orO oORDER BY avgnitor success/failure rates
- - - - - - - - - - - - - - - - - - - - - - - - - - - - ers:

1. SCHEDULED_TIME_RANGE_START:
   - Start of time window
   - Required for filtering
   - Use DATEADD() fo   - Use DATEADD() fo   - Use DATEADD() foEND:
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

- NAME: Task - NAME: Task - NAME: Task - NAME: Task - NAME: Task - NAME: Task - NAME: Task - NAs scheduled to run
- COMPLETED_TIME: When task finished
- QUERY_ID: Unique execution identifier
- ERROR_CODE: Error code-if- ERROR_CODE: ErroSSAGE: Error descripti- ERROR_CODE: Error code-if- ERROR_CODE: ErroSSAGE: Error descripti- ERROR_CODE: Error code-if- ERROR_CODE: ErroSSAGE: Error descripti- ERROR_CODE: Error code-if- ERROR_CODE: ErroSSAGE: Error descripti- ERROR_CODE: Error code-if- ERROR_CODE: ErroSSAGE: Error descripti- ERROR_CODE: Error cos:

1. Recent Executions:
   SELECT * FROM TABLE(TASK_HISTORY())   SELECT * FROM TABLE(TASK_HESC LIMIT 10;

2. Failed Tasks Today:
   SELECT * FROM T   SELENT_DATE()
   ))
   WHERE state = 'FAILED';

3. Specific Task Last Hour:
   SELECT * FROM TABLE(TASK_HISTORY(
       SCHEDULED_TIME_RANGE_START => DATEADD('h       SCHEDRRENT_TIMESTAMP()),
       TASK_NAME => 'MY_TASK'
                   Rate:
   SELECT
       name,
       COUNT(*) AS total,
       SUM(IFF(state = 'SUCCEEDED', 1, 0)) AS success
   FROM TABLE(TASK_HISTORY(...))
   GROUP BY name;

Best Practices:

1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.istory daily
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
   - Note norma   - Note norma   - N- Track changes over time

Troubleshooting Workflow:

1. Identify Problem:
   - Check for f   -d    - Check for f   -d    essages
   - Note when failures   - Note when failures   - Note whCheck task dependencies
   - Review recent changes
   - Verify data availability
   - Verify data availabili SQL errors
   - Adjust warehouse size   - Adjustata quality issues

4. Verify Fix:
   - Monitor next execution
   - Check success rate
   - Validate results

Real-Real-Real-Real-
-- Daily monitoring -- Daily monitoring -- Daily monitoring -- Daily oday,
    SUM(IFF(state = 'SUCCEEDED    SUM(IFF(state = 'SU,
    SUM(IFF(state = 'FAILED', 1, 0)) AS failed,
    AVG(DATEDIFF('second', sched    AVG(DATEDIFF('second', scS a    AVG(DATEDIFFMAX(completed_time) AS last_ru    AVG(DATEDIFF('sATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START => CURRENT_DATE()
))
GROUP BY name
ORDER BY failed DESC, nameORDER BY failed DESC, nameORDER BppeORDER BY failed 
   → Task never ran (check if RESUMED)
   → Check correct database/schema

❌ Too many results
   → Add RESULT_LIMIT   → Add RESULT_Lar   → Add RESULT_LIMIT   → Add RESULT_Lar   Missing recent executions
   → History may have delay
   → Wait a few minutes
   → Refresh query

Key Takeaway:Key Takeaway:Key Takeaway:Ke for monitoring
automated workflows. Use it to track success
rates, identify failures, and optimize
performance. Regular monitoring prevents
issues and ensures reliable automation!

Practiced: February 2026
Status: ✅ Completed - Task monitoring mastered
*/
