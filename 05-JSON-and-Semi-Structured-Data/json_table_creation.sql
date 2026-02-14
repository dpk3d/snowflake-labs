/*
===========================================
DEEPAK'S FINAL JSON TABLE CREATION
===========================================
Topic: Creating Final Tables from JSON
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- CREATE TABLE AS (CTAS) pattern
- INSERT INTO pattern
- When to use each approach
- Combining FLATTEN with table creation
- Best practices for final tables
===========================================
*/

-- Deepak's Note: Two ways to create final tables from JSON!
-- Choose based on your use case


-- ========================================
-- OPTION 1: CREATE TABLE AS (CTAS)
-- ========================================

-- Deepak's technique: Create and populate in one step
CREATE OR REPLACE TABLE deepak_json_db.public.employee_languages AS
SELECT
    raw_json:first_name::STRING AS first_name,
    f.value:language::STRING AS language,
    f.value:level::STRING AS proficiency_level
FROM deepak_json_db.public.employee_json_raw,
TABLE(FLATTEN(raw_json:spoken_languages)) f;

-- Deepak's learning: CTAS creates table and loads data in one command!

-- Verify the data
SELECT * FROM deepak_json_db.public.employee_languages;

-- Deepak's observation: Table created with data from flattened JSON


-- Clean up for next example
TRUNCATE TABLE deepak_json_db.public.employee_languages;


-- ========================================
-- OPTION 2: INSERT INTO
-- ========================================

-- Deepak's scenario: Table already exists, just insert data
INSERT INTO deepak_json_db.public.employee_languages
SELECT
    raw_json:first_name::STRING AS first_name,
    f.value:language::STRING AS language,
    f.value:level::STRING AS proficiency_level
FROM deepak_json_db.public.employee_json_raw,
TABLE(FLATTEN(raw_json:spoken_languages)) f;

-- Deepak's learning: INSERT INTO adds data to existing table

-- Verify the data
SELECT * FROM deepak_json_db.public.employee_languages;

-- Deepak's observation: Data inserted successfully


/*
DEEPAK'S TABLE CREATION INSIGHTS:
===================================

Two Approaches:

1. CREATE TABLE AS (CTAS)
2. INSERT INTO

CREATE TABLE AS (CTAS):

Syntax:
CREATE OR REPLACE TABLE table_name AS
SELECT ...;

Benefits:
✅ Single command
✅ Creates table structure automatically
✅ Infers data types from query
✅ Faster for initial load
✅ Simpler code
✅ No need to define schema

Drawbacks:
❌ Less control over data types
❌ No constraints (PK, FK, etc.)
❌ No comments on columns
❌ Replaces existing table
❌ Can't append to existing data

Example:
CREATE OR REPLACE TABLE customers AS
SELECT
    raw:id::INT AS customer_id,
    raw:name::STRING AS name,
    raw:email::STRING AS email
FROM customers_raw;

INSERT INTO:

Syntax:
-- First create table
CREATE TABLE table_name (
    column1 TYPE,
    column2 TYPE
);

-- Then insert data
INSERT INTO table_name
SELECT ...;

Benefits:
✅ Full control over schema
✅ Can add constraints
✅ Can add comments
✅ Can append data
✅ Explicit data types
✅ Better for production

Drawbacks:
❌ Two-step process
❌ More verbose
❌ Need to define schema
❌ Schema must match query

Example:
CREATE TABLE customers (
    customer_id INT,
    name VARCHAR(100),
    email VARCHAR(255),
    created_date DATE DEFAULT CURRENT_DATE()
);

INSERT INTO customers
SELECT
    raw:id::INT,
    raw:name::STRING,
    raw:email::STRING
FROM customers_raw;

When to Use Each:

CREATE TABLE AS (CTAS):
✅ Quick prototyping
✅ Temporary tables
✅ One-time loads
✅ Testing transformations
✅ Simple structures
✅ Development environment

Example Use Cases:
- Exploratory analysis
- Data validation
- Quick reports
- Temporary staging
- Testing queries

INSERT INTO:
✅ Production tables
✅ Need constraints
✅ Incremental loads
✅ Append data
✅ Specific data types
✅ Need comments/metadata

Example Use Cases:
- Production ETL
- Daily data loads
- Incremental updates
- Tables with constraints
- Documented schemas

Comparison Table:

Feature              | CTAS    | INSERT INTO
---------------------|---------|-------------
Speed                | Fast    | Fast
Schema Control       | Auto    | Manual
Data Types           | Inferred| Explicit
Constraints          | No      | Yes
Comments             | No      | Yes
Append Data          | No      | Yes
Replace Table        | Yes     | No
Code Simplicity      | Simple  | Verbose
Production Ready     | No      | Yes
Prototyping          | Yes     | No

Combining with FLATTEN:

Both work with FLATTEN:

CTAS + FLATTEN:
CREATE TABLE languages AS
SELECT
    raw:name::STRING,
    f.value:language::STRING
FROM employees,
TABLE(FLATTEN(raw:languages)) f;

INSERT + FLATTEN:
INSERT INTO languages
SELECT
    raw:name::STRING,
    f.value:language::STRING
FROM employees,
TABLE(FLATTEN(raw:languages)) f;

Best Practices:

For CTAS:
1. Use for temporary tables
2. Add explicit casts
3. Use meaningful names
4. Document in comments
5. Consider adding constraints later

For INSERT INTO:
1. Define schema first
2. Add constraints
3. Add column comments
4. Use explicit data types
5. Validate before insert

Production Pattern:

-- Step 1: Create table with schema
CREATE TABLE IF NOT EXISTS employee_languages (
    employee_id INT,
    first_name VARCHAR(100),
    language VARCHAR(50),
    proficiency_level VARCHAR(20),
    loaded_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    COMMENT = 'Employee language proficiency from JSON'
);

-- Step 2: Insert transformed data
INSERT INTO employee_languages
SELECT
    raw:id::INT,
    raw:first_name::STRING,
    f.value:language::STRING,
    f.value:level::STRING,
    CURRENT_TIMESTAMP()
FROM employee_raw,
TABLE(FLATTEN(raw:languages)) f;

Incremental Loading:

-- CTAS: Replaces all data
CREATE OR REPLACE TABLE daily_sales AS
SELECT * FROM sales_raw
WHERE date = CURRENT_DATE();

-- INSERT: Appends data
INSERT INTO daily_sales
SELECT * FROM sales_raw
WHERE date = CURRENT_DATE()
AND id NOT IN (SELECT id FROM daily_sales);

Error Handling:

-- CTAS with validation
CREATE OR REPLACE TABLE validated_data AS
SELECT
    raw:id::INT AS id,
    raw:name::STRING AS name
FROM raw_table
WHERE raw:id IS NOT NULL
AND raw:name IS NOT NULL;

-- INSERT with error handling
INSERT INTO target_table
SELECT
    TRY_CAST(raw:id AS INT) AS id,
    COALESCE(raw:name::STRING, 'Unknown') AS name
FROM raw_table
WHERE TRY_CAST(raw:id AS INT) IS NOT NULL;

Real-World Workflow:

Development:
1. Use CTAS for exploration
2. Test transformations
3. Validate results
4. Iterate quickly

Production:
1. Define proper schema
2. Add constraints
3. Add comments
4. Use INSERT INTO
5. Schedule incremental loads

Example:
-- Development
CREATE TABLE test_customers AS
SELECT raw:id::INT, raw:name::STRING
FROM raw;

-- Production
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    created_date DATE DEFAULT CURRENT_DATE(),
    COMMENT = 'Customer master data'
);

INSERT INTO customers
SELECT
    raw:id::INT,
    raw:name::STRING,
    raw:email::STRING,
    CURRENT_DATE()
FROM customers_raw;

Deepak's Decision Tree:

Need quick results?
└─ Yes → Use CTAS
└─ No → Continue

Need to append data?
└─ Yes → Use INSERT INTO
└─ No → Continue

Need constraints?
└─ Yes → Use INSERT INTO
└─ No → Continue

Production table?
└─ Yes → Use INSERT INTO
└─ No → Use CTAS

Key Takeaway:
Use CREATE TABLE AS for quick prototyping and
temporary tables. Use INSERT INTO for production
tables with proper schema, constraints, and
incremental loading.

Practiced: February 2026
Status: ✅ Completed - Understanding table creation patterns
*/
