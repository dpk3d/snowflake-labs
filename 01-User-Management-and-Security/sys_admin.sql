/*
===========================================
DEEPAK'S SYSADMIN ROLE PRACTICE
===========================================
Topic: Warehouse & Database Management
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- SYSADMIN creates and manages warehouses and databases
- Warehouses can auto-suspend to save costs
- Database ownership can be transferred to custom roles
- PUBLIC role allows company-wide access
===========================================
*/

-- Deepak's Note: Using SYSADMIN to set up infrastructure for different teams
-- This demonstrates warehouse creation, database management, and ownership transfer


-- ========================================
-- SHARED INFRASTRUCTURE SETUP
-- ========================================

-- Deepak's learning: Creating a small warehouse for general company use
CREATE WAREHOUSE deepak_public_wh WITH
WAREHOUSE_SIZE = 'X-SMALL'
AUTO_SUSPEND = 300          -- Suspend after 5 minutes of inactivity
AUTO_RESUME = TRUE          -- Auto-resume when queries are submitted
COMMENT = 'Shared warehouse for all employees';

-- Grant usage to PUBLIC role so everyone can use it
GRANT USAGE ON WAREHOUSE deepak_public_wh TO ROLE PUBLIC;

-- Deepak's observation: This warehouse will auto-suspend to minimize costs
-- 300 seconds = 5 minutes idle time before suspension


-- Create a common database accessible to all employees
CREATE DATABASE deepak_common_db
COMMENT = 'Shared database for company-wide data';

GRANT USAGE ON DATABASE deepak_common_db TO ROLE PUBLIC;

-- Deepak's note: PUBLIC grants allow all users to access this database


-- ========================================
-- SALES DEPARTMENT DATABASE
-- ========================================

-- Deepak's learning: Creating dedicated database for Sales team
CREATE DATABASE deepak_sales_db
COMMENT = 'Sales department database - customer and revenue data';

-- Transfer ownership to sales_admin role
GRANT OWNERSHIP ON DATABASE deepak_sales_db TO ROLE sales_admin;
GRANT OWNERSHIP ON SCHEMA deepak_sales_db.public TO ROLE sales_admin;

-- Deepak's observation: sales_admin now has full control over this database
-- They can create tables, views, and manage all objects within it


-- ========================================
-- HR DEPARTMENT DATABASE
-- ========================================

-- Deepak's experiment: Setting up HR database
CREATE DATABASE deepak_hr_db
COMMENT = 'HR department database - employee and payroll data';

-- Transfer ownership to hr_admin role
GRANT OWNERSHIP ON DATABASE deepak_hr_db TO ROLE hr_admin;
GRANT OWNERSHIP ON SCHEMA deepak_hr_db.public TO ROLE hr_admin;

-- Deepak's note: HR data is sensitive, so it's isolated in its own database


-- Verify all databases created
SHOW DATABASES;


/*
DEEPAK'S INFRASTRUCTURE SUMMARY:
================================

Warehouses Created:
- deepak_public_wh (X-SMALL) - Shared by all users

Databases Created:
- deepak_common_db - Accessible to everyone (PUBLIC)
- deepak_sales_db - Owned by sales_admin
- deepak_hr_db - Owned by hr_admin

Key Insights:
1. Warehouse auto-suspend saves costs when not in use
2. Database ownership allows department autonomy
3. PUBLIC role enables company-wide collaboration
4. Separate databases provide data isolation and security

Cost Optimization:
- X-SMALL warehouse is sufficient for learning/testing
- Auto-suspend after 5 minutes prevents unnecessary charges
- Can scale up warehouse size as needed

Practiced: February 2026
Status: ✅ Completed - Understanding infrastructure management
*/
