/*
===========================================
DEEPAK'S DATA MASKING POLICIES
===========================================
Topic: Creating and Applying Masking Policies
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Dynamic data masking for PII protection
- Role-based masking policies
- Column-level security
- Policy creation and application
- Testing masking with different roles
===========================================
*/

-- Deepak's Note: Data masking protects sensitive information (PII)!
-- Different roles see different data - powerful security feature!


-- ========================================
-- SETUP: DATABASE AND ROLE
-- ========================================

-- Deepak's customer database
CREATE OR REPLACE DATABASE deepak_customer_db;

USE DATABASE deepak_customer_db;
USE SCHEMA public;

-- Deepak's admin role
USE ROLE ACCOUNTADMIN;

-- Deepak's observation: ACCOUNTADMIN needed to create masking policies!


-- ========================================
-- STEP 1: CREATE CUSTOMER TABLE
-- ========================================

-- Deepak's customer table with PII data
CREATE OR REPLACE TABLE customers (
  customer_id NUMBER,
  full_name VARCHAR,
  email VARCHAR,
  phone VARCHAR,
  credit_card VARCHAR,
  ssn VARCHAR,
  annual_spent NUMBER(10,2),
  membership_tier VARCHAR,
  create_date DATE DEFAULT CURRENT_DATE
);

-- Deepak's observation: Table contains sensitive PII that needs masking!


-- ========================================
-- STEP 2: INSERT SAMPLE DATA
-- ========================================

-- Deepak's customer data with diverse names
INSERT INTO customers (customer_id, full_name, email, phone, credit_card, ssn, annual_spent, membership_tier)
VALUES
  (1001, 'Rajesh Kumar', 'rajesh.kumar@email.com', '91-98765-43210', '4532-1234-5678-9012', '123-45-6789', 125000.00, 'PLATINUM'),
  (1002, 'Priya Sharma', 'priya.sharma@email.com', '91-87654-32109', '5412-9876-5432-1098', '234-56-7890', 85000.00, 'GOLD'),
  (1003, 'Michael Chen', 'michael.chen@email.com', '65-9123-4567', '4716-5555-6666-7777', '345-67-8901', 150000.00, 'PLATINUM'),
  (1004, 'Sarah Johnson', 'sarah.j@email.com', '1-212-555-0123', '3782-8888-9999-0000', '456-78-9012', 45000.00, 'SILVER'),
  (1005, 'Ahmed Hassan', 'ahmed.hassan@email.com', '971-50-123-4567', '6011-1111-2222-3333', '567-89-0123', 95000.00, 'GOLD'),
  (1006, 'Maria Garcia', 'maria.g@email.com', '34-612-345-678', '5105-4444-5555-6666', '678-90-1234', 62000.00, 'SILVER'),
  (1007, 'Yuki Tanaka', 'yuki.tanaka@email.com', '81-90-1234-5678', '4111-7777-8888-9999', '789-01-2345', 110000.00, 'GOLD'),
  (1008, 'David Lee', 'david.lee@email.com', '82-10-9876-5432', '3714-2222-3333-4444', '890-12-3456', 78000.00, 'SILVER'),
  (1009, 'Fatima Al-Sayed', 'fatima.as@email.com', '20-100-123-4567', '6759-5555-6666-7777', '901-23-4567', 135000.00, 'PLATINUM'),
  (1010, 'Carlos Rodriguez', 'carlos.r@email.com', '52-55-1234-5678', '5019-8888-9999-0000', '012-34-5678', 52000.00, 'SILVER');

-- Deepak's verification
SELECT * FROM customers;

-- Deepak's observation: All sensitive data visible - need masking!


-- ========================================
-- STEP 3: CREATE CUSTOM ROLES
-- ========================================

-- Deepak's analyst role with masked data access
CREATE OR REPLACE ROLE deepak_analyst_masked;

-- Deepak's analyst role with full data access
CREATE OR REPLACE ROLE deepak_analyst_full;

-- Deepak's data scientist role (also masked)
CREATE OR REPLACE ROLE deepak_data_scientist;

-- Deepak's observation: Different roles for different access levels!


-- ========================================
-- STEP 4: GRANT TABLE PERMISSIONS
-- ========================================

-- Deepak's grant SELECT to all analyst roles
GRANT SELECT ON TABLE deepak_customer_db.public.customers TO ROLE deepak_analyst_masked;
GRANT SELECT ON TABLE deepak_customer_db.public.customers TO ROLE deepak_analyst_full;
GRANT SELECT ON TABLE deepak_customer_db.public.customers TO ROLE deepak_data_scientist;

-- Deepak's grant schema usage
GRANT USAGE ON DATABASE deepak_customer_db TO ROLE deepak_analyst_masked;
GRANT USAGE ON DATABASE deepak_customer_db TO ROLE deepak_analyst_full;
GRANT USAGE ON DATABASE deepak_customer_db TO ROLE deepak_data_scientist;

GRANT USAGE ON SCHEMA deepak_customer_db.public TO ROLE deepak_analyst_masked;
GRANT USAGE ON SCHEMA deepak_customer_db.public TO ROLE deepak_analyst_full;
GRANT USAGE ON SCHEMA deepak_customer_db.public TO ROLE deepak_data_scientist;

-- Deepak's observation: All roles can access table, but masking will differ!


-- ========================================
-- STEP 5: GRANT WAREHOUSE ACCESS
-- ========================================

-- Deepak's warehouse access for all roles
GRANT USAGE ON WAREHOUSE deepak_compute_wh TO ROLE deepak_analyst_masked;
GRANT USAGE ON WAREHOUSE deepak_compute_wh TO ROLE deepak_analyst_full;
GRANT USAGE ON WAREHOUSE deepak_compute_wh TO ROLE deepak_data_scientist;

-- Deepak's observation: Roles need warehouse to run queries!


-- ========================================
-- STEP 6: ASSIGN ROLES TO USER
-- ========================================

-- Deepak's assign roles to himself
GRANT ROLE deepak_analyst_masked TO USER DEEPAKSINGH;
GRANT ROLE deepak_analyst_full TO USER DEEPAKSINGH;
GRANT ROLE deepak_data_scientist TO USER DEEPAKSINGH;

-- Deepak's observation: User can switch between roles to test masking!


-- ========================================
-- STEP 7: CREATE PHONE MASKING POLICY
-- ========================================

-- Deepak's phone number masking policy
CREATE OR REPLACE MASKING POLICY phone_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE '***-***-****'
    END;

-- Deepak's observation: Full access roles see real data, others see masked!


-- ========================================
-- STEP 8: CREATE EMAIL MASKING POLICY
-- ========================================

-- Deepak's email masking policy
CREATE OR REPLACE MASKING POLICY email_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE CONCAT(LEFT(val, 3), '***@***', RIGHT(val, 4))
    END;

-- Deepak's observation: Partial masking - shows first 3 chars and domain extension!


-- ========================================
-- STEP 9: CREATE CREDIT CARD MASKING POLICY
-- ========================================

-- Deepak's credit card masking policy
CREATE OR REPLACE MASKING POLICY credit_card_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE CONCAT('****-****-****-', RIGHT(val, 4))
    END;

-- Deepak's observation: Shows only last 4 digits (industry standard)!


-- ========================================
-- STEP 10: CREATE SSN MASKING POLICY
-- ========================================

-- Deepak's SSN masking policy
CREATE OR REPLACE MASKING POLICY ssn_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE '***-**-' || RIGHT(val, 4)
    END;

-- Deepak's observation: Shows only last 4 digits of SSN!


-- ========================================
-- STEP 11: CREATE NAME MASKING POLICY
-- ========================================

-- Deepak's name masking policy
CREATE OR REPLACE MASKING POLICY name_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      WHEN CURRENT_ROLE() = 'DEEPAK_DATA_SCIENTIST' THEN CONCAT(LEFT(val, 1), '*** ', SPLIT_PART(val, ' ', -1))
      ELSE '*** ***'
    END;

-- Deepak's observation: Data scientists see first initial + last name!


-- ========================================
-- STEP 12: APPLY MASKING POLICIES
-- ========================================

-- Deepak's apply phone masking
ALTER TABLE customers MODIFY COLUMN phone
SET MASKING POLICY phone_mask;

-- Deepak's apply email masking
ALTER TABLE customers MODIFY COLUMN email
SET MASKING POLICY email_mask;

-- Deepak's apply credit card masking
ALTER TABLE customers MODIFY COLUMN credit_card
SET MASKING POLICY credit_card_mask;

-- Deepak's apply SSN masking
ALTER TABLE customers MODIFY COLUMN ssn
SET MASKING POLICY ssn_mask;

-- Deepak's apply name masking
ALTER TABLE customers MODIFY COLUMN full_name
SET MASKING POLICY name_mask;

-- Deepak's observation: All sensitive columns now protected!


-- ========================================
-- STEP 13: TEST WITH FULL ACCESS ROLE
-- ========================================

-- Deepak's switch to full access role
USE ROLE deepak_analyst_full;

-- Deepak's query as full access analyst
SELECT * FROM deepak_customer_db.public.customers
ORDER BY customer_id;

-- Deepak's observation: All data visible - no masking!
-- Sample output:
-- customer_id | full_name      | email                    | phone            | credit_card           | ssn           | annual_spent
-- 1001        | Rajesh Kumar   | rajesh.kumar@email.com   | 91-98765-43210   | 4532-1234-5678-9012   | 123-45-6789   | 125000.00
-- 1002        | Priya Sharma   | priya.sharma@email.com   | 91-87654-32109   | 5412-9876-5432-1098   | 234-56-7890   | 85000.00


-- ========================================
-- STEP 14: TEST WITH MASKED ROLE
-- ========================================

-- Deepak's switch to masked role
USE ROLE deepak_analyst_masked;

-- Deepak's query as masked analyst
SELECT * FROM deepak_customer_db.public.customers
ORDER BY customer_id;

-- Deepak's observation: Sensitive data masked!
-- Sample output:
-- customer_id | full_name | email           | phone         | credit_card           | ssn           | annual_spent
-- 1001        | *** ***   | raj***@***l.com | ***-***-****  | ****-****-****-9012   | ***-**-6789   | 125000.00
-- 1002        | *** ***   | pri***@***l.com | ***-***-****  | ****-****-****-1098   | ***-**-7890   | 85000.00


-- ========================================
-- STEP 15: TEST WITH DATA SCIENTIST ROLE
-- ========================================

-- Deepak's switch to data scientist role
USE ROLE deepak_data_scientist;

-- Deepak's query as data scientist
SELECT * FROM deepak_customer_db.public.customers
ORDER BY customer_id;

-- Deepak's observation: Partial name visible (first initial + last name)!
-- Sample output:
-- customer_id | full_name   | email           | phone         | credit_card           | ssn           | annual_spent
-- 1001        | R*** Kumar  | raj***@***l.com | ***-***-****  | ****-****-****-9012   | ***-**-6789   | 125000.00
-- 1002        | P*** Sharma | pri***@***l.com | ***-***-****  | ****-****-****-1098   | ***-**-7890   | 85000.00


-- ========================================
-- STEP 16: TEST SPECIFIC COLUMNS
-- ========================================

-- Deepak's back to ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Deepak's test phone masking
SELECT
  customer_id,
  full_name,
  phone
FROM customers
ORDER BY customer_id
LIMIT 5;

-- Deepak's observation: ACCOUNTADMIN sees all data!


-- ========================================
-- STEP 17: DESCRIBE MASKING POLICIES
-- ========================================

-- Deepak's describe phone policy
DESC MASKING POLICY phone_mask;

-- Deepak's observation: Shows policy definition and signature!


-- ========================================
-- STEP 18: SHOW ALL MASKING POLICIES
-- ========================================

-- Deepak's list all policies
SHOW MASKING POLICIES;

-- Deepak's observation: Shows all policies in current database!


-- ========================================
-- STEP 19: CHECK POLICY REFERENCES
-- ========================================

-- Deepak's check where phone_mask is applied
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'phone_mask'
));

-- Deepak's observation: Shows all columns using this policy!


-- ========================================
-- STEP 20: AGGREGATE ANALYSIS WITH MASKING
-- ========================================

-- Deepak's switch to masked role
USE ROLE deepak_analyst_masked;

-- Deepak's aggregate query (works with masked data)
SELECT
  membership_tier,
  COUNT(*) AS customer_count,
  AVG(annual_spent) AS avg_spent,
  SUM(annual_spent) AS total_spent
FROM deepak_customer_db.public.customers
GROUP BY membership_tier
ORDER BY total_spent DESC;

-- Deepak's observation: Analytics work fine with masked PII!
-- Sample output:
-- membership_tier | customer_count | avg_spent  | total_spent
-- PLATINUM        | 3              | 136666.67  | 410000.00
-- GOLD            | 3              | 96666.67   | 290000.00
-- SILVER          | 4              | 59250.00   | 237000.00


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. DATA MASKING BASICS
   - Protects sensitive PII (Personally Identifiable Information)
   - Dynamic masking based on user role
   - Column-level security
   - No data duplication needed
   - Transparent to applications

2. MASKING POLICY STRUCTURE
   - Function that takes column value as input
   - Returns masked or unmasked value
   - Uses CASE statement for role-based logic
   - CURRENT_ROLE() function checks user's role
   - Flexible masking rules

3. COMMON MASKING PATTERNS
   - Full masking: '***-***-****'
   - Partial masking: Show first/last N characters
   - Last 4 digits: Credit cards, SSN
   - Email: Show prefix and domain extension
   - Name: First initial + last name

4. ROLE-BASED ACCESS
   - ACCOUNTADMIN: Always sees unmasked data
   - Full access roles: See real data
   - Masked roles: See masked data
   - Custom logic per role
   - Multiple privilege levels

5. POLICY APPLICATION
   - ALTER TABLE ... MODIFY COLUMN ... SET MASKING POLICY
   - One policy per column
   - Multiple columns can use same policy
   - Policies applied at column level
   - Immediate effect

6. TESTING MASKING
   - Switch roles with USE ROLE
   - Query same table with different roles
   - Verify masking works correctly
   - Test all privilege levels
   - Document expected behavior

7. POLICY MANAGEMENT
   - DESC MASKING POLICY: View policy definition
   - SHOW MASKING POLICIES: List all policies
   - POLICY_REFERENCES(): Find where policy is used
   - Can modify policies (see Alter policies file)
   - Can drop and recreate

8. ANALYTICS WITH MASKING
   - Aggregations work normally
   - GROUP BY, SUM, AVG, COUNT unaffected
   - Only display values are masked
   - Performance impact minimal
   - Business logic unchanged

9. COMPLIANCE BENEFITS
   - GDPR compliance (data privacy)
   - PCI-DSS (credit card protection)
   - HIPAA (healthcare data)
   - SOX (financial data)
   - Audit trail

10. BEST PRACTICES
    ✅ Mask all PII columns
    ✅ Use appropriate masking patterns
    ✅ Test with all roles
    ✅ Document masking policies
    ✅ Regular access reviews
    ✅ Principle of least privilege
    ✅ Monitor policy usage
    ✅ Version control policies

11. COMMON PII TO MASK
    - Phone numbers
    - Email addresses
    - Credit card numbers
    - SSN / National IDs
    - Names (sometimes)
    - Addresses
    - Date of birth
    - Medical records

12. PERFORMANCE CONSIDERATIONS
    - Masking happens at query time
    - Minimal performance impact
    - No storage overhead
    - Scales with data volume
    - Efficient implementation

Data masking is essential for protecting sensitive information!
*/

-- Deepak's Summary:
-- Masking policies provide dynamic, role-based data protection
-- without duplicating data or changing application logic!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Data masking mastered!
===========================================
*/


