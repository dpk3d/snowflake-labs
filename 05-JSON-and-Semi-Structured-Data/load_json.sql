/*
===========================================
DEEPAK'S JSON LOADING PRACTICE
===========================================
Topic: Loading JSON Data from Azure
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- JSON file format for semi-structured data
- Query JSON directly from stage
- Access JSON attributes with $1:attribute
- Two-step pattern: Raw table then transform
- VARIANT data type for JSON storage
===========================================
*/

-- Deepak's Note: JSON is semi-structured data - flexible schema!
-- Snowflake handles JSON natively with VARIANT data type


-- ========================================
-- SETUP: CREATE JSON FILE FORMAT
-- ========================================

-- Deepak's scenario: Create file format for JSON files
CREATE OR REPLACE FILE FORMAT deepak_json_db.public.deepak_json_format
    TYPE = JSON
    COMMENT = 'Deepak - JSON file format for semi-structured data';

-- Deepak's observation: JSON format is simple - just specify TYPE = JSON


-- ========================================
-- CREATE AZURE STAGE WITH JSON FORMAT
-- ========================================

-- Deepak's scenario: Azure stage with JSON files
CREATE OR REPLACE STAGE deepak_json_db.public.deepak_azure_json_stage
    STORAGE_INTEGRATION = deepak_azure_integration
    URL = 'azure://deepaksnowflake.blob.core.windows.net/json-data'
    FILE_FORMAT = deepak_json_format
    COMMENT = 'Deepak - Azure stage for JSON car owner data';

-- List JSON files in stage
LIST @deepak_json_db.public.deepak_azure_json_stage;

-- Deepak's observation: JSON files ready to query


-- ========================================
-- QUERY JSON DIRECTLY FROM STAGE
-- ========================================

-- Deepak's experiment: Query raw JSON from stage
SELECT * FROM @deepak_json_db.public.deepak_azure_json_stage;

-- Deepak's learning: Returns JSON as VARIANT type in $1 column


-- Deepak's scenario: Query specific JSON attribute
SELECT $1:"Car Model" FROM @deepak_json_db.public.deepak_azure_json_stage;

-- Deepak's observation: Returns VARIANT - need to cast to proper type


-- Deepak's technique: Cast JSON attribute to STRING
SELECT $1:"Car Model"::STRING FROM @deepak_json_db.public.deepak_azure_json_stage;

-- Deepak's learning: Use :: to cast VARIANT to specific data type


-- ========================================
-- QUERY MULTIPLE JSON ATTRIBUTES
-- ========================================

-- Deepak's scenario: Extract all car owner attributes
SELECT
    $1:"Car Model"::STRING,
    $1:"Car Model Year"::INT,
    $1:"car make"::STRING,
    $1:"first_name"::STRING,
    $1:"last_name"::STRING
FROM @deepak_json_db.public.deepak_azure_json_stage;

-- Deepak's observation: Can cast to different types (STRING, INT, etc.)


-- Deepak's technique: Use aliases for cleaner output
SELECT
    $1:"Car Model"::STRING AS car_model,
    $1:"Car Model Year"::INT AS car_model_year,
    $1:"car make"::STRING AS car_make,
    $1:"first_name"::STRING AS first_name,
    $1:"last_name"::STRING AS last_name
FROM @deepak_json_db.public.deepak_azure_json_stage;

-- Deepak's learning: Aliases make results more readable


-- ========================================
-- METHOD 1: DIRECT LOAD TO FINAL TABLE
-- ========================================

-- Deepak's scenario: Create final table for car owners
CREATE OR REPLACE TABLE deepak_json_db.public.car_owners (
    car_model VARCHAR,
    car_model_year INT,
    car_make VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR
)
COMMENT = 'Deepak - Car owner information from JSON';

-- Deepak's technique: Load JSON directly into structured table
COPY INTO deepak_json_db.public.car_owners
FROM (
    SELECT
        $1:"Car Model"::STRING AS car_model,
        $1:"Car Model Year"::INT AS car_model_year,
        $1:"car make"::STRING AS car_make,
        $1:"first_name"::STRING AS first_name,
        $1:"last_name"::STRING AS last_name
    FROM @deepak_json_db.public.deepak_azure_json_stage
);

-- Deepak's learning: Transform JSON to structured data during COPY!

-- Verify loaded data
SELECT * FROM deepak_json_db.public.car_owners;

-- Deepak's observation: JSON successfully transformed to relational format


-- ========================================
-- METHOD 2: TWO-STEP PATTERN (RAW + TRANSFORM)
-- ========================================

-- Deepak's scenario: Alternative approach using raw table
TRUNCATE TABLE deepak_json_db.public.car_owners;
SELECT * FROM deepak_json_db.public.car_owners;

-- Deepak's observation: Table empty, ready for two-step approach


-- Step 1: Create raw table with VARIANT column
CREATE OR REPLACE TABLE deepak_json_db.public.car_owners_raw (
    raw_json VARIANT
)
COMMENT = 'Deepak - Raw JSON storage before transformation';

-- Deepak's learning: VARIANT data type stores JSON as-is


-- Step 2: Load raw JSON into table
COPY INTO deepak_json_db.public.car_owners_raw
FROM @deepak_json_db.public.deepak_azure_json_stage;

-- Deepak's observation: JSON loaded without transformation

-- View raw JSON
SELECT * FROM deepak_json_db.public.car_owners_raw;

-- Deepak's note: Each row contains full JSON object


-- Step 3: Transform and insert into final table
INSERT INTO deepak_json_db.public.car_owners
(
    SELECT
        raw_json:"Car Model"::STRING AS car_model,
        raw_json:"Car Model Year"::INT AS car_model_year,
        raw_json:"car make"::STRING AS car_make,
        raw_json:"first_name"::STRING AS first_name,
        raw_json:"last_name"::STRING AS last_name
    FROM deepak_json_db.public.car_owners_raw
);

-- Deepak's learning: Two-step gives more control and flexibility

-- Verify final data
SELECT * FROM deepak_json_db.public.car_owners;


/*
DEEPAK'S JSON LOADING INSIGHTS:
================================

What is JSON?
- JavaScript Object Notation
- Semi-structured data format
- Key-value pairs
- Nested objects and arrays
- Flexible schema

Snowflake JSON Support:
✅ Native JSON parsing
✅ VARIANT data type
✅ Query JSON directly from stage
✅ Transform during COPY
✅ Dot notation for attributes
✅ Array indexing

VARIANT Data Type:
- Stores semi-structured data
- Can hold JSON, XML, Avro, Parquet
- Flexible schema
- Query with : notation
- Cast to specific types

JSON Querying Syntax:
$1:attribute_name          -- Access attribute
$1:attribute::STRING       -- Cast to STRING
$1:attribute::INT          -- Cast to INT
$1:nested.field            -- Nested object
$1:array[0]                -- Array element

Two Loading Patterns:

Pattern 1: Direct Load
COPY INTO final_table
FROM (
    SELECT
        $1:field1::STRING,
        $1:field2::INT
    FROM @json_stage
);

Benefits:
✅ Single step
✅ Faster
✅ Less storage
✅ Simpler code

Pattern 2: Raw Table + Transform
-- Step 1: Load raw
COPY INTO raw_table FROM @json_stage;

-- Step 2: Transform
INSERT INTO final_table
SELECT
    raw:field1::STRING,
    raw:field2::INT
FROM raw_table;

Benefits:
✅ Keep original JSON
✅ Reprocess if needed
✅ Audit trail
✅ Flexible transformations
✅ Can query raw data

When to Use Each Pattern:

Direct Load:
✅ Simple transformations
✅ One-time load
✅ Storage constraints
✅ Fast processing needed

Raw Table:
✅ Complex transformations
✅ Need to keep original
✅ Multiple target tables
✅ Iterative development
✅ Audit requirements

JSON File Format Options:
CREATE FILE FORMAT json_format
    TYPE = JSON
    COMPRESSION = AUTO
    ENABLE_OCTAL = FALSE
    ALLOW_DUPLICATE = FALSE
    STRIP_OUTER_ARRAY = FALSE
    STRIP_NULL_VALUES = FALSE
    IGNORE_UTF8_ERRORS = FALSE;

Common JSON Patterns:

1. Simple Object:
{
  "first_name": "Deepak",
  "last_name": "Singh",
  "age": 30
}

Query:
SELECT
    $1:first_name::STRING,
    $1:last_name::STRING,
    $1:age::INT
FROM @stage;

2. Nested Object:
{
  "name": "Deepak",
  "address": {
    "city": "Mumbai",
    "country": "India"
  }
}

Query:
SELECT
    $1:name::STRING,
    $1:address.city::STRING,
    $1:address.country::STRING
FROM @stage;

3. Array:
{
  "name": "Deepak",
  "skills": ["SQL", "Python", "Snowflake"]
}

Query:
SELECT
    $1:name::STRING,
    $1:skills[0]::STRING,
    $1:skills[1]::STRING
FROM @stage;

Best Practices:
1. Use VARIANT for raw JSON storage
2. Cast to specific types for performance
3. Keep raw table for audit trail
4. Document JSON structure
5. Handle NULL values
6. Test transformations before production
7. Use meaningful column names

Error Handling:
-- Use TRY_CAST for safety
SELECT
    $1:name::STRING,
    TRY_CAST($1:age AS INT) AS age
FROM @stage;

-- Handle missing attributes
SELECT
    $1:name::STRING,
    COALESCE($1:age::INT, 0) AS age
FROM @stage;

Performance Tips:
1. Cast VARIANT to specific types
2. Create views for common queries
3. Use clustering on VARIANT columns
4. Consider materialized views
5. Index frequently queried paths

Real-World Example:
-- Load customer data from JSON
CREATE TABLE customers_raw (raw VARIANT);

COPY INTO customers_raw
FROM @customer_json_stage;

CREATE TABLE customers AS
SELECT
    raw:customer_id::INT AS customer_id,
    raw:name::STRING AS name,
    raw:email::STRING AS email,
    raw:address.city::STRING AS city,
    raw:address.country::STRING AS country,
    raw:signup_date::DATE AS signup_date
FROM customers_raw;

Deepak's Workflow:
1. Create JSON file format
2. Create stage with JSON format
3. Query stage to understand structure
4. Create raw table (VARIANT)
5. Load JSON to raw table
6. Explore and test transformations
7. Create final table structure
8. Transform and insert
9. Validate results
10. Document JSON schema

Key Takeaway:
JSON in Snowflake is powerful! Use VARIANT for storage,
dot notation for querying, and choose between direct load
or two-step pattern based on your needs.

Practiced: February 2026
Status: ✅ Completed - Mastering JSON data loading
*/
  