/*
===========================================
DEEPAK'S STALENESS AND DATA RETENTION
===========================================
Topic: Understanding Staleness in Streams and Materialized Views
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Stream staleness and data retention
- MAX_DATA_EXTENSION_TIME_IN_DAYS parameter
- Materialized view staleness (behind_by)
- Preventing and handling stale data
- Retention time management
===========================================
*/

-- Deepak's Note: Staleness occurs when streams or MVs fall behind base tables!
-- Understanding and managing staleness is critical for data pipelines


-- ========================================
-- PART 1: STREAM STALENESS
-- ========================================

-- Deepak's observation: Streams can become "stale" if not consumed regularly!


-- ========================================
-- SETUP: CREATE TEST ENVIRONMENT
-- ========================================

-- Deepak's sales database
CREATE OR REPLACE DATABASE deepak_sales_db;

USE DATABASE deepak_sales_db;

-- Deepak's schema
CREATE OR REPLACE SCHEMA staging;

USE SCHEMA staging;


-- ========================================
-- STEP 1: CREATE BASE TABLE
-- ========================================

-- Deepak's sales staging table
CREATE OR REPLACE TABLE sales_raw_staging (
  sale_id INT,
  customer_name STRING,
  product_name STRING,
  sale_amount NUMBER(10,2),
  sale_date DATE,
  region STRING,
  load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Deepak's observation: Base table ready for stream!


-- ========================================
-- STEP 2: INSERT SAMPLE DATA
-- ========================================

-- Deepak's initial data load
INSERT INTO sales_raw_staging (sale_id, customer_name, product_name, sale_amount, sale_date, region)
VALUES
  (1001, 'Rajesh Kumar', 'Laptop', 85000.00, '2024-02-01', 'Mumbai'),
  (1002, 'Priya Sharma', 'Monitor', 15000.00, '2024-02-01', 'Delhi'),
  (1003, 'Michael Chen', 'Keyboard', 3500.00, '2024-02-02', 'Singapore'),
  (1004, 'Sarah Johnson', 'Mouse', 1200.00, '2024-02-02', 'New York'),
  (1005, 'Ahmed Hassan', 'Headphones', 8500.00, '2024-02-03', 'Dubai');

-- Deepak's verification
SELECT * FROM sales_raw_staging;


-- ========================================
-- STEP 3: CREATE STREAM
-- ========================================

-- Deepak's CDC stream
CREATE OR REPLACE STREAM sales_stream
ON TABLE sales_raw_staging
COMMENT = 'Deepak: Tracks changes to sales staging table';

-- Deepak's observation: Stream created and ready to track changes!


-- ========================================
-- STEP 4: SHOW STREAMS
-- ========================================

-- Deepak's list all streams
SHOW STREAMS;

-- Deepak's observation: Shows:
-- - Stream name, database, schema
-- - Table name (source table)
-- - Owner, mode (DEFAULT or APPEND_ONLY)
-- - Stale: FALSE (stream is fresh)
-- - Stale_after: Timestamp when stream becomes stale

-- Deepak's detailed output:
-- name          | database_name    | schema_name | table_name         | owner   | mode    | stale | stale_after
-- sales_stream  | DEEPAK_SALES_DB  | STAGING     | SALES_RAW_STAGING  | DEEPAK  | DEFAULT | FALSE | 2024-02-28 10:30:00


-- ========================================
-- STEP 5: DESCRIBE STREAM
-- ========================================

-- Deepak's stream details
DESC STREAM sales_stream;

-- Deepak's observation: Shows:
-- - Column definitions (includes METADATA$ columns)
-- - Data types
-- - Stream configuration

-- Deepak's sample output:
-- name                  | type          | kind   | null? | default | primary key | unique key
-- SALE_ID               | NUMBER(38,0)  | COLUMN | Y     | NULL    | N           | N
-- CUSTOMER_NAME         | VARCHAR       | COLUMN | Y     | NULL    | N           | N
-- METADATA$ACTION       | VARCHAR       | COLUMN | N     | NULL    | N           | N
-- METADATA$ISUPDATE     | BOOLEAN       | COLUMN | N     | NULL    | N           | N
-- METADATA$ROW_ID       | VARCHAR       | COLUMN | N     | NULL    | N           | N


-- ========================================
-- STEP 6: CHECK STREAM DATA
-- ========================================

-- Deepak's check stream contents
SELECT * FROM sales_stream;

-- Deepak's observation: Shows initial INSERT operations
-- METADATA$ACTION = 'INSERT' for all 5 rows


-- ========================================
-- STEP 7: VIEW RETENTION TIME PARAMETERS
-- ========================================

-- Deepak's check table parameters
SHOW PARAMETERS IN TABLE sales_raw_staging;

-- Deepak's observation: Key parameters:
-- - DATA_RETENTION_TIME_IN_DAYS: Time travel retention (default: 1 day)
-- - MAX_DATA_EXTENSION_TIME_IN_DAYS: Stream staleness threshold (default: 14 days)

-- Deepak's important parameters:
-- Parameter Name                      | Value | Default | Level
-- DATA_RETENTION_TIME_IN_DAYS         | 1     | 1       | TABLE
-- MAX_DATA_EXTENSION_TIME_IN_DAYS     | 14    | 14      | TABLE


-- ========================================
-- STEP 8: UNDERSTANDING MAX_DATA_EXTENSION_TIME_IN_DAYS
-- ========================================

/*
Deepak's Explanation: MAX_DATA_EXTENSION_TIME_IN_DAYS

What it controls:
- Maximum time a stream can remain unconsumed before becoming stale
- Extends data retention beyond DATA_RETENTION_TIME_IN_DAYS
- Prevents data loss for streams

Example:
- DATA_RETENTION_TIME_IN_DAYS = 1 (time travel: 1 day)
- MAX_DATA_EXTENSION_TIME_IN_DAYS = 14 (stream staleness: 14 days)
- Stream can track changes for up to 14 days without being consumed
- After 14 days, stream becomes STALE and cannot be used

Why it matters:
- Prevents accidental data loss
- Allows streams to "catch up" after downtime
- Balances storage cost vs data safety
*/


-- ========================================
-- STEP 9: CHANGE RETENTION TIME
-- ========================================

-- Deepak's increase retention time for critical table
ALTER TABLE sales_raw_staging
SET MAX_DATA_EXTENSION_TIME_IN_DAYS = 30;

-- Deepak's observation: Stream can now remain unconsumed for 30 days!

-- Deepak's verify change
SHOW PARAMETERS LIKE 'MAX_DATA_EXTENSION_TIME_IN_DAYS' IN TABLE sales_raw_staging;

-- Deepak's output:
-- key                                 | value | default | level
-- MAX_DATA_EXTENSION_TIME_IN_DAYS     | 30    | 14      | TABLE


-- ========================================
-- STEP 10: DECREASE RETENTION TIME
-- ========================================

-- Deepak's reduce retention for non-critical table
ALTER TABLE sales_raw_staging
SET MAX_DATA_EXTENSION_TIME_IN_DAYS = 7;

-- Deepak's observation: Stream must be consumed within 7 days!
-- Lower retention = lower storage cost
-- Higher retention = more safety buffer


-- ========================================
-- STEP 11: SIMULATE STREAM STALENESS
-- ========================================

-- Deepak's note: In real scenario, stream becomes stale if:
-- 1. Not consumed for MAX_DATA_EXTENSION_TIME_IN_DAYS
-- 2. Base table data older than retention period is modified

-- Deepak's check stream status
SHOW STREAMS LIKE 'sales_stream';

-- Deepak's observation: Check 'stale' column
-- - FALSE: Stream is fresh and usable
-- - TRUE: Stream is stale and cannot be used


-- ========================================
-- STEP 12: HANDLING STALE STREAMS
-- ========================================

/*
Deepak's Stale Stream Recovery:

If stream becomes stale:
1. Cannot query the stream
2. Cannot use in DML operations
3. Must recreate the stream

Recovery steps:
*/

-- Deepak's recreate stale stream
-- CREATE OR REPLACE STREAM sales_stream
-- ON TABLE sales_raw_staging;

-- Deepak's observation: Recreating stream resets it to current table state
-- All historical changes are lost!


-- ========================================
-- PART 2: MATERIALIZED VIEW STALENESS
-- ========================================

-- Deepak's observation: Materialized views also have staleness!


-- ========================================
-- STEP 13: CREATE MATERIALIZED VIEW
-- ========================================

-- Deepak's sales analytics MV
CREATE OR REPLACE MATERIALIZED VIEW sales_by_region_mv
AS
SELECT
  region,
  COUNT(*) AS sale_count,
  SUM(sale_amount) AS total_revenue,
  AVG(sale_amount) AS avg_sale_amount,
  MIN(sale_date) AS first_sale_date,
  MAX(sale_date) AS last_sale_date
FROM sales_raw_staging
GROUP BY region;

-- Deepak's observation: MV created and materialized!


-- ========================================
-- STEP 14: CHECK MV STALENESS
-- ========================================

-- Deepak's show materialized views
SHOW MATERIALIZED VIEWS;

-- Deepak's observation: Key column - 'behind_by'
-- - '0 seconds': Fully up-to-date
-- - '30 seconds': 30 seconds behind base table
-- - '5 minutes': 5 minutes behind base table

-- Deepak's sample output:
-- name                  | database_name    | schema_name | owner  | behind_by   | created_on
-- SALES_BY_REGION_MV    | DEEPAK_SALES_DB  | STAGING     | DEEPAK | 0 seconds   | 2024-02-14 10:30:00


-- ========================================
-- STEP 15: UPDATE BASE TABLE
-- ========================================

-- Deepak's insert new sales
INSERT INTO sales_raw_staging (sale_id, customer_name, product_name, sale_amount, sale_date, region)
VALUES
  (1006, 'Ananya Patel', 'Tablet', 45000.00, '2024-02-04', 'Mumbai'),
  (1007, 'David Lee', 'Webcam', 6500.00, '2024-02-04', 'Singapore');

-- Deepak's observation: Base table updated!
-- MV will refresh automatically in background


-- ========================================
-- STEP 16: CHECK MV STALENESS AFTER UPDATE
-- ========================================

-- Deepak's immediate check
SHOW MATERIALIZED VIEWS LIKE 'sales_by_region_mv';

-- Deepak's observation: 'behind_by' might show:
-- - '0 seconds': Already refreshed (fast!)
-- - '2 seconds': Refresh in progress
-- - Typically refreshes within seconds


-- ========================================
-- STEP 17: QUERY MATERIALIZED VIEW
-- ========================================

-- Deepak's query MV
SELECT * FROM sales_by_region_mv
ORDER BY total_revenue DESC;

-- Deepak's observation: Results include new sales!
-- Automatic refresh ensures data is current

-- Deepak's sample output:
-- region     | sale_count | total_revenue | avg_sale_amount | first_sale_date | last_sale_date
-- Mumbai     | 3          | 145000.00     | 48333.33        | 2024-02-01      | 2024-02-04
-- Singapore  | 2          | 10000.00      | 5000.00         | 2024-02-02      | 2024-02-04
-- Dubai      | 1          | 8500.00       | 8500.00         | 2024-02-03      | 2024-02-03


-- ========================================
-- STEP 18: MONITOR MV REFRESH LAG
-- ========================================

-- Deepak's continuous monitoring query
SELECT
  NAME,
  DATABASE_NAME,
  SCHEMA_NAME,
  BEHIND_BY,
  CREATED_ON
FROM INFORMATION_SCHEMA.MATERIALIZED_VIEWS
WHERE NAME = 'SALES_BY_REGION_MV';

-- Deepak's observation: Track 'behind_by' over time
-- Set up alerts if behind_by > threshold (e.g., 5 minutes)


-- ========================================
-- STEP 19: COMPARE STREAM VS MV STALENESS
-- ========================================

/*
Deepak's Comparison:

STREAM STALENESS:
- Controlled by MAX_DATA_EXTENSION_TIME_IN_DAYS
- Binary: Fresh (FALSE) or Stale (TRUE)
- Stale stream cannot be used
- Must recreate stale stream
- Staleness threshold: Days (e.g., 14 days)

MATERIALIZED VIEW STALENESS:
- Measured by 'behind_by' (time lag)
- Continuous metric (seconds/minutes)
- Stale MV can still be queried (shows old data)
- Automatic refresh catches up
- Staleness threshold: Seconds/minutes (e.g., < 1 minute)

Both require monitoring and management!
*/


-- ========================================
-- STEP 20: BEST PRACTICES
-- ========================================

/*
Deepak's Staleness Management Best Practices:

FOR STREAMS:
✅ Set appropriate MAX_DATA_EXTENSION_TIME_IN_DAYS
✅ Consume streams regularly (via tasks)
✅ Monitor stream staleness (SHOW STREAMS)
✅ Set up alerts for stale streams
✅ Document stream consumption frequency
✅ Balance retention vs storage cost

FOR MATERIALIZED VIEWS:
✅ Monitor 'behind_by' regularly
✅ Set up alerts for high lag (> 5 minutes)
✅ Investigate slow refreshes
✅ Optimize base table operations
✅ Review refresh history
✅ Document expected refresh patterns

GENERAL:
✅ Regular monitoring
✅ Automated alerting
✅ Documentation
✅ Performance reviews
✅ Cost optimization
*/


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. STREAM STALENESS BASICS
   - Occurs when stream not consumed within retention period
   - Controlled by MAX_DATA_EXTENSION_TIME_IN_DAYS
   - Default: 14 days
   - Stale stream cannot be used
   - Must recreate to recover

2. MAX_DATA_EXTENSION_TIME_IN_DAYS
   - Extends data retention for streams
   - Independent of DATA_RETENTION_TIME_IN_DAYS
   - Prevents accidental data loss
   - Configurable per table
   - Balance: Safety vs Storage cost

3. STREAM STALENESS PREVENTION
   - Consume streams regularly
   - Use scheduled tasks
   - Monitor stream status
   - Set appropriate retention
   - Alert on stale streams

4. MATERIALIZED VIEW STALENESS
   - Measured by 'behind_by' column
   - Shows time lag from base table
   - Automatic refresh reduces lag
   - Can still query stale MV (old data)
   - Monitor for performance issues

5. BEHIND_BY METRIC
   - '0 seconds': Fully current
   - '< 1 minute': Normal
   - '> 5 minutes': Investigate
   - '> 1 hour': Problem!
   - Check refresh history

6. RETENTION TIME CONFIGURATION
   - Higher retention: More safety, higher cost
   - Lower retention: Less safety, lower cost
   - Critical tables: 30+ days
   - Non-critical tables: 7-14 days
   - Review and adjust regularly

7. MONITORING STRATEGIES
   - Automated checks (every hour)
   - Alert thresholds
   - Dashboard metrics
   - Regular reviews
   - Trend analysis

8. TROUBLESHOOTING STALENESS
   - Streams: Check consumption frequency
   - MVs: Check refresh history
   - Review base table update patterns
   - Verify warehouse availability
   - Check for errors

9. COST IMPLICATIONS
   - Extended retention = higher storage cost
   - Stale streams = wasted storage
   - MV refresh lag = potential recompute
   - Monitor and optimize
   - Balance cost vs requirements

10. PRODUCTION BEST PRACTICES
    ✅ Set retention based on SLA
    ✅ Monitor staleness metrics
    ✅ Automate stream consumption
    ✅ Alert on anomalies
    ✅ Document retention policies
    ✅ Regular performance reviews
    ✅ Test recovery procedures

Understanding and managing staleness ensures reliable data pipelines!
*/

-- Deepak's Summary:
-- Staleness in streams and materialized views must be monitored and managed.
-- Set appropriate retention times and consume data regularly!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Staleness management mastered!
===========================================
*/