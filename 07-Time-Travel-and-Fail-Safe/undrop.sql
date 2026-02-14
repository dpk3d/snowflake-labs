/*
===========================================
DEEPAK'S UNDROP PRACTICE
===========================================
Topic: Recovering Dropped Objects with UNDROP
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- UNDROP recovers dropped tables, schemas, databases
- Works within retention period
- Can undrop multiple object types
- Handle name conflicts with RENAME
- UNDROP is a lifesaver for accidents!
===========================================
*/

-- Deepak's Note: UNDROP is the ultimate safety net!
-- Accidentally dropped a table? No problem - UNDROP it!


-- ========================================
-- SETUP: CREATE STAGE AND TABLE
-- ========================================

-- Deepak's scenario: Create stage for customer data
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.deepak_time_travel_stage
    URL = 's3://deepak-snowflake-fundamentals/time-travel/'
    FILE_FORMAT = deepak_mgmt_db.file_formats.deepak_csv_format
    COMMENT = 'Deepak - Stage for time travel practice data';

-- Deepak's scenario: Create customers table
CREATE OR REPLACE TABLE deepak_analytics_db.public.customers (
    id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    gender STRING,
    job STRING,
    phone STRING
)
COMMENT = 'Deepak - Customer data for UNDROP testing';

-- Load customer data
COPY INTO deepak_analytics_db.public.customers
FROM @deepak_mgmt_db.external_stages.deepak_time_travel_stage
FILES = ('customers.csv');

-- Verify loaded data
SELECT * FROM deepak_analytics_db.public.customers;

-- Deepak's observation: 1000 customer records loaded


-- ========================================
-- UNDROP TABLE
-- ========================================

-- Deepak's accident: Dropped the customers table!
DROP TABLE deepak_analytics_db.public.customers;

-- Deepak's panic: Try to query - ERROR!
SELECT * FROM deepak_analytics_db.public.customers;
-- Error: Table does not exist

-- Deepak's recovery: UNDROP the table
UNDROP TABLE deepak_analytics_db.public.customers;

-- Deepak's relief: Table is back!
SELECT * FROM deepak_analytics_db.public.customers;

-- Deepak's learning: UNDROP saves the day! ✅


-- ========================================
-- UNDROP SCHEMA
-- ========================================

-- Deepak's bigger accident: Dropped entire schema!
DROP SCHEMA deepak_analytics_db.public;

-- Deepak's panic: Schema and all tables gone!
SELECT * FROM deepak_analytics_db.public.customers;
-- Error: Schema does not exist

-- Deepak's recovery: UNDROP the schema
UNDROP SCHEMA deepak_analytics_db.public;

-- Deepak's relief: Schema and all tables restored!
SELECT * FROM deepak_analytics_db.public.customers;

-- Deepak's learning: UNDROP works for schemas too! ✅


-- ========================================
-- UNDROP DATABASE
-- ========================================

-- Deepak's worst accident: Dropped entire database!
DROP DATABASE deepak_analytics_db;

-- Deepak's panic: Everything is gone!
SELECT * FROM deepak_analytics_db.public.customers;
-- Error: Database does not exist

-- Deepak's recovery: UNDROP the database
UNDROP DATABASE deepak_analytics_db;

-- Deepak's relief: Database, schemas, and tables all back!
SELECT * FROM deepak_analytics_db.public.customers;

-- Deepak's learning: UNDROP works for databases too! ✅



-- ========================================
-- SCENARIO: UNDROP WITH NAME CONFLICT
-- ========================================

-- Deepak's scenario: Corrupt data with updates
UPDATE deepak_analytics_db.public.customers
SET last_name = 'Singh';

UPDATE deepak_analytics_db.public.customers
SET job = 'Data Engineer';

-- Deepak's observation: Data is corrupted


-- Deepak's attempt: Restore using CREATE OR REPLACE
CREATE OR REPLACE TABLE deepak_analytics_db.public.customers AS
SELECT * FROM deepak_analytics_db.public.customers
BEFORE (STATEMENT => '019b9f7c-0500-851b-0043-4d83000762be');

-- Deepak's note: This creates a NEW table and drops the old one

-- Verify restored data
SELECT * FROM deepak_analytics_db.public.customers;


-- Deepak's problem: Try to UNDROP the old version
UNDROP TABLE deepak_analytics_db.public.customers;

-- Deepak's observation: ERROR! Name already exists
-- Can't undrop because a table with that name exists


-- ========================================
-- SOLUTION: RENAME THEN UNDROP
-- ========================================

-- Deepak's solution: Rename current table first
ALTER TABLE deepak_analytics_db.public.customers
RENAME TO deepak_analytics_db.public.customers_wrong;

-- Deepak's observation: Current table renamed

-- Now UNDROP the original
UNDROP TABLE deepak_analytics_db.public.customers;

-- Deepak's learning: Can now access both versions!

-- Check the undropped (original) table
DESC TABLE deepak_analytics_db.public.customers;

-- Compare both tables
SELECT 'Original' AS version, COUNT(*) AS row_count
FROM deepak_analytics_db.public.customers
UNION ALL
SELECT 'Wrong' AS version, COUNT(*) AS row_count
FROM deepak_analytics_db.public.customers_wrong;


/*
DEEPAK'S UNDROP INSIGHTS:
==========================

What is UNDROP?

- Recovers dropped objects
- Works for: Tables, Schemas, Databases
- Must be within retention period
- Restores object and all data
- Preserves time travel history

UNDROP Syntax:

Tables:
UNDROP TABLE database.schema.table_name;

Schemas:
UNDROP SCHEMA database.schema_name;

Databases:
UNDROP DATABASE database_name;

How UNDROP Works:

When you DROP:
1. Object is marked as dropped
2. Data is not deleted immediately
3. Object enters "dropped" state
4. Retention period timer starts

When you UNDROP:
1. Object is unmarked as dropped
2. Object becomes active again
3. All data is restored
4. Time travel history preserved

UNDROP Requirements:

✅ Must be within retention period
✅ Must have appropriate privileges
✅ Name must not conflict
✅ Parent objects must exist

Retention Period Impact:

Standard Edition:
- Max 1 day retention
- Can undrop within 1 day

Enterprise Edition:
- Max 90 days retention
- Can undrop within 90 days

After retention period:
❌ Can't undrop
❌ Data enters Fail-Safe
❌ Only Snowflake support can help

UNDROP Hierarchy:

Database:
- Undrops database
- Undrops all schemas
- Undrops all tables
- Restores everything

Schema:
- Undrops schema
- Undrops all tables in schema
- Parent database must exist

Table:
- Undrops single table
- Parent schema must exist
- Parent database must exist

Name Conflicts:

Problem:
DROP TABLE customers;
CREATE TABLE customers (...);  -- New table
UNDROP TABLE customers;  -- ERROR! Name exists

Solution 1: Rename Current
ALTER TABLE customers RENAME TO customers_new;
UNDROP TABLE customers;

Solution 2: Undrop with Rename
UNDROP TABLE customers RENAME TO customers_old;

Solution 3: Drop Current First
DROP TABLE customers;
UNDROP TABLE customers;

Best Practices:

1. Set Appropriate Retention:
   - Critical tables: 30-90 days
   - Regular tables: 7-14 days
   - Gives more time to undrop

2. Document Drops:
   - Note when objects dropped
   - Track retention deadlines
   - Set reminders

3. Test UNDROP:
   - Practice in dev environment
   - Understand behavior
   - Know limitations

4. Handle Name Conflicts:
   - Rename before undrop
   - Or undrop with new name
   - Plan ahead

5. Verify After UNDROP:
   - Check row counts
   - Validate data
   - Test queries

Common Scenarios:

Scenario 1: Accidental Table Drop
DROP TABLE important_table;  -- Oops!
UNDROP TABLE important_table;  -- Fixed!

Scenario 2: Dropped Wrong Schema
DROP SCHEMA analytics;  -- Wrong one!
UNDROP SCHEMA analytics;  -- Restored!

Scenario 3: Entire Database Gone
DROP DATABASE production;  -- Disaster!
UNDROP DATABASE production;  -- Crisis averted!

Scenario 4: Name Conflict
DROP TABLE orders;
CREATE TABLE orders (...);  -- New table
-- Can't undrop directly
ALTER TABLE orders RENAME TO orders_new;
UNDROP TABLE orders;  -- Now works!

UNDROP vs Time Travel:

Time Travel:
- Query historical data
- Don't need to drop
- Can see changes over time
- More flexible

UNDROP:
- Recover dropped objects
- Only for dropped objects
- All-or-nothing restore
- Simpler for drops

Both:
- Use retention period
- Preserve data
- Enable recovery
- Cost storage

Real-World Examples:

Example 1: Recover Dropped Table
-- Accidentally dropped
DROP TABLE fact_sales;

-- Immediate recovery
UNDROP TABLE fact_sales;

-- Verify
SELECT COUNT(*) FROM fact_sales;

Example 2: Recover Schema
-- Dropped schema with 50 tables
DROP SCHEMA reporting;

-- Recover all at once
UNDROP SCHEMA reporting;

-- All 50 tables back!

Example 3: Handle Conflict
-- Dropped and recreated
DROP TABLE customers;
CREATE TABLE customers (id INT);

-- Can't undrop directly
-- Solution: Rename first
ALTER TABLE customers RENAME TO customers_v2;
UNDROP TABLE customers;

-- Now have both versions
SELECT * FROM customers;      -- Original
SELECT * FROM customers_v2;   -- New

Example 4: Partial Recovery
-- Dropped schema
DROP SCHEMA analytics;

-- Undrop schema
UNDROP SCHEMA analytics;

-- But only need one table
-- Can drop others
DROP TABLE analytics.table1;
DROP TABLE analytics.table2;
-- Keep analytics.table3

Monitoring Dropped Objects:

-- View dropped tables
SHOW TABLES HISTORY;

-- View dropped schemas
SHOW SCHEMAS HISTORY;

-- View dropped databases
SHOW DATABASES HISTORY;

-- Query dropped objects
SELECT *
FROM snowflake.account_usage.tables
WHERE deleted IS NOT NULL
AND deleted > DATEADD(day, -7, CURRENT_TIMESTAMP());

UNDROP Limitations:

❌ Can't undrop after retention period
❌ Can't undrop if name conflicts
❌ Can't undrop if parent dropped
❌ Can't partially undrop schema/database
❌ Can't undrop external tables
❌ Can't undrop temporary tables

Advanced UNDROP:

-- Undrop with new name
UNDROP TABLE customers RENAME TO customers_backup;

-- Undrop specific version
-- (if multiple drops)
UNDROP TABLE customers BEFORE (TIMESTAMP => '2026-02-14 10:00:00');

-- Check if can undrop
SHOW TABLES HISTORY LIKE 'customers';
-- Check DROPPED_ON column

Error Handling:

-- Check if table exists
SHOW TABLES LIKE 'customers';

-- Try to undrop
BEGIN
    UNDROP TABLE customers;
EXCEPTION
    WHEN OTHER THEN
        -- Handle error
        RETURN 'Could not undrop';
END;

Deepak's UNDROP Workflow:

1. Realize object was dropped
2. Check retention period
3. Verify parent objects exist
4. Check for name conflicts
5. UNDROP the object
6. Verify data restored
7. Test queries
8. Document incident

Deepak's UNDROP Checklist:
✅ Within retention period?
✅ Parent objects exist?
✅ Name conflict?
✅ Appropriate privileges?
✅ Verified after undrop?
✅ Documented incident?

Key Takeaway:
UNDROP is your safety net for dropped objects!
Works for tables, schemas, and databases within
retention period. Handle name conflicts with RENAME.
Always verify after undrop!

Practiced: February 2026
Status: ✅ Completed - UNDROP mastered
*/
    