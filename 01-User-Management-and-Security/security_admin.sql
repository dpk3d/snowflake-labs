/*
===========================================
DEEPAK'S SECURITYADMIN ROLE PRACTICE
===========================================
Topic: Custom Role Creation & User Management
Date Practiced: February 12, 2026
Difficulty: ⭐⭐⭐
Key Learnings:
- SECURITYADMIN creates and manages custom roles
- Role hierarchy is crucial for access control
- Best practice: Always grant custom roles to SYSADMIN
- Users should have minimal necessary privileges
===========================================
*/

-- Deepak's Note: Using SECURITYADMIN to create department-specific roles
-- This demonstrates role hierarchy and user assignment patterns


-- ========================================
-- SALES DEPARTMENT SETUP
-- ========================================

-- Deepak's observation: Creating a two-tier role structure for Sales team
CREATE ROLE sales_admin COMMENT = 'Sales department administrators';
CREATE ROLE sales_users COMMENT = 'Regular sales team members';

-- Create role hierarchy: sales_users reports to sales_admin
GRANT ROLE sales_users TO ROLE sales_admin;

-- Best Practice: Assign to SYSADMIN for proper role hierarchy
GRANT ROLE sales_admin TO ROLE SYSADMIN;

-- Deepak's note: This ensures SYSADMIN can manage sales resources


--- Sales Team Users ---

-- Regular Sales User (Amit)
CREATE USER amit_sales
PASSWORD = 'SalesTemp2026!'
DEFAULT_ROLE = sales_users
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'Amit Patel - Sales Representative';

GRANT ROLE sales_users TO USER amit_sales;

-- Sales Administrator (Sarah)
CREATE USER sarah_sales_admin
PASSWORD = 'SalesAdmin2026!'
DEFAULT_ROLE = sales_admin
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'Sarah Johnson - Sales Team Lead';

GRANT ROLE sales_admin TO USER sarah_sales_admin;

-- Deepak's learning: sales_admin can manage sales_users and their data


-- ========================================
-- HR DEPARTMENT SETUP
-- ========================================

-- Deepak's experiment: Testing what happens without SYSADMIN grant
CREATE ROLE hr_admin COMMENT = 'HR department administrators';
CREATE ROLE hr_users COMMENT = 'HR team members';

-- Create role hierarchy
GRANT ROLE hr_users TO ROLE hr_admin;

-- Deepak's note: Intentionally NOT granting to SYSADMIN to see the impact
-- This is AGAINST best practice - doing this for learning purposes only
-- GRANT ROLE hr_admin TO ROLE SYSADMIN;  -- Commented out intentionally


--- HR Team Users ---

-- Regular HR User (Priya)
CREATE USER priya_hr
PASSWORD = 'HRTemp2026!'
DEFAULT_ROLE = hr_users
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'Priya Reddy - HR Specialist';

GRANT ROLE hr_users TO USER priya_hr;

-- HR Administrator (Michael)
CREATE USER michael_hr_admin
PASSWORD = 'HRAdmin2026!'
DEFAULT_ROLE = hr_admin
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'Michael Chen - HR Manager';

GRANT ROLE hr_admin TO USER michael_hr_admin;


/*
DEEPAK'S OBSERVATIONS:
=====================
1. Sales roles are properly integrated with SYSADMIN hierarchy
2. HR roles are isolated - this will cause management issues
3. In production, ALWAYS grant custom admin roles to SYSADMIN
4. Role hierarchy prevents privilege escalation

Next Steps:
- Test access with different users
- Observe the difference between sales and hr role management
- Fix HR role hierarchy by granting to SYSADMIN

Practiced: February 2026
Status: ✅ Completed - Understanding role hierarchy importance
*/
