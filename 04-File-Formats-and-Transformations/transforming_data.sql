/*
===========================================
DEEPAK'S DATA TRANSFORMATION PRACTICE
===========================================
Topic: Transforming Data During COPY
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Can transform data during COPY using SELECT
- Use $1, $2, $3 to reference CSV columns
- Apply SQL functions during load
- Subset of functions available (no UDFs)
- ELT pattern: Extract, Load, Transform
===========================================
*/

-- Deepak's Note: Transform data WHILE loading - powerful ELT pattern!
-- No need for staging tables in many cases


-- ========================================
-- EXAMPLE 1: SELECT SPECIFIC COLUMNS
-- ========================================

-- Deepak's scenario: Load only first 2 columns from CSV
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_transform (
    order_id VARCHAR(30),
    amount NUMBER(10,2)
)
COMMENT = 'Deepak - Table with subset of columns';


-- Deepak's learning: Use SELECT to choose columns during COPY
COPY INTO deepak_sales_db.public.orders_transform
    FROM (
        SELECT
            s.$1 AS order_id,
            s.$2 AS amount
        FROM @deepak_mgmt_db.external_stages.deepak_aws_stage s
    )
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_2026.csv');

-- Deepak's observation: Loaded only 2 columns from multi-column file

SELECT * FROM deepak_sales_db.public.orders_transform LIMIT 10;


-- ========================================
-- EXAMPLE 2: ADD CALCULATED COLUMN
-- ========================================

-- Deepak's scenario: Add profitability flag during load
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_with_flag (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    profitable_flag VARCHAR(30)
)
COMMENT = 'Deepak - Orders with calculated profitability flag';


-- Deepak's learning: Use CASE statement to add derived column
COPY INTO deepak_sales_db.public.orders_with_flag
    FROM (
        SELECT
            s.$1 AS order_id,
            s.$2 AS amount,
            s.$3 AS profit,
            CASE
                WHEN CAST(s.$3 AS NUMBER) < 0 THEN 'Not Profitable'
                WHEN CAST(s.$3 AS NUMBER) = 0 THEN 'Break Even'
                ELSE 'Profitable'
            END AS profitable_flag
        FROM @deepak_mgmt_db.external_stages.deepak_aws_stage s
    )
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_2026.csv');

-- Deepak's observation: Added business logic during load!

SELECT
    profitable_flag,
    COUNT(*) AS order_count,
    SUM(profit) AS total_profit
FROM deepak_sales_db.public.orders_with_flag
GROUP BY profitable_flag
ORDER BY total_profit DESC;


-- ========================================
-- EXAMPLE 3: STRING MANIPULATION
-- ========================================

-- Deepak's scenario: Extract category prefix during load
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_with_category (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    category_code VARCHAR(5)
)
COMMENT = 'Deepak - Orders with category code extracted';


-- Deepak's learning: Use SUBSTRING to extract parts of strings
COPY INTO deepak_sales_db.public.orders_with_category
    FROM (
        SELECT
            s.$1 AS order_id,
            s.$2 AS amount,
            s.$3 AS profit,
            SUBSTRING(s.$5, 1, 5) AS category_code
        FROM @deepak_mgmt_db.external_stages.deepak_aws_stage s
    )
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_2026.csv');

-- Deepak's observation: Extracted first 5 characters of category

SELECT
    category_code,
    COUNT(*) AS orders,
    AVG(amount) AS avg_amount
FROM deepak_sales_db.public.orders_with_category
GROUP BY category_code
ORDER BY orders DESC;


-- ========================================
-- EXAMPLE 4: MULTIPLE TRANSFORMATIONS
-- ========================================

-- Deepak's advanced scenario: Multiple transformations in one COPY
CREATE OR REPLACE TABLE deepak_sales_db.public.orders_enriched (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    profit_margin NUMBER(5,2),
    category VARCHAR(30),
    category_upper VARCHAR(30),
    load_timestamp TIMESTAMP
)
COMMENT = 'Deepak - Fully enriched orders';


COPY INTO deepak_sales_db.public.orders_enriched
    FROM (
        SELECT
            s.$1 AS order_id,
            CAST(s.$2 AS NUMBER(10,2)) AS amount,
            CAST(s.$3 AS NUMBER(10,2)) AS profit,
            CASE
                WHEN CAST(s.$2 AS NUMBER) > 0
                THEN ROUND((CAST(s.$3 AS NUMBER) / CAST(s.$2 AS NUMBER)) * 100, 2)
                ELSE 0
            END AS profit_margin,
            s.$5 AS category,
            UPPER(s.$5) AS category_upper,
            CURRENT_TIMESTAMP() AS load_timestamp
        FROM @deepak_mgmt_db.external_stages.deepak_aws_stage s
    )
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    FILES = ('OrderDetails_2026.csv');

-- Deepak's observation: Calculated profit margin, uppercased category, added timestamp!

SELECT * FROM deepak_sales_db.public.orders_enriched LIMIT 10;


/*
DEEPAK'S DATA TRANSFORMATION INSIGHTS:
======================================

What is Transformation During COPY?
- Apply SQL transformations while loading
- Use SELECT statement in COPY command
- Reference CSV columns as $1, $2, $3, etc.
- Transform data before it hits the table
- ELT pattern (Extract, Load, Transform)

Column References:
$1 = First column in CSV
$2 = Second column
$3 = Third column
... and so on

Available Functions (Subset):
✅ CAST / TRY_CAST
✅ CASE WHEN
✅ SUBSTRING / SUBSTR
✅ UPPER / LOWER
✅ TRIM / LTRIM / RTRIM
✅ CONCAT / ||
✅ COALESCE / NVL
✅ Mathematical functions (+, -, *, /)
✅ ROUND / FLOOR / CEIL
✅ CURRENT_TIMESTAMP
✅ Date functions (limited)

NOT Available:
❌ User-defined functions (UDFs)
❌ Window functions
❌ Subqueries
❌ Joins with other tables
❌ Aggregate functions
❌ LATERAL joins

Benefits:
✅ No staging table needed
✅ Single-step load and transform
✅ Reduced storage costs
✅ Faster than two-step process
✅ Cleaner data in target table
✅ Less code to maintain

Use Cases:
✅ Column selection (load subset)
✅ Data type conversion
✅ String manipulation
✅ Calculated columns
✅ Data cleansing
✅ Adding metadata (timestamps, etc.)
✅ Simple business logic

Best Practices:
1. Keep transformations simple
2. Complex logic → use staging table
3. Test transformations with VALIDATION_MODE
4. Document transformation logic
5. Use meaningful column aliases
6. Handle NULLs explicitly
7. Add load timestamp for auditing

Pattern Comparison:

Traditional ETL (Two Steps):
-- Step 1: Load to staging
COPY INTO staging_table FROM @stage;

-- Step 2: Transform to final
INSERT INTO final_table
SELECT
    col1,
    UPPER(col2),
    col3 * 1.1
FROM staging_table;

Modern ELT (One Step):
-- Load and transform together
COPY INTO final_table
FROM (
    SELECT
        s.$1,
        UPPER(s.$2),
        s.$3 * 1.1
    FROM @stage s
);

Common Transformations:

1. Data Type Conversion:
CAST(s.$1 AS NUMBER(10,2))
TRY_CAST(s.$2 AS DATE)

2. String Cleaning:
TRIM(s.$1)
UPPER(s.$2)
SUBSTRING(s.$3, 1, 10)

3. Conditional Logic:
CASE
    WHEN s.$1 > 100 THEN 'High'
    ELSE 'Low'
END

4. Calculations:
s.$2 * s.$3 AS total
ROUND(s.$4 / s.$5, 2) AS ratio

5. NULL Handling:
COALESCE(s.$1, 'Unknown')
NVL(s.$2, 0)

6. Adding Metadata:
CURRENT_TIMESTAMP() AS loaded_at
'2026-02-12' AS batch_date

Real-World Example:
-- Load and enrich customer data
COPY INTO customers_enriched
FROM (
    SELECT
        s.$1 AS customer_id,
        TRIM(UPPER(s.$2)) AS customer_name,
        LOWER(s.$3) AS email,
        TRY_CAST(s.$4 AS DATE) AS signup_date,
        COALESCE(s.$5, 'Unknown') AS region,
        CASE
            WHEN s.$6 > 10000 THEN 'Premium'
            WHEN s.$6 > 1000 THEN 'Standard'
            ELSE 'Basic'
        END AS customer_tier,
        CURRENT_TIMESTAMP() AS processed_at,
        'BATCH_2026_02' AS batch_id
    FROM @customer_stage s
)
FILE_FORMAT = (FORMAT_NAME = csv_format)
ON_ERROR = 'CONTINUE';

Performance Considerations:
- Transformations add processing time
- Simple transforms: minimal impact
- Complex transforms: consider staging
- Test with VALIDATION_MODE first
- Monitor warehouse usage

Error Handling:
- Use TRY_CAST instead of CAST
- Handle NULLs with COALESCE
- Use CASE for conditional logic
- Test with VALIDATION_MODE
- Use ON_ERROR appropriately

Limitations:
- Cannot join with other tables
- Cannot use window functions
- Cannot use aggregates
- Cannot use UDFs
- Limited to row-level transforms

When to Use Staging Table Instead:
❌ Complex joins needed
❌ Window functions required
❌ Multiple transformation steps
❌ Need to validate before final load
❌ Aggregations required
❌ UDFs needed

Practiced: February 2026
Status: ✅ Completed - Mastering ELT transformations
*/




