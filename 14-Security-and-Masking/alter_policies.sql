/*
===========================================
DEEPAK'S ALTERING MASKING POLICIES
===========================================
Topic: Modifying Existing Masking Policies
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐
Key Learnings:
- Altering policy definitions
- Changing masking logic
- Unsetting policies from columns
- Policy versioning
- Testing policy changes
===========================================
*/

-- Deepak's Note: Masking policies can be modified after creation!
-- Learn to update policies and manage policy changes safely


-- ========================================
-- PREREQUISITE: ENSURE POLICIES EXIST
-- ========================================

-- Deepak's observation: This file assumes policies from Create+masking+policy.txt exist!
-- Run that file first if starting fresh

-- Deepak's verify database and table exist
USE DATABASE deepak_customer_db;
USE SCHEMA public;


-- ========================================
-- STEP 1: TEST CURRENT MASKING (BEFORE CHANGES)
-- ========================================

-- Deepak's test with masked role
USE ROLE deepak_analyst_masked;

-- Deepak's query to see current masking
SELECT
  customer_id,
  full_name,
  email,
  phone,
  credit_card
FROM customers
ORDER BY customer_id
LIMIT 5;

-- Deepak's observation: Current masking in effect!
-- Sample output:
-- customer_id | full_name | email           | phone         | credit_card
-- 1001        | *** ***   | raj***@***l.com | ***-***-****  | ****-****-****-9012
-- 1002        | *** ***   | pri***@***l.com | ***-***-****  | ****-****-****-1098


-- ========================================
-- STEP 2: SWITCH TO ADMIN ROLE
-- ========================================

-- Deepak's switch to admin (required to alter policies)
USE ROLE ACCOUNTADMIN;

-- Deepak's observation: Only ACCOUNTADMIN can alter masking policies!


-- ========================================
-- STEP 3: VIEW CURRENT POLICY DEFINITION
-- ========================================

-- Deepak's describe current phone policy
DESC MASKING POLICY phone_mask;

-- Deepak's observation: Shows current policy logic!


-- ========================================
-- STEP 4: ALTER PHONE MASKING POLICY
-- ========================================

-- Deepak's modify phone masking policy
ALTER MASKING POLICY phone_mask SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
    ELSE '**-**-**'
  END;

-- Deepak's observation: Changed masking pattern from '***-***-****' to '**-**-**'!
-- Policy updated immediately for all columns using it


-- ========================================
-- STEP 5: TEST ALTERED POLICY
-- ========================================

-- Deepak's switch to masked role
USE ROLE deepak_analyst_masked;

-- Deepak's query to see new masking
SELECT
  customer_id,
  full_name,
  phone
FROM customers
ORDER BY customer_id
LIMIT 5;

-- Deepak's observation: Phone now shows '**-**-**' instead of '***-***-****'!
-- Sample output:
-- customer_id | full_name | phone
-- 1001        | *** ***   | **-**-**
-- 1002        | *** ***   | **-**-**


-- ========================================
-- STEP 6: ALTER EMAIL POLICY (MORE COMPLEX)
-- ========================================

-- Deepak's switch back to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's modify email policy with enhanced logic
ALTER MASKING POLICY email_mask SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
    WHEN CURRENT_ROLE() = 'DEEPAK_DATA_SCIENTIST' THEN CONCAT(LEFT(val, 5), '***@', SPLIT_PART(val, '@', -1))
    ELSE '***@***.***'
  END;

-- Deepak's observation: Now data scientists see more of email (first 5 chars + domain)!


-- ========================================
-- STEP 7: TEST MULTI-ROLE EMAIL MASKING
-- ========================================

-- Deepak's test with data scientist role
USE ROLE deepak_data_scientist;

SELECT
  customer_id,
  full_name,
  email
FROM customers
ORDER BY customer_id
LIMIT 3;

-- Deepak's observation: Data scientists see 'rajesh***@email.com'!

-- Deepak's test with masked role
USE ROLE deepak_analyst_masked;

SELECT
  customer_id,
  email
FROM customers
LIMIT 3;

-- Deepak's observation: Masked analysts see '***@***.***'!


-- ========================================
-- STEP 8: UNSET MASKING POLICY FROM COLUMN
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's remove email masking policy
ALTER TABLE customers MODIFY COLUMN email
UNSET MASKING POLICY;

-- Deepak's observation: Email column no longer masked!


-- ========================================
-- STEP 9: VERIFY POLICY REMOVED
-- ========================================

-- Deepak's test with masked role
USE ROLE deepak_analyst_masked;

-- Deepak's query email (should be unmasked now)
SELECT
  customer_id,
  email
FROM customers
ORDER BY customer_id
LIMIT 5;

-- Deepak's observation: Email now visible to all roles!
-- Sample output:
-- customer_id | email
-- 1001        | rajesh.kumar@email.com
-- 1002        | priya.sharma@email.com


-- ========================================
-- STEP 10: RE-APPLY POLICY TO COLUMN
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's re-apply email masking
ALTER TABLE customers MODIFY COLUMN email
SET MASKING POLICY email_mask;

-- Deepak's observation: Email masked again!


-- ========================================
-- STEP 11: ALTER CREDIT CARD POLICY
-- ========================================

-- Deepak's modify credit card policy to show more digits
ALTER MASKING POLICY credit_card_mask SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
    ELSE CONCAT(LEFT(val, 4), '-****-****-', RIGHT(val, 4))
  END;

-- Deepak's observation: Now shows first 4 AND last 4 digits!


-- ========================================
-- STEP 12: TEST UPDATED CREDIT CARD MASKING
-- ========================================

-- Deepak's test with masked role
USE ROLE deepak_analyst_masked;

SELECT
  customer_id,
  full_name,
  credit_card
FROM customers
ORDER BY customer_id
LIMIT 5;

-- Deepak's observation: Credit card shows '4532-****-****-9012'!
-- More useful for customer service while still protecting data


-- ========================================
-- STEP 13: ALTER SSN POLICY (CONDITIONAL LOGIC)
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's modify SSN policy with multiple conditions
ALTER MASKING POLICY ssn_mask SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
    WHEN CURRENT_ROLE() = 'DEEPAK_DATA_SCIENTIST' THEN CONCAT('***-**-', RIGHT(val, 4))
    ELSE '***-**-****'
  END;

-- Deepak's observation: Data scientists see last 4, others see nothing!


-- ========================================
-- STEP 14: UNSET MULTIPLE POLICIES
-- ========================================

-- Deepak's remove phone masking
ALTER TABLE customers MODIFY COLUMN phone
UNSET MASKING POLICY;

-- Deepak's remove SSN masking
ALTER TABLE customers MODIFY COLUMN ssn
UNSET MASKING POLICY;

-- Deepak's observation: Multiple columns unmasked!


-- ========================================
-- STEP 15: VERIFY MULTIPLE UNSETS
-- ========================================

-- Deepak's test with masked role
USE ROLE deepak_analyst_masked;

SELECT
  customer_id,
  phone,
  ssn
FROM customers
LIMIT 3;

-- Deepak's observation: Both phone and SSN now visible!


-- ========================================
-- STEP 16: RE-APPLY POLICIES
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's re-apply phone masking
ALTER TABLE customers MODIFY COLUMN phone
SET MASKING POLICY phone_mask;

-- Deepak's re-apply SSN masking
ALTER TABLE customers MODIFY COLUMN ssn
SET MASKING POLICY ssn_mask;

-- Deepak's observation: Policies re-applied!


-- ========================================
-- STEP 17: CHECK POLICY REFERENCES
-- ========================================

-- Deepak's check which columns use phone_mask
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
  POLICY_NAME => 'phone_mask'
));

-- Deepak's observation: Shows all columns using this policy!


-- ========================================
-- STEP 18: ALTER POLICY WITH CONTEXT
-- ========================================

-- Deepak's create context-aware masking
ALTER MASKING POLICY name_mask SET BODY ->
  CASE
    WHEN CURRENT_ROLE() IN ('DEEPAK_ANALYST_FULL', 'ACCOUNTADMIN') THEN val
    WHEN CURRENT_ROLE() = 'DEEPAK_DATA_SCIENTIST' THEN CONCAT(LEFT(val, 1), '*** ', SPLIT_PART(val, ' ', -1))
    WHEN CURRENT_ROLE() = 'DEEPAK_ANALYST_MASKED' THEN CONCAT(LEFT(val, 2), '***')
    ELSE '***'
  END;

-- Deepak's observation: Different masking for different roles!


-- ========================================
-- STEP 19: TEST ROLE-SPECIFIC MASKING
-- ========================================

-- Deepak's test with data scientist
USE ROLE deepak_data_scientist;

SELECT customer_id, full_name FROM customers LIMIT 3;
-- Output: 'R*** Kumar', 'P*** Sharma'

-- Deepak's test with masked analyst
USE ROLE deepak_analyst_masked;

SELECT customer_id, full_name FROM customers LIMIT 3;
-- Output: 'Ra***', 'Pr***'

-- Deepak's observation: Each role sees different masking!


-- ========================================
-- STEP 20: FINAL VERIFICATION
-- ========================================

-- Deepak's switch to admin
USE ROLE ACCOUNTADMIN;

-- Deepak's show all policies
SHOW MASKING POLICIES;

-- Deepak's describe each policy
DESC MASKING POLICY phone_mask;
DESC MASKING POLICY email_mask;
DESC MASKING POLICY credit_card_mask;
DESC MASKING POLICY ssn_mask;
DESC MASKING POLICY name_mask;

-- Deepak's observation: All policies updated and documented!


-- ========================================
-- DEEPAK'S COMPREHENSIVE INSIGHTS
-- ========================================

/*
1. ALTERING POLICIES
   - ALTER MASKING POLICY ... SET BODY
   - Changes apply immediately
   - Affects all columns using the policy
   - No need to reapply to columns
   - Requires ACCOUNTADMIN role

2. POLICY MODIFICATION WORKFLOW
   - Describe current policy
   - Plan new masking logic
   - Alter policy definition
   - Test with all affected roles
   - Document changes

3. UNSETTING POLICIES
   - ALTER TABLE ... MODIFY COLUMN ... UNSET MASKING POLICY
   - Removes masking from column
   - Policy still exists (can reapply)
   - Column becomes visible to all roles
   - Use carefully!

4. RE-APPLYING POLICIES
   - ALTER TABLE ... MODIFY COLUMN ... SET MASKING POLICY
   - Can apply same or different policy
   - Immediate effect
   - Test after reapplying
   - Verify masking works

5. MULTI-ROLE MASKING
   - Different masking per role
   - Use multiple WHEN conditions
   - More granular control
   - Better user experience
   - Principle of least privilege

6. POLICY VERSIONING
   - Document policy changes
   - Test before production
   - Communicate changes to users
   - Rollback plan
   - Change management

7. TESTING STRATEGY
   - Test with all roles
   - Verify expected masking
   - Check edge cases
   - Validate business logic
   - User acceptance testing

8. COMMON ALTERATIONS
   - Change masking pattern
   - Add role-specific logic
   - Adjust visible characters
   - Enhance security
   - Improve usability

9. POLICY MANAGEMENT
   - SHOW MASKING POLICIES: List all
   - DESC MASKING POLICY: View definition
   - POLICY_REFERENCES(): Find usage
   - Regular reviews
   - Audit trail

10. BEST PRACTICES
    ✅ Test in dev before production
    ✅ Document all changes
    ✅ Communicate to stakeholders
    ✅ Version control policy definitions
    ✅ Regular policy reviews
    ✅ Minimize policy changes
    ✅ Test with all roles
    ✅ Have rollback plan

11. WHEN TO ALTER POLICIES
    - Security requirements change
    - New roles added
    - User feedback
    - Compliance updates
    - Business logic changes

12. COMMON PITFALLS
    ❌ Not testing with all roles
    ❌ Changing production without testing
    ❌ Not documenting changes
    ❌ Forgetting to reapply after unset
    ❌ Too frequent changes
    ❌ No rollback plan

Altering policies requires careful planning and testing!
*/

-- Deepak's Summary:
-- Masking policies can be altered to change masking logic,
-- but always test thoroughly before production changes!

/*
===========================================
Practiced: February 14, 2026
Status: ✅ Completed - Policy alteration mastered!
===========================================
*/
