/*
===========================================
DEEPAK'S TABLE CLONING PRACTICE
===========================================
Topic: Zero-Copy Table Cloning
Date Practiced: February 13, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Table cloning creates instant independent copies
- Clones don't affect original table
- Changes to clone don't impact source
- Temporary tables CANNOT be cloned
===========================================
*/

-- Deepak's Note: Table cloning is perfect for testing and development
-- Creates instant snapshot without copying data


-- ========================================
-- CLONE A PRODUCTION TABLE
-- ========================================

-- View original customer data
SELECT * FROM deepak_analytics_db.public.customers
ORDER BY customer_id
LIMIT 10;

-- Deepak's scenario: Clone production table for testing
CREATE TABLE deepak_analytics_db.public.customers_test
CLONE deepak_analytics_db.public.customers
COMMENT = 'Deepak - Test clone of customer table';

-- Deepak's observation: Clone created instantly, no wait time!


-- Validate cloned data matches original
SELECT COUNT(*) AS clone_count FROM deepak_analytics_db.public.customers_test;
SELECT COUNT(*) AS original_count FROM deepak_analytics_db.public.customers;

-- Deepak's learning: Both tables have identical data


-- ========================================
-- TEST MODIFICATIONS ON CLONE
-- ========================================

-- Deepak's experiment: Modify clone to test data anonymization
UPDATE deepak_analytics_db.public.customers_test
SET email = CONCAT('test_', customer_id, '@example.com'),
    phone = 'XXX-XXX-XXXX'
WHERE customer_id <= 100;

-- Deepak's note: Testing data masking logic on clone


-- Verify original table is unchanged
SELECT customer_id, full_name, email, phone
FROM deepak_analytics_db.public.customers
WHERE customer_id <= 5;

-- Deepak's observation: Original data intact! ✅


-- Verify clone has modifications
SELECT customer_id, full_name, email, phone
FROM deepak_analytics_db.public.customers_test
WHERE customer_id <= 5;

-- Deepak's learning: Clone is truly independent


-- ========================================
-- CLONING LIMITATIONS
-- ========================================

-- Deepak's experiment: Try to clone a temporary table
CREATE OR REPLACE TEMPORARY TABLE deepak_analytics_db.public.temp_test (
  id INT,
  test_value STRING
);

INSERT INTO deepak_analytics_db.public.temp_test VALUES (1, 'test');

-- Deepak's note: This will FAIL - temporary tables cannot be cloned
-- CREATE TEMPORARY TABLE deepak_analytics_db.public.temp_clone
-- CLONE deepak_analytics_db.public.temp_test;

-- Error: Temporary tables do not support cloning

-- Deepak's learning: Only permanent and transient tables can be cloned


/*
DEEPAK'S TABLE CLONING INSIGHTS:
=================================

Zero-Copy Cloning Benefits:
✅ Instant table copy (metadata only)
✅ No storage cost initially
✅ Independent from source table
✅ Perfect for testing changes
✅ Safe experimentation environment

What Can Be Cloned:
✅ Permanent tables
✅ Transient tables
✅ Tables with data
✅ Empty tables
❌ Temporary tables (NOT supported)
❌ External tables (NOT supported)

Common Use Cases:
1. Testing: Clone production for safe testing
2. Development: Give developers sandbox data
3. Debugging: Investigate issues without affecting production
4. Training: Create training environments
5. Reporting: Clone for heavy analytics queries

Storage Behavior:
- Initial clone: Minimal storage (metadata only)
- After modifications: Storage grows for changed data
- Original and clone share unchanged data (zero-copy)
- Monitor storage costs for long-lived clones

Best Practices:
- Name clones clearly (_test, _dev, _backup)
- Document clone purpose and owner
- Set up cleanup process for old clones
- Use for testing before production changes
- Clone before major data transformations

Real-World Workflow:
1. Clone production table
2. Test new transformation logic
3. Verify results on clone
4. Apply to production if successful
5. Drop clone after testing

Practiced: February 2026
Status: ✅ Completed - Understanding table cloning
*/