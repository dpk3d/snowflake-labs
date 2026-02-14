/*
===========================================
DEEPAK'S SYSADMIN PRACTICE - PART 2
===========================================
Topic: Advanced Warehouse & Database Operations
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- Multiple warehouses for different workloads
- Database lifecycle management (create/drop)
- Ownership transfer best practices
- Resource isolation strategies
===========================================
*/

-- Deepak's Note: This is an alternative approach to infrastructure setup
-- Practicing different warehouse configurations and database management


-- ========================================
-- COMPUTE WAREHOUSE SETUP
-- ========================================

-- Deepak's learning: Creating a cost-effective warehouse for analytics
CREATE WAREHOUSE deepak_analytics_wh WITH
WAREHOUSE_SIZE = 'X-SMALL'
AUTO_SUSPEND = 300          -- 5 minutes idle timeout
AUTO_RESUME = TRUE
COMMENT = 'Analytics warehouse for business intelligence queries';

-- Make it available to all users
GRANT USAGE ON WAREHOUSE deepak_analytics_wh TO ROLE PUBLIC;

-- Deepak's observation: X-SMALL is perfect for development and learning
-- Can scale up to MEDIUM or LARGE for production workloads


-- ========================================
-- SHARED DATA REPOSITORY
-- ========================================

-- Create company-wide shared database
CREATE DATABASE deepak_shared_data
COMMENT = 'Centralized repository for reference data and lookup tables';

GRANT USAGE ON DATABASE deepak_shared_data TO ROLE PUBLIC;

-- Deepak's note: This database will contain:
-- - Country codes, currency rates
-- - Product catalogs
-- - Other reference data accessible to all departments


-- ========================================
-- SALES ANALYTICS DATABASE
-- ========================================

-- Deepak's experiment: Creating dedicated sales analytics environment
CREATE DATABASE deepak_sales_analytics
COMMENT = 'Sales team analytics and reporting database';

-- Transfer full control to sales_admin
GRANT OWNERSHIP ON DATABASE deepak_sales_analytics TO ROLE sales_admin;
GRANT OWNERSHIP ON SCHEMA deepak_sales_analytics.public TO ROLE sales_admin;

-- Deepak's learning: sales_admin can now create tables, views, procedures


-- Verify database creation
SHOW DATABASES;


-- ========================================
-- HR DATABASE MANAGEMENT
-- ========================================

-- Deepak's note: Demonstrating database recreation
-- First, drop existing HR database if it exists
DROP DATABASE IF EXISTS deepak_hr_data;

-- Create fresh HR database
CREATE DATABASE deepak_hr_data
COMMENT = 'HR department - employee records and payroll';

-- Grant ownership to hr_admin
GRANT OWNERSHIP ON DATABASE deepak_hr_data TO ROLE hr_admin;
GRANT OWNERSHIP ON SCHEMA deepak_hr_data.public TO ROLE hr_admin;

-- Deepak's observation: DROP IF EXISTS prevents errors if database doesn't exist


/*
DEEPAK'S WAREHOUSE & DATABASE STRATEGY:
=======================================

Warehouses:
- deepak_analytics_wh: General purpose analytics (X-SMALL)
- Auto-suspend saves costs during idle periods
- Can create multiple warehouses for different workload types

Databases:
- deepak_shared_data: Company-wide reference data
- deepak_sales_analytics: Sales team workspace
- deepak_hr_data: HR sensitive data (isolated)

Best Practices Applied:
1. Descriptive naming convention (deepak_*)
2. Comments on all objects for documentation
3. Ownership transfer for department autonomy
4. PUBLIC access only for truly shared resources
5. DROP IF EXISTS for idempotent scripts

Next Steps:
- Monitor warehouse usage and costs
- Implement resource monitors for budget control
- Create additional warehouses for ETL vs Analytics workloads

Practiced: February 2026
Status: ✅ Completed - Understanding resource management
*/
