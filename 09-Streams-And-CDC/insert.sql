/*
===========================================
DEEPAK'S STREAMS PRACTICE - INSERT
===========================================
Topic: Tracking INSERT Changes with Streams
Date Practiced: February 11, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Streams capture INSERT changes automatically
- Stream shows only NEW rows since last consumption
- Consuming stream clears the changes
- Perfect for incremental ETL pipelines
- METADATA$ columns track change type
===========================================
*/

-- Deepak's Note: Streams are like change logs for tables
-- They track INSERTs, UPDATEs, and DELETEs automatically


-- ========================================
-- SETUP: CREATE DATABASE AND TABLES
-- ========================================

CREATE OR REPLACE TRANSIENT DATABASE deepak_streams_db
COMMENT = 'Deepak - Database for streams practice';

USE DATABASE deepak_streams_db;


-- Deepak's scenario: Create staging table for raw sales data
CREATE OR REPLACE TABLE deepak_streams_db.public.sales_raw_staging (
    id VARCHAR,
    product VARCHAR,
    price VARCHAR,
    amount VARCHAR,
    store_id VARCHAR
)
COMMENT = 'Deepak - Raw staging table for sales data';

-- Deepak's learning: Using VARCHAR for flexibility in staging


-- Load initial data into staging
INSERT INTO deepak_streams_db.public.sales_raw_staging
VALUES
    (1, 'Banana', 1.99, 1, 1),
    (2, 'Lemon', 0.99, 1, 1),
    (3, 'Apple', 1.79, 1, 2),
    (4, 'Orange Juice', 1.89, 1, 2),
    (5, 'Cereals', 5.98, 2, 1);

-- Deepak's observation: Initial 5 products loaded


-- Create store reference table
CREATE OR REPLACE TABLE deepak_streams_db.public.store_table (
    store_id NUMBER,
    location VARCHAR,
    employees NUMBER
)
COMMENT = 'Deepak - Store location and employee data';

INSERT INTO deepak_streams_db.public.store_table VALUES(1, 'Chicago', 33);
INSERT INTO deepak_streams_db.public.store_table VALUES(2, 'London', 12);

-- Deepak's learning: Two stores - Chicago and London


-- Create final sales table (enriched with store data)
CREATE OR REPLACE TABLE deepak_streams_db.public.sales_final_table (
    id INT,
    product VARCHAR,
    price NUMBER,
    amount INT,
    store_id INT,
    location VARCHAR,
    employees INT
)
COMMENT = 'Deepak - Final sales table with store information';

-- Deepak's note: Final table has proper data types


-- Initial load: Populate final table with existing data
INSERT INTO deepak_streams_db.public.sales_final_table
SELECT
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.store_id,
    ST.location,
    ST.employees
FROM deepak_streams_db.public.sales_raw_staging SA
JOIN deepak_streams_db.public.store_table ST ON ST.store_id = SA.store_id;

-- Deepak's observation: Initial 5 sales records loaded with store info



-- ========================================
-- CREATE STREAM ON STAGING TABLE
-- ========================================

-- Deepak's key step: Create stream to track changes
CREATE OR REPLACE STREAM deepak_streams_db.public.sales_stream
ON TABLE deepak_streams_db.public.sales_raw_staging
COMMENT = 'Deepak - Stream to track changes in sales staging';

-- Deepak's learning: Stream starts tracking from creation point


-- View all streams
SHOW STREAMS;

-- Deepak's observation: Can see stream metadata


-- Describe stream structure
DESC STREAM deepak_streams_db.public.sales_stream;

-- Deepak's learning: Stream has METADATA$ columns for change tracking


-- Check stream for changes (should be empty initially)
SELECT * FROM deepak_streams_db.public.sales_stream;

-- Deepak's observation: Stream is empty - no changes since creation


-- Verify staging table data
SELECT * FROM deepak_streams_db.public.sales_raw_staging
ORDER BY id;

-- Deepak's note: 5 initial records in staging


-- ========================================
-- INSERT NEW DATA (STREAM CAPTURES IT)
-- ========================================

-- Deepak's scenario: New sales data arrives
INSERT INTO deepak_streams_db.public.sales_raw_staging
VALUES
    (6, 'Mango', 1.99, 1, 2),
    (7, 'Garlic', 0.99, 1, 1);

-- Deepak's observation: Added 2 new products


-- Check stream - should show NEW inserts!
SELECT * FROM deepak_streams_db.public.sales_stream
ORDER BY id;

-- Deepak's learning: Stream captured the 2 new rows!
-- METADATA$ACTION = 'INSERT'
-- METADATA$ISUPDATE = 'FALSE'


-- Verify staging table (now has 7 rows)
SELECT * FROM deepak_streams_db.public.sales_raw_staging
ORDER BY id;


-- Check final table (still has 5 rows)
SELECT * FROM deepak_streams_db.public.sales_final_table
ORDER BY id;

-- Deepak's observation: Final table not updated yet


-- ========================================
-- CONSUME STREAM (PROCESS CHANGES)
-- ========================================

-- Deepak's ETL step: Process stream changes into final table
INSERT INTO deepak_streams_db.public.sales_final_table
SELECT
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.store_id,
    ST.location,
    ST.employees
FROM deepak_streams_db.public.sales_stream SA
JOIN deepak_streams_db.public.store_table ST ON ST.store_id = SA.store_id;

-- Deepak's learning: Reading from stream CONSUMES it!


-- Check stream again - should be EMPTY now!
SELECT * FROM deepak_streams_db.public.sales_stream;

-- Deepak's observation: Stream is empty after consumption
-- Changes have been processed


-- Verify final table (now has 7 rows)
SELECT * FROM deepak_streams_db.public.sales_final_table
ORDER BY id;

-- Deepak's learning: Final table updated with new data!


-- ========================================
-- SECOND BATCH OF INSERTS
-- ========================================

-- Deepak's scenario: Another batch of sales arrives
INSERT INTO deepak_streams_db.public.sales_raw_staging
VALUES
    (8, 'Paprika', 4.99, 1, 2),
    (9, 'Tomato', 3.99, 1, 2);

-- Deepak's observation: 2 more products added


-- Check stream - captures new inserts
SELECT * FROM deepak_streams_db.public.sales_stream
ORDER BY id;

-- Deepak's learning: Stream only shows changes since last consumption


-- Process second batch
INSERT INTO deepak_streams_db.public.sales_final_table
SELECT
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.store_id,
    ST.location,
    ST.employees
FROM deepak_streams_db.public.sales_stream SA
JOIN deepak_streams_db.public.store_table ST ON ST.store_id = SA.store_id;

-- Deepak's observation: Incremental processing pattern


-- ========================================
-- VERIFY FINAL STATE
-- ========================================

-- Check final table (should have 9 rows)
SELECT * FROM deepak_streams_db.public.sales_final_table
ORDER BY id;

-- Deepak's learning: All 9 sales records processed!


-- Check staging table (also has 9 rows)
SELECT * FROM deepak_streams_db.public.sales_raw_staging
ORDER BY id;


-- Check stream (should be empty)
SELECT * FROM deepak_streams_db.public.sales_stream;

-- Deepak's observation: Stream empty - all changes processed


/*
DEEPAK'S STREAMS INSERT INSIGHTS:
==================================

What are Streams?

- Change Data Capture (CDC) objects
- Track INSERT, UPDATE, DELETE changes
- Automatically capture changes
- Consumed when queried in DML
- Perfect for incremental ETL

How Streams Work:

1. Create stream on table
2. Stream starts tracking changes
3. Changes accumulate in stream
4. Query stream to see changes
5. Use stream in INSERT/MERGE
6. Stream is consumed (cleared)
7. Repeat for next batch

Stream Lifecycle:

CREATE STREAM → Changes Occur → Stream Captures →
Query Stream → Process Changes → Stream Consumed →
More Changes → Repeat

METADATA$ Columns:

METADATA$ACTION:
- 'INSERT' for new rows
- 'DELETE' for deleted rows

METADATA$ISUPDATE:
- 'TRUE' if part of UPDATE
- 'FALSE' if pure INSERT/DELETE

METADATA$ROW_ID:
- Unique row identifier

Stream Consumption:

Stream is consumed when used in:
✅ INSERT INTO ... SELECT FROM stream
✅ MERGE INTO ... USING stream
✅ CREATE TABLE AS SELECT FROM stream

Stream is NOT consumed when:
❌ SELECT * FROM stream (just viewing)
❌ Used in subquery
❌ Used in view

Benefits of Streams:

✅ Automatic change tracking
✅ No manual timestamp columns
✅ Captures all change types
✅ Efficient incremental processing
✅ Exactly-once semantics
✅ No data duplication

Use Cases:

1. Incremental ETL:
   - Process only new/changed data
   - Avoid full table scans
   - Faster pipelines

2. Data Synchronization:
   - Keep tables in sync
   - Replicate changes
   - Multi-environment sync

3. Audit Trails:
   - Track all changes
   - Compliance requirements
   - Change history

4. Real-time Analytics:
   - Process changes as they occur
   - Near real-time dashboards
   - Event-driven processing

Best Practices:

1. Process Regularly:
   - Don't let stream grow too large
   - Schedule regular consumption
   - Monitor stream size

2. Use Transactions:
   - Ensure atomic processing
   - Prevent partial consumption
   - Maintain data consistency

3. Handle Errors:
   - Validate before processing
   - Log failed records
   - Implement retry logic

4. Monitor Streams:
   - Check stream lag
   - Track consumption rate
   - Alert on issues

5. Document Stream Purpose:
   - What changes tracked
   - How often processed
   - Downstream dependencies

Incremental ETL Pattern:

-- Step 1: Create stream
CREATE STREAM staging_stream ON TABLE staging;

-- Step 2: Load new data
INSERT INTO staging VALUES (...);

-- Step 3: Process changes
INSERT INTO production
SELECT * FROM staging_stream;

-- Step 4: Stream auto-consumed
-- Repeat for next batch

Stream vs Traditional ETL:

Traditional:
- Track with timestamp column
- WHERE timestamp > last_run
- Manual tracking
- Risk of missing data

Streams:
- Automatic tracking
- No manual columns
- Guaranteed capture
- Exactly-once processing

Real-World Example:

-- Daily sales ETL
-- 1. Stream captures new sales
CREATE STREAM sales_stream ON TABLE sales_staging;

-- 2. Throughout day, sales inserted
INSERT INTO sales_staging VALUES (...);

-- 3. Nightly job processes changes
INSERT INTO sales_production
SELECT * FROM sales_stream
WHERE is_valid = TRUE;

-- 4. Stream consumed, ready for next day

Deepak's Stream Workflow:

1. Create stream on source table
2. Load data into source
3. Query stream to verify changes
4. Process stream into target
5. Verify stream consumed
6. Monitor for next batch
7. Repeat process

Deepak's Stream Checklist:

✅ Stream created on correct table
✅ Changes captured properly
✅ METADATA$ columns understood
✅ Processing logic tested
✅ Stream consumed after processing
✅ Error handling implemented
✅ Monitoring in place

Key Takeaway:
Streams provide automatic change tracking for
incremental ETL! They capture INSERTs, UPDATEs,
and DELETEs without manual timestamp columns.
Process stream in DML to consume it. Perfect for
efficient, exactly-once data pipelines!

Practiced: February 2026
Status: ✅ Completed - Stream INSERT tracking mastered
*/
