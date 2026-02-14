/*
===========================================
DEEPAK'S TIME TRAVEL RESTORATION PRACTICE
===========================================
Topic: Restoring Data Using Time Travel
Date Practiced: February 13 , 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Two methods to restore data
- Bad method: CREATE OR REPLACE (loses history)
- Good method: Backup + TRUNCATE + INSERT
- Preserve time travel history
- Safe restoration workflow
===========================================
*/

-- Deepak's Note: Restoring data is tricky - do it wrong and lose history!
-- Always use the backup method to preserve time travel


-- ========================================
-- SETUP: CREATE AND LOAD TEST TABLE
-- ========================================

-- Deepak's scenario: Create test table for restoration practice
CREATE OR REPLACE TABLE deepak_analytics_db.public.restoration_test (
    id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    gender STRING,
    job STRING,
    phone STRING
)
COMMENT = 'Deepak - Test table for time travel restoration';

-- Load customer data
COPY INTO deepak_analytics_db.public.restoration_test
FROM @deepak_mgmt_db.external_stages.deepak_time_travel_stage
FILES = ('customers.csv');

-- Verify loaded data
SELECT * FROM deepak_analytics_db.public.restoration_test;

-- Deepak's observation: Original data loaded successfully


-- ========================================
-- SCENARIO: ACCIDENTAL UPDATES
-- ========================================

-- Deepak's first mistake: Updated all last names
UPDATE deepak_analytics_db.public.restoration_test
SET last_name = 'Singh';

-- Deepak's note: Copy this query ID for restoration!
-- Query ID: 019b9eea-0500-845a-0043-4d830007402a

-- Deepak's second mistake: Updated all jobs
UPDATE deepak_analytics_db.public.restoration_test
SET job = 'Data Engineer';

-- Deepak's observation: Data is now corrupted with wrong values

-- Verify time travel can see original data
SELECT * FROM deepak_analytics_db.public.restoration_test
BEFORE (STATEMENT => '019b9eea-0500-845a-0043-4d830007402a');

-- Deepak's relief: Original data is still accessible!


-- ========================================
-- BAD RESTORATION METHOD ❌
-- ========================================

-- Deepak's warning: This method LOSES time travel history!

-- Bad approach: CREATE OR REPLACE
CREATE OR REPLACE TABLE deepak_analytics_db.public.restoration_test AS
SELECT * FROM deepak_analytics_db.public.restoration_test
BEFORE (STATEMENT => '019b9eea-0500-845a-0043-4d830007402a');

-- Deepak's observation: Data is restored BUT...
SELECT * FROM deepak_analytics_db.public.restoration_test;

-- Deepak's problem: Try to go back further - FAILS!
CREATE OR REPLACE TABLE deepak_analytics_db.public.restoration_test AS
SELECT * FROM deepak_analytics_db.public.restoration_test
BEFORE (STATEMENT => '019b9eea-0500-8473-0043-4d830007307a');

-- Deepak's learning: CREATE OR REPLACE destroys time travel history!
-- ❌ Previous versions are LOST
-- ❌ Can't go back to earlier states
-- ❌ Time travel chain is broken


-- ========================================
-- GOOD RESTORATION METHOD ✅
-- ========================================

-- Deepak's recommendation: Use backup + truncate + insert

-- Step 1: Create backup table with historical data
CREATE OR REPLACE TABLE deepak_analytics_db.public.restoration_test_backup AS
SELECT * FROM deepak_analytics_db.public.restoration_test
BEFORE (STATEMENT => '019b9ef0-0500-8473-0043-4d830007309a');

-- Deepak's observation: Backup created with correct data

-- Step 2: Truncate the original table (preserves structure and history)
TRUNCATE TABLE deepak_analytics_db.public.restoration_test;

-- Deepak's note: TRUNCATE keeps the table object, just removes data

-- Step 3: Insert data from backup
INSERT INTO deepak_analytics_db.public.restoration_test
SELECT * FROM deepak_analytics_db.public.restoration_test_backup;

-- Deepak's learning: This preserves time travel history! ✅

-- Verify restored data
SELECT * FROM deepak_analytics_db.public.restoration_test;

-- Deepak's observation: Data restored AND time travel history preserved!


/*
DEEPAK'S RESTORATION INSIGHTS:
===============================

Two Restoration Methods:

Method 1: CREATE OR REPLACE (BAD ❌)
CREATE OR REPLACE TABLE table_name AS
SELECT * FROM table_name
BEFORE (STATEMENT => 'query-id');

Problems:
❌ Destroys time travel history
❌ Can't go back to earlier states
❌ Breaks time travel chain
❌ Loses retention period
❌ Resets table metadata
❌ Dangerous for production

When It Happens:
- CREATE OR REPLACE creates NEW table
- Old table is dropped
- Time travel history is lost
- Can't access previous versions

Method 2: Backup + Truncate + Insert (GOOD ✅)
-- Step 1: Backup
CREATE TABLE table_backup AS
SELECT * FROM table_name
BEFORE (STATEMENT => 'query-id');

-- Step 2: Truncate
TRUNCATE TABLE table_name;

-- Step 3: Insert
INSERT INTO table_name
SELECT * FROM table_backup;

Benefits:
✅ Preserves time travel history
✅ Can still go back to earlier states
✅ Maintains time travel chain
✅ Keeps retention period
✅ Preserves table metadata
✅ Safe for production

Why It Works:
- Original table object remains
- Only data is removed (TRUNCATE)
- Data is re-inserted
- Time travel history intact
- Can access all previous versions

Comparison Table:

Feature                  | CREATE OR REPLACE | Backup + Truncate + Insert
-------------------------|-------------------|---------------------------
Restores Data            | Yes               | Yes
Preserves History        | No ❌             | Yes ✅
Time Travel Works        | No ❌             | Yes ✅
Table Metadata           | Lost              | Preserved
Retention Period         | Reset             | Preserved
Production Safe          | No ❌             | Yes ✅
Complexity               | Simple            | More steps
Risk Level               | High              | Low

Best Practices:

1. Always Use Backup Method:
   - Create backup table
   - Truncate original
   - Insert from backup
   - Verify results

2. Test Before Restoring:
   - Query historical data first
   - Verify it's correct
   - Then restore

3. Document Query IDs:
   - Keep track of important operations
   - Note query IDs for critical updates
   - Makes restoration easier

4. Verify After Restoration:
   - Check row counts
   - Validate data quality
   - Test time travel still works

5. Clean Up Backups:
   - Drop backup tables after verification
   - Don't accumulate unnecessary tables

Complete Restoration Workflow:

-- Step 1: Identify the problem
SELECT * FROM table_name;
-- Data is wrong!

-- Step 2: Find correct version
SELECT * FROM table_name
BEFORE (STATEMENT => 'query-id');
-- This looks correct!

-- Step 3: Create backup
CREATE TABLE table_name_backup AS
SELECT * FROM table_name
BEFORE (STATEMENT => 'query-id');

-- Step 4: Verify backup
SELECT COUNT(*) FROM table_name_backup;
SELECT * FROM table_name_backup LIMIT 10;

-- Step 5: Truncate original
TRUNCATE TABLE table_name;

-- Step 6: Restore from backup
INSERT INTO table_name
SELECT * FROM table_name_backup;

-- Step 7: Verify restoration
SELECT COUNT(*) FROM table_name;
SELECT * FROM table_name LIMIT 10;

-- Step 8: Test time travel
SELECT * FROM table_name
AT (OFFSET => -60*5);  -- 5 minutes ago
-- Still works! ✅

-- Step 9: Clean up
DROP TABLE table_name_backup;

Real-World Example:

-- Accidentally deleted important orders
DELETE FROM orders
WHERE order_date = '2026-02-14';

-- Panic! Need to restore

-- Step 1: Verify data exists in time travel
SELECT COUNT(*) FROM orders
BEFORE (STATEMENT => 'delete-query-id');
-- 1000 rows - good!

-- Step 2: Create backup
CREATE TABLE orders_backup AS
SELECT * FROM orders
BEFORE (STATEMENT => 'delete-query-id');

-- Step 3: Truncate
TRUNCATE TABLE orders;

-- Step 4: Restore
INSERT INTO orders
SELECT * FROM orders_backup;

-- Step 5: Verify
SELECT COUNT(*) FROM orders;
-- 1000 rows restored! ✅

-- Step 6: Clean up
DROP TABLE orders_backup;

Alternative: Selective Restoration

-- Only restore specific rows
INSERT INTO orders
SELECT * FROM orders
BEFORE (STATEMENT => 'delete-query-id')
WHERE order_date = '2026-02-14';

-- Restores only deleted rows

Common Mistakes:

❌ Using CREATE OR REPLACE
   - Loses history
   - Can't undo

❌ Not verifying backup
   - Might restore wrong data
   - Always check first

❌ Forgetting to clean up
   - Backup tables accumulate
   - Wastes storage

❌ Not testing time travel after
   - Might have broken it
   - Always verify

❌ Restoring without testing
   - Might make it worse
   - Query first, restore second

Advanced Techniques:

1. Partial Restoration:
-- Restore only specific columns
UPDATE table_name t
SET column1 = h.column1
FROM (
    SELECT id, column1
    FROM table_name
    BEFORE (STATEMENT => 'query-id')
) h
WHERE t.id = h.id;

2. Merge Restoration:
MERGE INTO table_name t
USING (
    SELECT * FROM table_name
    BEFORE (STATEMENT => 'query-id')
) h
ON t.id = h.id
WHEN MATCHED THEN UPDATE SET
    t.column1 = h.column1,
    t.column2 = h.column2;

3. Conditional Restoration:
-- Only restore rows that changed
INSERT INTO table_name
SELECT * FROM table_name
BEFORE (STATEMENT => 'query-id')
WHERE id NOT IN (SELECT id FROM table_name);

Deepak's Restoration Checklist:
✅ Identify the problem
✅ Find correct version with time travel
✅ Create backup table
✅ Verify backup data
✅ Truncate original table
✅ Insert from backup
✅ Verify restoration
✅ Test time travel still works
✅ Clean up backup table
✅ Document the incident

Key Takeaway:
NEVER use CREATE OR REPLACE to restore data!
Always use Backup + TRUNCATE + INSERT to preserve
time travel history. Your future self will thank you!

Practiced: February 2026
Status: ✅ Completed - Safe restoration mastered
*/