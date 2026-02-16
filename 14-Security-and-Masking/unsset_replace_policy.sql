/*
===========================================
DEEPAK'S UNSET & REPLACE MASKING POLICIES
===========================================
Topic: Advanced Policy Management - Unset, Replace, Drop
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Applying policies to multiple columns
- Dropping and replacing policies
- Policy reference tracking
- Safe policy replacement workflow
- Policy lifecycle management
===========================================
*/

-- Deepak's Note: Advanced policy management techniques!
-- Learn to safely replace, drop, and manage policies in production


-- ========================================
-- PREREQUISITE: SETUP
-- ========================================

-- Deepak's use admin role
USE ROLE ACCOUNTADMIN;

-- Deepak's verify database exists
USE DATABASE deepak_customer_db;
USE SCHEMA public;

-- Deepak's observation: Assumes customers table and policies exist!


-- ========================================
-- PART 1: APPLY POLICY TO MULTIPLE COLUMNS
-- ========================================

-- Deepak's observation: One policy can be applied to multiple columns!


-- ========================================
-- STEP 1: CREATE GENERIC MASKING POLICY
-- ========================================

-- Deepak's generic PII masking policy
CREATE OR REPLACE MASKING POLICY generic_pii_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE CONCAT(LEFT(val, 2), '*******')
    END;

-- Deepak's observation: Shows first 2 characters, masks rest!


-- ========================================
-- STEP 2: APPLY TO MULTIPLE COLUMNS
-- ========================================

-- Deepak's apply to full_name column
ALTER TABLE customers MODIFY COLUMN full_name
SET MASKING POLICY generic_pii_mask;

-- Deepak's apply to email column
ALTER TABLE customers MODIFY COLUMN email
SET MASKING POLICY generic_pii_mask;

-- Deepak's observation: Same policy applied to 2 different columns!


-- ========================================
-- STEP 3: TEST MULTI-COLUMN MASKING
-- ========================================

-- Deepak's test with masked role
USE ROLE deepak_analyst_masked;

SELECT
  customer_id,
  full_name,
  email
FROM customers
ORDER BY customer_id
LIMIT 5;

-- Deepak's observation: Both columns masked with same pattern!
-- Sample output:
-- customer_id | full_name   | email
-- 1001        | Ra*******   | ra*******
-- 1002        | Pr*******   | pr*******


-- ========================================
-- STEP 4: SHOW POLICY REFERENCES
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's check which columns use generic_pii_mask
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'generic_pii_mask'
));

-- Deepak's observation: Shows both full_name and email columns!
-- Sample output:
-- POLICY_DB | POLICY_SCHEMA | POLICY_NAME        | REF_DATABASE_NAME    | REF_SCHEMA_NAME | REF_ENTITY_NAME | REF_COLUMN_NAME
-- DEEPAK... | PUBLIC        | GENERIC_PII_MASK   | DEEPAK_CUSTOMER_DB   | PUBLIC          | CUSTOMERS       | FULL_NAME
-- DEEPAK... | PUBLIC        | GENERIC_PII_MASK   | DEEPAK_CUSTOMER_DB   | PUBLIC          | CUSTOMERS       | EMAIL


-- ========================================
-- PART 2: REPLACE POLICY (SAFE METHOD)
-- ========================================

-- Deepak's observation: To replace a policy, must unset from all columns first!


-- ========================================
-- STEP 5: LIST ALL POLICIES
-- ========================================

-- Deepak's show all masking policies
SHOW MASKING POLICIES;

-- Deepak's observation: See all policies in database!


-- ========================================
-- STEP 6: DESCRIBE POLICY BEFORE CHANGE
-- ========================================

-- Deepak's describe current policy
DESC MASKING POLICY generic_pii_mask;

-- Deepak's observation: Document current definition before changing!


-- ========================================
-- STEP 7: UNSET FROM ALL COLUMNS
-- ========================================

-- Deepak's unset from full_name
ALTER TABLE customers MODIFY COLUMN full_name
UNSET MASKING POLICY;

-- Deepak's unset from email
ALTER TABLE customers MODIFY COLUMN email
UNSET MASKING POLICY;

-- Deepak's observation: Policy removed from all columns!


-- ========================================
-- STEP 8: VERIFY NO REFERENCES
-- ========================================

-- Deepak's check policy references (should be empty)
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'generic_pii_mask'
));

-- Deepak's observation: No rows returned - policy not in use!


-- ========================================
-- STEP 9: DROP OLD POLICY
-- ========================================

-- Deepak's drop the policy
DROP MASKING POLICY generic_pii_mask;

-- Deepak's observation: Policy deleted!


-- ========================================
-- STEP 10: CREATE NEW POLICY (IMPROVED)
-- ========================================

-- Deepak's create improved policy with better masking
CREATE OR REPLACE MASKING POLICY generic_pii_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      WHEN CURRENT_ROLE() = 'DEEPAK_DATA_SCIENTIST' THEN CONCAT(LEFT(val, 3), '***', RIGHT(val, 3))
      ELSE CONCAT(LEFT(val, 2), '*******')
    END;

-- Deepak's observation: Now includes data scientist role with partial visibility!


-- ========================================
-- STEP 11: RE-APPLY NEW POLICY
-- ========================================

-- Deepak's apply to full_name
ALTER TABLE customers MODIFY COLUMN full_name
SET MASKING POLICY generic_pii_mask;

-- Deepak's apply to email
ALTER TABLE customers MODIFY COLUMN email
SET MASKING POLICY generic_pii_mask;

-- Deepak's observation: New policy applied!


-- ========================================
-- STEP 12: TEST NEW POLICY
-- ========================================

-- Deepak's test with data scientist role
USE ROLE deepak_data_scientist;

SELECT
  customer_id,
  full_name,
  email
FROM customers
LIMIT 3;

-- Deepak's observation: Data scientists see first 3 and last 3 chars!
-- Sample output:
-- customer_id | full_name      | email
-- 1001        | Raj***mar      | raj***com
-- 1002        | Pri***rma      | pri***com


-- ========================================
-- PART 3: CREATE OR REPLACE PATTERN
-- ========================================

-- Deepak's observation: CREATE OR REPLACE is easier but has limitations!


-- ========================================
-- STEP 13: CREATE OR REPLACE (WHEN NO REFERENCES)
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's create new policy for phone numbers
CREATE OR REPLACE MASKING POLICY phone_number_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE '***-***-****'
    END;

-- Deepak's observation: Policy created!


-- ========================================
-- STEP 14: APPLY PHONE POLICY
-- ========================================

-- Deepak's apply to phone column
ALTER TABLE customers MODIFY COLUMN phone
SET MASKING POLICY phone_number_mask;

-- Deepak's test
USE ROLE deepak_analyst_masked;
SELECT customer_id, phone FROM customers LIMIT 3;


-- ========================================
-- STEP 15: TRY CREATE OR REPLACE (WITH REFERENCES)
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's try to replace policy that's in use
-- CREATE OR REPLACE MASKING POLICY phone_number_mask
--   AS (val VARCHAR) RETURNS VARCHAR ->
--     CASE
--       WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
--       ELSE '##-##-####'
--     END;

-- Deepak's observation: This will FAIL if policy is applied to columns!
-- Error: "Cannot replace masking policy 'PHONE_NUMBER_MASK' because it is associated with one or more entities"


-- ========================================
-- STEP 16: SAFE REPLACEMENT WORKFLOW
-- ========================================

-- Deepak's step 1: Unset from all columns
ALTER TABLE customers MODIFY COLUMN phone
UNSET MASKING POLICY;

-- Deepak's step 2: Replace policy
CREATE OR REPLACE MASKING POLICY phone_number_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE '##-##-####'
    END;

-- Deepak's step 3: Re-apply policy
ALTER TABLE customers MODIFY COLUMN phone
SET MASKING POLICY phone_number_mask;

-- Deepak's observation: Safe replacement complete!


-- ========================================
-- STEP 17: CREATE MULTIPLE SPECIALIZED POLICIES
-- ========================================

-- Deepak's email-specific policy
CREATE OR REPLACE MASKING POLICY email_specific_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE CONCAT(LEFT(val, 3), '***@***', SPLIT_PART(SPLIT_PART(val, '@', -1), '.', -1))
    END;

-- Deepak's name-specific policy
CREATE OR REPLACE MASKING POLICY name_specific_mask
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
      WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
      ELSE CONCAT(LEFT(val, 1), '*** ', SPLIT_PART(val, ' ', -1))
    END;

-- Deepak's observation: Specialized policies for different data types!


-- ========================================
-- STEP 18: REPLACE GENERIC WITH SPECIFIC
-- ========================================

-- Deepak's unset generic policy from email
ALTER TABLE customers MODIFY COLUMN email
UNSET MASKING POLICY;

-- Deepak's apply email-specific policy
ALTER TABLE customers MODIFY COLUMN email
SET MASKING POLICY email_specific_mask;

-- Deepak's unset generic policy from full_name
ALTER TABLE customers MODIFY COLUMN full_name
UNSET MASKING POLICY;

-- Deepak's apply name-specific policy
ALTER TABLE customers MODIFY COLUMN full_name
SET MASKING POLICY name_specific_mask;

-- Deepak's observation: Replaced generic with specialized policies!


-- ========================================
-- STEP 19: VALIDATE ALL POLICIES
-- ========================================

-- Deepak's test with full access role
USE ROLE deepak_analyst_full;

SELECT * FROM customers
ORDER BY customer_id
LIMIT 3;

-- Deepak's observation: Full data visible!


-- Deepak's test with masked role
USE ROLE deepak_analyst_masked;

SELECT * FROM customers
ORDER BY customer_id
LIMIT 3;

-- Deepak's observation: All PII masked with specialized policies!
-- Sample output:
-- customer_id | full_name   | email           | phone       | credit_card
-- 1001        | R*** Kumar  | raj***@***com   | ##-##-####  | ****-****-****-9012
-- 1002        | P*** Sharma | pri***@***com   | ##-##-####  | ****-****-****-1098


-- ========================================
-- STEP 20: FINAL POLICY INVENTORY
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's show all policies
SHOW MASKING POLICIES;

-- Deepak's describe each policy
DESC MASKING POLICY email_specific_mask;
DESC MASKING POLICY name_specific_mask;
DESC MASKING POLICY phone_number_mask;

-- Deepak's check all policy references
SELECT
  POLICY_NAME,
  REF_ENTITY_NAME,
  REF_COLUMN_NAME
FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  REF_ENTITY_NAME => 'customers'
))
ORDER BY REF_COLUMN_NAME;

-- Deepak's observation: Complete policy inventory documented!


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. APPLYING POLICIES TO MULTIPLE COLUMNS
   - One policy can protect multiple columns
   - Consistent masking across columns
   - Easier maintenance
   - Less policy proliferation
   - Use for similar data types

2. POLICY REFERENCES
   - POLICY_REFERENCES() shows where policy is used
   - Check before dropping/replacing
   - Essential for impact analysis
   - Audit trail
   - Documentation

3. DROPPING POLICIES
   - Must unset from all columns first
   - DROP MASKING POLICY <name>
   - Cannot drop if in use
   - Permanent deletion
   - Use carefully!

4. REPLACING POLICIES (SAFE WORKFLOW)
   Step 1: Check references (POLICY_REFERENCES)
   Step 2: Unset from all columns
   Step 3: DROP or CREATE OR REPLACE
   Step 4: Re-apply to columns
   Step 5: Test with all roles

5. CREATE OR REPLACE LIMITATIONS
   - Cannot replace if policy is in use
   - Must unset first
   - Error message is clear
   - Use ALTER instead for in-use policies
   - Or follow safe workflow

6. GENERIC VS SPECIALIZED POLICIES
   - Generic: One policy for multiple data types
   - Specialized: Custom policy per data type
   - Trade-off: Simplicity vs Precision
   - Start generic, specialize as needed
   - Document policy purpose

7. POLICY LIFECYCLE
   - Create: Define masking logic
   - Apply: Attach to columns
   - Monitor: Check effectiveness
   - Modify: Alter as needed
   - Replace: Safe replacement workflow
   - Drop: Remove when obsolete

8. TESTING STRATEGY
   - Test with all roles
   - Verify each column
   - Check edge cases
   - Validate business logic
   - User acceptance testing
   - Document test results

9. POLICY INVENTORY MANAGEMENT
   - SHOW MASKING POLICIES: List all
   - DESC MASKING POLICY: View definition
   - POLICY_REFERENCES: Find usage
   - Regular audits
   - Documentation
   - Version control

10. BEST PRACTICES
    ✅ Check references before dropping
    ✅ Follow safe replacement workflow
    ✅ Test after every change
    ✅ Document all policies
    ✅ Use descriptive policy names
    ✅ Regular policy reviews
    ✅ Minimize policy count
    ✅ Version control definitions

11. COMMON SCENARIOS
    - Upgrading masking logic
    - Adding new roles
    - Changing compliance requirements
    - Consolidating policies
    - Specializing generic policies
    - Removing obsolete policies

12. TROUBLESHOOTING
    - "Cannot drop policy": Check POLICY_REFERENCES
    - "Cannot replace policy": Unset first
    - Unexpected masking: Check CURRENT_ROLE()
    - Missing masking: Verify policy applied
    - Wrong masking: Review policy logic

13. PRODUCTION CONSIDERATIONS
    - Change windows
    - Rollback plan
    - Communication to users
    - Testing in dev first
    - Monitoring after changes
    - Audit trail

14. POLICY NAMING CONVENTIONS
    - Descriptive names (email_mask, phone_mask)
    - Include data type or purpose
    - Consistent naming scheme
    - Avoid generic names
    - Document naming standards

Advanced policy management ensures secure and maintainable data protection!
*/

-- Deepak's Summary:
-- Safely managing policy lifecycle requires careful planning,
-- checking references, and thorough testing!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Advanced policy management mastered!
===========================================
*/
