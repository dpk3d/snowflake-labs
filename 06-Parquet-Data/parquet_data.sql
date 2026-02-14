/*
===========================================
DEEPAK'S PARQUET DATA PRACTICE
===========================================
Topic: Loading and Querying Parquet Files
Date Practiced: February 15, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Parquet file format for columnar data
- Query Parquet directly from S3 stage
- Access Parquet columns with $1:column
- File format in stage vs query
- Date conversion from Parquet
- Cast Parquet data to proper types
===========================================
*/

-- Deepak's Note: Parquet is a columnar storage format!
-- Much more efficient than CSV for analytics
-- Snowflake handles Parquet natively


-- ========================================
-- CREATE PARQUET FILE FORMAT
-- ========================================

-- Deepak's scenario: Create file format for Parquet files
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.file_formats.deepak_parquet_format
    TYPE = 'parquet'
    COMMENT = 'Deepak - Parquet file format for columnar data';

-- Deepak's observation: Parquet format is simple - just TYPE = 'parquet'


-- ========================================
-- CREATE S3 STAGE WITH PARQUET FORMAT
-- ========================================

-- Deepak's scenario: S3 stage with Parquet sales data
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.deepak_parquet_stage
    URL = 's3://deepak-snowflake-parquet-demo'
    FILE_FORMAT = deepak_mgmt_db.file_formats.deepak_parquet_format
    COMMENT = 'Deepak - S3 stage for Parquet sales data';

-- Deepak's learning: File format specified in stage definition


-- ========================================
-- PREVIEW PARQUET DATA
-- ========================================

-- Deepak's technique: List Parquet files in stage
LIST @deepak_mgmt_db.external_stages.deepak_parquet_stage;

-- Deepak's observation: Parquet files listed with size and metadata

-- Query Parquet data from stage
SELECT * FROM @deepak_mgmt_db.external_stages.deepak_parquet_stage;

-- Deepak's learning: Parquet data returned as structured columns!


-- ========================================
-- FILE FORMAT IN QUERY (ALTERNATIVE)
-- ========================================

-- Deepak's scenario: Stage without file format
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.deepak_parquet_stage_v2
    URL = 's3://deepak-snowflake-parquet-demo';

-- Deepak's observation: No FILE_FORMAT specified in stage

-- Deepak's technique: Specify file format in query
SELECT *
FROM @deepak_mgmt_db.external_stages.deepak_parquet_stage_v2
(file_format => 'deepak_mgmt_db.file_formats.deepak_parquet_format');

-- Deepak's learning: Can override or specify format at query time!


-- Deepak's alternative: Without quotes (if using current namespace)
USE deepak_mgmt_db.file_formats;

SELECT *
FROM @deepak_mgmt_db.external_stages.deepak_parquet_stage_v2
(file_format => deepak_parquet_format);

-- Deepak's observation: Quotes optional for current namespace


-- Deepak's preference: Define format in stage for consistency
CREATE OR REPLACE STAGE deepak_mgmt_db.external_stages.deepak_parquet_stage
    URL = 's3://deepak-snowflake-parquet-demo'
    FILE_FORMAT = deepak_mgmt_db.file_formats.deepak_parquet_format;


-- ========================================
-- EXPLORE PARQUET COLUMN STRUCTURE
-- ========================================

-- Deepak's experiment: Query all Parquet columns
SELECT
    $1:__index_level_0__,
    $1:cat_id,
    $1:date,
    $1:"__index_level_0__",
    $1:"cat_id",
    $1:"d",
    $1:"date",
    $1:"dept_id",
    $1:"id",
    $1:"item_id",
    $1:"state_id",
    $1:"store_id",
    $1:"value"
FROM @deepak_mgmt_db.external_stages.deepak_parquet_stage;

-- Deepak's observation: Parquet columns accessible with $1:column_name
-- Similar to JSON but Parquet has predefined schema!


-- ========================================
-- DATE CONVERSION FROM PARQUET
-- ========================================

-- Deepak's experiment: Understanding date values
SELECT 1;

-- Deepak's technique: Convert Unix timestamp to date
SELECT DATE(365*60*60*24);

-- Deepak's learning: Parquet often stores dates as Unix timestamps
-- Need to convert to DATE type


-- ========================================
-- QUERY WITH PROPER TYPES AND ALIASES
-- ========================================

-- Deepak's scenario: Extract and cast all sales data columns
SELECT
    $1:__index_level_0__::INT AS index_level,
    $1:cat_id::VARCHAR(50) AS category_id,
    DATE($1:date::INT) AS sale_date,
    $1:"dept_id"::VARCHAR(50) AS department_id,
    $1:"id"::VARCHAR(50) AS transaction_id,
    $1:"item_id"::VARCHAR(50) AS item_id,
    $1:"state_id"::VARCHAR(50) AS state_id,
    $1:"store_id"::VARCHAR(50) AS store_id,
    $1:"value"::INT AS sale_value
FROM @deepak_mgmt_db.external_stages.deepak_parquet_stage;

-- Deepak's learning: Cast Parquet columns to proper types!
-- Use meaningful aliases for clarity


/*
DEEPAK'S PARQUET INSIGHTS:
===========================

What is Parquet?

- Columnar storage format
- Optimized for analytics
- Compressed and efficient
- Self-describing schema
- Widely used in big data
- Created by Apache

Parquet vs CSV:

Feature          | Parquet      | CSV
-----------------|--------------|-------------
Storage          | Columnar     | Row-based
Compression      | Excellent    | Poor
Query Speed      | Fast         | Slow
Schema           | Embedded     | None
Size             | Small        | Large
Analytics        | Optimized    | Not optimized
Metadata         | Rich         | None

Benefits of Parquet:
✅ 10-100x smaller than CSV
✅ Faster query performance
✅ Built-in compression
✅ Schema evolution support
✅ Predicate pushdown
✅ Column pruning
✅ Type safety

Snowflake Parquet Support:

✅ Native Parquet reading
✅ Query directly from stage
✅ Automatic schema detection
✅ Efficient column access
✅ Metadata extraction
✅ Optimized performance

Parquet File Format:

CREATE FILE FORMAT parquet_format
    TYPE = 'parquet'
    COMPRESSION = AUTO
    BINARY_AS_TEXT = TRUE
    TRIM_SPACE = FALSE
    NULL_IF = ('NULL', 'null');

Options:
- TYPE: Must be 'parquet'
- COMPRESSION: AUTO, SNAPPY, GZIP, etc.
- BINARY_AS_TEXT: Convert binary to text
- TRIM_SPACE: Trim whitespace
- NULL_IF: NULL value representations

Querying Parquet:

Syntax:
$1:column_name

Examples:
$1:id
$1:name
$1:date
$1:"column with spaces"

With Quotes:
- Use quotes for special characters
- Use quotes for spaces
- Case-sensitive with quotes

Casting Parquet Data:

Common Casts:
$1:id::INT
$1:name::VARCHAR(100)
$1:date::DATE
$1:timestamp::TIMESTAMP
$1:amount::DECIMAL(10,2)
$1:is_active::BOOLEAN

Date Conversion:
DATE($1:date::INT)           -- Unix timestamp
TO_DATE($1:date::STRING)     -- String date
TO_TIMESTAMP($1:ts::INT)     -- Unix to timestamp

File Format Specification:

Option 1: In Stage Definition
CREATE STAGE stage_name
    URL = 's3://bucket'
    FILE_FORMAT = format_name;

Benefits:
✅ Consistent format
✅ Simpler queries
✅ Centralized config

Option 2: In Query
SELECT * FROM @stage
(file_format => 'format_name');

Benefits:
✅ Flexible per query
✅ Override stage format
✅ Test different formats

Best Practices:

1. Define format in stage (consistency)
2. Cast to proper types (performance)
3. Use meaningful aliases (readability)
4. Handle date conversions (accuracy)
5. Document schema (maintainability)
6. Test with sample data (validation)

Common Parquet Patterns:

1. Simple Query:
SELECT
    $1:id::INT,
    $1:name::STRING
FROM @parquet_stage;

2. With Date Conversion:
SELECT
    $1:id::INT,
    DATE($1:date::INT) AS date
FROM @parquet_stage;

3. With Metadata:
SELECT
    $1:id::INT,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER
FROM @parquet_stage;

4. Filtered Query:
SELECT
    $1:id::INT,
    $1:amount::DECIMAL(10,2)
FROM @parquet_stage
WHERE $1:status::STRING = 'ACTIVE';

Performance Advantages:

Parquet Benefits:
✅ Column pruning (read only needed columns)
✅ Predicate pushdown (filter at storage)
✅ Compression (less data transfer)
✅ Encoding (efficient storage)
✅ Statistics (skip unnecessary data)

Example:
SELECT $1:name FROM @stage;
-- Only reads 'name' column, not entire file!

Real-World Example:

-- Sales data in Parquet
SELECT
    $1:transaction_id::VARCHAR(50) AS txn_id,
    $1:customer_id::INT AS customer_id,
    $1:product_id::INT AS product_id,
    DATE($1:sale_date::INT) AS sale_date,
    $1:quantity::INT AS quantity,
    $1:unit_price::DECIMAL(10,2) AS unit_price,
    $1:total_amount::DECIMAL(10,2) AS total_amount,
    $1:store_id::VARCHAR(20) AS store_id,
    $1:region::VARCHAR(50) AS region
FROM @deepak_sales_parquet_stage
WHERE DATE($1:sale_date::INT) >= '2026-01-01';

Error Handling:

-- Safe casting
SELECT
    TRY_CAST($1:id AS INT) AS id,
    COALESCE($1:name::STRING, 'Unknown') AS name
FROM @parquet_stage;

-- Handle missing columns
SELECT
    $1:id::INT,
    COALESCE($1:optional_field::STRING, 'N/A') AS optional
FROM @parquet_stage;

Parquet Schema Evolution:

Parquet supports:
✅ Adding new columns
✅ Removing columns
✅ Changing column order
✅ Renaming columns (with mapping)

Snowflake handles gracefully:
- Missing columns → NULL
- Extra columns → Ignored
- Type mismatches → Error or NULL

Deepak's Parquet Workflow:
1. Create Parquet file format
2. Create stage with format
3. List files to verify
4. Query to explore schema
5. Identify column names and types
6. Cast to proper types
7. Add meaningful aliases
8. Handle date conversions
9. Load to table (next file!)

Key Takeaway:
Parquet is a columnar format optimized for analytics.
Query with $1:column_name, cast to proper types, and
enjoy 10-100x better performance than CSV!

Practiced: February 2026
Status: ✅ Completed - Understanding Parquet data querying
*/

