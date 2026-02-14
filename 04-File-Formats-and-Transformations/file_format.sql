/*
===========================================
DEEPAK'S FILE FORMAT OBJECTS PRACTICE
===========================================
Topic: Creating and Managing File Format Objects
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- File format objects are reusable configurations
- Can be altered (except TYPE property)
- Centralized management in dedicated schema
- Can override properties in COPY command
- Support CSV, JSON, PARQUET, AVRO, ORC, XML
===========================================
*/

-- Deepak's Note: File format objects make data loading consistent and maintainable
-- Define once, use everywhere!


-- ========================================
-- INLINE FILE FORMAT (NOT RECOMMENDED)
-- ========================================

-- Deepak's scenario: Load orders with inline format definition
COPY INTO deepak_sales_db.public.orders_staging
    FROM @deepak_mgmt_db.external_stages.deepak_aws_stage
    FILE_FORMAT = (
        TYPE = CSV
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
    )
    FILES = ('OrderDetails_2026.csv')
    ON_ERROR = 'SKIP_FILE_3';

-- Deepak's observation: Works, but not reusable or maintainable


-- ========================================
-- CREATE TABLE FOR TESTING
-- ========================================

CREATE OR REPLACE TABLE deepak_sales_db.public.orders_staging (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Staging table for order data';


-- ========================================
-- CREATE FILE FORMAT SCHEMA
-- ========================================

-- Deepak's best practice: Dedicated schema for file formats
CREATE OR REPLACE SCHEMA deepak_mgmt_db.file_formats
COMMENT = 'Deepak - Centralized file format objects';

USE SCHEMA deepak_mgmt_db.file_formats;


-- ========================================
-- CREATE FILE FORMAT OBJECT (DEFAULT)
-- ========================================

-- Deepak's learning: Create basic file format (defaults to CSV)
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.file_formats.deepak_csv_format;

-- Deepak's note: Default CSV format with standard settings


-- Describe to see all properties
DESC FILE FORMAT deepak_mgmt_db.file_formats.deepak_csv_format;

-- Deepak's observation: Shows TYPE=CSV, COMPRESSION=AUTO, etc.


-- ========================================
-- USE FILE FORMAT OBJECT
-- ========================================

-- Deepak's scenario: Use file format object in COPY command
COPY INTO deepak_sales_db.public.orders_staging
    FROM @deepak_mgmt_db.external_stages.deepak_aws_stage
    FILE_FORMAT = (FORMAT_NAME = deepak_mgmt_db.file_formats.deepak_csv_format)
    FILES = ('OrderDetails_2026.csv')
    ON_ERROR = 'SKIP_FILE_3';

-- Deepak's learning: Much cleaner than inline format!


-- ========================================
-- ALTER FILE FORMAT OBJECT
-- ========================================

-- Deepak's scenario: Update file format to skip header
ALTER FILE FORMAT deepak_mgmt_db.file_formats.deepak_csv_format
    SET SKIP_HEADER = 1;

-- Deepak's note: Changes apply to all future uses of this format


-- ========================================
-- CREATE FILE FORMAT WITH PROPERTIES
-- ========================================

-- Deepak's experiment: Create JSON file format
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.file_formats.deepak_json_format
    TYPE = JSON
    TIME_FORMAT = 'AUTO'
    COMPRESSION = 'AUTO'
    COMMENT = 'Deepak - JSON format for API data';

-- Describe JSON format
DESC FILE FORMAT deepak_mgmt_db.file_formats.deepak_json_format;

-- Deepak's observation: TYPE=JSON, different properties than CSV


-- ========================================
-- ATTEMPT TO CHANGE TYPE (FAILS)
-- ========================================

-- Deepak's experiment: Try to change TYPE from JSON to CSV
ALTER FILE FORMAT deepak_mgmt_db.file_formats.deepak_json_format
SET TYPE = CSV;

-- Deepak's learning: ERROR! Cannot alter TYPE property
-- Must use CREATE OR REPLACE instead


-- ========================================
-- RECREATE FILE FORMAT
-- ========================================

-- Deepak's solution: Recreate with new type
CREATE OR REPLACE FILE FORMAT deepak_mgmt_db.file_formats.deepak_json_format;

-- Deepak's note: Now it's CSV (default type)

DESC FILE FORMAT deepak_mgmt_db.file_formats.deepak_json_format;


-- ========================================
-- CLEAR STAGING TABLE
-- ========================================

TRUNCATE TABLE deepak_sales_db.public.orders_staging;

-- Deepak's note: Ready for next test


-- ========================================
-- OVERRIDE FILE FORMAT PROPERTIES
-- ========================================

-- Deepak's scenario: Override format properties in COPY command
COPY INTO deepak_sales_db.public.orders_staging
    FROM @deepak_mgmt_db.external_stages.deepak_aws_stage
    FILE_FORMAT = (
        FORMAT_NAME = deepak_mgmt_db.file_formats.deepak_csv_format
        FIELD_DELIMITER = ','
        SKIP_HEADER = 1
    )
    FILES = ('OrderDetails_2026.csv')
    ON_ERROR = 'SKIP_FILE_3';

-- Deepak's learning: Can override specific properties while using format object
-- Best of both worlds!


-- Describe stage to verify configuration
DESC STAGE deepak_mgmt_db.external_stages.deepak_aws_stage;


/*
DEEPAK'S FILE FORMAT INSIGHTS:
==============================

What are File Format Objects?
- Reusable configurations for data loading
- Define how to parse files (CSV, JSON, etc.)
- Centralized management
- Can be shared across databases

Supported File Types:
✅ CSV - Comma-separated values
✅ JSON - JavaScript Object Notation
✅ PARQUET - Columnar format
✅ AVRO - Row-based format
✅ ORC - Optimized Row Columnar
✅ XML - Extensible Markup Language

CSV Format Properties:
- FIELD_DELIMITER: Column separator (default: ,)
- RECORD_DELIMITER: Row separator (default: \n)
- SKIP_HEADER: Skip header rows (default: 0)
- FIELD_OPTIONALLY_ENCLOSED_BY: Quote character
- ESCAPE: Escape character
- NULL_IF: Define null values
- COMPRESSION: GZIP, BZIP2, AUTO, etc.
- ENCODING: UTF8, ISO8859_1, etc.
- TRIM_SPACE: Remove leading/trailing spaces

JSON Format Properties:
- COMPRESSION: AUTO, GZIP, etc.
- DATE_FORMAT: Date parsing format
- TIME_FORMAT: Time parsing format
- TIMESTAMP_FORMAT: Timestamp format
- FILE_EXTENSION: Expected file extension

Benefits of File Format Objects:
✅ Reusability across multiple COPY commands
✅ Consistency in data loading
✅ Easier maintenance (change once, apply everywhere)
✅ Better organization
✅ Can be granted to roles
✅ Version control friendly

Best Practices:
1. Create dedicated schema for file formats
2. Use descriptive names (csv_orders, json_api, etc.)
3. Document purpose in COMMENT
4. Test format before production use
5. Use VALIDATION_MODE to test
6. Override properties only when necessary
7. Keep formats simple and focused

Common File Formats:
-- CSV with pipe delimiter
CREATE FILE FORMAT csv_pipe
    TYPE = CSV
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1;

-- CSV with custom null handling
CREATE FILE FORMAT csv_nulls
    TYPE = CSV
    NULL_IF = ('NULL', 'null', '', '\\N')
    EMPTY_FIELD_AS_NULL = TRUE;

-- JSON with timestamp format
CREATE FILE FORMAT json_api
    TYPE = JSON
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS';

-- Parquet (no special config needed)
CREATE FILE FORMAT parquet_default
    TYPE = PARQUET;

Alterable Properties:
✅ SKIP_HEADER
✅ FIELD_DELIMITER
✅ NULL_IF
✅ COMPRESSION
✅ ENCODING
✅ Most properties except TYPE

Non-Alterable Properties:
❌ TYPE (must recreate format)

Property Override:
-- Use format but override delimiter
COPY INTO table
    FROM @stage
    FILE_FORMAT = (
        FORMAT_NAME = my_format
        FIELD_DELIMITER = '\t'  -- Override
    );

Management Commands:
-- Create
CREATE FILE FORMAT format_name ...;

-- Alter
ALTER FILE FORMAT format_name SET property = value;

-- Describe
DESC FILE FORMAT format_name;

-- Show all formats
SHOW FILE FORMATS;

-- Drop
DROP FILE FORMAT format_name;

Real-World Example:
-- Production CSV format
CREATE FILE FORMAT prod_csv
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null')
    EMPTY_FIELD_AS_NULL = TRUE
    COMPRESSION = AUTO
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    COMMENT = 'Production CSV format for daily loads';

-- Use in COPY command
COPY INTO sales_table
    FROM @sales_stage
    FILE_FORMAT = (FORMAT_NAME = prod_csv)
    ON_ERROR = CONTINUE;

Practiced: February 2026
Status: ✅ Completed - Understanding file format objects
*/
