/*
===========================================
DEEPAK'S SIZE_LIMIT PRACTICE
===========================================
Topic: Limiting Data Load Size
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- SIZE_LIMIT controls max bytes to load
- Specified in bytes (not rows)
- Stops load when limit reached
- Useful for testing and incremental loads
- Prevents runaway loads
===========================================
*/

-- Deepak's Note: SIZE_LIMIT is like a safety valve for data loads
-- Prevents loading too much data at once!


-- ========================================
-- SETUP: CREATE DATABASE AND TABLE
-- ========================================

-- Deepak's scenario: Create database for size limit testing
CREATE OR REPLACE DATABASE deepak_size_test_db
COMMENT = 'Deepak - Database for testing SIZE_LIMIT option';

USE DATABASE deepak_size_test_db;


-- Deepak's scenario: Orders table for testing
CREATE OR REPLACE TABLE deepak_size_test_db.public.orders_size_test (
    order_id VARCHAR(30),
    amount NUMBER(10,2),
    profit NUMBER(10,2),
    quantity INT,
    category VARCHAR(30),
    subcategory VARCHAR(30)
)
COMMENT = 'Deepak - Table for SIZE_LIMIT testing';


-- ========================================
-- CREATE STAGE
-- ========================================

-- Deepak's scenario: Stage with multiple large files
CREATE OR REPLACE STAGE deepak_size_test_db.public.deepak_size_stage
    URL = 's3://deepak-snowflake-data/large-files/'
    COMMENT = 'Deepak - Stage with large data files';

-- List files in stage
LIST @deepak_size_test_db.public.deepak_size_stage;

-- Deepak's observation: Multiple files, varying sizes


-- ========================================
-- TEST 1: LOAD WITH SIZE_LIMIT
-- ========================================

-- Deepak's experiment: Load with 20KB limit
COPY INTO deepak_size_test_db.public.orders_size_test
    FROM @deepak_size_test_db.public.deepak_size_stage
    FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1)
    PATTERN = '.*Order.*'
    SIZE_LIMIT = 20000;

-- Deepak's learning: Load stops when 20,000 bytes loaded
-- May load partial files or skip files to stay under limit

-- Check how much data was loaded
SELECT COUNT(*) AS rows_loaded FROM deepak_size_test_db.public.orders_size_test;

-- Deepak's observation: Only loaded data up to size limit


/*
DEEPAK'S SIZE_LIMIT INSIGHTS:
==============================

What is SIZE_LIMIT?
- COPY option to limit data load size
- Specified in bytes (not rows)
- Stops loading when limit reached
- Default: No limit (load all files)
- Useful for controlled loads

How It Works:
1. Snowflake starts loading files
2. Tracks cumulative bytes loaded
3. Stops when SIZE_LIMIT reached
4. May load partial files
5. Remaining files not loaded

SIZE_LIMIT Specification:
- Value in bytes
- Examples:
  - 1000 = 1 KB
  - 1000000 = 1 MB
  - 1000000000 = 1 GB

Common Values:
SIZE_LIMIT = 1000         -- 1 KB (testing)
SIZE_LIMIT = 10000        -- 10 KB (small test)
SIZE_LIMIT = 1000000      -- 1 MB (medium test)
SIZE_LIMIT = 10000000     -- 10 MB (larger test)
SIZE_LIMIT = 100000000    -- 100 MB (production sample)

When to Use SIZE_LIMIT:
✅ Testing data loads
✅ Sampling large datasets
✅ Incremental loads
✅ Preventing runaway loads
✅ Development/debugging
✅ Proof of concept
✅ Resource management

When NOT to Use:
❌ Production full loads
❌ When all data needed
❌ Critical complete datasets
❌ When partial data causes issues

Benefits:
✅ Prevents loading too much data
✅ Faster testing iterations
✅ Saves warehouse credits
✅ Reduces load time
✅ Easier to debug small datasets
✅ Protects against mistakes

Limitations:
⚠️  Measured in bytes, not rows
⚠️  May load partial files
⚠️  Not deterministic (which files loaded)
⚠️  Doesn't guarantee specific row count
⚠️  File order affects what's loaded

Behavior Examples:

Scenario 1: Multiple Small Files
Files: file1.csv (5KB), file2.csv (5KB), file3.csv (5KB)
SIZE_LIMIT = 12000 (12KB)

Result:
- file1.csv: Loaded (5KB)
- file2.csv: Loaded (10KB total)
- file3.csv: Partially loaded (2KB, total 12KB)
- Remaining: Not loaded

Scenario 2: One Large File
Files: large.csv (100KB)
SIZE_LIMIT = 20000 (20KB)

Result:
- large.csv: Partially loaded (20KB)
- Remaining 80KB: Not loaded

Scenario 3: Exact Match
Files: file1.csv (10KB), file2.csv (10KB)
SIZE_LIMIT = 20000 (20KB)

Result:
- file1.csv: Loaded (10KB)
- file2.csv: Loaded (20KB total)
- Perfect match!

Testing Pattern:

-- Step 1: Test with small SIZE_LIMIT
COPY INTO test_table
    FROM @stage
    FILE_FORMAT = (...)
    SIZE_LIMIT = 10000;  -- 10KB for quick test

-- Step 2: Verify data looks correct
SELECT * FROM test_table LIMIT 100;

-- Step 3: If good, load more
TRUNCATE TABLE test_table;

COPY INTO test_table
    FROM @stage
    FILE_FORMAT = (...)
    SIZE_LIMIT = 1000000;  -- 1MB for larger test

-- Step 4: Full load (no SIZE_LIMIT)
TRUNCATE TABLE test_table;

COPY INTO test_table
    FROM @stage
    FILE_FORMAT = (...);  -- No SIZE_LIMIT

Incremental Load Pattern:

-- Load data in chunks
-- Chunk 1
COPY INTO orders
    FROM @stage
    FILE_FORMAT = (...)
    SIZE_LIMIT = 100000000;  -- 100MB

-- Check progress
SELECT COUNT(*) FROM orders;

-- Chunk 2 (load more)
COPY INTO orders
    FROM @stage
    FILE_FORMAT = (...)
    SIZE_LIMIT = 100000000;  -- Another 100MB

-- Continue until all loaded

Combining with Other Options:

-- Safe testing load
COPY INTO test_table
    FROM @stage
    FILE_FORMAT = (...)
    PATTERN = '.*2026.*'
    SIZE_LIMIT = 50000
    ON_ERROR = CONTINUE
    VALIDATION_MODE = RETURN_10_ROWS;  -- Validate first

-- Production sample
COPY INTO sample_table
    FROM @production_stage
    FILE_FORMAT = (...)
    SIZE_LIMIT = 10000000  -- 10MB sample
    ON_ERROR = ABORT_STATEMENT;

Monitoring Load Size:

-- Check how much data was loaded
SELECT
    file_name,
    file_size,
    row_count,
    row_parsed
FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'deepak_size_test_db.public.orders_size_test',
        START_TIME => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
);

-- Calculate total bytes loaded
SELECT
    SUM(file_size) AS total_bytes_loaded,
    SUM(row_count) AS total_rows_loaded
FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'deepak_size_test_db.public.orders_size_test',
        START_TIME => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
    )
);

Real-World Examples:

1. Development Testing:
-- Quick test with small dataset
COPY INTO dev_orders
    FROM @dev_stage
    FILE_FORMAT = (FORMAT_NAME = csv_format)
    SIZE_LIMIT = 100000  -- 100KB for quick test
    ON_ERROR = CONTINUE;

2. Data Sampling:
-- Load sample for analysis
COPY INTO sample_customers
    FROM @customer_stage
    FILE_FORMAT = (FORMAT_NAME = csv_format)
    SIZE_LIMIT = 5000000  -- 5MB sample
    PATTERN = '.*customers.*';

3. Proof of Concept:
-- Demo with limited data
COPY INTO poc_table
    FROM @poc_stage
    FILE_FORMAT = (...)
    SIZE_LIMIT = 1000000  -- 1MB for demo
    VALIDATION_MODE = RETURN_ERRORS;

Best Practices:
1. Use for testing, not production
2. Start small, increase gradually
3. Monitor actual bytes loaded
4. Document SIZE_LIMIT usage
5. Remove SIZE_LIMIT for final load
6. Combine with VALIDATION_MODE
7. Test with representative data

Common Mistakes:

❌ Thinking SIZE_LIMIT is row count
   (It's bytes, not rows!)

❌ Using in production without reason
   (Can cause incomplete loads)

❌ Not checking what was loaded
   (May be partial/unexpected data)

❌ Forgetting to remove for full load
   (Production load incomplete)

Conversion Reference:
1 KB = 1,000 bytes
1 MB = 1,000,000 bytes
1 GB = 1,000,000,000 bytes

SIZE_LIMIT = 1000          -- 1 KB
SIZE_LIMIT = 10000         -- 10 KB
SIZE_LIMIT = 100000        -- 100 KB
SIZE_LIMIT = 1000000       -- 1 MB
SIZE_LIMIT = 10000000      -- 10 MB
SIZE_LIMIT = 100000000     -- 100 MB
SIZE_LIMIT = 1000000000    -- 1 GB

Deepak's Testing Workflow:
1. Start with SIZE_LIMIT = 10000 (10KB)
2. Verify data structure and quality
3. Increase to SIZE_LIMIT = 1000000 (1MB)
4. Test transformations and logic
5. Remove SIZE_LIMIT for full load
6. Monitor and validate complete load

Key Takeaway:
SIZE_LIMIT is perfect for testing and sampling, but
remember it's measured in BYTES, not rows. Always
remove it for production full loads unless you have
a specific reason to limit the load size!

Practiced: February 2026
Status: ✅ Completed - Understanding size-limited loads
*/

