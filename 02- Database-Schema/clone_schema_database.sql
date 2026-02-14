/*
===========================================
DEEPAK'S SCHEMA & DATABASE CLONING PRACTICE
===========================================
Topic: Zero-Copy Cloning for Schemas and Databases
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Cloning creates instant copies without duplicating data
- TRANSIENT clones don't have fail-safe protection
- Clones are independent - changes don't affect original
- Extremely useful for testing and development
===========================================
*/

-- Deepak's Note: Snowflake's zero-copy cloning is a game-changer!
-- Creates instant snapshots without storage overhead


-- ========================================
-- SCHEMA CLONING
-- ========================================

-- Deepak's scenario: Creating a test environment from production schema
CREATE TRANSIENT SCHEMA deepak_analytics_db.test_schema
CLONE deepak_analytics_db.public
COMMENT = 'Test environment cloned from production';

-- Verify the cloned schema has all the data
SELECT * FROM deepak_analytics_db.test_schema.customers;

-- Deepak's observation: All tables and data are instantly available!
-- No waiting for data copy - this is zero-copy cloning magic


-- Deepak's experiment: Clone a schema from different database
CREATE TRANSIENT SCHEMA deepak_analytics_db.staging_backup
CLONE deepak_sales_db.public
COMMENT = 'Backup of sales data for staging tests';

-- Deepak's learning: Can clone schemas across databases
-- Useful for consolidating data or creating backups


-- ========================================
-- DATABASE CLONING
-- ========================================

-- Deepak's use case: Create complete database snapshot for testing
CREATE TRANSIENT DATABASE deepak_analytics_db_snapshot
CLONE deepak_analytics_db
COMMENT = 'Full database snapshot for testing new features';

-- Deepak's observation: Entire database cloned in seconds!
-- All schemas, tables, views, and data are available immediately


-- ========================================
-- CLEANUP
-- ========================================

-- Deepak's note: Removing test clones to avoid unnecessary storage costs
DROP DATABASE IF EXISTS deepak_analytics_db_snapshot;
DROP SCHEMA IF EXISTS deepak_analytics_db.staging_backup;
DROP SCHEMA IF EXISTS deepak_analytics_db.test_schema;

-- Deepak's learning: Always clean up test environments


/*
DEEPAK'S CLONING INSIGHTS:
==========================

Zero-Copy Cloning Benefits:
✅ Instant creation - no data copy time
✅ No additional storage initially (metadata only)
✅ Independent objects - changes don't affect original
✅ Perfect for testing, development, and backups
✅ Can clone tables, schemas, and entire databases

TRANSIENT vs PERMANENT Clones:
- TRANSIENT: No fail-safe, lower storage costs
- PERMANENT: Full fail-safe protection, higher costs
- Choose based on importance of cloned data

Common Use Cases:
1. Testing: Clone production to test schema changes
2. Development: Give developers safe sandbox environments
3. Debugging: Clone production data to investigate issues
4. Reporting: Clone for heavy analytics without impacting production
5. Backups: Quick snapshots before major changes

Storage Considerations:
- Initial clone uses minimal storage (metadata only)
- Storage grows as cloned data diverges from original
- Monitor storage costs for long-lived clones
- Drop unused clones to save costs

Best Practices:
- Use TRANSIENT for temporary test environments
- Use PERMANENT for important backups
- Document clone purpose and ownership
- Set up automated cleanup for old clones
- Use naming conventions (e.g., _test, _backup, _snapshot)

Real-World Example:
Before deploying new ETL pipeline:
1. Clone production database
2. Test pipeline on clone
3. Verify results
4. Deploy to production
5. Drop clone

Practiced: February 2026
Status: ✅ Completed - Understanding zero-copy cloning
*/
