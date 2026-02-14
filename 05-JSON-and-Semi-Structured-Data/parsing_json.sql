/*
===========================================
DEEPAK'S JSON PARSING PRACTICE
===========================================
Topic: Parsing and Analyzing Raw JSON Data
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Query VARIANT columns with : notation
- Cast JSON attributes to specific types
- Extract multiple attributes
- Handle nested JSON objects
- Difference between $1 and column name
===========================================
*/

-- Deepak's Note: After loading JSON to raw table, parse it!
-- Use column_name:attribute syntax for VARIANT columns


-- ========================================
-- QUERY SINGLE JSON ATTRIBUTES
-- ========================================

-- Deepak's scenario: Query city from raw JSON table
SELECT raw_json:city FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Returns VARIANT type


-- Deepak's alternative: Using $1 notation (if loaded without column name)
SELECT $1:first_name FROM deepak_json_db.public.employee_json_raw;

-- Deepak's learning: Both work, but column name is clearer


-- ========================================
-- CAST TO SPECIFIC DATA TYPES
-- ========================================

-- Deepak's technique: Cast VARIANT to STRING
SELECT
    raw_json:first_name::STRING AS first_name
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Now returns STRING instead of VARIANT


-- Deepak's scenario: Cast to INT
SELECT
    raw_json:id::INT AS id
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's learning: Use ::TYPE to cast VARIANT to specific type


-- ========================================
-- QUERY MULTIPLE ATTRIBUTES
-- ========================================

-- Deepak's scenario: Extract multiple employee attributes
SELECT
    raw_json:id::INT AS id,
    raw_json:first_name::STRING AS first_name,
    raw_json:last_name::STRING AS last_name,
    raw_json:gender::STRING AS gender,
    raw_json:city::STRING AS city
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Can extract and cast multiple attributes at once


-- ========================================
-- PREVIEW: NESTED DATA
-- ========================================

-- Deepak's experiment: Query nested job object
SELECT
    raw_json:job AS job
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Returns nested object as VARIANT
-- Need to drill deeper to get specific fields (covered in next file)


/*
DEEPAK'S JSON PARSING INSIGHTS:
================================

Querying VARIANT Columns:

Syntax:
column_name:attribute_name

Examples:
raw_json:first_name
raw_json:id
raw_json:city

Alternative ($1 notation):
$1:attribute_name
-- Use when column is unnamed

Casting VARIANT to Types:

Syntax:
column_name:attribute::TYPE

Common Types:
::STRING
::INT
::NUMBER
::FLOAT
::BOOLEAN
::DATE
::TIMESTAMP
::ARRAY
::OBJECT

Examples:
raw_json:id::INT
raw_json:name::STRING
raw_json:salary::NUMBER(10,2)
raw_json:hire_date::DATE

Why Cast?
✅ Better performance
✅ Proper data types
✅ Enable type-specific operations
✅ Clearer query results
✅ Avoid implicit conversions

VARIANT vs Typed Columns:

VARIANT:
- Flexible schema
- Slower queries
- More storage
- Use for: Raw storage

Typed Columns:
- Fixed schema
- Faster queries
- Less storage
- Use for: Final tables

Best Practices:
1. Cast VARIANT to specific types
2. Use meaningful aliases
3. Extract only needed attributes
4. Create views for common queries
5. Document JSON structure
6. Test with sample data

Common Patterns:

1. Simple Extraction:
SELECT
    raw:field1::STRING,
    raw:field2::INT
FROM raw_table;

2. With Aliases:
SELECT
    raw:field1::STRING AS field1,
    raw:field2::INT AS field2
FROM raw_table;

3. Multiple Attributes:
SELECT
    raw:id::INT AS id,
    raw:name::STRING AS name,
    raw:email::STRING AS email,
    raw:age::INT AS age
FROM raw_table;

4. Nested Preview:
SELECT
    raw:nested_object AS nested
FROM raw_table;

Error Handling:

-- Use TRY_CAST for safety
SELECT
    TRY_CAST(raw:id AS INT) AS id
FROM raw_table;

-- Handle NULLs
SELECT
    COALESCE(raw:name::STRING, 'Unknown') AS name
FROM raw_table;

-- Check if attribute exists
SELECT
    CASE
        WHEN raw:email IS NOT NULL
        THEN raw:email::STRING
        ELSE 'No email'
    END AS email
FROM raw_table;

Performance Tips:
1. Cast to specific types (not VARIANT)
2. Create materialized views
3. Use clustering on VARIANT columns
4. Extract frequently used fields
5. Consider creating typed tables

Real-World Example:

-- Raw JSON table
CREATE TABLE customers_raw (
    raw VARIANT
);

-- Parse and create view
CREATE VIEW customers_parsed AS
SELECT
    raw:customer_id::INT AS customer_id,
    raw:first_name::STRING AS first_name,
    raw:last_name::STRING AS last_name,
    raw:email::STRING AS email,
    raw:phone::STRING AS phone,
    raw:city::STRING AS city,
    raw:country::STRING AS country,
    raw:signup_date::DATE AS signup_date
FROM customers_raw;

-- Query the view
SELECT * FROM customers_parsed
WHERE country = 'India';

Deepak's Parsing Workflow:
1. Load JSON to raw table (VARIANT)
2. Query to understand structure
3. Identify needed attributes
4. Cast to appropriate types
5. Create view or table
6. Validate results
7. Document schema

Key Takeaway:
Use column_name:attribute::TYPE syntax to extract
and cast JSON attributes. Always cast VARIANT to
specific types for better performance!

Practiced: February 2026
Status: ✅ Completed - Understanding JSON parsing basics
*/