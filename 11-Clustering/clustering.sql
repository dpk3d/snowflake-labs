/*
===========================================
DEEPAK'S TABLE CLUSTERING PRACTICE
===========================================
Topic: Optimizing Query Performance with Clustering Keys
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Clustering keys organize data in micro-partitions
- Dramatically improves query performance on large tables
- Reduces data scanning (fewer partitions read)
- Automatic background maintenance
- Can use expressions (MONTH, YEAR, etc.)
- Choose based on query patterns
===========================================
*/

-- Deepak's Note: Clustering is like organizing a library by topic
-- Instead of searching every shelf, you go straight to the right section!


-- ========================================
-- SETUP: CREATE DATABASE AND STAGE
-- ========================================

-- Deepak's scenario: Create database for clustering practice
CREATE OR REPLACE DATABASE deepak_clustering_db
COMMENT = 'Deepak - Database for clustering practice';

USE DATABASE deepak_clustering_db;


-- Create schema for external stages
CREATE OR REPLACE SCHEMA deepak_clustering_db.external_stages
COMMENT = 'Deepak - Schema for external stages';


-- Create publicly accessible AWS stage
CREATE OR REPLACE STAGE deepak_clustering_db.external_stages.deepak_aws_stage
    URL = 's3://bucketsnowflakes3'
    COMMENT = 'Deepak - AWS S3 stage for order data';

-- Deepak's observation: Public S3 bucket with sample data


-- List files in stage
LIST @deepak_clustering_db.external_stages.deepak_aws_stage;

-- Deepak's note: Check available files


-- ========================================
-- LOAD INITIAL DATA
-- ========================================

-- Deepak's scenario: Create orders table
CREATE OR REPLACE TABLE deepak_clustering_db.public.orders (
    order_id VARCHAR(30),
    amount NUMBER(38,0),
    profit NUMBER(38,0),
    quantity NUMBER(38,0),
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Base orders table';


-- Load data from S3
COPY INTO deepak_clustering_db.public.orders
    FROM @deepak_clustering_db.external_stages.deepak_aws_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*OrderDetails.*';

-- Deepak's observation: Initial order data loaded


-- ========================================
-- CREATE LARGE TABLE FOR CLUSTERING TEST
-- ========================================

-- Deepak's key step: Create large table with random dates
-- This simulates a real production table with millions of rows
CREATE OR REPLACE TABLE deepak_clustering_db.public.orders_clustering (
    order_id VARCHAR(30),
    amount NUMBER(38,0),
    profit NUMBER(38,0),
    quantity NUMBER(38,0),
    category VARCHAR(30),
    subcategory VARCHAR(30),
    date DATE
)
COMMENT = 'Deepak - Large orders table for clustering demo';


-- Deepak's technique: Use CROSS JOIN to multiply data
-- Creates millions of rows with random dates
INSERT INTO deepak_clustering_db.public.orders_clustering
SELECT
    t1.order_id,
    t1.amount,
    t1.profit,
    t1.quantity,
    t1.category,
    t1.subcategory,
    DATE(UNIFORM(1500000000, 1700000000, (RANDOM()))) AS date
FROM deepak_clustering_db.public.orders t1
CROSS JOIN (SELECT * FROM deepak_clustering_db.public.orders) t2
CROSS JOIN (SELECT TOP 100 * FROM deepak_clustering_db.public.orders) t3;

-- Deepak's learning: CROSS JOIN creates cartesian product
-- UNIFORM generates random Unix timestamps
-- DATE() converts to date
-- Result: Millions of rows with dates spread across years


-- Check table size
SELECT COUNT(*) AS total_rows
FROM deepak_clustering_db.public.orders_clustering;

-- Deepak's observation: Large dataset created


-- ========================================
-- QUERY PERFORMANCE BEFORE CLUSTERING
-- ========================================

-- Deepak's experiment: Query specific date WITHOUT clustering
SELECT *
FROM deepak_clustering_db.public.orders_clustering
WHERE date = '2020-06-09';

-- Deepak's observation: Check query profile
-- - Partitions scanned: HIGH (scans many micro-partitions)
-- - Partitions total: HIGH
-- - Query time: SLOW
-- - Bytes scanned: HIGH

-- Deepak's learning: Without clustering, Snowflake scans ALL partitions
-- Data is randomly distributed across micro-partitions


-- ========================================
-- ADD CLUSTERING KEY
-- ========================================

-- Deepak's key technique: Add clustering key on DATE column
ALTER TABLE deepak_clustering_db.public.orders_clustering
CLUSTER BY (date);

-- Deepak's learning: This tells Snowflake to organize data by date
-- Background process will reorganize micro-partitions
-- Similar dates will be stored together

-- Deepak's note: Clustering happens automatically in background
-- May take time for large tables


-- ========================================
-- QUERY PERFORMANCE AFTER CLUSTERING
-- ========================================

-- Deepak's experiment: Query specific date WITH clustering
SELECT *
FROM deepak_clustering_db.public.orders_clustering
WHERE date = '2020-01-05';

-- Deepak's observation: Check query profile
-- - Partitions scanned: LOW (only relevant partitions)
-- - Partitions total: Same as before
-- - Query time: FAST (10-100x faster!)
-- - Bytes scanned: LOW

-- Deepak's learning: Clustering dramatically reduces partitions scanned
-- Only reads micro-partitions containing '2020-01-05'
-- Massive performance improvement!


-- ========================================
-- CLUSTERING WITH EXPRESSIONS
-- ========================================

-- Deepak's scenario: Query by MONTH instead of exact date
SELECT *
FROM deepak_clustering_db.public.orders_clustering
WHERE MONTH(date) = 11;

-- Deepak's observation: Still scans many partitions
-- Clustering by DATE doesn't help MONTH queries
-- Need to cluster by MONTH expression!


-- Deepak's technique: Change clustering key to use MONTH function
ALTER TABLE deepak_clustering_db.public.orders_clustering
CLUSTER BY (MONTH(date));

-- Deepak's learning: Can cluster by expressions, not just columns
-- Now data organized by month
-- MONTH queries will be much faster


-- Re-run month query
SELECT *
FROM deepak_clustering_db.public.orders_clustering
WHERE MONTH(date) = 11;

-- Deepak's observation: Much faster now!
-- Only scans partitions with November data


-- ========================================
-- CHECK CLUSTERING INFORMATION
-- ========================================

-- Deepak's monitoring: Check clustering depth
SELECT SYSTEM$CLUSTERING_INFORMATION('deepak_clustering_db.public.orders_clustering');

-- Deepak's learning: Shows clustering quality
-- - average_depth: Lower is better (well-clustered)
-- - cluster_by_keys: Current clustering key


-- Check clustering depth for specific column
SELECT SYSTEM$CLUSTERING_DEPTH('deepak_clustering_db.public.orders_clustering', '(date)');

-- Deepak's observation: Depth indicates how well data is clustered


-- ========================================
-- VIEW CLUSTERING KEY
-- ========================================

-- Deepak's check: See current clustering key
SHOW TABLES LIKE 'orders_clustering' IN deepak_clustering_db.public;

-- Or use DESCRIBE
DESC TABLE deepak_clustering_db.public.orders_clustering;

-- Deepak's note: Clustering key shown in table metadata


/*
DEEPAK'S CLUSTERING INSIGHTS:
==============================

What is Table Clustering?

- Physical organization of data in micro-partitions
- Groups similar values together
- Reduces data scanning for queries
- Automatic background maintenance
- Enterprise Edition feature

How Clustering Works:

1. Define clustering key (column or expression)
2. Snowflake reorganizes micro-partitions
3. Similar values stored together
4. Queries scan fewer partitions
5. Automatic re-clustering as data changes

Clustering Key Syntax:

-- Single column
ALTER TABLE table_name CLUSTER BY (column1);

-- Multiple columns
ALTER TABLE table_name CLUSTER BY (column1, column2);

-- Expression
ALTER TABLE table_name CLUSTER BY (MONTH(date_column));

-- Remove clustering
ALTER TABLE table_name DROP CLUSTERING KEY;

Performance Impact:

Without Clustering:
┌─────────────────────┬──────────┐
│ Metric              │ Value    │
├─────────────────────┼──────────┤
│ Partitions Scanned  │ 1,000    │
│ Partitions Total    │ 1,000    │
│ Scan Percentage     │ 100%     │
│ Query Time          │ 10 sec   │
│ Bytes Scanned       │ 10 GB    │
└─────────────────────┴──────────┘

With Clustering:
┌─────────────────────┬──────────┐
│ Metric              │ Value    │
├─────────────────────┼──────────┤
│ Partitions Scanned  │ 10       │
│ Partitions Total    │ 1,000    │
│ Scan Percentage     │ 1%       │
│ Query Time          │ 0.1 sec  │
│ Bytes Scanned       │ 100 MB   │
└─────────────────────┴──────────┘

Result: 100x faster, 99% less data scanned!

When to Use Clustering:

✅ Large tables (multi-TB)
✅ Frequent queries on specific columns
✅ Date/time range queries
✅ High-cardinality columns
✅ Predictable query patterns
✅ Performance-critical queries

When NOT to Use Clustering:

❌ Small tables (< 1 TB)
❌ Frequently changing data
❌ No clear query pattern
❌ Low-cardinality columns
❌ Ad-hoc exploratory queries
❌ Cost-sensitive workloads

Choosing Clustering Keys:

Best Candidates:
1. Columns in WHERE clauses
2. Date/timestamp columns
3. High-cardinality columns
4. Columns in JOIN conditions
5. Frequently filtered columns

Poor Candidates:
1. Low-cardinality (few unique values)
2. Randomly distributed data
3. Columns rarely queried
4. Frequently updated columns

Clustering Key Examples:

-- Date-based (common)
CLUSTER BY (order_date)
CLUSTER BY (YEAR(order_date), MONTH(order_date))

-- Geographic
CLUSTER BY (country, state, city)

-- Customer-based
CLUSTER BY (customer_id)

-- Multi-column
CLUSTER BY (region, product_category)

-- Expression-based
CLUSTER BY (DATE_TRUNC('month', timestamp_column))

Clustering Depth:

- Measures clustering quality
- Lower = better clustering
- Range: 0 (perfect) to high number (poor)
- Check with SYSTEM$CLUSTERING_DEPTH()

Clustering Depth Interpretation:
┌────────────┬─────────────────┐
│ Depth      │ Quality         │
├────────────┼─────────────────┤
│ 0-2        │ Excellent       │
│ 2-4        │ Good            │
│ 4-8        │ Fair            │
│ 8+         │ Poor            │
└────────────┴─────────────────┘

Automatic Re-Clustering:

- Snowflake maintains clustering automatically
- Runs in background
- Triggered by DML operations (INSERT, UPDATE, DELETE)
- No manual intervention needed
- Consumes credits (Enterprise Edition)

Re-Clustering Cost:

- Charged for compute used
- Automatic background service
- Can be significant for large tables
- Monitor with AUTOMATIC_CLUSTERING_HISTORY view

-- Check re-clustering costs
SELECT
    start_time,
    end_time,
    table_name,
    credits_used,
    num_bytes_reclustered
FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
WHERE table_name = 'ORDERS_CLUSTERING'
ORDER BY start_time DESC
LIMIT 10;

Monitoring Clustering:

-- Clustering information
SELECT SYSTEM$CLUSTERING_INFORMATION('schema.table');

-- Clustering depth
SELECT SYSTEM$CLUSTERING_DEPTH('schema.table', '(column)');

-- Clustering history
SELECT * FROM TABLE(INFORMATION_SCHEMA.AUTOMATIC_CLUSTERING_HISTORY(
    DATE_RANGE_START => DATEADD('day', -7, CURRENT_DATE())
));

Best Practices:

1. Choose Wisely:
   - Analyze query patterns
   - Pick most-filtered columns
   - Consider cardinality
   - Test performance impact

2. Monitor Costs:
   - Track re-clustering credits
   - Balance performance vs cost
   - Suspend if too expensive

3. Use Expressions:
   - MONTH(date) for monthly queries
   - YEAR(date) for yearly queries
   - DATE_TRUNC for time buckets

4. Multi-Column Keys:
   - Order matters (most selective first)
   - Limit to 3-4 columns
   - Test different combinations

5. Review Regularly:
   - Query patterns change
   - Re-evaluate clustering keys
   - Drop if not beneficial

Clustering vs Partitioning:

Snowflake (Automatic):
- Micro-partitions created automatically
- 50-500 MB compressed
- Clustering organizes these partitions
- No manual partition management

Traditional Databases (Manual):
- Manual partition definition
- Explicit partition keys
- Maintenance overhead
- Rigid structure

Real-World Example:

-- E-commerce orders table
-- 10 TB, 10 billion rows
-- Common query: Last 30 days

-- Before clustering
SELECT * FROM orders
WHERE order_date >= DATEADD('day', -30, CURRENT_DATE());
-- Scans: 10 TB, Time: 60 seconds

-- Add clustering
ALTER TABLE orders CLUSTER BY (order_date);

-- After clustering
SELECT * FROM orders
WHERE order_date >= DATEADD('day', -30, CURRENT_DATE());
-- Scans: 100 GB, Time: 0.6 seconds
-- 100x faster!

Common Mistakes:

❌ Clustering small tables (waste of credits)
❌ Too many clustering keys (diminishing returns)
❌ Clustering on low-cardinality columns
❌ Not monitoring re-clustering costs
❌ Clustering without analyzing queries
❌ Forgetting to drop unused clustering

Deepak's Clustering Workflow:

1. Identify large, slow tables
2. Analyze query patterns
3. Choose clustering key candidates
4. Test clustering on copy of table
5. Measure performance improvement
6. Monitor re-clustering costs
7. Adjust or remove if needed
8. Document clustering strategy

Deepak's Clustering Checklist:

✅ Table > 1 TB
✅ Clear query pattern identified
✅ High-cardinality column selected
✅ Performance tested
✅ Re-clustering costs acceptable
✅ Clustering depth monitored
✅ Query performance improved
✅ Cost-benefit justified

Key Takeaway:
Clustering organizes data in micro-partitions to
dramatically reduce data scanning. Choose clustering
keys based on query patterns, monitor re-clustering
costs, and use expressions for time-based queries.
Can improve performance 10-100x on large tables!

Practiced: February 2026
Status: ✅ Completed - Table clustering mastered
*/
