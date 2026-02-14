/*
===========================================
DEEPAK'S PARQUET LOADING PRACTICE
===========================================
Topic: Loading Parquet Data with Metadata
Date Practiced: February 15, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Add metadata columns to Parquet queries
- METADATA$FILENAME for source tracking
- METADATA$FILE_ROW_NUMBER for row tracking
- TO_TIMESTAMP_NTZ for load timestamps
- Create table for Parquet data
- COPY INTO with transformations
===========================================
*/

-- Deepak's Note: Always track data lineage with metadata!
-- Know which file and row each record came from


-- ========================================
-- QUERY PARQUET WITH METADATA
-- ========================================

-- Deepak's technique: Add metadata columns to query
SELECT
    $1:__index_level_0__::INT AS index_level,
    $1:cat_id::VARCHAR(50) AS category_id,
    DATE($1:date::INT) AS sale_date,
    $1:"dept_id"::VARCHAR(50) AS department_id,
    $1:"id"::VARCHAR(50) AS transaction_id,
    $1:"item_id"::VARCHAR(50) AS item_id,
    $1:"state_id"::VARCHAR(50) AS state_id,
    $1:"store_id"::VARCHAR(50) AS store_id,
    $1:"value"::INT AS sale_value,
    METADATA$FILENAME AS source_filename,
    METADATA$FILE_ROW_NUMBER AS source_row_number,
    TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP) AS load_timestamp
FROM @deepak_mgmt_db.external_stages.deepak_parquet_stage;

-- Deepak's learning: Metadata columns provide data lineage!
-- METADATA$FILENAME: Which file the row came from
-- METADATA$FILE_ROW_NUMBER: Row number within the file
-- TO_TIMESTAMP_NTZ: Current timestamp without timezone


-- Deepak's experiment: Test timestamp function
SELECT TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP);

-- Deepak's observation: Returns current timestamp in NTZ (no timezone)


-- ========================================
-- CREATE DESTINATION TABLE
-- ========================================

-- Deepak's scenario: Create table for Parquet sales data
CREATE OR REPLACE TABLE deepak_analytics_db.public.parquet_sales_data (
    row_number INT,
    index_level INT,
    category_id VARCHAR(50),
    sale_date DATE,
    department_id VARCHAR(50),
    transaction_id VARCHAR(50),
    item_id VARCHAR(50),
    state_id VARCHAR(50),
    store_id VARCHAR(50),
    sale_value INT,
    load_timestamp TIMESTAMP DEFAULT TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP)
)
COMMENT = 'Deepak - Sales data loaded from Parquet files with metadata';

-- Deepak's observation: Table structure matches Parquet schema
-- Added load_timestamp with DEFAULT for automatic timestamping


-- ========================================
-- LOAD PARQUET DATA TO TABLE
-- ========================================

-- Deepak's technique: COPY INTO with transformation
COPY INTO deepak_analytics_db.public.parquet_sales_data
FROM (
    SELECT
        METADATA$FILE_ROW_NUMBER,
        $1:__index_level_0__::INT,
        $1:cat_id::VARCHAR(50),
        DATE($1:date::INT),
        $1:"dept_id"::VARCHAR(50),
        $1:"id"::VARCHAR(50),
        $1:"item_id"::VARCHAR(50),
        $1:"state_id"::VARCHAR(50),
        $1:"store_id"::VARCHAR(50),
        $1:"value"::INT,
        TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP)
    FROM @deepak_mgmt_db.external_stages.deepak_parquet_stage
);

-- Deepak's learning: Transform Parquet data during COPY!
-- Cast types, convert dates, add metadata - all in one step


-- ========================================
-- VERIFY LOADED DATA
-- ========================================

-- Deepak's verification: Check loaded Parquet data
SELECT * FROM deepak_analytics_db.public.parquet_sales_data;

-- Deepak's observation: Data loaded with all transformations applied

-- Check metadata columns
SELECT
    source_filename,
    source_row_number,
    load_timestamp,
    COUNT(*) AS record_count
FROM deepak_analytics_db.public.parquet_sales_data
GROUP BY source_filename, source_row_number, load_timestamp
LIMIT 10;

-- Deepak's learning: Can track exactly where each row came from!


-- Deepak's analysis: Sales summary by store
SELECT
    store_id,
    COUNT(*) AS transaction_count,
    SUM(sale_value) AS total_sales,
    AVG(sale_value) AS avg_sale_value,
    MIN(sale_date) AS first_sale,
    MAX(sale_date) AS last_sale
FROM deepak_analytics_db.public.parquet_sales_data
GROUP BY store_id
ORDER BY total_sales DESC
LIMIT 10;

-- Deepak's observation: Parquet data ready for analytics!


/*
DEEPAK'S PARQUET LOADING INSIGHTS:
====================================

Metadata Columns:

METADATA$FILENAME:
- Source file name
- Tracks data lineage
- Useful for debugging
- Required for auditing

Example:
METADATA$FILENAME AS source_file
→ 'sales_2026_02.parquet'

METADATA$FILE_ROW_NUMBER:
- Row number within file
- 1-based indexing
- Unique within file
- Useful for troubleshooting

Example:
METADATA$FILE_ROW_NUMBER AS row_num
→ 1, 2, 3, ...

METADATA$FILE_LAST_MODIFIED:
- File modification timestamp
- Useful for incremental loads
- Track file versions

METADATA$FILE_CONTENT_KEY:
- Unique file identifier
- Hash of file content
- Detect file changes

METADATA$START_SCAN_TIME:
- When scan started
- Performance tracking

Why Add Metadata?

✅ Data lineage tracking
✅ Debugging data issues
✅ Audit trail
✅ Incremental load support
✅ Error investigation
✅ Data quality monitoring
✅ Compliance requirements

Timestamp Functions:

CURRENT_TIMESTAMP:
- Current timestamp with timezone
- Session timezone

TO_TIMESTAMP_NTZ(CURRENT_TIMESTAMP):
- No timezone (NTZ)
- Consistent across sessions
- Recommended for load timestamps

CURRENT_TIMESTAMP() vs TO_TIMESTAMP_NTZ():
CURRENT_TIMESTAMP()           → 2026-02-14 10:30:00 -0800
TO_TIMESTAMP_NTZ(...)         → 2026-02-14 10:30:00

Loading Parquet Pattern:

Step 1: Create Table
CREATE TABLE table_name (
    -- Data columns
    col1 TYPE,
    col2 TYPE,
    -- Metadata columns
    source_file VARCHAR,
    row_number INT,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

Step 2: Load with COPY INTO
COPY INTO table_name
FROM (
    SELECT
        $1:col1::TYPE,
        $1:col2::TYPE,
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        CURRENT_TIMESTAMP()
    FROM @parquet_stage
);

Benefits of This Pattern:
✅ Full data lineage
✅ Easy troubleshooting
✅ Audit compliance
✅ Incremental load support
✅ Data quality tracking

Parquet vs JSON Loading:

Parquet:
✅ Schema embedded
✅ Typed columns
✅ Faster loading
✅ Better compression
✅ Column pruning
✅ Predicate pushdown

JSON:
✅ Flexible schema
✅ Nested structures
✅ Human readable
✅ Schema evolution
❌ Slower loading
❌ Larger files

Best Practices:

1. Always Add Metadata:
   - METADATA$FILENAME
   - METADATA$FILE_ROW_NUMBER
   - Load timestamp

2. Use Proper Types:
   - Cast Parquet columns
   - Convert dates properly
   - Use appropriate precision

3. Add Comments:
   - Table comments
   - Column comments
   - Document schema

4. Default Values:
   - Load timestamp DEFAULT
   - Status columns
   - Audit fields

5. Validate After Load:
   - Check row counts
   - Verify data types
   - Test queries

Complete Loading Example:

-- Create table with metadata
CREATE TABLE sales_fact (
    -- Business columns
    transaction_id VARCHAR(50) PRIMARY KEY,
    sale_date DATE NOT NULL,
    store_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,

    -- Metadata columns
    source_file VARCHAR(255),
    source_row_number INT,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    load_user VARCHAR(100) DEFAULT CURRENT_USER(),

    COMMENT = 'Sales transactions from Parquet files'
);

-- Load with full metadata
COPY INTO sales_fact
FROM (
    SELECT
        $1:txn_id::VARCHAR(50),
        DATE($1:date::INT),
        $1:store_id::VARCHAR(20),
        $1:product_id::VARCHAR(20),
        $1:qty::INT,
        $1:amount::DECIMAL(10,2),
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        CURRENT_TIMESTAMP(),
        CURRENT_USER()
    FROM @parquet_stage
)
ON_ERROR = CONTINUE
RETURN_FAILED_ONLY = TRUE;

-- Validate load
SELECT
    source_file,
    COUNT(*) AS rows_loaded,
    MIN(load_timestamp) AS load_start,
    MAX(load_timestamp) AS load_end,
    SUM(amount) AS total_amount
FROM sales_fact
GROUP BY source_file;

Incremental Loading:

-- Track loaded files
CREATE TABLE loaded_files (
    filename VARCHAR(255),
    load_timestamp TIMESTAMP,
    row_count INT
);

-- Load only new files
COPY INTO sales_fact
FROM (
    SELECT
        $1:txn_id::VARCHAR(50),
        DATE($1:date::INT),
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER,
        CURRENT_TIMESTAMP()
    FROM @parquet_stage
)
FILES = (
    SELECT filename
    FROM @parquet_stage
    WHERE filename NOT IN (
        SELECT filename FROM loaded_files
    )
);

-- Record loaded files
INSERT INTO loaded_files
SELECT
    source_file,
    MAX(load_timestamp),
    COUNT(*)
FROM sales_fact
WHERE load_timestamp > DATEADD(minute, -5, CURRENT_TIMESTAMP())
GROUP BY source_file;

Error Handling:

-- Safe loading with error handling
COPY INTO sales_fact
FROM (
    SELECT
        TRY_CAST($1:txn_id AS VARCHAR(50)),
        TRY_CAST(DATE($1:date::INT) AS DATE),
        COALESCE($1:store_id::VARCHAR(20), 'UNKNOWN'),
        METADATA$FILENAME,
        METADATA$FILE_ROW_NUMBER
    FROM @parquet_stage
)
ON_ERROR = CONTINUE
VALIDATION_MODE = RETURN_ERRORS;

Performance Tips:

1. Use COPY INTO (not INSERT)
2. Load in parallel (multiple files)
3. Use appropriate warehouse size
4. Partition large files
5. Use clustering keys
6. Monitor load performance

Monitoring Queries:

-- Load statistics
SELECT
    source_file,
    COUNT(*) AS rows,
    MIN(load_timestamp) AS first_load,
    MAX(load_timestamp) AS last_load,
    COUNT(DISTINCT source_row_number) AS unique_rows
FROM sales_fact
GROUP BY source_file;

-- Data quality check
SELECT
    source_file,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT transaction_id) AS unique_txns,
    SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) AS negative_amounts,
    SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) AS null_dates
FROM sales_fact
GROUP BY source_file;

Deepak's Parquet Loading Workflow:
1. Create Parquet file format
2. Create stage with format
3. Query to explore schema
4. Create destination table
5. Add metadata columns
6. Load with COPY INTO
7. Validate row counts
8. Check data quality
9. Monitor performance
10. Document process

Key Takeaway:
Always load Parquet data with metadata columns
(FILENAME, FILE_ROW_NUMBER, LOAD_TIMESTAMP) for
complete data lineage and easy troubleshooting!

Practiced: February 2026
Status: ✅ Completed - Mastering Parquet data loading
*/
