/*
===========================================
DEEPAK'S TABLE SWAPPING PRACTICE
===========================================
Topic: Swapping Tables for Zero-Downtime Deployments
Date Practiced: February 13, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- SWAP WITH exchanges table metadata instantly
- Zero-downtime deployment strategy
- Perfect for blue-green deployments
- Atomic operation (all or nothing)
- Works with schemas and databases too
===========================================
*/

-- Deepak's Note: Table swapping is a game-changer for production deployments
-- Allows testing changes in dev, then instantly swapping to production


-- ========================================
-- SETUP: CREATE DEV ENVIRONMENT
-- ========================================

-- Deepak's scenario: Clone production schema to dev for testing
CREATE OR REPLACE TRANSIENT SCHEMA deepak_analytics_db.dev_schema
CLONE deepak_analytics_db.public
COMMENT = 'Deepak - Development schema cloned from production';

-- Deepak's learning: CLONE creates instant copy with zero-copy technology


-- Verify both schemas have same data
SELECT COUNT(*) AS prod_count FROM deepak_analytics_db.public.customers;
SELECT COUNT(*) AS dev_count FROM deepak_analytics_db.dev_schema.customers;

-- Deepak's observation: Both have identical data after cloning


-- ========================================
-- MODIFY DEV TABLE
-- ========================================

-- Deepak's scenario: Test data cleanup in dev environment
-- Remove test customers (ID < 1000)
DELETE FROM deepak_analytics_db.dev_schema.customers
WHERE customer_id < 1000;

-- Deepak's note: Making changes in dev, production is untouched


-- Verify dev changes
SELECT
    COUNT(*) AS total_customers,
    MIN(customer_id) AS min_id,
    MAX(customer_id) AS max_id
FROM deepak_analytics_db.dev_schema.customers;

-- Deepak's observation: Dev table has fewer records now


-- Compare with production (unchanged)
SELECT
    COUNT(*) AS total_customers,
    MIN(customer_id) AS min_id,
    MAX(customer_id) AS max_id
FROM deepak_analytics_db.public.customers;

-- Deepak's learning: Production still has all original data


-- ========================================
-- SWAP TABLES (BLUE-GREEN DEPLOYMENT)
-- ========================================

-- Deepak's critical moment: Swap dev and production tables
-- This is INSTANT and ATOMIC
ALTER TABLE deepak_analytics_db.dev_schema.customers
SWAP WITH deepak_analytics_db.public.customers;

-- Deepak's observation: Swap completed in milliseconds!
-- No data movement, just metadata exchange


-- ========================================
-- VERIFY SWAP RESULTS
-- ========================================

-- Check production (now has cleaned data)
SELECT
    COUNT(*) AS total_customers,
    MIN(customer_id) AS min_id,
    MAX(customer_id) AS max_id
FROM deepak_analytics_db.public.customers;

-- Deepak's observation: Production now has the cleaned data!


-- Check dev (now has original data)
SELECT
    COUNT(*) AS total_customers,
    MIN(customer_id) AS min_id,
    MAX(customer_id) AS max_id
FROM deepak_analytics_db.dev_schema.customers;

-- Deepak's learning: Dev now has the original production data
-- Perfect for rollback if needed!


/*
DEEPAK'S TABLE SWAPPING INSIGHTS:
=================================

What is SWAP WITH?
- Exchanges table metadata between two tables
- Instant operation (milliseconds)
- No data movement
- Atomic (all or nothing)
- Zero downtime

How It Works:
1. Table A points to Data Set 1
2. Table B points to Data Set 2
3. SWAP WITH exchanges the pointers
4. Table A now points to Data Set 2
5. Table B now points to Data Set 1

Blue-Green Deployment Pattern:
┌─────────────────────────────────────┐
│ BEFORE SWAP:                        │
│ Production → Original Data          │
│ Dev → Modified Data                 │
│                                     │
│ AFTER SWAP:                         │
│ Production → Modified Data ✅       │
│ Dev → Original Data (backup)        │
└─────────────────────────────────────┘

Use Cases:
✅ Zero-downtime deployments
✅ Blue-green deployments
✅ Testing changes before production
✅ Instant rollback capability
✅ Schema migrations
✅ Data transformations
✅ A/B testing

Advantages:
- Instant execution (no data copy)
- Zero downtime
- Easy rollback (just swap back)
- Test in dev, deploy to prod instantly
- No impact on queries during swap
- Preserves grants and privileges

Limitations:
- Tables must be in same account
- Cannot swap between different databases
- Both tables must exist
- Cannot swap temporary tables
- Cannot swap external tables

Real-World Deployment Workflow:
1. Clone production to dev
2. Make changes in dev
3. Test thoroughly in dev
4. SWAP dev with production (instant)
5. Monitor production
6. If issues: SWAP back (instant rollback)
7. If success: Keep new version

Example: Daily ETL Deployment
-- Step 1: Clone current production
CREATE SCHEMA etl_new CLONE etl_prod;

-- Step 2: Run ETL in new schema
INSERT INTO etl_new.fact_sales
SELECT ... FROM staging;

-- Step 3: Validate new data
SELECT COUNT(*) FROM etl_new.fact_sales;

-- Step 4: Swap to production (instant!)
ALTER SCHEMA etl_new SWAP WITH etl_prod;

-- Step 5: Old production is now in etl_new (backup)

Swapping Schemas:
ALTER SCHEMA schema_dev
SWAP WITH schema_prod;

Swapping Databases:
ALTER DATABASE db_dev
SWAP WITH db_prod;

Best Practices:
1. Always test in dev before swapping
2. Validate data after swap
3. Keep old version for quick rollback
4. Document swap operations
5. Monitor queries after swap
6. Use transactions for related swaps
7. Communicate with team before production swaps

Rollback Strategy:
-- If issues detected after swap
ALTER TABLE deepak_analytics_db.public.customers
SWAP WITH deepak_analytics_db.dev_schema.customers;
-- Instant rollback to previous version!

Comparison with Other Methods:
┌──────────────────────┬────────────┬──────────┬──────────┐
│ Method               │ Speed      │ Downtime │ Rollback │
├──────────────────────┼────────────┼──────────┼──────────┤
│ SWAP WITH            │ Instant    │ Zero     │ Instant  │
│ DROP + RENAME        │ Fast       │ Yes      │ Hard     │
│ DELETE + INSERT      │ Slow       │ Yes      │ Hard     │
│ TRUNCATE + INSERT    │ Medium     │ Yes      │ Hard     │
└──────────────────────┴────────────┴──────────┴──────────┘

Security Considerations:
- Grants and privileges are preserved
- Access policies remain intact
- Row access policies stay with data
- Masking policies follow the table

Monitoring:
-- Check query history for swap operations
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%SWAP WITH%'
ORDER BY start_time DESC;

Advanced Pattern: Multi-Table Swap
BEGIN TRANSACTION;
  ALTER TABLE schema_dev.table1 SWAP WITH schema_prod.table1;
  ALTER TABLE schema_dev.table2 SWAP WITH schema_prod.table2;
  ALTER TABLE schema_dev.table3 SWAP WITH schema_prod.table3;
COMMIT;

Practiced: February 2026
Status: ✅ Completed - Mastering zero-downtime deployments
*/