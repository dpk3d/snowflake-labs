/*
===========================================
DEEPAK'S ERROR HANDLING PRACTICE
===========================================
Topic: Monitoring and Troubleshooting Errors
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Multiple ways to check for errors
- VALIDATE_PIPE_LOAD for Snowpipe errors
- COPY_HISTORY for COPY command errors
- SYSTEM$PIPE_STATUS for pipe health
- Error messages help troubleshoot issues
===========================================
*/

-- Deepak's Note: Error handling is critical for production pipelines
-- Know how to find and fix errors quickly!


-- ========================================
-- SETUP: CREATE FILE FORMAT
-- ========================================

-- Deepak's scenario: Standard CSV file format with NULL handling
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.file_formats.deepak_csv_error_format
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    COMMENT = 'Deepak - CSV format with error handling';

-- Deepak's observation: NULL_IF handles various NULL representations

-- Check employees table
SELECT * FROM deepak_mgmt_db.public.employees LIMIT 10;


-- ========================================
-- REFRESH PIPE
-- ========================================

-- Deepak's scenario: Manually refresh pipe to process files
ALTER PIPE deepak_mgmt_db.pipes.deepak_employee_pipe REFRESH;

-- Deepak's learning: REFRESH forces pipe to check for new files


-- ========================================
-- METHOD 1: SYSTEM$PIPE_STATUS
-- ========================================

-- Deepak's scenario: Check if pipe is running properly
SELECT SYSTEM$PIPE_STATUS('deepak_mgmt_db.pipes.deepak_employee_pipe');

-- Deepak's observation: Returns JSON with pipe status
-- Shows: executionState, pendingFileCount, lastIngestedTime


-- ========================================
-- METHOD 2: VALIDATE_PIPE_LOAD
-- ========================================

-- Deepak's scenario: Check Snowpipe load errors
SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME => 'deepak_mgmt_db.pipes.deepak_employee_pipe',
        START_TIME => DATEADD(HOUR, -2, CURRENT_TIMESTAMP())
    )
);

-- Deepak's learning: Shows errors from Snowpipe loads in last 2 hours
-- Returns: file_name, row_number, column_name, error_message


-- ========================================
-- METHOD 3: COPY_HISTORY
-- ========================================

-- Deepak's scenario: Check COPY command history and errors
SELECT * FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'deepak_mgmt_db.public.employees',
        START_TIME => DATEADD(HOUR, -2, CURRENT_TIMESTAMP())
    )
);

-- Deepak's observation: Complete history of COPY operations
-- Shows success/failure, row counts, error details


/*
DEEPAK'S ERROR HANDLING INSIGHTS:
==================================

Error Monitoring Methods:

1. VALIDATE_PIPE_LOAD:
   - For Snowpipe errors
   - Shows file-level errors
   - Row and column details
   - Use for: Continuous ingestion

2. SYSTEM$PIPE_STATUS:
   - Pipe health check
   - Execution state
   - Pending files
   - Use for: Monitoring pipe status

3. COPY_HISTORY:
   - For COPY command errors
   - Load statistics
   - Error counts
   - Use for: Batch loads

4. VALIDATE function:
   - Validate last load
   - Error details
   - Use for: Immediate feedback

Error Information Available:
✅ File name
✅ Row number
✅ Column name
✅ Error message
✅ Rejected record
✅ Error count
✅ Load timestamp

Common Error Types:
❌ Data type mismatch
❌ NULL in NOT NULL column
❌ Value too long
❌ Invalid date format
❌ Number format error
❌ Column count mismatch
❌ File format issues

VALIDATE_PIPE_LOAD Syntax:
SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME => 'database.schema.pipe_name',
        START_TIME => DATEADD(HOUR, -N, CURRENT_TIMESTAMP())
    )
);

COPY_HISTORY Syntax:
SELECT * FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'database.schema.table_name',
        START_TIME => DATEADD(HOUR, -N, CURRENT_TIMESTAMP())
    )
);

Monitoring Best Practices:
1. Check errors regularly
2. Set up alerts for failures
3. Monitor error rates
4. Investigate patterns
5. Document common issues
6. Fix root causes
7. Keep error logs

Error Analysis Queries:

-- Count errors by type
SELECT
    error_message,
    COUNT(*) AS error_count
FROM TABLE(VALIDATE_PIPE_LOAD(...))
GROUP BY error_message
ORDER BY error_count DESC;

-- Find files with most errors
SELECT
    file_name,
    COUNT(*) AS error_count
FROM TABLE(VALIDATE_PIPE_LOAD(...))
GROUP BY file_name
ORDER BY error_count DESC;

-- Check load success rate
SELECT
    status,
    COUNT(*) AS load_count,
    SUM(row_count) AS total_rows,
    SUM(error_count) AS total_errors
FROM TABLE(COPY_HISTORY(...))
GROUP BY status;

Pipe Status Interpretation:
{
  "executionState": "RUNNING",  // RUNNING, PAUSED, STOPPED
  "pendingFileCount": 5,        // Files waiting to load
  "lastIngestedTime": "..."     // Last successful load
}

Troubleshooting Workflow:
1. Check pipe status (SYSTEM$PIPE_STATUS)
2. If errors, check VALIDATE_PIPE_LOAD
3. Identify error patterns
4. Fix source data or schema
5. Resume pipe if paused
6. Monitor for recurrence

Creating Error Tables:
-- Save errors for analysis
CREATE TABLE deepak_mgmt_db.public.load_errors AS
SELECT * FROM TABLE(
    VALIDATE_PIPE_LOAD(
        PIPE_NAME => 'deepak_mgmt_db.pipes.deepak_employee_pipe',
        START_TIME => DATEADD(DAY, -7, CURRENT_TIMESTAMP())
    )
);

-- Analyze error trends
SELECT
    DATE(CURRENT_TIMESTAMP()) AS error_date,
    COUNT(*) AS error_count,
    COUNT(DISTINCT file_name) AS files_with_errors
FROM deepak_mgmt_db.public.load_errors
GROUP BY error_date
ORDER BY error_date DESC;

Real-World Monitoring:
-- Daily error report
SELECT
    DATE(last_load_time) AS load_date,
    status,
    COUNT(*) AS load_count,
    SUM(row_count) AS rows_loaded,
    SUM(error_count) AS errors,
    ROUND(SUM(error_count) / SUM(row_parsed) * 100, 2) AS error_rate_pct
FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'deepak_mgmt_db.public.employees',
        START_TIME => DATEADD(DAY, -30, CURRENT_TIMESTAMP())
    )
)
GROUP BY load_date, status
ORDER BY load_date DESC;

Deepak's Error Handling Checklist:
✅ Monitor pipe status regularly
✅ Check COPY_HISTORY after loads
✅ Set up error alerts
✅ Save error records for analysis
✅ Document common errors
✅ Fix root causes, not symptoms
✅ Test fixes before production
✅ Keep error logs for auditing

Practiced: February 2026
Status: ✅ Completed - Mastering error monitoring
*/