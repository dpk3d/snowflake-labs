/*
===========================================
DEEPAK'S TEMPORARY TABLES PRACTICE
===========================================
Topic: Temporary Tables and Session Scope
Date Practiced: February 13, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Temporary tables exist only in current session
- Can have same name as permanent table
- Temporary table takes precedence over permanent
- Automatically dropped when session ends
- No fail-safe, minimal storage costs
===========================================
*/

-- Deepak's Note: Temporary tables are perfect for intermediate processing
-- They're session-specific and don't clutter the database


USE DATABASE deepak_analytics_db;


-- ========================================
-- CREATE PERMANENT TABLE
-- ========================================

-- Deepak's scenario: Create permanent customer table
CREATE OR REPLACE TABLE deepak_analytics_db.public.customers (
   customer_id INT,
   first_name STRING,
   last_name STRING,
   email STRING,
   department STRING,
   job_title STRING,
   phone STRING
)
COMMENT = 'Deepak - Permanent customer table';


-- Load data from source
INSERT INTO deepak_analytics_db.public.customers
SELECT
    customer_id,
    full_name AS first_name,
    'Singh' AS last_name,
    email,
    region AS department,
    'Customer' AS job_title,
    phone
FROM deepak_sales_db.public.customers;


-- Verify permanent table data
SELECT * FROM deepak_analytics_db.public.customers
LIMIT 10;


-- ========================================
-- CREATE TEMPORARY TABLE (SAME NAME!)
-- ========================================

-- Deepak's experiment: Create temp table with SAME name as permanent table
CREATE OR REPLACE TEMPORARY TABLE deepak_analytics_db.public.customers (
   customer_id INT,
   first_name STRING,
   last_name STRING,
   email STRING,
   department STRING,
   job_title STRING,
   phone STRING
)
COMMENT = 'Deepak - Temporary customer table for testing';


-- Deepak's observation: Temporary table now "shadows" the permanent table
-- Queries will hit the temporary table, not the permanent one


-- Validate which table is active
SELECT * FROM deepak_analytics_db.public.customers;

-- Deepak's learning: This returns EMPTY because temp table has no data yet!
-- Permanent table is hidden by temp table


-- ========================================
-- WORK WITH TEMPORARY TABLE
-- ========================================

-- Create another temporary table for processing
CREATE OR REPLACE TEMPORARY TABLE deepak_analytics_db.public.customer_processing (
   customer_id INT,
   first_name STRING,
   last_name STRING,
   email STRING,
   department STRING,
   job_title STRING,
   phone STRING,
   processed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
COMMENT = 'Deepak - Temporary processing table';


-- Insert test data into temp processing table
INSERT INTO deepak_analytics_db.public.customer_processing
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    department,
    job_title,
    phone,
    CURRENT_TIMESTAMP()
FROM deepak_analytics_db.public.customers;

-- Deepak's note: This pulls from the TEMPORARY customers table (which is empty)
-- So customer_processing will also be empty


-- Verify temp table
SELECT * FROM deepak_analytics_db.public.customer_processing;


-- Show all tables (both permanent and temporary)
SHOW TABLES;

-- Deepak's observation: Temporary tables are marked with "kind = TEMPORARY"


/*
DEEPAK'S TEMPORARY TABLES INSIGHTS:
===================================

Key Characteristics:
✅ Session-scoped (only visible in current session)
✅ Automatically dropped when session ends
✅ Can have same name as permanent table
✅ Takes precedence over permanent table
✅ No fail-safe protection
✅ Minimal storage costs
✅ Cannot be cloned
✅ Cannot be shared

Table Precedence:
When querying "customers":
1. TEMPORARY TABLE customers (if exists) ← Highest priority
2. PERMANENT TABLE customers (if exists)
3. Error if neither exists

Use Cases:
✅ ETL intermediate results
✅ Complex query breakdowns
✅ Testing without affecting production
✅ Session-specific calculations
✅ Temporary data transformations
✅ Staging data for processing

Advantages:
- Fast creation and deletion
- No impact on permanent tables
- Automatic cleanup (session end)
- Lower storage costs
- Perfect for testing

Disadvantages:
- Lost when session ends
- Cannot be shared across sessions
- No fail-safe recovery
- Cannot be cloned
- Not suitable for persistent data

Best Practices:
1. Use for intermediate processing only
2. Don't rely on temp tables for important data
3. Be aware of name shadowing
4. Document when using same names as permanent tables
5. Clean up explicitly if session is long-running

Comparison with Permanent Tables:
┌─────────────────────┬────────────┬────────────┐
│ Feature             │ Temporary  │ Permanent  │
├─────────────────────┼────────────┼────────────┤
│ Session Scope       │ Yes        │ No         │
│ Fail-Safe           │ No         │ Yes        │
│ Time Travel         │ 0-1 day    │ 0-90 days  │
│ Can Clone           │ No         │ Yes        │
│ Can Share           │ No         │ Yes        │
│ Storage Cost        │ Lower      │ Higher     │
│ Auto Cleanup        │ Yes        │ No         │
└─────────────────────┴────────────┴────────────┘

Real-World Example:
-- ETL pipeline using temporary tables
CREATE TEMPORARY TABLE staging_data AS
SELECT * FROM raw_data WHERE date = CURRENT_DATE();

CREATE TEMPORARY TABLE cleaned_data AS
SELECT * FROM staging_data WHERE is_valid = TRUE;

INSERT INTO production_table
SELECT * FROM cleaned_data;

-- Temp tables automatically cleaned up at session end

Practiced: February 2026
Status: ✅ Completed - Understanding temporary tables
*/


