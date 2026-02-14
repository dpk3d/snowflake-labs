/*
===========================================
DEEPAK'S STREAMS CDC PROCESSING PRACTICE
===========================================
Topic: Processing All Data Changes with Streams
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Streams capture INSERT, UPDATE, DELETE changes
- MERGE statement processes all changes simultaneously
- METADATA$ACTION identifies change type
- METADATA$ISUPDATE distinguishes updates from inserts
- Efficient CDC (Change Data Capture) pattern
===========================================
*/

-- Deepak's Note: Streams = Change tracking on steroids!
-- Capture every INSERT, UPDATE, DELETE automatically


-- ========================================
-- SETUP: CREATE DATABASE AND TABLES
-- ========================================

-- Deepak's setup: Create dedicated database for streams
CREATE OR REPLACE DATABASE deepak_streams_db;

USE DATABASE deepak_streams_db;


-- Deepak's staging tabl-- Deepak's staging tabl-- Deepak's staging tabl-- Deepa_raw_staging (
    id INT,
    product VARCHAR(50),
    price DECIMAL(10,2),
    store_id INT,
    amount INT
);

-- Deepak's store reference table
CREATE OR REPLACE TABLE store_table (
    store_id INT,
    location VARCHAR(100),
    employees INT
);

-- Deepak's final ta-- Deepak's final ta-- Deepak's final ta-- DeepLACE TABLE sales_final_table (
    id INT,
    product VARCHAR(50),
    price DECIMAL(10,2),
    store_id INT,
    amount INT,
    employees INT,
    location VARCHAR(100)
);


-- Deepak's initial da-- Deepak's initial da-- Deepak's initial _t-ble VALUES 
    (1, 'Mumbai Central', 25),
    (2, 'Delhi Co    (2, 'Delhi Co    (2, 'Delhi Co    (2, 'Delhi Co , 20);

-- Deepak's initial sales data
INSERT ININSERT ININSERT ININSERT ININSERT I, 'Apple', 1.50, 1, 10),
    (2, 'Banana', 0.75    (2, 'Banana', 0.75    (2, 'Banana', 0.75    (2, 'Ba', 3.50, 1, 12),
    (5, 'Potato', 1.25, 3, 20),
    (5, 'Potato', 1.25, 3, 20);

-- Deepak's verification: Check initial data
SELECT * FROM sales_raw_staging;
SELECT * FROM storSELECT * FELECT * FROM sales_final_table;  -- Empty initially
SELECT * FRs observation: Staging hasSELECT * FRs observation: St

-- =======================================-- =============AM-- ==========================================-===-- =======================================-- =============AM-- =================================le-- =======N -- ====================;
-- ====================w -- =============SH-- ===========- -- ==============ti-- ====================wch-nges-- ====================w -- =============SH-- ===========- -- ==============tt no changes captured yet


-- ========================================
-- INITIAL LOAD: POPULATE FINAL TABLE
-- ========================================

-- Deepak's initial load: Merge staging data into final-- Deepak's initial load: Merge staging data into final-- Deepak's initial load: Merge stagin,-- Deepak's initial load: FROM s-- Deepak's initial load: Merre_table st
        ON stre.store_id = st.store_id
) S
ON F.id = S.id
WHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN M    THEN DELETE
WHEN MATCHED 
    AND S.METADATA$ACTION = 'INSERT' 
                                                                                                                                                                                                                                                  n
WHEN NOT MATCHED 
    AND S.METADATA$ACTION = 'INSERT'
    THEN INSERT (id, product, price, store_id, amount, employees, location)
    VALUES (S.id, S.product, S.price, S.store_id, S.amount, S.employees, S.location)    VALUES (S.id, S.product, S.price, S.st
SELECT * FROM sales_raw_staging;
SELECTSELECTSELECTSELECTSELECTSELECTSELECTSELECT(coSELECTSELECTSELECTSELECTSELECTSELECTSELECTSELECT(coSELECTSELECTSELECTSELECTSELECTSELECTSELECTSELECT(coSELECTSELECTSELECTSELECTSELECTSELECTSELECTSELECT(coSELECTSELECTSELECTSELECTSELECTSELECTSELECTSELECT(coSELECTSELECTSELECHANGE
-- ===============================-===-- ==========pa-- ===============================-===-- ==========pa-- ===============================-===-- =========);
-- ===epak's c-- ===epak's c-- ===epak's c-- ===ep* FROM sales_stream;

-- Deepak's observation: Stream shows INSERT with METADATA$ACTION = 'INSERT'
SELECT 
    id,
    product,
    price,
    METADATA$ACTION,
    METADATA$ISUPDATE,
    METADATA$ROW_ID
FROM sales_stream;

-- Deepak's learning: METADATA$ACTION = 'INSERT', METADATA$ISUPDATE = FALSE


-- Deepak's merge: Process the INSERT
MERGE INTO sales_final_table F
USING (
    SELECT 
        stre.*,
        st.location,
        st.employees
    FROM sales_stream stre
    JOIN store_table st
                                    id
) S
ON F.id = S.id
WHEN MATCHED 
    AND S.METADATA$ACTION = 'DELETE' 
    AND S.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE
WHEN MATCHED 
    AND S.METADATA$ACTION = 'INSERT' 
    AND S.METADATA$ISUPDATE = 'TRUE'
    THEN UPDATE SET
        F.product = S.product,
        F.price = S.price,
        F.amount = S.amount,
        F.store_id = S.store_id,
        F.employees = S.employees,
        F.location = S.location
WHEN NOT MATCHEWHEN NOT MATCHEWHEN NOT MATCHEWHEN NOT MATCHEWHEN NOT MATCHEWHEN NOT  price, store_id, amount, employees, location)
    VALUES (S.id, S.product, S.price, S.store_id,    VALUES S.    VALUE, S.location);

-- Deepak's verification: Lemo-- Deepak's verifial-- Deepak's verifROM sales_final_table WHERE product = 'Lemon';

-- Deepak's observation: INSERT p-- Deepak's observation: INSERT p-- ================================
-- EXAMP-- EXAMP--ESS UPDATE CHANGE
-- ========================================

-- Deepak's scenario: Up-- Deepak's scenario: TE sales_raw_staging
SET product = 'Lemonade'
WHERE product = 'Lemon';

-- Deepak's check: View UPDATE in stream
SELECT 
    id,
    product,
    META    META    ME      META    UP    META    META    ME      META    _stream;

-- Deepak's learning: UPDATE -- Deepak's learni
------------------------------ME------------------------- 2. INSERT (new value) with METADATA$ISUPDATE = TRUE


-- Deepak-- Deepak-- Deepak-- Deepak-- DRGE -- Deepak-- Deepak-- Deepak--  (
    SELECT 
        stre.*,
        st.location,
        st.employees
    FROM sales_stream stre
    JOIN store_table st
        ON stre.store_id = st.store_id
) S
ON F.id = S.id
WHEN MATCHED 
    AND S.METADATA$ACTION = 'DELETE' 
    AND S.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE
WHEN MATCHED 
    AND S.METADATA$ACTION = 'INSERT' 
    AND S.METADATA$ISUPDATE = 'TRUE'
    THEN UPDATE SET
        F.product = S.product,
        F        F        F        F        = S.amount,
        F.store_id = S.store_id,
        F.employees = S.employees,
        F.location = S.location
WWWWWWWWWWWWWWWWWWWWWWWWD WWWWWWWWWWWWWWWWWWWWWWWSERWWWWWWWWWWWWWWWWWWWWWWWWD WWWWWWWWWWWWW sWWWWWWd, amount, employees, location)
    VALUES (S.id, S.product, S.price, S.store_id, S.amount, S.employees, S.location);

-- Deepak's verification: Product sh-- Deepak's verification: Product sh-- Deepak's verification: Product sh-- Deepak's verification: ProductATE processed successfully!


-- ========================================
-- EXAMPLE-- EXAOCESS -- EXAMPLE-- E---- EXAMPLE-- EXAOCE======================

-- Deepak's scenario: Delete product from staging
-- Deepak's scenario: Delete product ro--ct = 'Lemonade';
-- Deepak's  c-- Deepak's  c-- Deepak's  c-- Deepa  -- Deepak's  c-- Deepak's  c-- DeepaON-- Deepak's  c$ISUPDATE,
    METADATA$ROW_ID
FROM sales_stream;

-- Deepak's learning: DELETE shows METAD-- Deepak's learniTE', METADATA$ISUPDATE = FALSE


-- Deepak's merge: Process the DELETE
MERGE INTO sales_final_table F
USING (
    SELECT 
    SELECT 
ales_final_table F
DEon,
        st.employees
    FROM sales_stream stre
    JOIN store_table st
        ON stre.store_id = st.store_id
) S
ON F.id = S.id
WHEN MATCHED 
    AND S.METADATA$ACTION = 'DELETE' 
    AND S.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE
WHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEDWHEN MATCHEount = S.amount,
        F.store_id = S.store_id,
        F.employees = S.employees,
        F.location = S.location
WHEN NOT MATCHED 
    AND S.METADATA$ACTION = 'INSERT'
    THEN INSERT (id, product, price, store_id, amount, employees, location)
    VALUES (S.id, S.product, S.price, S.store_id, S.amount, S.employees, S.location);

-- Deepak's verif-- Deepak's verif-ho-- Deepak's verifLEC-- Deepak's verif-- Deepak's verif-ho-- Deepak's verifLEC-- Deepak's verif-- Deepak's vcess-- Deepak's verif-- Deepak's verif-==============================
-- -- -- E 4: PROCESS MULTIPLE CHANGES SIMULTANEOUSLY
-- ========================-- ======================ak's scenario: Mix of INSERT, UPDATE, DELETE
INSERT INTO sales_raw_stINSERT INTO s(10, 'Lemon JuicINSERT INTO sales_raw_stINSERT INTO taging
SET price = 3.75
WHERE product = WHERE product TE FROM sales_raw_staging
WHERE product = 'Potato';

-- Deepak's check: View all changes in stream
SELECT 
    id,
    product,
    price,
    METADATA$ACTION,
    METADATA$ISUPDATE
FROM sales_streaFROM sales_streaFROM sales_streervation: Stream shows:
-- - INSERT f-- - INSERT f-- - INSERT f-- -LE-- - INSERT f-- Ma-- - INSERT f-- - INSERT f-- - INSEot-- - INSERT f-- - INSERT f-- - INSERT f-- -LE-- - INSERT f-- Ma-- - INSERT INTO sales_final_table F
USING (
    SELECT 
        stre.*,
        st.location,
        st.employees
    FROM sales_stream stre
    JOIN store_table st
        ON stre.store_id = st.store_id
) S
ON F.id = S.id
WHEN MATCHED 
    AND S.METADATA$ACTION = 'DELETE' 
    AND S.METADATA$ISUPDATE = 'FALSE'
    AND S.METADATA$ISUPDATE = 'FALSE'

-- -LE-- - INION = 'INSERT' 
    AND S.METADATA$ISUPDATE = 'TRUE'
    THEN UPDATE SET
        F.product = S.prod        F.product = S.prod        F.product = S.prod        F.product = S.prod        F.produc          F.produes        F.product = S.prod        F.product = S.prod  OT MATCHED 
    AND S.METADATA$ACTION = 'INSERT'
    THEN INSERT (id, product, pric    THre    THEN IN, employees, location)
    VALUES     VALUES     VALS.price, S.store_id, S.amount, S.employees, S.location);

-- Deepak's verification: Check all changes applied
SELECT * FROM sales_raw_staging ORDER BY id;
SELECT * FROM sales_stream;  -- Should be empty
SELECT * FROM sales_final_table ORDER BY id;

-- Deepak's observation: All chang-- Deepak'ed in ONE merge!
-- - Lemon Juice inser-- - Lemon Juice ine -- - Lemon Juice inser-- to-- - Lemon Juice inser================================
-- EXAMP-E 5-- EXAMP-E 5-NA-- EXAMP-E 5ICHMENT
-- =============================-- =============================-- Add new products with different stores
INSERT INTO sales_raw_staging VALUES 
    (11, 'Milk', 1.99, 2, 25),
    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    (11, 'Milk', 12.    F    (11, 'Milk', 12.    (11, 'Milk'd,
        stre.product,
        stre.price,
        stre.store_id,
        st        st        st        st        st        st        st        st        st            stre.METADATA$ISUPDATE
    FROM sales_stream stre
    JOIN store_table st
        ON stre.store_id = st.store_id
) S
ON F.id = S.id
WHEN MATWHEN MATWHEN MATWHEN MATWHEN MATWHEN MATWHE
    AND S.METADATA$ISUPDATE = 'FALSE'
    THEN DELETE
WHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MroWHEN MATCWHEN MATCWHEN MATCWHEN MATCWHEN MATCount = S.amount,
        F.store_id = S.store_id,
        F.employees = S.employees,
        F.location = S.location
WHEN NOT MATCHED 
    AND S.M    AND S.M    AND S.M    AND THEN INSERT (id, product, price, store_id, amount, employees, location)
    VALUES (S.id, S.product, S.price, S.store_id, S.amount, S.employees, S.location);

-- Deepak's verification: Check enriched data
SELECT 
    id,
    product,
    price,
    location,
    employees
FROM sales_fiFROM sales_fiFROM  IFROM sales_fiFROM salBY id;

-- Deepak's observation: Data enriched with store location and employees!


-- ========================================-- ======================S
-- ========================================

/*
Deepak's Key InDeghDeepak's Key inDeepak's Key InDeghDeepak's Key inDeepak's Key InD  Deepak's Key InDeghDeepak's Key inDeTEDeepak's Key IA$Deepak's Key InDeghDeepak's Key inDeepak's Key InDeghDeepak's Key inDeepak's Key InD  Deepak's Key InDeghDeepak's Key inDeTEDeepak's Key IA$Deepak's Key InDeghDeepak's Key inDeepak's Key InDeghD�───────────�Deepak's Key InDeghDeepak's Key i��───────────────┐
   │ Change Type │ METADATA$ACTION  │ METADATA$ISUPDATE  │
   ├─────────────┼──────────────────┼─────────�   ├────────────�SE   ├     ├SE   ├─�     ├─     ├──�   ├─�DAT   ├─────────────┼───└�    ├─────────────┼─────────�   ├─────────────┼──────�──────┴─────────�   ├─────────────┼──────────────────┼─────────�   ├────────────�SE   ├     ├SE   ├─�     ├─     ├──�   ├─�DAT   ├─────────────┼───└�    ├─────────────┼─────────�   ├─────────────┼─────�FALSE'
          THEN DELETE
   
   b) UPDATE (update operation):
      WHEN MATCHED 
          AND METADATA$ACTION = 'INSERT' 
          AND METADATA$ISUPDATE = 'TRUE'
          THEN UPDATE SET ...
   
   c) INSERT (new record):
      WHEN NOT MATCHED 
          AND METADATA$ACTION = 'INSERT'
          THEN INSERT ...

4. WHY THIS PATTERN WORKS:
   - Handles all DML operations in ONE statement
   - Processes changes in correct order
   - Maintains data consistency
   - Efficient (single pass through stream)
   - Atomic operation (all or nothing)

5. STREAM CONSUMPTION:
   - Stream is consumed after successful query
   - Changes removed from stream
   - New changes start accumulating
   - Transactional (rollback restores stream)

6. DATA ENRICHMENT:
   - Join stream with reference tables
   - Add calculated columns
   - Apply business logic
   - Transform data during merge

7. BEST PRACTICES:
   ✅ Always check stream before processing
   ✅ Use transactions for critical operations
   ✅ Monitor stream lag
   ✅ Handle errors gracefully
   ✅ Handle errors gracefully first
   ✅ Document merge logic
   ✅ Use meaningful column    ✅ Use meaningful column    ✅ Useonditions

8. COMMON PATTERNS:


  Pattern 1: Simple Sync
   ME   ME   ME   ME   ME  NG   ME   ME   ME   ME   ME  NG   ME   MEWH   ME   ME   ME   ME   MEN    ME   ME   ME   ME   MED UPDATE THEN UPDATE
   WHEN NOT MATCHED THEN INSERT

   Pattern 2: With Enrichment
   MERGE INTO target
   USING (stream JOIN reference_table)
   ON ...
   
   Patter   Patter   Patter   Patter   Patter get   Patter   Patter   RO   Patter   Patter   Patter   Patter   PatterRMANCE TIPS:
   - Process streams regularly (don't let them grow)
   - Use appropriate warehouse size
   - Partition l   - Partition l  re   - Partition l   - Partition l  re to   - Partition l   - PartiROUBLESHOOTING:
    ❌ "Str    ❌ "Str    ❌ "Str    ❌nge    ❌ "Str    �umption
       → Check source table for changes
    
    ❌ "Duplicate key error"
       → Check MERGE join condition
       → Verify primary key logic
    
    ❌ "Stream not updating"
       → Verify stream is on correct table
       → Check if stream was dropped/recreated

11. REAL-WORLD USE CASES:
    - ETL pipelines (staging → production)
    - Data synchronization (source → target)
    - Audit logging (track all changes)
    - Real-time analytics (process change    - Real-time analytics (prohousing (incremental loads)

12. 12. 12. 12. 12. 12.

    -- Check stream status
    SHOW STREAMS;
    
    -- Count pending changes
    SELECT COUNT(*) FROM my_stream;
    
    -- View change types
    SELECT 
        METADATA$ACTION,
        METADATA$ISUPDATE,
        COUNT(*)
    FROM m    FROM m    FROM m    FROM m          FROM m    FROM m    FROM m    FROM m          FROM m    FROM m    FROM m    FROM m          FROM m    FROM m   ==
-- CLEANUP
-- ========================================

-- Deepak's cl-- Deepak's cl-- Deepak's cl-- Deepak's les_raw-- Deepak's cl-- Deepak's cl * FROM sales_final_table ORDER BY id;
SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSuld be empty


-- ===================-- ===================-- ====================-- ===================-- ===================-- ================================
DEEPAK'S SUMMARY: PROCESSING ALL DATA CHANGES
===========================================

What I Learned:
1. Streams capture INSERT, UPDATE, DELETE automatically
2. MERGE statement processes all changes in one operation
3. META3. META3. META3. META3 change type (INSERT/DELETE)
4. METADATA$ISUPDAT4. istinguishes updates from standalone operations
5. UPDATE appears as DELETE + INSERT in stream
6.6.6ream is consumed after successful processing
7. Can enrich data by joining stream with reference tables
8. Single MERGE handles all DML operations efficiently
9. Atomic operation ensures data consistency
10. Essential pattern for CDC (Change 10. Essenure)

Key Commands:
- CREATE STREAM: Create cha- CREATE STREAM: Create cha- CREATE STREAM: Create cha- CREATE STREAM: Create cha- CREATE STREAM: Create cha- CREATE STREAM: CTE- CREATE STREAM: Create cha- CREATE STREAM: Cr_DATA(): Check if stream has changes

MERGE Pattern:
WHEN MATCHED AND DELETE → Handle deletes
WHEN MATCHED AND UPDATE → Handle updates
WHEN NOT MATWHEN NOT MATWHEN NOT MATWHEN NOT MATWHEN NOT Process streams regularly
✅ Use transactions✅ Use transaoperations
✅ Monitor stream lag
✅ Test merge logic tho✅ Test merge logic tho✅ Test merge logic tho✅ Tests gracefully
✅ Enrich data during merge
✅ Use appropriate warehouse size

Real-World Applications:
- ETL pipelines (staging to production)
- Data synchronization across syst- Data synchronization across syst- Data synchroal data warehouse loads
- Audit trail maintenance
- Change da- Change da- Change da- Change da- Change da- Change  Powerful CDC pattern!
Automatically track and process all data changes
without manual tracking. Effwithout manuable, and
scalable solution for keeping tables in sync.

Next Steps:
- Automate with tasks
- Implement error handling
- Monitor stream performance
- Build production CDC pipelines

Practiced: February 14, 2026
Status: ✅ Completed - CDC proStatus: ✅ CreStatus: ✅ Completed - CDC proStatu==========
*/
