/*
===========================================
DEEPAK'S SECURE VIEWS
===========================================
Topic: Regular Views vs Secure Views
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Regular view security limitations
- Secure view benefits
- Query optimization differences
- Definition visibility
- Access control patterns
===========================================
*/

-- Deepak's Note: Secure views hide definition and prevent optimization leaks!
-- Essential for protecting sensitive business logic and data


-- ========================================
-- SETUP: CREATE DATABASE AND TABLE
-- ========================================

-- Deepak's customer database
CREATE OR REPLACE DATABASE deepak_customer_db;

USE DATABASE deepak_customer_db;
USE SCHEMA public;

-- Deepak's customer table
CREATE OR REPLACE TABLE customers (
  customer_id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  gender STRING,
  job_title STRING,
  phone STRING,
  salary NUMBER(10,2),
  department STRING,
  hire_date DATE
);

-- Deepak's observation: Table ready for customer data!


-- ========================================
-- STEP 1: CREATE MANAGEMENT DATABASE
-- ========================================

-- Deepak's management database for stages and formats
CREATE OR REPLACE DATABASE deepak_manage_db;

-- Deepak's file formats schema
CREATE OR REPLACE SCHEMA deepak_manage_db.file_formats;

-- Deepak's external stages schema
CREATE OR REPLACE SCHEMA deepak_manage_db.external_stages;


-- ========================================
-- STEP 2: CREATE FILE FORMAT
-- ========================================

-- Deepak's CSV file format
CREATE OR REPLACE FILE FORMAT deepak_manage_db.file_formats.csv_standard
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TRIM_SPACE = TRUE;

-- Deepak's observation: Reusable file format!


-- ========================================
-- STEP 3: CREATE EXTERNAL STAGE
-- ========================================

-- Deepak's S3 stage for customer data
CREATE OR REPLACE STAGE deepak_manage_db.external_stages.customer_data_stage
  URL = 's3://data-snowflake-fundamentals/time-travel/'
  FILE_FORMAT = deepak_manage_db.file_formats.csv_standard
  COMMENT = 'Deepak: Stage for customer CSV files';

-- Deepak's list files
LIST @deepak_manage_db.external_stages.customer_data_stage;

-- Deepak's observation: Files available in stage!


-- ========================================
-- STEP 4: LOAD DATA INTO TABLE
-- ========================================

-- Deepak's load customer data
COPY INTO deepak_customer_db.public.customers
FROM @deepak_manage_db.external_stages.customer_data_stage
FILES = ('customers.csv')
ON_ERROR = 'CONTINUE';

-- Deepak's verification
SELECT COUNT(*) as total_customers FROM customers;

-- Deepak's sample data
SELECT * FROM customers LIMIT 10;

-- Deepak's sample output:
-- customer_id | first_name | last_name | email                  | gender | job_title       | phone          | salary    | department
-- 1           | Rajesh     | Kumar     | rajesh.k@company.com   | Male   | DATA SCIENTIST  | 91-9876543210  | 125000.00 | Analytics
-- 2           | Priya      | Sharma    | priya.s@company.com    | Female | ENGINEER        | 91-8765432109  | 95000.00  | Engineering
-- 3           | Michael    | Chen      | michael.c@company.com  | Male   | MANAGER         | 65-91234567    | 110000.00 | Sales

-- Deepak's observation: Data loaded successfully!


-- ========================================
-- STEP 5: CREATE REGULAR VIEW
-- ========================================

-- Deepak's regular view (excludes data scientists)
CREATE OR REPLACE VIEW customer_view_regular AS
SELECT
  customer_id,
  first_name,
  last_name,
  email,
  department
FROM deepak_customer_db.public.customers
WHERE job_title != 'DATA SCIENTIST'
  AND salary < 100000;

-- Deepak's observation: Regular view created!
-- Business logic: Hide data scientists and high earners


-- ========================================
-- STEP 6: GRANT PERMISSIONS ON REGULAR VIEW
-- ========================================

-- Deepak's create analyst role
CREATE OR REPLACE ROLE deepak_analyst_role;

-- Deepak's grant database and schema usage
GRANT USAGE ON DATABASE deepak_customer_db TO ROLE deepak_analyst_role;
GRANT USAGE ON SCHEMA deepak_customer_db.public TO ROLE deepak_analyst_role;

-- Deepak's grant SELECT on view
GRANT SELECT ON VIEW deepak_customer_db.public.customer_view_regular TO ROLE deepak_analyst_role;

-- Deepak's grant warehouse
GRANT USAGE ON WAREHOUSE deepak_compute_wh TO ROLE deepak_analyst_role;

-- Deepak's assign role to user
GRANT ROLE deepak_analyst_role TO USER DEEPAKSINGH;

-- Deepak's observation: Analyst can query view!


-- ========================================
-- STEP 7: QUERY REGULAR VIEW
-- ========================================

-- Deepak's switch to analyst role
USE ROLE deepak_analyst_role;

-- Deepak's query view
SELECT * FROM deepak_customer_db.public.customer_view_regular
ORDER BY customer_id
LIMIT 10;

-- Deepak's observation: Only non-data-scientists with salary < 100K visible!


-- ========================================
-- STEP 8: SHOW REGULAR VIEW DEFINITION
-- ========================================

-- Deepak's show views
SHOW VIEWS LIKE '%CUSTOMER%' IN DATABASE deepak_customer_db;

-- Deepak's observation: Regular view shows:
-- - is_secure: FALSE
-- - Definition is visible!

-- Deepak's get view definition
GET_DDL('VIEW', 'deepak_customer_db.public.customer_view_regular');

-- Deepak's observation: PROBLEM! View definition is exposed!
-- Analysts can see the WHERE clause and business logic!


-- ========================================
-- STEP 9: SECURITY ISSUE WITH REGULAR VIEWS
-- ========================================

/*
Deepak's Security Problem with Regular Views:

1. DEFINITION VISIBILITY:
   - Users can see view definition
   - Business logic exposed (WHERE job_title != 'DATA SCIENTIST')
   - Filter conditions visible (salary < 100000)
   - Reveals what data is being hidden

2. QUERY OPTIMIZATION LEAKS:
   - Snowflake optimizer may expose filtered data
   - Query plans can reveal hidden values
   - Potential data leakage through optimization

3. EXAMPLE LEAK:
   - User knows data scientists are filtered
   - User knows salary threshold is 100K
   - Sensitive business logic exposed
*/


-- ========================================
-- STEP 10: CREATE SECURE VIEW
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's secure view (same logic, but secure!)
CREATE OR REPLACE SECURE VIEW customer_view_secure AS
SELECT
  customer_id,
  first_name,
  last_name,
  email,
  department
FROM deepak_customer_db.public.customers
WHERE job_title != 'DATA SCIENTIST'
  AND salary < 100000;

-- Deepak's observation: SECURE keyword added!


-- ========================================
-- STEP 11: GRANT PERMISSIONS ON SECURE VIEW
-- ========================================

-- Deepak's grant SELECT on secure view
GRANT SELECT ON VIEW deepak_customer_db.public.customer_view_secure TO ROLE deepak_analyst_role;

-- Deepak's observation: Same permissions as regular view!


-- ========================================
-- STEP 12: QUERY SECURE VIEW
-- ========================================

-- Deepak's switch to analyst role
USE ROLE deepak_analyst_role;

-- Deepak's query secure view
SELECT * FROM deepak_customer_db.public.customer_view_secure
ORDER BY customer_id
LIMIT 10;

-- Deepak's observation: Same data as regular view!
-- But definition is hidden!


-- ========================================
-- STEP 13: TRY TO VIEW SECURE VIEW DEFINITION
-- ========================================

-- Deepak's try to get DDL
-- GET_DDL('VIEW', 'deepak_customer_db.public.customer_view_secure');

-- Deepak's observation: FAILS! Access denied!
-- Error: "Insufficient privileges to operate on view 'CUSTOMER_VIEW_SECURE'"

-- Deepak's observation: Definition is protected!


-- ========================================
-- STEP 14: COMPARE VIEWS
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's show all views
SHOW VIEWS LIKE '%CUSTOMER%' IN DATABASE deepak_customer_db;

-- Deepak's observation: Compare is_secure column:
-- - customer_view_regular: is_secure = FALSE
-- - customer_view_secure: is_secure = TRUE


-- ========================================
-- STEP 15: VIEW DEFINITION AS ADMIN
-- ========================================

-- Deepak's get regular view DDL
SELECT GET_DDL('VIEW', 'deepak_customer_db.public.customer_view_regular');

-- Deepak's observation: Definition visible to admin!

-- Deepak's get secure view DDL
SELECT GET_DDL('VIEW', 'deepak_customer_db.public.customer_view_secure');

-- Deepak's observation: Definition visible to admin (owner)!
-- But NOT to regular users!


-- ========================================
-- STEP 16: CREATE SECURE VIEW WITH JOINS
-- ========================================

-- Deepak's create department table
CREATE OR REPLACE TABLE departments (
  department_id INT,
  department_name STRING,
  budget NUMBER(12,2),
  is_confidential BOOLEAN
);

-- Deepak's insert sample departments
INSERT INTO departments VALUES
  (1, 'Engineering', 5000000.00, FALSE),
  (2, 'Analytics', 3000000.00, TRUE),
  (3, 'Sales', 4000000.00, FALSE),
  (4, 'HR', 2000000.00, TRUE);

-- Deepak's secure view with join
CREATE OR REPLACE SECURE VIEW customer_department_view AS
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  c.department,
  d.department_name,
  d.budget
FROM deepak_customer_db.public.customers c
JOIN deepak_customer_db.public.departments d
  ON c.department = d.department_name
WHERE d.is_confidential = FALSE;

-- Deepak's observation: Hides confidential departments!


-- ========================================
-- STEP 17: GRANT AND TEST JOINED SECURE VIEW
-- ========================================

-- Deepak's grant access
GRANT SELECT ON VIEW deepak_customer_db.public.customer_department_view TO ROLE deepak_analyst_role;

-- Deepak's test
USE ROLE deepak_analyst_role;

SELECT * FROM deepak_customer_db.public.customer_department_view
LIMIT 10;

-- Deepak's observation: Only non-confidential departments visible!
-- Business logic (is_confidential filter) is hidden!


-- ========================================
-- STEP 18: PERFORMANCE CONSIDERATIONS
-- ========================================

/*
Deepak's Performance Notes:

REGULAR VIEWS:
- Query optimizer can push down predicates
- Better performance optimization
- Faster queries in some cases
- Definition visible

SECURE VIEWS:
- Limited query optimization
- Optimizer cannot expose filtered data
- May be slightly slower
- Definition hidden

Trade-off: Security vs Performance
- Use secure views for sensitive logic
- Use regular views for non-sensitive data
*/


-- ========================================
-- STEP 19: CREATE SECURE VIEW WITH MASKING
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's secure view with inline masking
CREATE OR REPLACE SECURE VIEW customer_masked_view AS
SELECT
  customer_id,
  first_name,
  last_name,
  CASE
    WHEN CURRENT_ROLE() = 'ACCOUNTADMIN' THEN email
    ELSE CONCAT(LEFT(email, 3), '***@***', SPLIT_PART(email, '@', -1))
  END AS email,
  department
FROM deepak_customer_db.public.customers
WHERE job_title != 'DATA SCIENTIST';

-- Deepak's observation: Combines secure view + inline masking!


-- ========================================
-- STEP 20: TEST SECURE VIEW WITH MASKING
-- ========================================

-- Deepak's grant access
GRANT SELECT ON VIEW deepak_customer_db.public.customer_masked_view TO ROLE deepak_analyst_role;

-- Deepak's test as analyst
USE ROLE deepak_analyst_role;

SELECT * FROM deepak_customer_db.public.customer_masked_view
LIMIT 5;

-- Deepak's observation: Email masked AND definition hidden!
-- Double security!


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. REGULAR VIEWS
   - Definition visible to users
   - Query optimization enabled
   - Better performance
   - Business logic exposed
   - Use for non-sensitive data

2. SECURE VIEWS
   - Definition hidden from users
   - Limited query optimization
   - Slightly slower performance
   - Business logic protected
   - Use for sensitive data

3. WHEN TO USE SECURE VIEWS
   ✅ Hiding sensitive business logic
   ✅ Protecting filter conditions
   ✅ Concealing data relationships
   ✅ Compliance requirements
   ✅ Multi-tenant applications
   ✅ Shared data scenarios

4. WHEN TO USE REGULAR VIEWS
   ✅ Non-sensitive transformations
   ✅ Performance-critical queries
   ✅ Internal use only
   ✅ No security concerns
   ✅ Simple aggregations

5. SECURITY BENEFITS
   - Definition not visible via GET_DDL
   - Query plans don't expose logic
   - Prevents reverse engineering
   - Protects intellectual property
   - Compliance (GDPR, HIPAA, etc.)

6. PERFORMANCE TRADE-OFFS
   - Secure views: Limited optimization
   - Regular views: Full optimization
   - Impact usually minimal
   - Test performance in production
   - Monitor query times

7. COMBINING WITH MASKING
   - Secure views + masking policies
   - Secure views + inline masking
   - Double layer of security
   - Best practice for PII
   - Comprehensive protection

8. ACCESS CONTROL
   - Grant SELECT on view
   - Users don't need base table access
   - Principle of least privilege
   - Simplified permission management
   - Audit trail

9. BEST PRACTICES
   ✅ Use SECURE for sensitive logic
   ✅ Document view purpose
   ✅ Test performance impact
   ✅ Combine with masking for PII
   ✅ Regular access reviews
   ✅ Monitor view usage
   ✅ Version control definitions

10. COMMON USE CASES
    - Multi-tenant data isolation
    - Row-level security
    - Column filtering
    - Sensitive calculations
    - Compliance reporting
    - Data sharing

11. LIMITATIONS
    - Cannot see definition (even as owner)
    - Limited query optimization
    - Slightly higher compute cost
    - Cannot use in some optimizations
    - Trade-off for security

12. MONITORING
    - SHOW VIEWS: Check is_secure flag
    - Query history: Monitor usage
    - Performance metrics: Track speed
    - Access logs: Audit access
    - Regular reviews

Secure views are essential for protecting sensitive business logic!
*/

-- Deepak's Summary:
-- Secure views hide definitions and prevent optimization leaks,
-- essential for protecting sensitive business logic and data!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Secure views mastered!
===========================================
*/



