/*
===========================================
DEEPAK'S CUSTOM ROLES & PRIVILEGES PRACTICE
===========================================
Topic: Role-Based Access Control (RBAC) in Action
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Custom roles enable fine-grained access control
- Privileges must be granted at database, schema, and table levels
- Users can only perform operations they have privileges for
- Testing privileges is crucial for security
===========================================
*/

-- Deepak's Note: This demonstrates real-world RBAC implementation
-- We'll create a customer table and control access with custom roles


-- ========================================
-- SETUP: SWITCH TO SALES_ADMIN ROLE
-- ========================================

USE ROLE sales_admin;
USE DATABASE deepak_sales_db;

-- Deepak's observation: sales_admin owns this database
-- So we can create tables and manage all objects


-- ========================================
-- CREATE CUSTOMER TABLE
-- ========================================

-- Deepak's scenario: Building a customer analytics table
CREATE OR REPLACE TABLE customers (
  customer_id NUMBER AUTOINCREMENT START 1 INCREMENT 1,
  full_name VARCHAR(100),
  email VARCHAR(150),
  phone VARCHAR(20),
  total_spent NUMBER(10,2),
  customer_since DATE DEFAULT CURRENT_DATE,
  region VARCHAR(50),
  PRIMARY KEY (customer_id)
);

-- Deepak's note: Using realistic customer data for e-commerce analytics


-- ========================================
-- INSERT SAMPLE CUSTOMER DATA
-- ========================================

-- Deepak's learning: Populating with diverse, realistic customer data
INSERT INTO customers (full_name, email, phone, total_spent, customer_since, region)
VALUES
  ('Rajesh Kumar', 'rajesh.kumar@email.com', '+91-98765-43210', 15420.50, '2024-03-15', 'India'),
  ('Emily Watson', 'emily.watson@email.com', '+1-555-0123', 8750.25, '2024-06-22', 'North America'),
  ('Carlos Rodriguez', 'carlos.r@email.com', '+52-555-1234', 12300.00, '2023-11-08', 'Latin America'),
  ('Yuki Tanaka', 'yuki.tanaka@email.com', '+81-3-1234-5678', 22150.75, '2023-09-12', 'Asia Pacific'),
  ('Fatima Al-Said', 'fatima.alsaid@email.com', '+971-4-123-4567', 9875.00, '2024-01-20', 'Middle East'),
  ('Sophie Martin', 'sophie.martin@email.com', '+33-1-23-45-67-89', 18600.50, '2024-04-10', 'Europe');

-- Deepak's observation: Diverse international customer base

SHOW TABLES;

-- Verify data insertion
SELECT * FROM customers ORDER BY total_spent DESC;


-- ========================================
-- GRANT PRIVILEGES TO SALES_USERS
-- ========================================

-- Deepak's learning: Granting minimal necessary privileges
-- sales_users need to query data but not modify it

USE ROLE sales_admin;

-- Grant database and schema access
GRANT USAGE ON DATABASE deepak_sales_db TO ROLE sales_users;
GRANT USAGE ON SCHEMA deepak_sales_db.public TO ROLE sales_users;

-- Grant SELECT privilege on customers table
GRANT SELECT ON TABLE deepak_sales_db.public.customers TO ROLE sales_users;

-- Deepak's note: sales_users can now read customer data but cannot modify it


-- ========================================
-- TEST PRIVILEGES AS SALES_USERS
-- ========================================

-- Deepak's experiment: Testing what sales_users can and cannot do
USE ROLE sales_users;

-- This should work: SELECT privilege granted
SELECT * FROM customers WHERE region = 'India';

-- Deepak's test: Try to drop table (should fail - no DROP privilege)
-- DROP TABLE customers;  -- Uncomment to test - will fail with permission error

-- Deepak's test: Try to delete data (should fail - no DELETE privilege)
-- DELETE FROM customers WHERE customer_id = 1;  -- Will fail

SHOW TABLES;

-- Deepak's observation: sales_users can see tables but cannot modify them


-- ========================================
-- GRANT DELETE PRIVILEGE
-- ========================================

-- Deepak's scenario: Sales team needs to remove duplicate/test records
USE ROLE sales_admin;

GRANT DELETE ON TABLE deepak_sales_db.public.customers TO ROLE sales_users;

-- Deepak's note: Now sales_users can delete records but still cannot drop table


-- ========================================
-- VERIFY ENHANCED PRIVILEGES
-- ========================================

USE ROLE sales_users;

-- Now this should work
DELETE FROM customers WHERE customer_id = 999;  -- Safe: ID doesn't exist

-- Deepak's observation: DELETE works now, but DROP TABLE still fails
-- This demonstrates fine-grained privilege control


-- Return to admin role
USE ROLE sales_admin;


/*
DEEPAK'S RBAC IMPLEMENTATION SUMMARY:
====================================

Privilege Hierarchy Demonstrated:
1. Database USAGE - Required to access database
2. Schema USAGE - Required to access schema
3. Table SELECT - Required to query data
4. Table DELETE - Required to remove rows
5. Table DROP - Required to delete table (NOT granted)

Sales Roles Access Matrix:
┌─────────────────┬──────────────┬──────────────┐
│ Operation       │ sales_admin  │ sales_users  │
├─────────────────┼──────────────┼──────────────┤
│ CREATE TABLE    │ ✅           │ ❌           │
│ SELECT          │ ✅           │ ✅           │
│ INSERT          │ ✅           │ ❌           │
│ UPDATE          │ ✅           │ ❌           │
│ DELETE          │ ✅           │ ✅ (granted) │
│ DROP TABLE      │ ✅           │ ❌           │
│ GRANT PRIVILEGE │ ✅           │ ❌           │
└─────────────────┴──────────────┴──────────────┘

Security Best Practices:
- Grant minimum necessary privileges
- Test privileges before deploying to production
- Document all privilege grants
- Regular audit of role privileges
- Use role hierarchy for easier management

Real-World Application:
- Analysts get SELECT only
- Data engineers get INSERT/UPDATE/DELETE
- Admins get full control including DROP
- Separate roles for different teams/functions

Practiced: February 2026
Status: ✅ Completed - Understanding RBAC implementation
*/