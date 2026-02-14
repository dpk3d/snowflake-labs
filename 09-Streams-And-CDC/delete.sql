/*
===========================================
DEEPAK'S STREAMS PRACTICE - DELETE
===========================================
Topic: Tracking DELETE Changes with Streams
Date Practiced: February 11, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Streams capture DELETE operations
- METADATA$ACTION = 'DELETE' identifies deletions
- METADATA$ISUPDATE = 'FALSE' for pure deletes
- Use MERGE to propagate deletes to target
- DELETE in source → DELETE in target
===========================================
*/

-- Deepak's Note: This builds on the INSERT stream example
-- Now we'll track and process DELETE operations

-- Deepak's prerequisite: Assumes tables and stream from Insert.txt exist
-- sales_raw_staging, sales_final_table, sales_stream


-- ========================================
-- VERIFY CURRENT STATE
-- ========================================

-- Check final table (should have data)
SELECT * FROM deepak_streams_db.public.sales_final_table
ORDER BY id;

-- Deepak's observation: Final table has all sales records


-- Check staging table
SELECT * FROM deepak_streams_db.public.sales_raw_staging
ORDER BY id;

-- Deepak's note: Staging has same data


-- Check stream (should be empty if previous work consumed)
SELECT * FROM deepak_streams_db.public.sales_stream;

-- Deepak's learning: Stream empty - ready to capture new changes


-- ========================================
-- DELETE DATA FROM STAGING
-- ========================================

-- Deepak's scenario: Remove discontinued product
DELETE FROM deepak_streams_db.public.sales_raw_staging
WHERE product = 'Lemon';

-- Deepak's observation: Deleted 1 row (Lemon)


-- Verify deletion in staging
SELECT * FROM deepak_streams_db.public.sales_raw_staging
WHERE product = 'Lemon';

-- Deepak's learning: Lemon no longer in staging


-- ========================================
-- CHECK STREAM FOR DELETE
-- ========================================

-- Deepak's key check: Stream should capture the DELETE
SELECT * FROM deepak_streams_db.public.sales_stream
ORDER BY id;

-- Deepak's observation: Stream shows deleted row!
-- METADATA$ACTION = 'DELETE'
-- METADATA$ISUPDATE = 'FALSE' (pure delete, not part of update)


-- ========================================
-- PROPAGATE DELETE TO FINAL TABLE
-- ========================================

-- Deepak's technique: Use MERGE to process DELETE
MERGE INTO deepak_streams_db.public.sales_final_table F
USING deepak_streams_db.public.sales_stream S
ON F.id = S.id
WHEN MATCHED
    AND S.METADATA$ACTION = 'DELETE'
    AND S.METADATA$ISUPDATE = 'FALSE'
THEN DELETE;

-- Deepak's learning: MERGE processes DELETE from stream
-- Deletes matching rows in final table


-- ========================================
-- VERIFY DELETE PROPAGATED
-- ========================================

-- Check final table - Lemon should be gone
SELECT * FROM deepak_streams_db.public.sales_final_table
WHERE product = 'Lemon';

-- Deepak's observation: Lemon deleted from final table!


-- Verify all data in final table
SELECT * FROM deepak_streams_db.public.sales_final_table
ORDER BY id;

-- Deepak's learning: Final table in sync with staging


-- Check stream - should be empty (consumed)
SELECT * FROM deepak_streams_db.public.sales_stream;

-- Deepak's observation: Stream consumed by MERGE


/*
DEEPAK'S STREAMS DELETE INSIGHTS:
==================================

DELETE Tracking:

When you DELETE from source table:
1. Row removed from source
2. Stream captures DELETE event
3. METADATA$ACTION = 'DELETE'
4. METADATA$ISUPDATE = 'FALSE'
5. Row appears in stream with DELETE marker

Processing DELETEs:

Use MERGE statement:
MERGE INTO target F
USING stream S
ON F.id = S.id
WHEN MATCHED
    AND S.METADATA$ACTION = 'DELETE'
    AND S.METADATA$ISUPDATE = 'FALSE'
THEN DELETE;

Why MERGE for DELETE?

- INSERT can't delete rows
- DELETE can't use stream directly
- MERGE handles all change types
- Single statement for sync

METADATA$ Columns for DELETE:

METADATA$ACTION = 'DELETE':
- Indicates row was deleted
- Row data shows deleted values
- Use to filter DELETE events

METADATA$ISUPDATE = 'FALSE':
- Confirms pure DELETE
- Not part of UPDATE operation
- Important for correct processing

DELETE vs UPDATE:

Pure DELETE:
- METADATA$ACTION = 'DELETE'
- METADATA$ISUPDATE = 'FALSE'
- Row removed from source

UPDATE (shows as DELETE + INSERT):
- METADATA$ACTION = 'DELETE' (old values)
- METADATA$ISUPDATE = 'TRUE'
- METADATA$ACTION = 'INSERT' (new values)
- METADATA$ISUPDATE = 'TRUE'

Complete MERGE Pattern:

MERGE INTO target F
USING stream S
ON F.id = S.id
WHEN MATCHED
    AND S.METADATA$ACTION = 'DELETE'
    AND S.METADATA$ISUPDATE = 'FALSE'
THEN DELETE
WHEN MATCHED
    AND S.METADATA$ACTION = 'INSERT'
    AND S.METADATA$ISUPDATE = 'TRUE'
THEN UPDATE SET ...
WHEN NOT MATCHED
    AND S.METADATA$ACTION = 'INSERT'
THEN INSERT ...;

Real-World Example:

-- Product discontinued in source
DELETE FROM product_staging
WHERE product_id = 123;

-- Stream captures delete
SELECT * FROM product_stream;
-- Shows product 123 with METADATA$ACTION = 'DELETE'

-- Propagate to production
MERGE INTO product_production F
USING product_stream S
ON F.product_id = S.product_id
WHEN MATCHED AND S.METADATA$ACTION = 'DELETE'
THEN DELETE;

-- Product 123 removed from production

Best Practices:

1. Always Check METADATA$ISUPDATE:
   - Distinguish pure DELETE from UPDATE
   - Prevents incorrect processing
   - Ensures data integrity

2. Use MERGE for Deletes:
   - Can't use INSERT for deletes
   - MERGE handles all change types
   - Single statement for sync

3. Verify Deletions:
   - Check target after MERGE
   - Confirm rows deleted
   - Validate counts

4. Handle Cascading Deletes:
   - Consider foreign keys
   - Delete child records first
   - Maintain referential integrity

5. Log Deletions:
   - Track what was deleted
   - Audit trail
   - Recovery if needed

Common Mistakes:

❌ Using INSERT to process deletes
❌ Forgetting METADATA$ISUPDATE check
❌ Not verifying deletions
❌ Ignoring foreign key constraints
❌ No audit trail for deletes

Deepak's DELETE Workflow:

1. DELETE from source table
2. Query stream to verify DELETE captured
3. Check METADATA$ACTION = 'DELETE'
4. Check METADATA$ISUPDATE = 'FALSE'
5. MERGE to propagate delete
6. Verify target table updated
7. Confirm stream consumed

Deepak's DELETE Checklist:

✅ DELETE executed on source
✅ Stream captured DELETE
✅ METADATA$ columns verified
✅ MERGE statement correct
✅ Target table updated
✅ Stream consumed
✅ Deletions logged

Key Takeaway:
Streams capture DELETE operations with
METADATA$ACTION = 'DELETE'. Use MERGE to
propagate deletes to target tables. Always
check METADATA$ISUPDATE to distinguish pure
deletes from UPDATE operations!

Practiced: February 2026
Status: ✅ Completed - Stream DELETE tracking mastered
*/