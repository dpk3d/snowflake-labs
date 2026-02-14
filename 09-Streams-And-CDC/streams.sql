/*
===========================================
DEEPAK'S STREAM TYPES PRACTICE
===========================================
Topic: Understanding Standard vs Append-Only Streams
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Two stream types: Standard and Append-Only
- Standard tracks INSERT, UPDATE, DELETE
- Append-Only tracks INSERT only
- Choose type based on use case
- Stream type affects metadata columns
===========================================
*/

-- Deepak's Note: Different stream types for different needs!
-- Standard = Full CDC, Append-Only = Inserts only


-- ========================================
-- SETUP: CREATE DATABASE AND TABLES
-- ========================================

-- Deepak's setup: Create dedicated database
CREATE OR REPLACE DATABASE deepak_stream_types_db;

USE DATABASE deepak_stream_types_db;


-- Deepak's staging table for testing
CREATE OR REPLACE TABLE sales_raw_staging (
    id INT,
    product VARCHAR(50),
    price DECIMAL(10,2),
    quantity INT,
    store_id INT
);

-- Deepak's initial data
INSERT INTO sales_raw_staging VALUES
    (1, 'Apple', 1.50, 1, 10),
    (2, 'Banana', 0.75, 1, 15),
    (3, 'Orange', 2.00, 2, 8),
    (4, 'Milk', 3.50, 1, 12),
    (5, 'Bread', 2.50, 2, 20),
    (6, 'Eggs', 4.00, 1, 6),
    (7, 'Coffee', 8.99, 2, 5);

-- Deepak's verification: Check initial data
SELECT * FROM sales_raw_staging;

-- Deepak's observat-- De7 products loaded


-- ========================================
-- EXAMPLE 1: -REA-- EXAMPLE 1: -REA-- EXAMPLE 1: -REA-- EXAMPLE 1: -REA-- EXA============

-- Deepak's standard stream: Tracks ALL changes
CREATE OR REPLACE STREAM sales_stream_standard
ON TABLE sales_raw_staging;ON TABLE sales_raw_staging;ONheck stream propON TABLE sales_raw_staging;ON TABLE sales_ion: MODE = DEFAULT (Standard stream)


-- Deepak's che-- Deepak's che-- Deepak's che-- DeT * -- Deepak's che-- Deepak's che-- Deeak-- Deepak's che-- Deepak's che-- Deepak's em-- Deepak'==-- Deepak's che-- Deepa==-- Deepak's che-- Deepa 2-- Deepak's che-ON-- Deepak's che==-===================================

-- Deepak's append-only stream: Tracks INSERT only
CREATE OR REPLACE STREAM sales_stream_apCREATE OR REPLACE STREAM saleng
APPEND_ONLY = TRUE;

-- Deepak's verification: Check stream properties
SHOW STREAMS;

-- -- -- -- -- -- -- -- -- -- --APPEND_ONLY


-- Deepak's check: Stream is empty-- Deepak's check: Stream is emstream_append;

-- Deepak's observation: No chan-- Deepak's observation: No chan-- Deepak'==-- Deepak's observation: No chan-- Deepak's observation: No chan-- Deepak'==-- Deepak's o==========

-- Deepak's test: Insert new products
INSERT INTO sales_raw_staging VALUES 
    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14, '    (14m
SELECT * FROM sales_stream_standard;

-- Deepak's observation: Standard stream shows 2 INSERT rows
-- METADATA$ACTION = 'INSERT'
-- METADATA$ISUPDATE = FALSE


-- Deepak's check: View append-only stream
SELECT * FROM sales_stream_append;

-- Deepak's observation: Append-only stream shows 2 INSERT rows
-- METADATA$ACTION = 'IN-- METADATA$ACTION = 'IN-- METADATA$ACTION = 'IN-- METADATA$ACTION = '==-- METADA========================
-- TEST 2: DELETE OPERATIONS
-- =====-- =====-- ========================

-- Deepak's test: Delete-- Deepak's test: Delete-- Deepak's test: Delete-- Deepak's test: Deletervation: Deleted Coffee (id=7)


-- Deepak's check: View standard stream
SELECT * FROM sales_stream_standard;

-- Deepak's observation: Standard stream shows:
-- - 2 INSERT rows (from previous test)
-- - 1 DELETE row (id=7, METADATA$ACTION = 'DELETE')
-- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Total: -- Tota (-- Total: -- Total: -- Total: -- Torow-- Total: -- Total: -- Total: -- Total: -- Total: -- Total:key insight: Append-only ignores-- Total: -- Total: -- Tota===========================
-- TEST 3: UPDATE O-- TEST 3: UPDATE O-- TEST 3: UP====-- TEST 3: UPDATE O-- TEST 3: UPDATE O-- TEST 3: UP====-- TESTal-- TEST 3: UPDATE O-- TEST 3: UPDATE O-- TEST 3: UP====-- TEST 3: UPDATE O-- TEST 3: UPDATE O-- TEST 3: UP====-- TESTal-- TEST 3fee 200g


-- Deepak's check: View standard stream
SELECT * FROM sales_streaSELECT * FROM sales_streaSELECT * FROM sales_streaSELECT * FROM sales_streaSELECT * FROM sales_streaSELECT * FROM sales_strea
-- - 2 UPDATE rows (1 DELETE + 1 INSERT for the UPDATE)
--   * Row 1: METADATA$AC--   * Row 1: METADATA$AC--   * Row 1: METADATue)
--   * Row 2: METADATA$ACTION='INSERT', METADATA$ISUPDATE=TRUE (new value)
-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rows-- Total: 5 rowBY-SIDE BEHAVIOR
-- ========================================

-- Deepak's comparison table:
/*
┌─────────────────┬──────────────────────┬─────────────────────┐
│ Operation       │ Standard Stream      │ Append-Only Stream  │
├─────────────────┼──────────────────────┼──────�├─────────────────┼─────� Tracked (1 row)   │ ✅ Tracked (1 row)  │
│ UPDATE          │ ✅ Tracked (2 rows)  │ ❌ Ignored          │
│ DELETE          │ ✅ Tracked (1 row)   │ ❌ Ignored          │
│ METADATA$ACTION │ INSERT/DELETE        │ INSERT only         │
│ METADATA$ISUPDATE│ TRUE/FALSE          │ Always FALSE        │
│ Use Case        │ Full CDC             │ Insert-only logs    │
└─────────────�└─────────────��───────────�└─────────────�└─────────────��───────────�└─────────────�└────────

-- Deepak's test: Consume standard stream
CREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE TEMPORARY TABCREATE OR REPLACE standard;

-- Deepak's observation: Stream is now empty (consumed)


-- Deepak's test: Consume append-only stream
CREATE OR REPLACE TEMPORARY TABLE product_table_append
AS SELECT * FROM sales_stream_append;

-- Deepak's verification: Check consumed data
SELECT * FROM product_table_append;

-- Deepak's observation: 2 rows captured (only INSERTs)


-- Deepak's check: Stream after consumption
SELECT * FROM sales_stream_append;

-- Deepak's observation: Stream is now empty (consumed)


-- ========================================
-- EXAMPLE 3: EVENT LOG USE CASE (APPEND-ONLY)
-- ========================================

-- Deepak's use case: Event logs are append-only by nature

CREATE OR REPLACE TABLE event_log (
    event_id INT,
    event_type VARCHAR(50),
    user_id INT,
    timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Deepak's append-only stream for event log
CREATE OR REPLACE STREAM event_log_stream
ON TABLE event_log
APPEND_ONLY = TRUE;

-- Deepak's observation: Perfect for event logs (never updated/deleted)


-- Deepak's test: Insert events
INSERT INTO event_INSERT INTO event_INSERT INTser_id) VALUES
                                                       3,                                     101);

-- Deepak's check: View stream
SELECT * FROM event_log_stream;

-- Deepak's ob-- Deepak's ob-- Deepak's ob-- Deepak's ob-- Deepak's ====-- Deepak's ob-- Deepak's ob-- Deepak's obMER DATA USE CASE (STANDARD)
-- ========================================

-- Deepak's use case: Customer data changes frequently

CREATE OR CREATE OR CREATE OR CREATE OR CREATE OR CREAT ICREATE OR CREATE OR CREATE OR CREATE OR CRAR(CREATE OR CREATE OR CREATE OR CREATE OR CREATE OR CREAT IeamCREATE OR CREATE OR CREATE OR CREACECREATE OR CREATE_dCREATE OR CREATE OR CREATEerCREATE OR CREATak's observation: Need full CDC for customer updates


-- Deepak's test: Insert customers
INSERT INTO customer_data VALUES
    (1, 'Deepak Singh', 'd    (1, 'Deepak S', 'ACTIVE'),
    (2, 'Priya Sharma', 'priya@example.com', 'ACTIVE');

-- Deepak's test: Update c-- Deepak's test: Update c-- D_data
SET status = 'INACTIVE'
WHERE customer_id = 2;

-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepaw s-- Deepak-- Deepak-- Deepak--da-- Deepak-- Deepak-- Deepak-- ati-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepak-- Deepaw s-- Deepak-- Deepak-- Deepak--da d-- Deepak-- Deepak-- Deepak-- Deepak-- Deee history!


-- ========================================
-- PERFORMANCE COMPARISON
-- ========================================

-- Deepak's performance test: Large table

CREATE OR REPLACE TABLE large_table (
    id INT,
    data VARCHAR(100)
);

-- Deepak's insert: 1000 rows
INSERT INTO large_table
SELECT 
    SEQ4() AS id,
    'Data_' || SEQ4() AS data
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


-- Deepa-- Deepa-- Deepa-- Deepa-- DeepEPLACE STREAM large_table_standard
ON TABLE large_table;

------------------------------------------------------- large_table_append
ON TABLE large_table
APPEND_ONLY = TRUE;


------------------------ 1---------------------arge_table
SELECT 
    SEQ4() + 1000 AS id,
    'New_Data_' || SEQ4() AS data
FROM TABLE(GENERATOR(ROWCOUNT => 100));


-- Deepak's observation: Both streams show 100 rows (same for INSERT)


-- Deepak's test: Update 50 rows
UPDATE large_table
SET data = 'Updated_' || id
WHERE id BETWEEN 1 AND 50;


-- Deepak's check: Standard stream
SELECT COUNT(*) FROM large_table_standaSELECT COUNT(*) FROM large_table_standaSEL0 SELECT COUNT(*) FROM lar- Deepak's check: Append-only stream
SELECT COUNT(*) FROM large_table_append;

-- Deepak's observation: 100 rows (100 INSERT only)

-- Deepak's key insight: Append-on-- Deepak's key insight: Apper-- Deepak's key insigh- -- =====-- Deepak's key ==-- Deepak's key insight: AppIVE INSIGHTS
-- =============================-- =============================-- =============================-- =====PREHENSIVE INSIGHTS: STRE-- =============================-- =============================-- ======(DEFAULT):
   ✅ Tracks all DML operations
                                                         IS PDATE d                        ✅ Complete change history
   ✅ Higher storage and compute costs
   ✅ Re   ✅ Re   ✅ Re   ✅ Re   ✅ Re   ✅ Re   ✅ Re   ✅ Re   �
�y                                                    ION always 'INSERT'
   ✅ Partial change history
   ✅ Lower storage and compute costs
   ✅ More efficient for insert-only tables

3. WHEN TO USE STANDARD:
   - Customer data
   - Inventory management
   - Any table with updates/deletes
   - Full CDC requirements
   - Audit trails

4. WHEN TO USE APPEND-ONLY:
   - Event logs
                                                                                                                                                            METADATA$ISUPDATE: TRUE/FALSE (Standard only)
   - METADATA$ROW_ID: Unique row identifier

6. STREAM CONSUMPTION:
   - Reading from stream marks records as consumed
   - Both types behave the same for consumption
   - Use transactions for atomic c   - Use transactions for atomic c   - Use transactions for atomic c   - Use transactions for atomic c   - Use transagher overhead due to tracking all changes
   - Choose based on data mutability

8. COST IMPLICATIONS:
   - Append-only: ~   - Append-only: ~   - Append-only: ~   - Append-only: ~   - Append-obu   - Append-only: ~   - Appe     - Append-only: ~   - Append-only9. S   - Append-only: ~   - Append-only: ~   - p a   - Append-only: ~   -ha   - Append-onPlan    - Append-only: ~   - g
   - Append-only: ~   - Appure

10. 10. 10. 10. 10. 10. 10. 1at10. 10. 10. 10.to data mutability
    ✅ Use a    ✅ Use a  insert-only tables
    ✅ Use standard when updates/deletes matter
    ✅ Test both types before deciding
    ✅ Consider performance vs completeness tradeoff
    ✅ Monitor stream size and efficienc    ✅ Monitor stream size and efficienc ========================================
*/


-- ========================================
-- CLEANUP
-- =====================-- =====================-- =====================-- =====================-- =====================-- =====================-- =====================-- =====================-- ====================P STREAM IF EXISTS customer_data_stream;-- =================TS large_table_standard;
DROP STREAM IF EXISTS large_table_append;

-- Deepak's verification: Check remaining streams
SHOW STREAMS;

-- Deepak's observation: All test streams removed


-- ========================================
-- SUMMARY AND KEY TAKEAWAYS
-- =================-- =================-- =========-- =================-- =================-- =========-- =======AM -- =================-- =================-- ====-- =================-- =================-- ====rd-- =================-- ===============SE-- =================-- =================-- =========IN-- =================-- =================-- =========-- =================-- =================-- =========-- =======AM -- ==io-s
6. Choose type based on use case and data mutability
7. Cannot change stream type after creation
8. Append-only is more efficient for insert-only tables
9. Standard required for full CDC
10. Stream type affects performance and cost

Standard Stream:
✅ Tracks all DML operations
✅ UPDATE = 2 rows (DELETE + INSERT)
✅ METADATA$ISUPDATE distinguishes upd✅ METADATA$ISUPDATE distinguishes upd�her storage and compute costs
✅ Required for full C✅ Requirednly✅ Required for full C✅ Requirednly✅ RequirTE a✅ Required for full C✅ Requirednly✅ RT'
✅ Partial change history
✅ Lower storage and compute costs
✅ Ideal for immutable data

Use Cases:

Standard Stream:
- Customer data
- Inventory management
- Any table with updates/deletes
- Full CDC requirements
- Audit trails

Append-Only Stream:
- Event logs
- Transaction logs
- Sensor data
- Click streams
- Immutable data sources

Syntax:

-- Standard (default)
CREATE STREAM stream_name ON TABLE table_name;

-- Append-only
CREATE STREAM stream_nameCREATE STREAM stream_nameCREATE STREAM stream_nameCk stream type
SHOW STREAMS;

Best Practices:
✅ Match stream type to data mutability
✅ Use append-only for insert-only tables
✅ Use✅ Use✅ Use✅ Use✅ Use✅ Use✅ Use�est both types befor✅ Use✅ Use✅ Use✅ Useor✅ Use✅ Use✅ Use✅ Use✅ Use�onitor stream size and efficiency
✅ Document stream type choice

Real-World Impact:
- Append-only can save 50%+ for insert-heavy tables
- Standard ensures complete audit trails
- Wrong stream type = missing changes or wasted resources
- Stream t- Stream t- Stream t- Str not implementation detail

Key Takeaway:
Stream type must match your data's mutStream type musinStream type mntsStream type must matcutable data, Standard for everythinStream type must match- Stream type mange it later without rStream type
Practiced: February Practiced: FtuPracticed: Feted - Stream types mastered!
===========================================
*/
