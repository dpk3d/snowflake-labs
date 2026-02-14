/*
===========================================
DEEPAK'S STREAMS WITH TASKS AUTOMATION PRACTICE
===========================================
Topic: Automating CDC Updates with Streams and Tasks
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Tasks can automate stream processing
- WHEN clause enables conditional execution
- SYSTEM$STREAM_HAS_DATA() checks for changes
- Efficient automation of CDC pipelines
- Combines scheduling with change detection
===========================================
*/

-- Deepak's Note: Streams + Tasks = Automated CDC magic!
-- Only run when there's actual data to process


-- ========================================
-- SETUP: CREATE DATABASE AND TABLES
-- ========================================

-- Deepak's setup: Use existing streams database
USE DATABASE deepak_streams_db;


-- Deepak's verification: Check existing tables
SHOW TABLES;

-- Deepak's observation: Using tables from previous-- Deepak's observation: Using tables f================
-- EXAMPLE 1: BASIC TASK WITH STREAM CONDITION
-- ======-- ======-- ======-- =============

-- Deepak's first automated task: Process stream only wh-- Deepak's first automated task: Process stream onta_changes_task
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = '1 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('sales_stream')
    AS 
MERGE INTO sales_final_table F
USING ( 
    SELECT STRE.*, ST.location, ST.employees
    FROM sales_stream STRE
    JOIN store_table ST
    ON STRE.store_id = ST.store_id
) S
ON F.id = S.id
WHEN MATCHED 
W   W   W   W   W   W   W   W   W   W   W   W   W   W   W  UPDATE = 'FALSE'
    THEN DELETE                   
WHEN MATCHED 
    AND S.METADATA$ACTION = 'INSERT' 
    AND S.METADATA$ISUPDATE = 'TRUE'       
    THEN UPDATE 
    SET F.product = S.product,
        F.price = S.price,
                                     F.store_id = S.store_id,
        F.employees = S.      ees,
        F.location = S.location
WHEN NOT MATCHED 
    AND S.METADATA$ACTION = 'INSERT'
    THEN INSERT 
    (i    (i    (i    (i    (i    (i    (i    (i   s, location)
    VALUES
    (S.id, S.product, S.price, S.store_id, S.amount, S.employees, S.location);

-- Deepak's check: View task details
SHOW TASKS;

-- Deepak's obse-- Deepak's obse-- Deepak's obsnded by default


-- Deepak's-- Deepak's-- Deepak's-- Deepak's-- Deepak's--SK deepak_all_data_changes_task RESUME;


- Deepak's verification: Check task state
SHOW TASKS LIKE 'deepak_all_data_changSHOW TASKS LIKE 'dee's lSHOW TASKS LIKE 'deepak_all_dy minute fSHOW TASKS LIa!


-- ========-- ========-- ========-- ========-- ========-- ========-- ========-=========-- ========-- ========-- ========Deepak's test: A-- ========-- ========-- ========-- es-- ========-- =LUES (11, 'Milk', 1.99, 1, 2)-- ========-- =ales_raw_staging VALUES (12, 'Chocolate', 4.49, 1, 2);

-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- Dtr-- D-- D-- D-- D-- D-- D-- D-- D-new INSERT records in stream


-- -- -- -- -- -tes f-- -- -- -- -- -tes f-- -- -- -- --fication: Check if task processed the data
SELECT * FROM sales_final_table ORDER BY id DESC;

-- Deepak's learning: New records automatically appeared!


-- Deepak's stream check: Should be empty after processin-- DeeCT * FR-- Deepak's stream check: Should be empty after processin-- Dask worked perfectly!


-- ========================================
-- TESTING: UPDATE DATA
-- ========-- ========-- ========-- ========-- ====pak's test: Update existing record
UPDATE sales_raw_staging
SET price = 2.49
WHERE id = 11;

-- Deepak's check: Stream shows UPDATE as DELETE + INSERT
SELECT 
    id,
    product,
    price,
    METADATA$ACTION,
    METADATA$ISUPDATE
FROM sales_stream
ORDER BY id, METADATA$ACTION;

-- Deepak's observation: 2 rows for id=11 (DELETE + INSERT with ISUPDATE=TRUE)


-- Wait for task to run...

-- Deepak's verification: Check updated price
SELECT * FROM sales_final_table WHERE id = 11;

-- Deepak's learning: Price updated to 2.49 automatica-- Deepak's learning: Price updated to 2.49 automatica-- Deepak's learning: Price updated to 2.49==-- Deepak's learning: Price updated to 2.49 aut rec-- Deepak's learning: Price updated to 2.49 automatica--pak'-- Deepak's learning: Price updated to 2.49 automatica-- Deepak's learning: Price updated to 2.49 automatica-- Deepak's learning: Price updated to 2LETE wi-- Deepak's learning: Price updated to 2.4n.-- Deepak's learning: cation: Record should be gone
SELECT * FROM sales_final_table WHERE id = 12;

-- Deepak's learning: Record deleted automatically! CDC working perfectly!


-- ========================================
-- MONITORING: TASK EXECUTION HISTORY
-- =========================-- =================Deepak's monitoring:-- =========================y
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS_value
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'DEEPAK_ALL_DATA_CHANGES_TASK',
    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_RANGE_S    SCHEDULED_TIME_D'
ORDER BY scheduled_time DESC;

-- Deepak's learning: Monitor for failures and troubleshoot!


-- ========================================
-- EXAMPLE 2: MULTIPLE STREAMS WITH SEPARATE TASKS
-- ==============-- ==============-- ==============-- ==============-- ==============-- ==============-- ========edules

-- Create additional tables
CREATE OR REPLACE TABLE customer_staging (
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_date TIMESTAM    signup_d_final F
USING customer_stream S
ON F.customer_id = S.customer_id
WHEN MATCHED 
    AND S.METADA    AND S.METADA    AND S.METADA    AND S.SUPDATE = 'FALSE'
    THEN DELETE
WHEN MATCHED 
    AND S.METADATA$ACTION = 'INSERT' 
    AND S.METADATA$ISUPDATE = 'TRUE'
    THEN UPDATE 
    SET F.customer_name = S.customer_name,
        F.email = S.email,
        F.signup_date = S.signup_da        F.signupocess        F.signup__TIMESTAMP()
WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWHD WHWHWHWHWHWHWHWHWHWHWHWH));

-- Wait 5 minutes...

-- Deepak's verification: Check p-- Deepak's to-- Deepak's verification: Check p-- Deepak's to-- Deepak's verification: Cing: Multiple inde-- Deepak's pi-- Deepak's verification: Check p-- ==========================
-- EXAMPLE 3: TASK WITH ERROR HANDLING
-- ========================================

-- Deepak's adv-- Deepak's adv-- Deepak's adv-- Deepak's adv-- Deepak's adv-- Deepak's adv-- Deepak_log (
    task_name VARCHAR(100),
    error_time TIMESTAMP,
    error_message VARCHAR(5000)
);

-- Deepak's note: In production, you'd use stored procedure for better error handling
-- This is a simplified example

-- Deepak's check: View all active tasks
SHOW TASKS;

-- Deepak's observation: Multiple tasks running independently


-- ========================================
-- PERFORMANCE MONITORING
-- ========================================

-- Deepak's monitoring: Check stream lag
SELECT 
    'sales_stream' AS stream_name,
    SYSTEM$STREAM_HAS_DATA('sales_stream') AS has_data,
    (SELECT COUNT(*) FROM sales_stream) AS pending_changes;

-- Deepak's monitoring: Task execution frequency
SELECT
    name,
    COUNT(*) AS execution_count,
    SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 ELSE 0 END) AS success_count,
    SUM(CASE WHEN state = 'FAILED' THEN 1 ELSE 0 END) AS    SUM(CASE WHEN state = 'FAILED' THEN 1  query_start_time, completed_time)) AS avg_duration_seconds
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    SCHEDULED_TIME_RANGE_START =>    SCHEDULED_TIME_RANGREN    SCHEDULED_TIME_RANGE_STARTIKE 'DEEPAK%'
GROUP BY name
ORDER BY name;

-- Deepak's learning: Monitor performance and re-- Deepak's learning: Monitor ==========================
-- BEST PRACTICES DEMONSTRATION
-- ========================================

-- Deepak's best -- Deepak's best -- Deepak's best -- Deep
-- Task only runs when stream has data (no wasted warehouse time)

-- Dee-- Dee-- Dee-- Dee-- Dee-- Dee-- Dee-- du-- intervals
-- Frequent changes → 1 MINU-- Frequent changes → 1 MINU-- Frequent changes → ss-- Frequent changes → 1 MINU-- Frequent changes → 1 MItor task history regularly
SELECT
    name,
    state,
    scheduled_    scheduled_    scheduled_   he    scheduled_    scheduled_    scheduled_   he    scheduled_    scheduleHE    scheduled_    scheduled_    scheduled_   he    scheduled_    scheduled_    scheduled_   he    scheduled_    scheduleHE    scheduled_    scheduled_    sc 20;


-- ========================================
-- CLEANUP AND SUSPENSION
-- ========================================

-- Deepak's cleanup: Suspend all tasks
ALTER TASK deepak_ALTER TASK deepak_ALTER TASK deepak_ALTER TASK deepak_ALTER TASK deepak_ALTER TASK deepak_ALTER TASK n: Check task states
SHOW TASKS;

-- Deepak's observation: All tasks suspended, no more automatic processing


-- Deepak's final check: View-- Deepak's final check: View-- Deepak's final check: View-- Dee * -- Deepak's final check: View-- Deepak's final check: Vieream check: Any remaining changes?
SELECT COUNT(*) AS pending_sales_changes FROM sales_stream;
SELECT COUNT(*) AS pending_customer_changes FROM customer_stream;


-- ===============-- =======-- ============
-- COMPREHENSIVE INSIGHTS
-- ========================================

/*
Deepak's Key Insights on Streams with Tasks:

1. WHY COMBINE STREAMS WITH TASKS?
   ✅ Automation: No manual intervention needed
   ✅ Efficiency: Only process when data changes
   ✅ Cost Savings: WHEN    ✅ Cost Savings: WHEN    ✅ Cost Savili   ✅ Cost Savings: WHEeduled processing
   ✅ Scalability: Handle mu   ✅ Scalability: Handle mu   �SE BENEFITS:
   - Conditional execution based on stream state
   - SYSTEM$STREAM_HAS_DATA('stream_name') returns TRUE/FALSE
   - Task skips execution if stream is empty
   - Saves warehouse credits significantly
   - Essential for cost-effective CDC

3. TASK SCHEDULING STRATEGIES:
   
   Real-time (1-5 MINUTE):
   - Critical data synchronization
   - Real-time analytics
   - High-frequency changes
   
   Near real-time (15-30 MINUTE):
   - Regular ETL updates
   - Moderate change frequency
   - Balanced cost/latency
   
   Batch (HOURLY/DAILY):
   Batch (HOURLY/DAILY):
y
ncy
):

DC
ntlsitive updates
   - Cost opti   - Cost opti   - Cost opti   - Cost optCUTION:
   
   Check task history:
   SELECT * FROM T   SELECT * FROM T   SELECT * FROORY(
       TASK_NAME => 'task_name',
       SCHEDU       SCHEDU       SCHEDU       SCHEDU     URRENT       SCHEDU       SCHEDU       SCHEDU       SCHEDU     URRENT       SCHEDU       SCHEDU       SCHEDU       Sration trends
   - Error patterns

5. STREAM CONSUMPTION BEHAVIOR:
   - Stream is consumed when task completes successfully
   - Failed task does NOT consume stream (data preserved)
   - Transactional consistency maintained
   - Can reprocess on failure

6. MULTIPLE STREAMS PATTERN:
   
   Scenario: Different table   Scenario: Different table  CREATE TASK task_a
       SCHEDU       SCHEDU       SCHEDU       M$       SCHEDU       SCH_a       SCHEDU       SCHEDUbl  a]       SCHEDU       SCHEDU         SCHEDULE = '5 MINUTE'
       WHEN SYSTEM$STREAM_HAS_DATA('stream_b')
       AS [merge for table_b];
   
   Bene   Bene   Bene   Beent proc  si g
   -   -   -   -   -ul   -   -   -   -   -ul   -   -   -   -   -ul   -   -   -   - ING STRATEGIES:
   
   ❌ Task fails → Stream NOT consumed
   ✅ Fix issue → Ta   ✅ Fix issue → Ta   ✅ F✅ Data preserved → No data loss
   
   Monitor failures:
   SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(...))
   WHERE state = 'FAILED';
   
   Common failure causes:
   - Warehouse suspended/unavailable
   - Insufficient privileges
   - SQL errors in MERGE logic
   - Target table locke   - Target table locke   - Target table locke   - Targe-    - Target table locke   - Tar40 runs per day
   - Warehouse active even with no data
   - High credi  co   - High credi  co   - High credi  co   - High credi  co   - High credi  c
                                                                                                                                                                 E-commerce order processing
   
   Source: orders_staging (receives orders from  ebs   Source: orders_staging (receivesssed orders)
   Stream: orders_stream
   Task: Process every 1 minute when data exists
   
   Benefits:
   - Orders processed within 1 minute
   - No m   - No m   - No m   - No m   - No m   - No m   - No m   - No m   - No m   - No m   - Nnt (onl   - No m   - No m ar   - No m   - No m   - No m   - No m   - No m   - No m   -      - No m   - No m   - Noand will run on schedule
    SUS    SUS    SUS    SUS    SUS    SUSte
    
    Commands:
    ALTER    ALTER    ALTER    ALTER  Start
    ALTER TASK task_name SUSPEND;  -- Stop

11. DEBUGGING WORKFLOW:
    
    Step 1: Check if stream has data
    SELECT COUNT(*) FROM my_stream;
    
    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T  ck    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T  ck    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T    Step 2: T E   y_task';
    
    Step 5: Check warehouse availability
    SHOW WAREHOUSES;

12. BEST PRACTICES:
    �    �    �    �    �   EM$STREAM_HAS_DATA() for cost efficiency
    ✅ Choose    ✅ Choe     ✅ Choose    ✅ Choe     ✅ C      ✅ Choose    ✅ Choe     ✅ Choose    ✅ Choe     ✅ C      ✅ Choose    ✅ Choe     ✅ Choose    ✅ Choe     ✅ C      ✅ Choose    ✅ Choe     ✅ Choose    ✅ Choe     ✅ C      ✅ Choose    ✅ Choe     ✅ Chpen    ✅ Choose    ✅ Choe     ✅ Choose  dencies and schedules    ✅ Choose    �rts for task failures (in    ✅ Choose    ✅ Choe     ✅ Chooseschedules periodically

13. COMMON PATTERNS:

    Pattern 1: Simple CDC Automation
    CREATE TASK sync_task
                                                                                                                                                                                                                                                                                                                  ASK   nc_customers ...SCHEDULE = '15 MINUTE'...
    CREATE TASK sync_products ...SCHEDULE = '1 HOUR'...

    Pattern 3: Dependent Tasks (covered in task trees)
    Pattern 3: Dependent Tasks (covered in task trees)

                                                                                                                                                                                                                                                          ASK   nc_customers ...SCHEDULE = '15 MINUTE'...
MERGE join conditions
    - Consider clustering keys on target tables
    - Use transient tables for staging if appropriate

15. TROUBLESHOOT15. TROUBLESHOOT15. TROUBLESHOOT15.t running?
       → Check if task is STARTED (not SUSPENDED)
       → Verify warehouse is available
       → Check WHEN clause (stream might be empty)
    
    ❌ Task running but no data processed?
       → Check stream has data: SELECT * FROM stream
       → Verify MERGE join condition
       → Check for SQL errors in task history
    
    ❌ Task failing repeatedly?
       → Review error message in TASK_HISTORY()
                                                        et                                                     fficient resources
    
    ❌ High costs?
       → Ensure WHEN clause is used
       → Review schedule frequency (too frequent?)
       → Check warehouse auto-suspend settings
       → Monitor actual vs scheduled runs

16. MONITORING QUERIES:

    -- Active tasks
    SHOW TASKS;
    
    -- Task execution summar    -- Task execution summar    -- Task execut runs,
        SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 E        SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 E        SLED        SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 EFO        SUM(CASE WHEN state = 'SUCCEEDEHE        SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 E T_   ESTAMP())
    ))
    GROUP BY name;
    
    -- Stream status
    SELECT 
        SYSTEM$STREAM_HAS_DATA('my_stream') AS has_data,
        (SELECT COUNT(*) FROM my_stream) AS pending_chang   

===============================================================================================================================================================================================================MMARY: STREAMS WITH TASKS
===========================================

What I Learned:
1. Tasks automate stream processing on a schedule
2. WHEN clause enables conditional execution
3. SYSTEM$STREAM_HAS_DATA() checks if stream has changes
4. Task only runs when4. Task only rta4.cost efficient!)
5. MERGE statement processes all changes automatically
6. Stream consumed after successful task execution
7. Failed tasks preserve stream data (no data loss)
8. Can run multiple independent CDC pipelines
9. Monitor execution via TASK_HISTORY()
10. Suspend tasks to stop automation

Key Commands:
- CREATE TASK: Define automated task
- WHEN SYSTE- WHEN SYSTE- WHE(): Con- WHEN SYSTE- WHEN - ALTER TASK...RESUME: Start task
- ALTER TASK...SUSPEND: Stop task
- T- T- T- T- T- T- T- T- T- T- T- T- T- T- T- T- T- T- T- T-sks

Task Pattern:
CREATE TASK task_name
    WAREHOUSE = warehouse_name
    SCHEDULE = 'interval'
    WHEN SYSTEM$STREAM_HAS_DATA('stream_name')
    AS [MERGE statement];

Best Practices:
✅ Always use WHEN clause for cost efficiency
���������������������� Monitor task execu���������������������� Monating
✅ Handle errors gracefully
✅ Use descriptive task names
✅ Set appropriate warehouse size
✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅�ations:
- Automated ETL pipelines
- Real-time data synchronization
- Incremental data warehouse loads
- Change data capture automation
- Multi-table sync workfl- Multi-table sync workfl- Multi-table sync h - Multi-table sync workfl- Multi-tablelines.
No manual intervention needed - dNo manual inare automatically
detected and processedetected and processedetected and processedetected and processedetected and processedeteedetected and processedetected andedetected and processedetected and processedetected and processeuledetected andordetected and processtune performance

Practiced: FebrPracticed: FebrPracticed� Practiced: FebrPracticed: FebrPracticed� Prac=============================Practiced: FebK_EOF
:
cat > "14-Streams-and-CDC/Types+of+stream.txt" << 'DEEPAK_EOF'
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
                                            0,2),
    store_id INT,
            NT
);

-- Deepak's initial data
INSERT INTO sales_raw_staging VALUES
    (1, 'Apple', 1.50, 1, 10),
    (2, 'Banana', 0.75, 1, 15),
    (3, 'Orange', 2.00, 2, 8),
    (4, 'Milk', 3.50, 1, 12),
    (5, 'Bread', 2.50, 2, 2    (5, 'BreaEggs', 4.00, 1, 6),
    (7, 'Coffee', 8.99, 2, 5);

-- Deepak's verification: Check initial data
SELECT * FROM sales_raw_SELECT * FROM sales_raw_SELECTk's observation: 7 products loaded


-- ========================================
-- EXAMPLE 1: CREATE STANDARD STREAM (DEFAULT)
-- ========================================

-- Deepak's standard stream: Tr-- Deepak's standard stream: Tr-- Deepak'sCREATE OR REPLACE STREAM sales_stream_standard
ON TABLE sales_raw_staging;

-- Deepa-- Deepa-- Deepa-- Deepa-- Deepa-- Deepa-- AMS;

-- Deepak's observation: MODE = DEFAULT (Standard stream)


-- Deepak's check: Stream is empty initially
SELECT * FROM sales_stream_standard;

-- Deepak's observation: No changes yet, stream is empty


-- ========================================
-- -- -- -- -- -EA-E A-- -- -- -- -- -EA-E A-======================================
-- -- -- -- -- -EA-E A-- -- -am-- -- -- -- -- -EA-E A-- -- -a R-- -- -- -- -- -EA-E A-- -- -pe-- -- -- -- -- -EA-E A-- -- g -- -- -- -- -- -EA-E A-- -- -am-- -- -- -- -- -EA-E A-- --
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSServSSSSSSSSSSSSSSSSSSSSSSSSSSSSSServSSSSSSSSSSFASSSSSSSSSSSSSSSSSSSSSSSSSSSSSServSSSSSSSSSSSSSSSSSSSSSSSSSSSSSServSSSSSSSSSSFASSSSSSSSS====SSSSSSSSSSSSSSSSSSSSSSSSSSSSSServSSSSSSSSS==SSSSSSSSSSSSSSSSSSSSSSSSSSSSSServSSSSSSSSSSSSest: Insert new records
INSERT INTO sales_raw_staging VALUES (8, 'Tea', 5.99, 1, 4);
INSERT INTO sales_raw_staging VALUES (9, 'Sugar', 3.25, 2, 10);

-- Deepak's check-- Deepak's check-- DeepakNSE-- Deepak's check-- Deepak's check-- DeepakNSE-- DeeADATA$ACTION,
    METADATA$ISUPDATE,
    METADATA$ROW_ID
FROM salFROM salFROM salFROM salFROM salFROM salFROs observation: 2 rows with METADATA$ACTIFROM salFROM salFROM salFROM salFROM salFROM salFROs obalsoFROM salFROM salFROM salFROM salFROM salFRt,FROM salFROM salFROM salFROM salFROM salFROM salFROs observation: 2 rows with METAales_stream_append
ORDER BY id;

-- Deepak's observation: 2 rows with METADATA$ACTION = 'INSERT'
-- Both streams capture INSERT operations!


-- ========================================-- ========================================-- ========================================-- ========================================-- ========================================-- ========================================-- ========================================-- ================
    id,
    product,
    price,
    METADATA$ACTION,
    METADATA    METADATA    METADATA    METADATA    METADATA    METADATA  ION;

-- Deepak's observation: 
-- 4 rows total:
-- - 2 rows for id=8,9 (previous INSERTs)
-- - 2 rows for id=7 (UP-- - 2 rows for id=7 + -- - 2 rows for idTE=TRUE)


-- Deepak's check: Append-only stream (does NOT show UPDATEs)
SELECT 
    id,
    product,
    price,
    METADATA$ACTION,
    METADATA$ISUPDATE
FROM sales_stream_append
ORDER BY id;

-- Deepak's observation: Still only 2 rows (id=8,9)
-- UPDATE is NOT captured in append-only stream!
------------he KEY difference!


-- ========================================
-- TEST 3: DELETE OPERATIONS
-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- ===============-- =====vation:--- Now 5 rows total:-- ======ow-- ===============RTs-- ===============-- ===============-- ===============-- ===============-- ==E with ISUPDATE=FALSE)


-- Deepak's check: Append-only stream (does NOT show DELETEs)
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS$ISUPDATE
FROM sales_stream_append
ORDER BY id;

-- Deepak's obser--tion: -- Deeonly 2 rows (id=8,9)
-- DELETE is NOT captured in append-only stream!-- DELETE is NOT captur=======================
-- SIDE-BY-SIDE COMPARISON
-- ========================================

-- Deepak's compariso-- Deepak's compariso-- Deepaam
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSUNT(*) AS change_count
FROM sales_stream_standard
UNION ALL
SELECT 'Append-Only Stream' AS stream_type, COUNT(*) AS change_count
FROM sales_stream_append;

-- Deepak's observation:
-- Standard: 5 changes (2 INSERTs + 2 UPDATE rows + 1 DELETE)
-- Append-Only: 2 changes (2 INSERTs only)


-- Deepak's comparison: Change types in standard stream
SELECT 
    METADATA$ACTION,
    METADATA$ISUPDATE,
    COUNT(*) AS count
FROM sales_stream_standard
GROUP BY METADATA$ACTION, METADATA$ISUPDATE
ORDER BY METADATA$ACTION, METADATA$ISUPDATE;

-- Deepak's observation:
-- DELETE, FALSE: 1 (standalone delete)
-- DELETE, TRUE: 1 (part of update)
-- INSERT, FALSE: 2 (standalone inserts)
-- INSERT, TRUE: 1 (part of update)


-- ========================================
-- CONSUMING STREAMS
-- ========================================

-- Deepak's test: Consume stand-- Deepak's test: ConsumeION;

-- Deepak's processing: Read from stream
-- Deepak's processing: Read from stream
s test: Conges AS
SELECT * FROM sales_stream_standard;

COMMIT;

-- Deepak's check: Stream should be empty now
SELECT COUNT(*) AS remaining_changes FROM sales_stream_standard;

-- Deep-- Deep-- Deep-- Deep--  - stream consumed!


-- Deepak's test: Consume append-only stream
BEGIN TRANSACTION;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- REATE OR REPLACE TEMPORARY TABLE temp_append_changes AS
SELECTSELECTM sales_stream_append;
SELECTSELECTM sales_s check: Stream should be empty now
SELECT COUNT(*) AS remaining_changes FROM sales_stream_appenSELECT COUNT(*) AS remaining_changes FROM sm consumed!


-- ===========-- ===========-- ===========-- =======LE 3: REAL-WORLD USE CASES
-- ========================================

-- Deepak's use case 1: Event logging (Append-Only)
-- Scenario: Log all new events, never update or delete

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCnt_id INT,
    event_type VARCHAR(50),
    event_timestamp TIMESTAMP,
    user_id INT
);

CREATE OR REPLACCREATE OR REPLACCREATE OR REPLACCREATE t_log
APPEND_ONLY = APPEND_ONLY = APPEND_ONLY = APPEND_s aAPPENDutable, only INSERTs matter
-- No need to track u-- No need to track u-- No need to track u-- No need to track uStandard)
-- Scenario: Track all changes to customer records

CREATE OR REPLACE TABLE customer_masterCREATE OR REPLACid INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    status VARCHAR(20)
);

CREATE OR RCREATE OR RCREATE OR RCREATE OR Ream
ON TABLE customer_master;

-- Deepak's reasoning: Need-- Deepak's reasoning: Need-- Deepak's reasoning: Need-- Deepak's reasoning: Need-- Deepak's reasoning: Need-- ==================================
-- EXAMPLE 4: PERFORMANCE COMPARISON
-- ========================================

-- Deepak's test: Create large dataset
CREATE OR REPLACE TABLE laCREATE OR REPLACE TABLE laCREATE OR REPLACE TABLE laCRue CREATE OR REPLACE TABLE laCREATE OR REPLACE TABLE laws
INSERT INTO large_table
SELSELSELSELSELSELSELSELSELSELSEata_' || SEQ4() AS datSELSELSELSELSELSELSELSELSELSELSEata_' || SEQ4() AS datSELSEATOR(ROWCOUNT => 10000));

-- Deepak's streams: Create both types
CREATE OR REPLACE STRECREATE OR REPLACE STRECREATE OR REPLACE STRECREATE OR REPLACE STRECREATE OR REPLACE STRECREAN CREATE OR REPLACE STRECREATE OR REPLACE STRECpak's test: Insert 1,000 new rows
INSERT INTO large_table
SELECT 
                                  _Data_' || SEQ4() AS data,
    UNIFORM(1, 1000, RANDOM()) AS value
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- Deepak's test: U-- Deepak's test: U-- Deepak's test: U-- Deepak's test: U-- Deepak's test: U-- Deepak's test: U-- Deepak's test: U-- Deepak's test: U-- Deepak's test: U-- Deepak's test: U00-- Deepak's test: U-- Deepak's testanges
SELECT 'Standard Stream' AS stream_type, SELECT 'Standard Stream' AS stream_tystSELECT 'Standard Stream' AS stream_type, SELECT 'Standard Stream' AS stream_tystSELECT 'Standard Stream' AS stream_type, SELECT 'S:
-- Standard: 2,100 changes (1,000 INSERTs + 1,000 UPDATE rows + 100 DELETEs)
-- Append-Only: 1,000 changes (1,000 INSERTs only)
-- Append-only is more efficient when you only care about inserts!


-- ========================================
-- EXAMPLE 5: STREAM TYPE CONVERSION
-- ========================================

-- Deepak's note: Cannot change stream type after creation
-- Must drop and recreate

-- Deepak's example: Convert append-only to standard
DROP STREAM IF EXISTS sales_stream_DROP STREAM IF EXISTS sales_stream_DROs_DROP STREAM IF EXISTS sales_stream_DROPg;
DROP STREAM IF EXISTS sales_stream_DROP STREAM IF EXISTS sales_stream_DROs_DROP STREAM IF EXISTS sales_stream_DROPg;
pe, SELECT 'Standard Stream' AS stream_tystSELECT 'Standard Stream' AS stream_type, SELECT 'S:
==============================

/*
Deepak's Key Insights on Stream Types:

1. STANDARD STREAM (DEFAULT):
   
   Characteristics:
   - Tracks INSERT, UPDATE, DELETE operations
   - UPDATE appears as DELETE + INSERT (2 rows)
   - METADATA$ISUPDATE distinguishes update from standalone operations
   - More comprehensive change tracking
   - Larger stream size wit   - Larger stream size wit   - Larger stream size wit   - Largerpture)
   - Audit trails requiring all changes
   - Data synchronization with updates   - Data synchronization with updates   -Slowly changing dimensions (SCD Type 2)
   
   Example:
   CREATE STREAM my_stream ON TAB   CREATE STREAM my_stream ON TAB   CREATE STREAM teristics:
   - Tracks INSERT operations ONLY
   - Ignores UPDATE and DELETE operations
   - Smaller stream size (fewer changes)
   - More efficient for insert-only scenarios
   - METADATA$ACTION always 'INSERT'
   
   Use Cases:
   - Event logging (immutable events)
   - Transaction logs
   - Sensor data ingestion
   - Append-onl   - Append-onl   - Append-ons d ta
   - Audit logs (write-once)
   
   Example:
   CREATE STREAM my_stream 
   CREATE STREAM ble   CREATE STREAM ble   CREATE STREAM ble   CS    CREATE STREAM ble   CREATE STREAM ble   CREATA$ACTION: 'INSERT' or 'DELETE'
   - METADATA$ISUPDATE: TRUE or FALSE
   - METADATA$ROW_ID: Unique row identifier
   
   Append-Only Stream:
   - METADATA$ACTION: Always 'INSERT'
   - METADATA$ISUPDATE: Always FALSE
   - METADATA$ROW_ID: Unique row identifier

4. PERFORMANCE CONSIDERATIONS:
   
   Standard Stream:
   - More rows (updates = 2 rows each)
   - More storage fo   - More et   - More storage fo   - More et   - More storage fo   - More et   - More storage fo   - Morly Stream:
   - Fewer rows (inserts o   - Fewer rows (inserts o   - Fewer rowter processing
   - Incomplete change history (by design)
   
   Rule of Thumb:
   - If t   - If t   - If t   - If t   - If �� Sta   - If t   f table is insert-only → Append-Only


  - If t   - If t  T STREAM TYPE:
   
   Use STA   Use STA   Use STA   Use STA   Use STA   Use STns   Use STA   Use STA   Use DC        Maintain   Use STA   Use STA   Usenchronizing data with updates/deletes
   ✅ Building slowly changing dimensions
   ✅ Tracking customer/product master data
   
   Use APPEND-ONLY when:
   ✅ Table is insert-only by design
   ✅ Events/logs are immutable
   ✅    ✅    ✅    ✅ al
   ✅ Storage efficiency matters
   ✅ Only care about new records
   ✅ Time-series or sensor data

6. STREAM CONSUMPTION BEHAVIOR:
   
   Both stream types:
   - Consumed after successful read in transaction
   - Can be queried multiple times before consumption
   - Offset advances after consumption
   - Can be reset (recreate stream)
   
   Consumption pattern:
   BEGIN TRANSACTION;
   INSERT INTO target SELECT * FROM stream;
   COMMIT;
   -- Stream is now consumed

7. COMMON PATTERN7. COMMON PATTERN7. COMMON PATTERN7. COMMON PATTERN7. COMMON PATTERN7. COMMON PATTERN7. COMMONvents 
                                  TE TASK process_events
       SCHEDULE = '1 MINUTE'
       WHEN SYSTEM$STREAM_HAS_DATA('event_stream')
       AS
   INSERT INTO processed_events
   SELECT * FROM event_stream;
   SELECT * FROM event_stream;

TA('eventStream
   CREATE STREAM customer_stream 
   ON TABLE customers;
   
   CREATE TASK sync_customers
       SCHEDULE = '5 MINUTE'
       WHEN SYSTEM$STREAM_HAS_DATA('customer_stream       WHEN SYSTEM$STREAM_HAS_DAme       WHEN SYSTEM$STREAM_HAS_DATea       WHEN SYSTES.id
   WHEN MATCH   WHEN MATCH   WHEN MATCH   WLE  ' 
       THEN DELETE
                                                         THEN UPDATE SET ...
   WHEN NOT MATCHED 
       THEN INSERT ...;

8. LIMITATIONS AND CONSTRAINTS:
   
   - Cannot change stream type after creation
   -    -    -    -    - te to change type
   - Append-only streams ign   -updates/deletes (by design)
   - Stan   - Stan   - Stan   - Stan   - Stan   - Stan   - Stan   - Stan   - Stan   - Stan   - Stan   - Stan   - Stan   - Sta  
   Check stream type:
   SHOW STREAMS;
   -- Look at MOD   -- Look at MOD   -- Look_ONLY
   
   Check stream contents:
   SELECT 
       METADATA$ CTION,
       METADATA$ISUPDATE,
       COUNT(*)
   FROM my_stream
   GROUP BY METADATA$ACTION, METADATA$ISUPDATE;
   
   Verify stream has data:
   SELECT SYSTEM$STREAM_H   SELECT SYSTEM$STREAM_H   EA   SELECT SYSTEM$STREAM_H  Example 1: IoT Sensor Data (Append-Only)
    - Sensors only send new readings
    - No updates or deletes
    - High volume, insert-only
    - A    - A    - A    - A    - A    - A    - A    - : Customer Database (Standard)
    - Customers update email, address
    - Customers can be delete    - Customers can full change history
    - Standard stream required
    
    Example 3: Financial Transactions (Append-Only)
    Example 3: Financial Transactions (Ap updates allowed (audit requirement)
    - Only new transactio    - Only new transactio    - Only new transactio    - Only new transactio    - Only new transactio    - Only new transactio her compute costs
    - More storage for metadata
    - Complete change tracking
    
    Appen    Appen    Appen    Aper    s to process
    - Lower comput    - Lower comput    - ge    - Lower coPa    - Lower compck    - Lower comput    - Lower comput    - ge  it  1M inserts, 500K updates, 100    - Lower comput    - Lower comput    - ge    - Lower coPa    - Lower compck    - Lower comput    - Lower comput    - g to process!

12. BEST PRACTICES:
    ✅ Choose stream type based     ✅ Choose stream type ba    ✅ Use append-only for insert-only tables
    ✅ Use standard for tables with updates/deletes
    ✅ Document stream type choice in comments
    ✅ Test stream behavior before production
    ✅ Test stream behavior nd   rformance
    ✅ Consider storage and compute costs
                                                                             uring design phase
    ✅ Don't use standard if append-only suffices

13. TROUBLESHOOTING:
    
    ❌ "Stream not capturing updates"
       → Check if stream is append-only
       → Recreate as st       → Recreate as st        ❌ "Too many rows in stream"
       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Check if updat       → Cly tables
       → Optimize processing frequency

14. DECISION TREE:
    
    Question 1: Does table have updates or deletes?
    -     -     -     -     -     -     -     -     -    tion 2
    
    Question 2: Will table ever have updates/deletes?
    - YES → Use Standard Stream (future-proof)
    - NO → Go to Question 3
    
    Question 3: Is data immutable by design?
    - YES → Use Append-Only Stream
    - NO → Use Standard Stream (safer choice)

15. TESTING CHECKLIST:
    ✅ Create both stream types
    ✅ Test INSERT operations (both should capture)
    ✅    ✅    ✅    ✅    ✅    ✅  d captures)
    ✅ Test DELETE operations (only standard captures)
    ✅ Verify metadata columns
    ✅ Test stream consumption
    ✅ Measure performance difference
    ✅ Validate use case alignment

===========================================
*/


-- ========================================
-- CLEANUP
-- ========================================

-- Deepak's cleanup: Drop test streams
DROP STREAM IF EXISTS sales_stream_standard;
DROP STREAM IF EXISTS sales_stream_append;
DROP STREAM IF EXISTS event_log_stream;
DROP STREDROP STREDROP STREDROP STREDROP STREDROP STREDROP STREDROP STRgeDROble_standard;
DROP STREAM IF EXISTS large_table_append;

-- Deepak's verification: Check remaining stream-- Deepak's verification: Ch o-servation: All test streams removed


-- ========================================
-- S-- S-- S-- S-- S-- S-- S-- S-- S-- S-- S-- S--====

/*
===========================================
DEEPAKDEEPAKDEEPAKDEEPAKDEEPAKDEEPAKDEEPAKDEEPAKDEEPAKDEE=================

What I Learned:
1. Two stream types: St1. Two stream types: St1. Two stream types: St1. Two sSERT, UPDATE, DELETE operations
3. Append-Only tracks INSERT operations only
4. UPDATE appears as DELETE 4. UPDATE appears as DELETE 4. UPDend4. UPDATE appears as DELETE 4. UPDATE appely
6. Choose type based on use case and data mutability
7. Can7. Can7. Can7. Can7. Can7. Can7. Can7. CaAppend-only is more efficient for insert-only tables
9. Standard required for full CDC
10. Stream type affects performance and cost10. Stream type affects performance an✅ Tracks all DML operations
✅ UPDATE = 2 rows (DELETE + INSERT)
✅ METADATA$ISUPDATE di✅ METADATA$ISUPDATE di✅ METADATA$ISUhistory
✅ Higher storage and compute costs
✅ Required for full CDC

Append-Only Stream:
✅ Tracks INSERT only
✅ Ignores UPDATE and DELETE
✅ METADATA$ACTION always 'INSERT'
✅ Partial change history
✅ Lower st�ra✅ Lower st�ra✅ Lower st�ra✅ Lower stab✅ Lower st�ra✅ Lower st�ra✅ Lower st�ra✅ Lower stab✅ Lower st�rcat✅ Lower st�rory management
- Any table with updates/deletes
- Full CDC requirements
- Audit trails

Append-Only Stream:
- Event logs
- Transaction logs
- Sensor data
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  stream_name ON TABLE table_name;

-- Append-only
CREATE STREAM stream_name 
ON TABLE table_name 
APPEND_ONLY = TRUE;

-- Check stream type
SHOW STREAMS;

Best Practices:
✅ Match stream type to data mutability
✅ Use append-only for insert-only tables
✅ Use standard when updates/deletes matter
✅ Test both types before deciding
✅ Con✅ Con✅ Con✅ Con✅ Con✅ Con✅ Con✅ Con✅ Con✅ Con✅ Cone
✅ Monitor stream size and efficienc✅ Monitor stream size s r✅ Monitor streamWorld Impact:
- Append-on- Append-on- Append-on- Appe 50%+ for insert-heavy tables
- Standa- Standa- Standa- Stlete audit trails
- Wrong stream type = missing changes or wasted resources
- Stream type is a design decision, not implementation detail

Key Takeaway:
Stream type must match your data's mutability and business requirements.
ApApApApApApApA immutable data, Standard for everytApApApApApApApA i wApApApA you can't change it later without recreating!

Practiced: February 14, 2026
Status: ✅ Completed - Stream types mastered!
===========================================
*/
