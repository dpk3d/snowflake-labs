/*
===========================================
DEEPAK'S STREAMS PRACTICE - OFFSET
===========================================
Topic: Partial Stream Consumption with OFFSET
Date Practiced: February 11, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Streams can be partially consumed
- Use WHERE clause to filter stream
- Only matching rows are consumed
- Non-matching rows remain in stream
- Useful for selective processing
===========================================
*/

-- Deepak's Note: Sometimes you don't want to process ALL changes
-- OFFSET example shows selective stream consumption


-- ========================================
-- SETUP: CREATE DATABASE AND TABLES
-- ========================================

CREATE OR REPLACE TRANSIENT DATABASE deepak_streams_offset_db
COMMENT = 'Deepak - Database for stream offset practice';

USE DATABASE deepak_streams_offset_db;


-- Deepak's scenario: Create staging table
CREATE OR REPLACE TABLE deepak_streams_offset_db.public.sales_raw_staging (
    id VARCHAR,
    product VARCHAR,
    price VARCHAR,
    amount VARCHAR,
    store_id VARCHAR
)
COMMENT = 'Deepak - Staging table for offset example';

-- Load initial data
INSERT INTO deepak_streams_offset_db.public.sales_raw_staging
VALUES
    (1, 'Banana', 1.99, 1, 1),
    (2, 'Lemon', 0.99, 1, 1),
    (3, 'Apple', 1.79, 1, 2),
    (4, 'Orange Juice', 1.89, 1, 2),
    (5, 'Cereals', 5.98, 2, 1);

-- Deepak's observation: 5 initial products


-- Create store table
CREATE OR REPLACE TABLE deepak_streams_offset_db.public.store_table (
    store_id NUMBER,
    location VARCHAR,
    employees NUMBER
)
COMMENT = 'Deepak - Store reference data';

INSERT INTO deepak_streams_offset_db.public.store_table VALUES(1, 'Chicago', 33);
INSERT INTO deepak_streams_offset_db.public.store_table VALUES(2, 'London', 12);


-- Create final table
CREATE OR REPLACE TABLE deepak_streams_offset_db.public.sales_final_table (
    id INT,
    product VARCHAR,
    price NUMBER,
    amount INT,
    store_id INT,
    location VARCHAR,
    employees INT
)
COMMENT = 'Deepak - Final sales table';

-- Initial load
INSERT INTO deepak_streams_offset_db.public.sales_final_table
SELECT
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.store_id,
    ST.location,
    ST.employees
FROM deepak_streams_offset_db.public.sales_raw_staging SA
JOIN deepak_streams_offset_db.public.store_table ST ON ST.store_id = SA.store_id;

-- Deepak's learning: Initial 5 records loaded



-- ========================================
-- CREATE STREAM
-- ========================================

-- Deepak's key step: Create stream on staging table
CREATE OR REPLACE STREAM deepak_streams_offset_db.public.sales_stream
ON TABLE deepak_streams_offset_db.public.sales_raw_staging
COMMENT = 'Deepak - Stream for offset example';

-- Deepak's learning: Stream starts tracking from now


-- View streams
SHOW STREAMS;


-- Describe stream
DESC STREAM deepak_streams_offset_db.public.sales_stream;


-- Check stream (should be empty)
SELECT * FROM deepak_streams_offset_db.public.sales_stream;

-- Deepak's observation: No changes yet


-- Verify staging data
SELECT * FROM deepak_streams_offset_db.public.sales_raw_staging
ORDER BY id;

-- Deepak's note: 5 initial records


-- ========================================
-- INSERT NEW DATA
-- ========================================

-- Deepak's scenario: Add 2 new products
INSERT INTO deepak_streams_offset_db.public.sales_raw_staging
VALUES
    (6, 'Mango', 1.99, 1, 2),
    (7, 'Garlic', 0.99, 1, 1);

-- Deepak's observation: Added Mango and Garlic


-- ========================================
-- CHECK STREAM
-- ========================================

-- Deepak's check: Stream should show 2 new rows
SELECT * FROM deepak_streams_offset_db.public.sales_stream
ORDER BY id;

-- Deepak's learning: Stream captured both inserts
-- ID 6 (Mango) and ID 7 (Garlic)


-- Verify staging table
SELECT * FROM deepak_streams_offset_db.public.sales_raw_staging
ORDER BY id;

-- Deepak's observation: Now has 7 rows


-- Check final table (still has 5)
SELECT * FROM deepak_streams_offset_db.public.sales_final_table
ORDER BY id;


-- ========================================
-- PARTIAL STREAM CONSUMPTION (KEY CONCEPT!)
-- ========================================

-- Deepak's key technique: Process ONLY ID = 6 from stream
-- This is the "OFFSET" concept - selective consumption
INSERT INTO deepak_streams_offset_db.public.sales_final_table
SELECT
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.store_id,
    ST.location,
    ST.employees
FROM deepak_streams_offset_db.public.sales_stream SA
JOIN deepak_streams_offset_db.public.store_table ST ON ST.store_id = SA.store_id
WHERE SA.id = 6;  -- Deepak's filter: Only process ID 6!

-- Deepak's learning: WHERE clause filters which rows are consumed
-- Only ID 6 is consumed, ID 7 remains in stream!


-- ========================================
-- VERIFY PARTIAL CONSUMPTION
-- ========================================

-- Check final table - should have 6 rows (added Mango only)
SELECT * FROM deepak_streams_offset_db.public.sales_final_table
ORDER BY id;

-- Deepak's observation: Mango (ID 6) added, but not Garlic (ID 7)


-- Check stream - should still have ID 7!
SELECT * FROM deepak_streams_offset_db.public.sales_stream
ORDER BY id;

-- Deepak's key learning: ID 7 (Garlic) still in stream!
-- Partial consumption - only ID 6 was consumed


-- Verify staging table (has both)
SELECT * FROM deepak_streams_offset_db.public.sales_raw_staging
ORDER BY id;

-- Deepak's observation: Staging has both Mango and Garlic


-- ========================================
-- PROCESS REMAINING STREAM DATA
-- ========================================

-- Deepak's scenario: Now process the remaining ID 7
INSERT INTO deepak_streams_offset_db.public.sales_final_table
SELECT
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.store_id,
    ST.location,
    ST.employees
FROM deepak_streams_offset_db.public.sales_stream SA
JOIN deepak_streams_offset_db.public.store_table ST ON ST.store_id = SA.store_id;

-- Deepak's observation: No WHERE clause - processes all remaining


-- Check final table - should have 7 rows now
SELECT * FROM deepak_streams_offset_db.public.sales_final_table
ORDER BY id;

-- Deepak's learning: All 7 products now in final table


-- Check stream - should be empty
SELECT * FROM deepak_streams_offset_db.public.sales_stream;

-- Deepak's observation: Stream fully consumed


/*
DEEPAK'S STREAM OFFSET INSIGHTS:
=================================

What is Stream Offset/Partial Consumption?

- Processing only SOME rows from stream
- Using WHERE clause to filter
- Only matching rows are consumed
- Non-matching rows remain in stream
- Allows selective, incremental processing

How It Works:

1. Stream has multiple changes
2. Query stream with WHERE clause
3. Only filtered rows consumed
4. Other rows stay in stream
5. Process remaining rows later

Example:

-- Stream has IDs 6 and 7
SELECT * FROM stream;  -- Shows both

-- Process only ID 6
INSERT INTO target
SELECT * FROM stream
WHERE id = 6;  -- Only ID 6 consumed

-- Stream still has ID 7
SELECT * FROM stream;  -- Shows only ID 7

Use Cases:

1. Priority Processing:
   - Process high-priority records first
   - Low-priority records later
   - Based on business rules

2. Batch Processing:
   - Process in small batches
   - Avoid large transactions
   - Better performance

3. Error Handling:
   - Process valid records
   - Leave invalid in stream
   - Fix and reprocess later

4. Conditional Processing:
   - Different logic per record type
   - Filter by category
   - Route to different targets

5. Rate Limiting:
   - Process limited records per run
   - Avoid overwhelming downstream
   - Controlled throughput

Real-World Example:

-- Stream has 1000 new orders
SELECT COUNT(*) FROM order_stream;  -- 1000

-- Process only high-value orders first
INSERT INTO priority_orders
SELECT * FROM order_stream
WHERE order_value > 10000;  -- 50 consumed

-- Stream still has 950 orders
SELECT COUNT(*) FROM order_stream;  -- 950

-- Process remaining in batches
INSERT INTO regular_orders
SELECT * FROM order_stream
LIMIT 100;  -- Next 100

Best Practices:

1. Use Meaningful Filters:
   - Clear business logic
   - Documented criteria
   - Consistent rules

2. Monitor Remaining Stream:
   - Check stream size
   - Track unconsumed records
   - Alert if growing

3. Process Completely Eventually:
   - Don't leave records forever
   - Schedule cleanup jobs
   - Avoid stream bloat

4. Document Partial Logic:
   - Why partial consumption
   - What gets processed when
   - Dependencies

5. Test Thoroughly:
   - Verify correct filtering
   - Check consumption
   - Validate remaining records

Partial Consumption Patterns:

Pattern 1: Priority-Based
-- High priority first
INSERT INTO target
SELECT * FROM stream
WHERE priority = 'HIGH';

-- Then medium
INSERT INTO target
SELECT * FROM stream
WHERE priority = 'MEDIUM';

-- Finally low
INSERT INTO target
SELECT * FROM stream;

Pattern 2: Batch-Based
-- Process 100 at a time
INSERT INTO target
SELECT * FROM stream
LIMIT 100;

-- Repeat until empty

Pattern 3: Type-Based
-- Route by type
INSERT INTO type_a_target
SELECT * FROM stream
WHERE type = 'A';

INSERT INTO type_b_target
SELECT * FROM stream
WHERE type = 'B';

Pattern 4: Validation-Based
-- Process valid records
INSERT INTO target
SELECT * FROM stream
WHERE is_valid = TRUE;

-- Invalid remain for review
SELECT * FROM stream;  -- Only invalid left

Monitoring Partial Consumption:

-- Check stream size
SELECT COUNT(*) FROM stream;

-- See what's left
SELECT
    category,
    COUNT(*) AS remaining
FROM stream
GROUP BY category;

-- Track consumption rate
SELECT
    CURRENT_TIMESTAMP() AS check_time,
    COUNT(*) AS unconsumed_count
FROM stream;

Common Mistakes:

❌ Forgetting to process remaining
❌ No monitoring of stream size
❌ Unclear filter logic
❌ Stream grows indefinitely
❌ No documentation

Performance Considerations:

- Partial consumption is efficient
- No performance penalty
- Stream tracks offset internally
- Only scans matching rows
- Good for large streams

Deepak's Offset Workflow:

1. Insert data into source
2. Check stream for changes
3. Apply WHERE filter
4. Process filtered subset
5. Verify partial consumption
6. Check remaining in stream
7. Process remaining later
8. Verify stream empty

Deepak's Offset Checklist:

✅ Stream has multiple changes
✅ WHERE clause applied
✅ Only matching rows consumed
✅ Non-matching rows remain
✅ Remaining rows tracked
✅ Eventually fully processed
✅ Stream monitored

Key Takeaway:
Streams support partial consumption using WHERE
clauses! Only filtered rows are consumed, others
remain in stream. Perfect for priority processing,
batching, and conditional routing. Monitor stream
to ensure all records eventually processed!

Practiced: February 2026
Status: ✅ Completed - Stream offset/partial consumption mastered
*/