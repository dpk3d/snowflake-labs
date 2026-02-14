/*
===========================================
DEEPAK'S DATA SAMPLING PRACTICE
===========================================
Topic: Sampling Large Datasets for Analysis
Date Practiced: February 11, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- ROW sampling: Probabilistic row-by-row sampling
- SYSTEM sampling: Block-level sampling (faster)
- SEED ensures reproducible results
- Sampling perfect for testing and analysis
- Views can use sampling for consistent subsets
===========================================
*/

-- Deepak's Note: Sampling is crucial for working with large datasets
-- Allows quick analysis without scanning entire tables


-- ========================================
-- SETUP: CREATE SAMPLING DATABASE
-- ========================================

CREATE OR REPLACE TRANSIENT DATABASE deepak_sampling_db
COMMENT = 'Deepak - Database for data sampling practice';

USE DATABASE deepak_sampling_db;


-- ========================================
-- ROW SAMPLING WITH VIEW
-- ========================================

-- Deepak's scenario: Create view with 1% sample of customer addresses
-- Using ROW sampling for precise percentage
CREATE OR REPLACE VIEW deepak_sampling_db.public.address_sample
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE ROW (1) SEED(27);

-- Deepak's learning: SEED(27) ensures same sample every time
-- ROW(1) = 1% of rows, probabilistic sampling


-- Query the sampled view
SELECT * FROM deepak_sampling_db.public.address_sample
LIMIT 100;

-- Deepak's observation: View returns consistent 1% sample


-- ========================================
-- ANALYZE SAMPLE DATA
-- ========================================

-- Deepak's analysis: Distribution of location types in sample
SELECT
    ca_location_type,
    COUNT(*) AS sample_count,
    COUNT(*) / 3254250 * 100 AS estimated_percentage
FROM deepak_sampling_db.public.address_sample
GROUP BY ca_location_type
ORDER BY sample_count DESC;

-- Deepak's learning: Can estimate full dataset distribution from sample
-- 3254250 is approximate total row count


-- ========================================
-- SYSTEM SAMPLING (BLOCK-LEVEL)
-- ========================================

-- Deepak's experiment: SYSTEM sampling (faster, less precise)
-- Samples at block level, not row level
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE SYSTEM (1) SEED(23)
LIMIT 100;

-- Deepak's observation: SYSTEM sampling is faster for large tables
-- Less precise than ROW sampling


-- Deepak's comparison: 10% SYSTEM sample
SELECT
    ca_location_type,
    COUNT(*) AS sample_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE SYSTEM (10) SEED(23)
GROUP BY ca_location_type
ORDER BY sample_count DESC;

-- Deepak's learning: Larger sample = more accurate distribution


-- ========================================
-- DEEPAK'S SAMPLING EXPERIMENTS
-- ========================================

-- Deepak's test: Compare ROW vs SYSTEM sampling
-- ROW sampling (1%)
SELECT COUNT(*) AS row_sample_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE ROW (1) SEED(100);

-- SYSTEM sampling (1%)
SELECT COUNT(*) AS system_sample_count
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE SYSTEM (1) SEED(100);

-- Deepak's observation: ROW gives more consistent percentage
-- SYSTEM is faster but less precise


-- Deepak's scenario: Sample for testing query performance
SELECT
    ca_state,
    ca_city,
    COUNT(*) AS address_count,
    AVG(ca_gmt_offset) AS avg_gmt_offset
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE ROW (5) SEED(42)
GROUP BY ca_state, ca_city
HAVING COUNT(*) > 10
ORDER BY address_count DESC
LIMIT 20;

-- Deepak's learning: Test complex queries on sample before running on full data


-- Deepak's analysis: Different SEED values give different samples
SELECT COUNT(*) AS count_seed_1
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE ROW (1) SEED(1);

SELECT COUNT(*) AS count_seed_2
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE ROW (1) SEED(2);

SELECT COUNT(*) AS count_seed_3
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE ROW (1) SEED(3);

-- Deepak's observation: Different seeds = different samples
-- Same seed = reproducible results


/*
DEEPAK'S DATA SAMPLING INSIGHTS:
=================================

What is Data Sampling?

- Returns subset of table data
- Two methods: ROW and SYSTEM
- Controlled by percentage (0-100)
- SEED ensures reproducibility
- Perfect for large dataset analysis

ROW Sampling:

Syntax:
SELECT * FROM table SAMPLE ROW (percentage) SEED(number);

How it works:
- Probabilistic row-by-row sampling
- Each row has X% chance of inclusion
- More precise percentage
- Slower than SYSTEM
- Better for statistical accuracy

Example:
SAMPLE ROW (1) SEED(27)
- 1% of rows
- SEED 27 for reproducibility

SYSTEM Sampling:

Syntax:
SELECT * FROM table SAMPLE SYSTEM (percentage) SEED(number);

How it works:
- Block-level sampling
- Samples entire micro-partitions
- Faster than ROW
- Less precise percentage
- Better for performance

Example:
SAMPLE SYSTEM (10) SEED(23)
- ~10% of blocks
- SEED 23 for reproducibility

ROW vs SYSTEM Comparison:

┌─────────────────────┬────────────┬────────────┐
│ Feature             │ ROW        │ SYSTEM     │
├─────────────────────┼────────────┼────────────┤
│ Sampling Level      │ Row        │ Block      │
│ Precision           │ High       │ Lower      │
│ Performance         │ Slower     │ Faster     │
│ Percentage Accuracy │ Exact      │ Approximate│
│ Use Case            │ Analysis   │ Testing    │
│ Reproducible        │ Yes (SEED) │ Yes (SEED) │
└─────────────────────┴────────────┴────────────┘

SEED Parameter:

Purpose:
- Ensures reproducible samples
- Same SEED = same sample
- Different SEED = different sample

Example:
SAMPLE ROW (5) SEED(42)  -- Always same 5%
SAMPLE ROW (5) SEED(99)  -- Different 5%

Without SEED:
SAMPLE ROW (5)  -- Random 5% each time

Use Cases:

1. Testing Queries:
   - Test on 1% sample first
   - Verify logic works
   - Then run on full data

2. Development:
   - Work with manageable data
   - Faster iteration
   - Lower compute costs

3. Statistical Analysis:
   - Estimate distributions
   - Calculate percentages
   - Identify patterns

4. Data Exploration:
   - Quick data profiling
   - Understand data structure
   - Find data quality issues

5. Performance Testing:
   - Test query performance
   - Optimize before full scan
   - Validate indexes/clustering

Best Practices:

1. Use ROW for Analysis:
   - More accurate percentages
   - Better for statistics
   - Reliable distributions

2. Use SYSTEM for Testing:
   - Faster execution
   - Good enough for logic testing
   - Lower compute cost

3. Always Use SEED:
   - Reproducible results
   - Consistent testing
   - Debugging easier

4. Start Small:
   - Begin with 1% sample
   - Increase if needed
   - Balance speed vs accuracy

5. Document SEED Values:
   - Track which seeds used
   - Ensure reproducibility
   - Share with team

Sampling in Views:

-- Create view with sample
CREATE VIEW customer_sample AS
SELECT * FROM customers
SAMPLE ROW (10) SEED(42);

-- Query view (always same 10%)
SELECT * FROM customer_sample;

Benefits:
- Consistent sample
- Easy to share
- Reusable

Real-World Examples:

Example 1: Test ETL Logic
-- Test on 1% sample
INSERT INTO target_table
SELECT * FROM source_table
SAMPLE ROW (1) SEED(100)
WHERE date = CURRENT_DATE();

-- Verify results
-- Then run on full data

Example 2: Data Profiling
-- Profile data distribution
SELECT
    column_name,
    COUNT(*) AS count,
    COUNT(DISTINCT column_name) AS distinct_count,
    COUNT(*) * 100 AS estimated_total
FROM large_table
SAMPLE ROW (1) SEED(50)
GROUP BY column_name;

Example 3: Performance Testing
-- Test query on sample
SELECT *
FROM fact_sales
SAMPLE SYSTEM (5) SEED(10)
WHERE date BETWEEN '2026-01-01' AND '2026-01-31';

-- Optimize query
-- Then run on full data

Example 4: Training Data
-- Create training dataset
CREATE TABLE ml_training_data AS
SELECT * FROM customer_data
SAMPLE ROW (80) SEED(123);

-- Create test dataset
CREATE TABLE ml_test_data AS
SELECT * FROM customer_data
SAMPLE ROW (20) SEED(456);

Sampling Limitations:

❌ Not for exact counts
❌ Not for critical business metrics
❌ May miss rare values
❌ Block sampling less precise
❌ Can't sample external tables

When NOT to Use Sampling:

❌ Financial reports (need exact numbers)
❌ Compliance queries (need all data)
❌ Small tables (no benefit)
❌ Critical business decisions
❌ Audit trails

Sampling Percentage Guidelines:

1% - Quick data exploration
5% - Statistical analysis
10% - Development/testing
20% - Training datasets
50% - Large-scale testing

Performance Impact:

Small Sample (1-5%):
- Very fast
- Low compute cost
- Good for exploration

Medium Sample (10-20%):
- Moderate speed
- Balanced cost
- Good for testing

Large Sample (50%+):
- Slower
- Higher cost
- Better accuracy

Deepak's Sampling Workflow:

1. Explore with 1% ROW sample
2. Analyze distributions
3. Test query logic
4. Increase to 5-10% if needed
5. Validate results
6. Run on full data
7. Compare sample vs full results

Deepak's Sampling Checklist:

✅ Use ROW for analysis
✅ Use SYSTEM for speed
✅ Always specify SEED
✅ Document SEED values
✅ Start with small percentage
✅ Test before full scan
✅ Validate sample results

Key Takeaway:
Sampling is essential for working with large datasets!
Use ROW sampling for accurate analysis, SYSTEM for
speed. Always use SEED for reproducibility. Test on
samples before running expensive full-table scans!

Practiced: February 2026
Status: ✅ Completed - Data sampling mastered
*/
