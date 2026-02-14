/*
===========================================
DEEPAK'S USERADMIN ROLE PRACTICE
===========================================
Topic: User Administration & Role Management
Date Practiced: February 12, 2026
Difficulty: ⭐⭐
Key Learnings:
- USERADMIN can create users and grant roles
- USERADMIN has limited privileges compared to SECURITYADMIN
- Can grant existing roles but cannot create new roles
- Useful for delegating user management tasks
===========================================
*/

-- Deepak's Note: USERADMIN is a specialized role for user management
-- It can create users and assign roles, but cannot create new roles


-- ========================================
-- CREATE NEW USER WITH USERADMIN
-- ========================================

--- HR Department User (Jennifer) ---
-- Deepak's scenario: Adding a new HR team member

CREATE USER jennifer_hr
PASSWORD = 'TempHR2026!'
DEFAULT_ROLE = hr_users
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'Jennifer Williams - HR Coordinator';

-- Grant HR admin role to this user
GRANT ROLE hr_admin TO USER jennifer_hr;

-- Deepak's observation: jennifer_hr now has hr_admin privileges
-- She can manage HR database and users with hr_users role


-- ========================================
-- VERIFY AVAILABLE ROLES
-- ========================================

-- Deepak's learning: Check all roles in the system
SHOW ROLES;

-- Deepak's note: This shows all roles including:
-- - System roles (ACCOUNTADMIN, SECURITYADMIN, SYSADMIN, USERADMIN, PUBLIC)
-- - Custom roles (sales_admin, sales_users, hr_admin, hr_users)


-- ========================================
-- FIX ROLE HIERARCHY
-- ========================================

-- Deepak's important fix: Grant hr_admin to SYSADMIN
-- This was intentionally skipped earlier for learning purposes
GRANT ROLE hr_admin TO ROLE SYSADMIN;

-- Deepak's observation: Now hr_admin is properly integrated into role hierarchy
-- SYSADMIN can now manage HR resources and users


/*
DEEPAK'S USERADMIN INSIGHTS:
============================

USERADMIN Capabilities:
✅ Create new users
✅ Grant existing roles to users
✅ Modify user properties (password, default role, etc.)
✅ Drop users

USERADMIN Limitations:
❌ Cannot create new roles (need SECURITYADMIN)
❌ Cannot grant privileges on objects (need object owner or ACCOUNTADMIN)
❌ Cannot create databases or warehouses (need SYSADMIN)

When to Use USERADMIN:
- Delegate user onboarding/offboarding to team leads
- Separate user management from security policy management
- Reduce need for SECURITYADMIN access

Role Hierarchy After Fix:
ACCOUNTADMIN
  └─ SECURITYADMIN
       └─ USERADMIN
  └─ SYSADMIN
       ├─ sales_admin
       │    └─ sales_users
       └─ hr_admin
            └─ hr_users

Practiced: February 2026
Status: ✅ Completed - Understanding USERADMIN role
*/