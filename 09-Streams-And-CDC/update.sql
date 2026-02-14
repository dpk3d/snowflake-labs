/*
===========================================
DEEPAK'S STREAMS PRACTICE - UPDATE
===========================================
Topic: Tracking UPDATE Changes with Streams
Date Practiced: February 11, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- UPDATEs appear as DELETE + INSERT in stream
- METADATA$ISUPDATE = 'TRUE' for both rows
- DELETE row has old values
- INSERT row has new values
- Use MERGE with UPDATE clause to process
===========================================
*/

-- Deepak's Note: UPDATEs are tricky in streams!
-- They appear as TWO rows: DELETE (old) + INSERT (new)

-- Deepak's prerequisite: Assumes tables and stream from Insert.txt exist


-- ========================================
-- UPDATE 1: CHANGE PRODUCT NAME
-- ========================================

-- Check staging table before update
SELECT * FROM deepak_streams_db.public.sales_raw_staging
ORDER BY id;

-- Deepak's observation: Banana exists in staging


-- Check stream (should be empty)
SELECT * FROM deepak_streams_db.public.sales_stream;

-- Deepak's note: Stream empty before update


-- Deepak's scenario: Product name changed (Banana → Potato)
UPDATE deepak_streams_db.public.sales_raw_staging
SET product = 'Potato'
WHERE product = 'Banana';

-- Deepak's observation: Updated 1 row


-- ========================================
-- CHECK STREAM AFTER UPDATE
-- ========================================

-- Deepak's key learning: Stream shows TWO rows for one UPDATE!
SELECT * FROM deepak_streams_db.public.sales_stream
ORDER BY id, METADATA$ACTION;

-- Deepak's observation:
-- Row 1: METADATA$ACTION = 'DELETE', product = 'Banana', METADATA$ISUPDATE = 'TRUE'
-- Row 2: METADATA$ACTION = 'INSERT', product = 'Potato', METADATA$ISUPDATE = 'TRUE'

-- Deepak's learning: UPDATE = DELETE (old values) + INSERT (new values)


-- ========================================
-- PROPAGATE UPDATE TO FINAL TABLE
-- ========================================

-- Deepak's technique: Use MERGE with UPDATE clause
MERGE INTO deepak_streams_db.public.sales_final_table F
USING deepak_streams_db.public.sales_stream S
ON F.id = S.id
WHEN MATCHED
    AND S.METADATA$ACTION = 'INSERT'
    AND S.METADATA$ISUPDATE = 'TRUE'
THEN UPDATE SET
    F.product = S.product,
    F.price = S.price,
    F.amount = S.amount,
    F.store_id = S.store_id;

-- Deepak's learning: Match on INSERT + ISUPDATE = TRUE for updates
-- This processes the NEW values


-- ========================================
-- VERIFY UPDATE 1
-- ========================================

-- Check final table - should show Potato
SELECT * FROM deepak_streams_db.public.sales_final_table
WHERE id = 1;

-- Deepak's observation: Product changed to Potato!


-- Check all data in final table
SELECT * FROM deepak_streams_db.public.sales_final_table
ORDER BY id;


-- Check staging table
SELECT * FROM deepak_streams_db.public.sales_raw_staging
ORDER BY id;

-- Deepak's learning: Both tables in sync


-- Check stream - should be empty (consumed)
SELECT * FROM deepak_streams_db.public.sales_stream;

-- Deepak's observation: Stream consumed by MERGE


-- ========================================
-- UPDATE 2: ANOTHER PRODUCT CHANGE
-- ========================================

-- Deepak's scenario: Change Apple to Green apple
UPDATE deepak_streams_db.public.sales_raw_staging
SET product = 'Green apple'
WHERE product = 'Apple';

-- Deepak's observation: Updated 1 row


-- Check stream - should show DELETE + INSERT again
SELECT * FROM deepak_streams_db.public.sales_stream
ORDER BY id, METADATA$ACTION;

-- Deepak's learning: Same pattern - 2 rows for 1 UPDATE


-- Process second update
MERGE INTO deepak_streams_db.public.sales_final_table F
USING deepak_streams_db.public.sales_stream S
ON F.id = S.id
WHEN MATCHED
    AND S.METADATA$ACTION = 'INSERT'
    AND S.METADATA$ISUPDATE = 'TRUE'
THEN UPDATE SET
    F.product = S.product,
    F.price = S.price,
    F.amount = S.amount,
    F.store_id = S.store_id;

-- Deepak's observation: Same MERGE pattern works


-- ========================================
-- VERIFY UPDATE 2
-- ========================================

-- Check final table
SELECT * FROM deepak_streams_db.public.sales_final_table
ORDER BY id;

-- Deepak's learning: Green apple updated successfully


-- Check staging table
SELECT * FROM deepak_streams_db.public.sales_raw_staging
ORDER BY id;

-- Deepak's observation: Both tables match


-- Check stream
SELECT * FROM deepak_streams_db.public.sales_stream;

-- Deepak's learning: Stream empty - all changes processed


/*
DEEPAK'S STREAMS UPDATE INSIGHTS:
==================================

How UPDATEs Work in Streams:

UPDATE in source table creates TWO rows in stream:

Row 1 (Old Values):
- METADATA$ACTION = 'DELETE'
- METADATA$ISUPDATE = 'TRUE'
- Contains old/previous values

Row 2 (New Values):
- METADATA$ACTION = 'INSERT'
- METADATA$ISUPDATE = 'TRUE'
- Contains new/updated values

Why Two Rows?

- Streams track before/after state
- DELETE row = before state
- INSERT row = after state
- Allows full change tracking
- Enables audit trails

Processing UPDATEs:

Use MERGE with UPDATE clause:

MERGE INTO target F
USING stream S
ON F.id = S.id
WHEN MATCHED
    AND S.METADATA$ACTION = 'INSERT'
    AND S.METADATA$ISUPDATE = 'TRUE'
THEN UPDATE SET
    F.column1 = S.column1,
    F.column2 = S.column2;

Key Points:
- Match on INSERT (new values)
- Check METADATA$ISUPDATE = 'TRUE'
- UPDATE target with new values
- Ignore DELETE row (old values)

Complete MERGE for All Changes:

MERGE INTO target F
USING stream S
ON F.id = S.id
-- Handle UPDATEs
WHEN MATCHED
    AND S.METADATA$ACTION = 'INSERT'
    AND S.METADATA$ISUPDATE = 'TRUE'
THEN UPDATE SET F.product = S.product
-- Handle DELETEs
WHEN MATCHED
    AND S.METADATA$ACTION = 'DELETE'
    AND S.METADATA$ISUPDATE = 'FALSE'
THEN DELETE
-- Handle INSERTs
WHEN NOT MATCHED
    AND S.METADATA$ACTION = 'INSERT'
    AND S.METADATA$ISUPDATE = 'FALSE'
THEN INSERT VALUES (S.id, S.product);

Deepak's UPDATE Checklist:

✅ UPDATE executed on source
✅ Stream shows 2 rows
✅ DELETE row has old values
✅ INSERT row has new values
✅ Both have ISUPDATE = TRUE
✅ MERGE uses INSERT row
✅ Target table updated
✅ Stream consumed

Key Takeaway:
UPDATEs appear as DELETE + INSERT in streams!
Both rows have METADATA$ISUPDATE = 'TRUE'.
Use MERGE with UPDATE clause, matching on
INSERT row to get new values!

Practiced: February 2026
Status: ✅ Completed - Stream UPDATE tracking mastered
*/


