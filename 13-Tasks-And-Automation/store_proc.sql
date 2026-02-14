/*
===========================================
DEEPAK'S TASKS WITH STORED PROCEDURES PRACTICE
===========================================
Topic: Using Stored Procedures with Snowflake Tasks
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Stored procedures encapsulate complex logic
- JavaScript language for procedural code
- Tasks can call stored procedures
- Better code organization and reusability
- Error handling in procedures
===========================================
*/

-- Deepak's Note: Stored procedures = reusable code blocks
-- Tasks can call them instead of inline SQL!


-- ========================================
-- SETUP: CREATE DATABASE AND TABLE
-- ========================================

-- Deepak's setup: Create dedicated database
CREATE OR REPLACE DATABASE deepak_task_db;

USE DATABASE deepak_task_db;


-- Deepak's table: Track customer records
CREATE OR REPLACE TABLE customers (
    customer_id INT AUTOINCREMENT,
    create_date TIMESTAMP,
    customer_name VARCHAR(100),
    status VARCHAR(20)
);

-- Deepak's check: Verify empty table
SELECT * FROM customers;

-- Deepak's observation: Table created, ready for automation


-- ========================================
-- EXAMPLE 1: BASIC STORED PROCEDURE
-- ==-- ==-- ==-- =========================

-- Deepak's first procedure: Simple insert with timestamp
CREATE OR REPLACE PROCEDURE deepak_customer_insert_proc (create_date VARCHAR)
    RETURNS STRING NOT NULL
    LANG    LANG    LANG    LANG    LAN$$
        var sq        var sq        var sq        var sq        var sq );'
        snowflake.execute({
            sqlTex            sqlTex            sqlTex      _D            sqlTex            sqlTuccessfully executed.";
        $$;

-- Deepak'-- Deepak'-- Deepak'-- Deepak'-- Deepak'-- _customer_insert_proc(CURRENT_TIMESTAMP());

----------------------------eck ----------------------------eck --------


---------------------------eck --rk---------------------------eck --=============================---------------------------eckCA------------------------========================================
-----------------------: Task calls procedure every minute
CREATE OR REPLACE TASK deepak_customer_task_proc
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = '1 MINUTE'
    COMMENT = 'Deepak - Calls stored procedure to insert customer'
    AS CALL deepak_customer_insert_proc(CURRENT_TIMESTAMP());

-- Deepak's check: View task details
SHOW TASKS;

-- Deepak's activation: Start the task
ALTER TASK deepak_customer_task_proc RESUME;

-- Deepak's observation: Task now running every minute!


-- Wait a few minutes...

-- Deepak's verification: Check automated inserts
SELECT * FROM customers ORDER BY create_date DESC;

-- Deepak's learning: Multiple records inserted automatically!


-- Deepak's cleanup: Stop the task
ALTER TASK deepak_customer_task_proc SUSPEND;


-- ========================================
-- EXAMPLE 2: ADVANCED STORED PROCEDURE WITH MULTIPLE OPERATIONS
-- ========================================

-- Deepak's scenario: More complex procedure with multiple steps
CREATE OR REPLACE PROCEDURE deepak_customer_full_insert_proc (
    p_customer_name VARCHAR,
    p    p    p    p    p    p    p    p    p    p     LANGUAGE JAVASCRIPT
    AS
        $$
        try {
            // Step 1: Insert customer
            var insert_sql = `
                                                                , s                                   NT         P(), :1, :2)
            `;
            sno            sno            sno            snsert_sql,
                binds: [P_CUSTOMER_NAME, P_STATUS]
            });
                                                          v                                                 mer                                                          v  : co                            _result.next();
            var total_count = count_result.getColumnValue(1);
            
            return "Success! Customer '" + P_CUSTOMER_NAME + "' inserted.            return "Success! Customer '" +     
        } catch (err) {
            return "Error: " + err.message;
        }
        $$;

-- Deepak's test: Call with parame-- Deepak's test: Call withul-- Deepak's test: Call with parame-- Deepak's test: Call withul-- Deepak'_p-- DeRahul Verma',-- Deepak's 
CALL deepak_customer_full_insert_proc('ACALL deepak_customer_);

-- Deepak's verification: Check results
SELECT * FROM customers ORDER BY create_date DESC;

-- Deepak's observation: Procedure returns success mess-- Deepak's observation: Procedure returns success mess-- Deepak's AM-- Deepak's observation: Procedure returns s
-- ========================================

-- Deepak's advanced procedure: Generate random customer data
CREATE OR REPLACE PROCEDURE deepak_random_customer_proc()
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    AS
        $$
        // Array of sample names
        var names = [
            'Deepak Singh',            'Deepak Singh',            'Deepak Singh',            'Deepak Singh',            'Deepak Singh',                       'Rohan Mehta',            'Deepak Singh',            'De            'Sarah Johnson', 'Michael Chen', 'Emily Davis', 'James Wilson'
        ];
        
        // Array of statuses
        var statuses = ['ACTIVE', 'PENDING', 'INACTIVE', 'TRIAL'];
        
        // Pick random name and status
        var random_name = names[Math.floor(Math.random() * names.length)];
        var random_status = statuses[Math.floor(Math.random() * statuses.length)];
        
        // Insert
        var sql = `
            INSERT INTO customers(create_date, customer_name, status)
            VALUES(CURRENT_TIMESTAMP(), :1, :2)
        `;
        snowflake.execute({
            sqlText: sql,
            binds: [random_name, random_status]
        });
        
        return "Inserted: " + random_name + " with status " + random_status;
        $$;

-- Deepak's test: Generate random customers
CALL deepak_random_customer_proc();
CALL deepak_random_customer_proc();
CALL deepak_random_customer_proc();

-- Deepak's verification: See random data
SELECT * FROM customers ORDER BY create_date DESC LIMIT 10;

-- Deepak's learning: JavaScript allows complex logic!


-- ========-- =============================
-- CREATE TASK WITH RANDOM CUSTOMER GENERATION
-- ======================-- ===============

-- Deepak's automation: Task generates random customer every minute
CREATE OR REPLACE TASK deepak_random_customer_task
    WAREHOUSE = deepak_compute_wh
    SCHEDULE = '1 MINUTE'
    COMMENT = 'D    COMMENT = 'Ds random customer data via stored procedure'
    AS CALL deepak_random_customer_proc();

-- Deepak's activation: Start random generation
ALTER TASK deeALTER TASK deeALTER TASK dESUME;

-- Wait a few minutes...

-- Deepak's verification: Check automated -- Deepak'erts
SELECT 
    customer_name,
    status,
    create_date,
    COUNT(*) OVER() AS total_customers
FROM customers 
ORDER BY create_date DESC 
LILILILILILILILILILILILILILILILILILIRandom customers being generated automLILILILILILILILILILILILILILILILILItop the task
ALTER TASK deepak_random_customer_task SUSPEND;


-- ========================================-- ========================================-- ===========================================

-- Deepak's validation procedure: Check data quality before insert
CREATE OR REPLACE PROCEDURE deepak_validated_insert_proc(
    p_customer_name VARCHAR,
    p_status VARCHAR
)
    RETURNS STRING NOT NULL
    LANGUAGE JAV    LANGUAGE JAV    LANGUAGE      try {
            // Validation 1: Check name is not empty
            if (!P_CUSTOMER_NAME || P_CUSTOMER_NAME.trim() === '') {
                return "Error: Customer name cannot be empty";
            }
            
            // Validation 2: Check status is valid
            var valid_statuses = ['ACTIVE', 'PENDING', 'INACTIVE'            var v            va            varcludes(P_STATUS)) {
                retur      or: Invalid status. Must be ACTIVE, P                retur      or: Invalid status. Must be ACTIVE, P                retur      or: Invalid status. Must be                   retur      or: Invalid staCOUNT(*)                retur      or: Invalid status. Must be ACTIVE, P                retur      or: Invalid status. Must be ACTIVE, P r', -1, CURRENT_TIMESTAMP())
            `;
            var check_result = snowflake.execute({
                sqlText: check_sql,                sqlText: chCU                sql                    sqlText: esult.next();
            var duplicate_count = check_result.getColumnValue(1);
            
            if (duplicate_count > 0) {
                return "Warning: Customer '" + P_CUSTOMER_NAME + "' already inserted in last hour. Skipping.";
             
            
                                                           var insert_sql = `
                INSERT INTO customers(create_date, customer_name, status)
                VALUES(CURRENT_TIMESTAMP(), :1, :2)
            `;
            snowflake.execute({
                sqlText: insert_sql,
                binds: [P_CUSTOMER_NAME, P_STATUS]
            });
            
            return "Success: Customer '" + P_CUSTOMER_NAME + "' inserted with status " + P_STATUS;
            
        } catch (err) {
            return "Error: " + err.message;
        }
        $$;

-- Deepak's test: Va-- Deepak's test: Va-- Deepak's test: Va-- Deepakpak Singh', 'ACTIVE');

-- Deepak's test: Invalid status
CALL deepak_validated_insert_proc('Test User', 'INVALID_STATUS');

-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- D-- DAC-- D-);

-- Deepak's test: Duplicate (within 1 hour)-- Deepak's test: Duplicate (within 1 hour)-- Deepak's test: Duplicate (within 1 hour)-- Deepak's test: Duplida-- Deepak========================================
-- EXAMPLE 5: PROCEDURE WITH CONDITIONAL LOGIC
-- =====-- =====-- =====-- =====-- =====-- =====-- =====-- =====-- =====-- =====Different actions based on time
CREATE OR REPLACE PROCCREATE OR REPtime_based_insert_proc()
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    AS
        $$
        // Get current hour        // Getou        // LECT HOUR(CURRENT_TIMESTAMP()) AS current_hour';
        var hour_result = snowflake.execute({sqlText        vl});        var hoursult.nex        var hour_result = snowflake.execult.       mnValue(1);
        
        var customer_name;
        var status;
        
        // Business hours (9 AM - 5 PM): ACTIVE customers
                                                                    stomer_name = 'Business Hour Customer';
            status = 'ACTIVE';
        }
        // Evening (5 PM - 11 PM): PENDING customers
        else if (current_hour >= 17 && current_hour < 23) {
            customer_name = 'Evening Customer';
            status = 'PENDING';
        }
        // Night (11 PM - 9 AM): TRIAL customers
                                                                                                                      // Insert
        var insert_sql = `
            INSERT INTO customers(create_date, customer_name, status)
                 S(CURRENT_TIMESTAMP(), :1, :2)
        `;
        snowflake.execute({
            sqlText: insert_sql,
                                                                                                                                   our + ", Status: " + status + ")";
        $$;

-- Deepak's test: Time-based logic
CALL deepak_time_based_insert_proc();

-- Deepak's verification: Check what was inserted
SELECT * FROM customers ORDER BY create_date DESC LIMIT 5;

-- Deepak's learning: Procedures can have complex conditional logic!


-- ========================================
-- COMPREHENSIVE INSIGHTS
-- ========================================

/*
Deepak's Key Insights on Stored Procedures with Tasks:

1. WHY USE STORED PROCEDURES WITH TASKS?
   ✅ Code Reusability: Write once, call from multiple tasks
   ✅ Complex Logic: JavaScript allows loops, conditionals, error handling
   ✅ Maintainability: Update procedure without changing task
   ✅ Testing: Test procedure independently before automation
   ✅ Modularity: Separate business logic from scheduling

2. STORED PROCEDURE BASICS:
   - Language: JavaScript (most common), Python, Java, Scala, SQL
   - Parameters: Can accept input parameters
   - Return Values: Must return a value
   - Binds: Use :1, :2 for parameter binding (prevents SQL injection)
   - Error Handling: Use try-catch blocks

3. JAVASCRIPT IN STORED PROCEDURES:
   - snowflake.execute(): Run SQL commands
   - result.next(): Move to next row
   - result.getColumnValue(index): Get column value
   - Variables: var, let, const
   - Arrays: var arr = [1, 2, 3]
   - Objects: var obj = {key:    - Objects: var obj = {key:    - Objectsom num   - Objects: var obj = {key:    - Objects: var 
4. CALLING PROCEDURES FROM TASKS:
   Syntax: AS CALL procedure_name(parameters)
   
   Example:
   CREATE TASK my_task
       WAREHOUSE = my_wh
       SCHEDULE = '1 MINUTE'
       AS CALL my_procedure(CURRENT_TIMESTAMP());

5. PARAMETER BINDING:
                                                               table VALUES('" + user_input + "')";
   
   ✅ Good (Safe):
       var sql = "INSERT INTO table VALUES(:1)";
       snowflake.execute({sqlText: sql, binds:        snowflake.execute({sqlText: sql, bin:
       snowflake.execute({sqlText: sqlnowflake.execute({sqlText: sql});
       return "Success";
   } catch (e   } catch (e   } catch (e   } catch (e age   } catch (e   } catch (e   } catData validation before insert
   - Multi-step ETL processes
   - Conditional data processing
   - Random data generation (testing)
   - Time-based logic
   - Complex calculations
   - Calling multiple tables/operations

8. STORED PROCEDURE vs INLINE SQL IN TASKS:
   
   Use Inline SQL when:
   - Simple single statement
   - No conditional logic needed
   - No reusability required
   
   Use Stored Procedure when:
   - Complex multi-step logic
   - Conditional proces   - Conditional proces   -eded
   - Code reusability important
   - Testing independently required

999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999 string concatenation)
                                                  edures manually before automating
   ✅ Add comments in JavaScript code
   ✅ Validate input   ✅ Validate input   ✅ Validate input   ✅ Validate input   ✅ res focused (single responsibility)
   ✅ Log important operations
   ✅ Handle NULL values

10. DEBUGGING STORED PROCEDURES:
    - Call manually with test data
    - Check re    - Check re    - Check re   statements to verify data
    - Add logg    - Add logg    - s
    - Test edge cases (NULL, empty, invalid)
    - Check TASK_HISTORY() for errors

11. PERFORMANCE CONSIDERATI1NS:11. PERFORMANCE CONSIDin warehouse (consume credits)
11. PERFORMANCE CONSIDERATI1NS:ec11. PERFORMANCE CONSIDERATIQL11ithin procedures
    - Avoid unnecessary loops
    - Use bulk operations when possible
    - Consider warehouse size for heavy procedures

12. COMMON PATTERNS:

    Pattern 1: Insert with Validation
    CREATE PROCEDURE validate_and_insert(p_data VARCHAR)
        RETURNS STRING
        LANGUAGE JAVASCRIPT
        AS $$
            if (!P_DATA) return "Error: Empty data";
            snowfl            snowfl            snowfl n "Success";
        $$;

    Pattern 2: Multi-Step ETL
    CREATE PROCEDURE etl_process()
        RETURNS STRING
        LANGUAG        LANGUAG        LANGUAG         // Step 1: Extract
            snowflake.execute({sqlText: 'INSERT INTO staging ...'});
            // Step 2: Transform
            snowflake.execute({sqlText: 'INSERT INTO cleaned ...'});
            // Step 3: Load
            snowflake.execute({sqlText: 'INSERT INTO final ..            snowflake.execute({sqlText: 'INSERT INTO final ..            snowflakerocessing
    CREATE PROCEDURE conditional_insert()
        RETURNS STRING
        LANGUAGE JAVASCRIPT
        AS        AS        AS        AS        .execute({sqlText: 'SELECT COUNT(*) ...'});
            result.next();
            var count = result.getColumnValue(1);
            if (count > 100) {
                sno                sno  xt: 'INSERT INTO archive ...'}               }
            return "Processed";
        $$;

13. REAL-WORLD EXAMPLE:
    Scenario: Daily customer signup processing
    
    Procedure:
    - Validate signup data
    - Check for duplicates
    - Assign customer tier based on signup source
    - Insert into customers table
    - Send welcome    - Send welcome    - Send welcome    - Send welcome    - Send we:
    - Send welcome    - Send wels    - Send welcome    - Send wels    - Send welcome    - Send wels     ❌ "Procedure not found"
       → Check database/schema context
       → Verify procedure name spelling
    
    ❌ "Parameter count mismatch"
       → Check number of parameters in CALL
       → Verify procedure signature
    
    ❌ "JavaScript execution erro    ❌ "JavaScript execution erro    ❌ "JavaScript execution erro    ❌ "JavaScript ex v    ❌ "JavaScript execueters
    
    ❌ "Task fails silently"
       → Check TASK_HISTORY() for errors       → Check TASK_HISTORY() for errors       → Check TASK_HISTORY() for errors MO       → Check TASK_HISTORY(re       → from tasks
    SELECT
        name,
        state,
        error_message,
                 t
                 t
ge,
ISN_SCHEMA.TASK_HISTORY(
                                                     -1, CURRENT_TIMESTAMP())
    ))
    W    W    W    W    W    W    W    W    W    W    W    W    W    W    W    W    W    W===========================
-- CLEANUP
-- ========================================

-- Deepak's cleanup: Stop all tasks
ALTER TASK deepak_customer_task_proc SUSPEND;
ALTER TALTER TALTER TALTER TALTER TALTER TALTER


L DeL DeL DeL DeL DeL DeL DeL DeL DeLstL DeL DeL DeL DeL DeL DeL DeL DeL DeLstL DeLew all customers
SELECT 
    customer_name,
                                                                                                                                                            SUMMARY
-- ========================================

/*
===========================================
DEEPAK'S SUMMARY: TASKS WITH STORED PROCEDURES
===========================================

What I Learned:
1. Stored procedures encapsulate comp1. Stored proJa1. Stored procedures  call procedures using AS CALL syntax
3.3.rocedures allow validation, conditional logic, error handling
4. Parameter binding prevents SQL injection
5. JavaScript enables loops, arrays, conditionals
6. Procedures are reusable across multiple tasks
7. Try-catch blocks handle errors gracefully
8. Return values provide execution feedback
9. Test procedures manually before automating
10. Monitor execution via TASK_HISTORY()

Key Commands:
- CREATE PROCEDURE: Define stored procedure
- CALL procedure_name(): Execute procedure
- snowflake.execute(): Run SQL from JavaScript
- result.next(): Move to next row
- result.getColumnValue(): Get column value
- AS CALL: Call procedure from task

Best Practices:
✅ Use stored procedures for complex logic
✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ � er�or handling with try-catch
✅ Return meaningful messages
✅ Test independently before automation
✅ Validate input parameters
✅ Keep ✅ Keep ✅ Kused and modular
✅ Add comments in JavaScript code
✅ Monitor task execution regularly
✅ Handle edge cases (NULL, empty, invalid)

Real-World Applications:
- Multi-step ETL processes
- Data validation pipelines
- Conditional data processing
- Random test data generati- Random test data generati- Random test datculations
- External API integrations
- Automated reporting

Why This Matters:
Stored procedurStored procedurStored procedurStored proceduheStored procedurStored procedurStored preduStored proced Stored procedurStored procedurStored proceSQStored procedurStored procedurStored procesting.

Next Steps:
- Practice writing JavaScrip- Practice writing JavaScrip- PrET- Practice writing JavaScrip- Practice write- Practice writing JavaScrip- Pracbrary
- Monitor and optimize performance

Practiced: February 14, 2026
Status: ✅ Completed - Stored procedures with tasks mastered!
===========================================
*/
