/*
===========================================
DEEPAK'S SNOWFLAKE USER MANAGEMENT PRACTICE
===========================================
Topic: User Creation & Role Assignment
Date Practiced: February 12, 2026
Difficulty: ⭐⭐
Key Learnings:
- ACCOUNTADMIN has full system privileges
- SECURITYADMIN manages users and roles
- SYSADMIN manages warehouses and databases
- Always enforce MUST_CHANGE_PASSWORD for security
===========================================
*/

-- Deepak's Note: Creating users with different administrative roles
-- This demonstrates Snowflake's Role-Based Access Control (RBAC)

--- User 1: Account Administrator (Deepak) ---
-- Purpose: Full administrative access for managing the entire Snowflake account
CREATE USER deepak_admin
PASSWORD = 'TempPass2026!'
DEFAULT_ROLE = ACCOUNTADMIN
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'Deepak - Primary account administrator';

GRANT ROLE ACCOUNTADMIN TO USER deepak_admin;

-- Deepak's observation: ACCOUNTADMIN is the most powerful role
-- Should be used sparingly and only for critical administrative tasks


--- User 2: Security Administrator (Priya) ---
-- Purpose: Manages user access, roles, and security policies
CREATE USER priya_security
PASSWORD = 'SecureTemp123!'
DEFAULT_ROLE = SECURITYADMIN
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'Priya Sharma - Security and access management';

GRANT ROLE SECURITYADMIN TO USER priya_security;

-- Deepak's note: SECURITYADMIN is responsible for user and role management
-- This role can create users and grant/revoke privileges


--- User 3: System Administrator (Rahul) ---
-- Purpose: Manages databases, warehouses, and other Snowflake objects
CREATE USER rahul_sysadmin
PASSWORD = 'SysAdmin2026!'
DEFAULT_ROLE = SYSADMIN
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'Rahul Kumar - Database and warehouse administrator';

GRANT ROLE SYSADMIN TO USER rahul_sysadmin;

-- Deepak's learning: SYSADMIN creates and manages databases, schemas, tables
-- This is the role most commonly used for day-to-day database operations


/*
DEEPAK'S ADDITIONAL NOTES:
========================
Role Hierarchy in Snowflake:
ACCOUNTADMIN (top) → SECURITYADMIN → SYSADMIN → Custom Roles → PUBLIC (bottom)

Best Practice: Use the least privileged role necessary for each task
Security Tip: Always use strong passwords and enable MFA in production

Practiced: February 2026
Status: ✅ Completed and understood
*/
