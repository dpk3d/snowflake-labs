/*
===========================================
DEEPAK'S TASK DEPENDENCIES PRACTICE
===========================================
Topic: Creating Task Trees (Parent-Child Dependencies)
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Tasks can have dependencies (AFTER clause)
- Child tasks run AFTER parent completes
- Must suspend root task before modifying tree
- Resume child tasks first, then root task
- SYSTEM$TASK_DEPENDENTS_ENABLE() for bulk resume
===========================================
*/

-- Deepak's Note: Task trees are like assembly lines
-- Each step waits for the previous step to complete!


-- ========================================
-- SETUP: USE DATABASE
-- ========================================

USE DATABASE deepak_task_db;

-- Deepak's check: View existing tasks
SHOW TASKS IN deepak_task_db.public;


-- ========================================
-- CREATE TABLES FOR TASK CHAIN
-- ========================================

-- Deepak's scenario: Multi-stage data pipeline
-- Stage 1: Raw customer data
CREATE OR REPLACE TABLE deepak_task_db.public.customers_raw (
    customer_id INT AUTOINCREMENT START = 1 INCREMENT = 1,
    first_name VARCHAR(40) DEFAULT 'Customer',
    create_date TIMESTAMP,
    PRIMARY KEY (customer_id)
)
COMMENT = 'Deepak - Raw customer data (stage 1)';

-- Insert initial data
INSERT INTO deepak_task_db.public.customers_raw (first_name, create_date)
VALUES
    ('Priya', CURRENT_TIMESTAMP()),
    ('Rahul', CURRENT_TIMESTAMP()),
    ('Amit', CURRENT_TIMESTAMP());

-- Deepak's check: Verify initial data
SELECT * FROM deepak_task_db.public.customers_raw;


-- Stage 2: Cleaned customer data
CREATE OR REPLACE TABLE deepak_task_db.public.customers_cleaned (
    customer_id INT,
    first_name VARCHAR(40),
    create_date DATE
)
COMMENT = 'Deepak - Cleaned customer data (stage 2)';


-- Stage 3: Final customer data with metadata
CREATE OR REPLACE TABLE deepak_task_db.public.customers_final (
    customer_id INT,
    first_name VARCHAR(40),
    create_date DATE,
    insert_date DATE DEFAULT DATE(CURRENT_TIMESTAMP())
)
COMMENT = 'Deepak - Final customer data with metadata (stage 3)';


-- ========================================
-- CREATE ROOT TASK (PARENT)
-- ========================================

-- Deepak's scenario: Root task inserts new customer
CREATE OR REPLACE TASK deepak_task_db.public.deepak_customer_insert_root
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = '1 MINUTE'
    COMMENT = 'Deepak - Root task: Insert new customer'
    AS
    INSERT INTO deepak_task_db.public.customers_raw (first_name, create_date)
    VALUES (
        CONCAT('Customer_', FLOOR(RANDOM() * 1000)),
        CURRENT_TIMESTAMP()
    );

-- Deepak's observation: Root task created in SUSPENDED state


-- ========================================
-- SUSPEND ROOT TASK BEFORE ADDING CHILDREN
-- ========================================

-- Deepak's CRITICAL STEP: Must suspend root before modifying tree!
ALTER TASK deepak_task_db.public.deepak_customer_insert_root SUSPEND;

-- Deepak's learning: This is REQUIRED before adding child tasks
-- Prevents inconsistent state during tree modification


-- ========================================
-- CREATE CHILD TASK 1 (DEPENDS ON ROOT)
-- ========================================

-- Deepak's scenario: Child task 1 cleans data
-- Runs AFTER root task completes
CREATE OR REPLACE TASK deepak_task_db.public.deepak_customer_clean
    WAREHOUSE = deepak_compute_wh
    AFTER deepak_task_db.public.deepak_customer_insert_root
    COMMENT = 'Deepak - Child task 1: Clean customer data'
    AS
    INSERT INTO deepak_task_db.public.customers_cleaned
    SELECT
        customer_id,
        UPPER(first_name) AS first_name,  -- Clean: uppercase names
        DATE(create_date) AS create_date
    FROM deepak_task_db.public.customers_raw;

-- Deepak's learning: AFTER clause creates dependency
-- This task waits for deepak_customer_insert_root to finish


-- ========================================
-- CREATE CHILD TASK 2 (DEPENDS ON CHILD 1)
-- ========================================

-- Deepak's scenario: Child task 2 adds metadata
-- Runs AFTER child task 1 completes
CREATE OR REPLACE TASK deepak_task_db.public.deepak_customer_finalize
    WAREHOUSE = deepak_compute_wh
    AFTER deepak_task_db.public.deepak_customer_clean
    COMMENT = 'Deepak - Child task 2: Finalize with metadata'
    AS
    INSERT INTO deepak_task_db.public.customers_final (customer_id, first_name, create_date)
    SELECT
        customer_id,
        first_name,
        create_date
    FROM deepak_task_db.public.customers_cleaned;

-- Deepak's learning: Creates a chain!
-- Root → Child 1 → Child 2


-- ========================================
-- VIEW TASK TREE
-- ========================================

-- Deepak's check: See all tasks and their dependencies
SHOW TASKS IN deepak_task_db.public;

-- Deepak's observation:
-- - deepak_customer_insert_root (root, has schedule)
-- - deepak_customer_clean (child, AFTER root)
-- - deepak_customer_finalize (child, AFTER clean)


-- ========================================
-- CONFIGURE ROOT TASK SCHEDULE
-- ========================================

-- Deepak's configuration: Set schedule on root task
ALTER TASK deepak_task_db.public.deepak_customer_insert_root
SET SCHEDULE = '1 MINUTE';

-- Deepak's learning: Only root task has schedule
-- Child tasks triggered by parent completion


-- ========================================
-- RESUME TASKS (CORRECT ORDER!)
-- ========================================

-- Deepak's CRITICAL STEP: Resume child tasks FIRST!
-- Order: Leaf → Parent → Root

-- Resume child task 2 (leaf)
ALTER TASK deepak_task_db.public.deepak_customer_finalize RESUME;

-- Resume child task 1 (middle)
ALTER TASK deepak_task_db.public.deepak_customer_clean RESUME;

-- Resume root task (last!)
ALTER TASK deepak_task_db.public.deepak_customer_insert_root RESUME;

-- Deepak's learning: Must resume in reverse order
-- Children first, then parent, then root


-- ========================================
-- ALTERNATIVE: BULK RESUME
-- ========================================

-- Deepak's technique: Use system function to resume all at once
-- (Uncomment to use instead of manual resume)

/*
SELECT SYSTEM$TASK_DEPENDENTS_ENABLE('deepak_task_db.public.deepak_customer_insert_root');
*/

-- Deepak's learning: This recursively resumes root and all dependents
-- Easier than manual resume, but less control


-- ========================================
-- MONITOR TASK EXECUTION
-- ========================================

-- Deepak's monitoring: Wait a few minutes, then check results

-- Check raw table (should have new rows every minute)
SELECT COUNT(*) AS raw_count, MAX(create_date) AS latest
FROM deepak_task_db.public.customers_raw;

-- Check cleaned table (should match raw)
SELECT COUNT(*) AS cleaned_count, MAX(create_date) AS latest
FROM deepak_task_db.public.customers_cleaned;

-- Check final table (should match cleaned)
SELECT COUNT(*) AS final_count, MAX(insert_date) AS latest
FROM deepak_task_db.public.customers_final;

-- Deepak's observation: All three tables growing together!


-- View recent data in final table
SELECT *
FROM deepak_task_db.public.customers_final
ORDER BY insert_date DESC
LIMIT 10;


-- ========================================
-- SUSPEND TASKS (CORRECT ORDER!)
-- ========================================

-- Deepak's cleanup: Suspend tasks to stop execution
-- Order: Root → Parent → Leaf

-- Suspend root task first (stops new executions)
ALTER TASK deepak_task_db.public.deepak_customer_insert_root SUSPEND;

-- Suspend child task 1
ALTER TASK deepak_task_db.public.deepak_customer_clean SUSPEND;

-- Suspend child task 2
ALTER TASK deepak_task_db.public.deepak_customer_finalize SUSPEND;

-- Deepak's learning: Suspend root first to stop the chain
-- Then suspend children


/*
DEEPAK'S TASK DEPENDENCIES INSIGHTS:
=====================================

What are Task Dependencies?

- Parent-child relationships between tasks
- Child tasks run AFTER parent completes
- Creates sequential workflows
- Enables complex ETL pipelines
- Automatic orchestration

Task Tree Structure:

Root Task (has SCHEDULE):
├── Child Task 1 (AFTER root)
│   └── Child Task 2 (AFTER child 1)
└── Child Task 3 (AFTER root)

Execution Flow:

1. Root task runs on schedule
2. Root task completes successfully
3. Child tasks start (in parallel if multiple)
4. Child tasks complete
5. Grandchild tasks start
6. Process repeats on next schedule

Creating Task Trees:

Step 1: Suspend root task
ALTER TASK root_task SUSPEND;

Step 2: Create child tasks with AFTER
CREATE TASK child_task
    WAREHOUSE = wh
    AFTER root_task
    AS SELECT 1;

Step 3: Resume children first, then root
ALTER TASK child_task RESUME;
ALTER TASK root_task RESUME;

Task Tree Rules:

✅ Only root task has SCHEDULE
✅ Child tasks use AFTER clause
✅ Must suspend root before modifying tree
✅ Resume children before root
✅ Suspend root before children
✅ Max 1000 tasks in a tree
✅ Max 100 predecessors per task

Resume Order (Bottom-Up):

1. Resume leaf tasks (no children)
2. Resume middle tasks
3. Resume root task (last!)

Example:
ALTER TASK grandchild RESUME;  -- Leaf
ALTER TASK child RESUME;       -- Middle
ALTER TASK root RESUME;        -- Root

Suspend Order (Top-Down):

1. Suspend root task (first!)
2. Suspend middle tasks
3. Suspend leaf tasks

Example:
ALTER TASK root SUSPEND;       -- Root
ALTER TASK child SUSPEND;      -- Middle
ALTER TASK grandchild SUSPEND; -- Leaf

Bulk Operations:

Resume all dependents:
SELECT SYSTEM$TASK_DEPENDENTS_ENABLE('root_task');

Suspend all dependents:
-- No built-in function, must suspend manually

Common Patterns:

Pattern 1: Linear Chain
Root → Clean → Transform → Load

Pattern 2: Fan-Out
Root → Child1
     → Child2
     → Child3

Pattern 3: Fan-In
Root1 → Child
Root2 → Child
Root3 → Child

Pattern 4: Complex Tree
Root → Clean → Transform → Load
            → Validate → Alert

Real-World Example: ETL Pipeline

-- Stage 1: Extract
CREATE TASK extract_data
    WAREHOUSE = etl_wh
    SCHEDULE = 'USING CRON 0 2 * * * UTC'
    AS
    COPY INTO raw_data FROM @s3_stage;

-- Stage 2: Clean
CREATE TASK clean_data
    WAREHOUSE = etl_wh
    AFTER extract_data
    AS
    INSERT INTO cleaned_data
    SELECT * FROM raw_data WHERE is_valid = TRUE;

-- Stage 3: Transform
CREATE TASK transform_data
    WAREHOUSE = etl_wh
    AFTER clean_data
    AS
    INSERT INTO transformed_data
    SELECT customer_id, SUM(amount)
    FROM cleaned_data
    GROUP BY customer_id;

-- Stage 4: Load
CREATE TASK load_data
    WAREHOUSE = etl_wh
    AFTER transform_data
    AS
    MERGE INTO production_table ...;

Error Handling:

If parent task fails:
- Child tasks DO NOT run
- Workflow stops at failure point
- Check task history for errors
- Fix and manually re-run if needed

Monitoring:
SELECT
    name,
    state,
    schedule,
    predecessors,
    error_integration
FROM TABLE(INFORMATION_SCHEMA.TASK_DEPENDENTS(
    TASK_NAME => 'root_task',
    RECURSIVE => TRUE
));

Best Practices:

1. Plan Workflow First:
   - Draw task tree diagram
   - Identify dependencies
   - Determine parallelism

2. Use Meaningful Names:
   - Indicate order (step1_, step2_)
   - Describe purpose
   - Consistent naming

3. Suspend Before Modifying:
   - Always suspend root first
   - Prevents inconsistent state
   - Safer modifications

4. Resume in Correct Order:
   - Children before parents
   - Test with frequent schedule
   - Monitor execution

5. Add Error Handling:
   - Use error integrations
   - Alert on failures
   - Implement retry logic

6. Monitor Execution:
   - Check task history
   - Verify data flow
   - Track execution times

Common Mistakes:

❌ Not suspending root before modifying
❌ Resuming root before children
❌ Creating circular dependencies
❌ No error handling
❌ Too many tasks in tree (performance)
❌ Not monitoring execution

Troubleshooting:

Problem: Child task not running
→ Check parent task completed successfully
→ Verify child task is RESUMED
→ Check task history for errors

Problem: Can't modify task tree
→ Suspend root task first
→ Wait for running tasks to complete
→ Then modify

Problem: Tasks running out of order
→ Check AFTER dependencies
→ Verify resume order
→ Check task history

Deepak's Task Tree Workflow:

1. Design workflow (draw diagram)
2. Create all tables
3. Create root task (suspended)
4. Suspend root task
5. Create child tasks with AFTER
6. Test with frequent schedule
7. Resume children first
8. Resume root last
9. Monitor execution
10. Adjust as needed

Deepak's Task Tree Checklist:

✅ Workflow designed and documented
✅ All tables created
✅ Root task created with schedule
✅ Root task suspended
✅ Child tasks created with AFTER
✅ Dependencies verified
✅ Children resumed first
✅ Root resumed last
✅ Monitoring enabled
✅ Error handling implemented

Key Takeaway:
Task dependencies create powerful workflows!
Use AFTER clause to chain tasks. Always suspend
root before modifying tree. Resume children first,
then root. Suspend root first, then children.
Monitor execution and handle errors. Perfect for
complex ETL pipelines!

Practiced: February 2026
Status: ✅ Completed - Task dependencies mastered
*/




