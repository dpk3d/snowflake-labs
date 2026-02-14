/*
===========================================
DEEPAK'S NESTED JSON PRACTICE
===========================================
Topic: Handling Nested Objects and Arrays
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Access nested objects with dot notation
- Query JSON arrays with [index]
- Use ARRAY_SIZE to count array elements
- UNION ALL to flatten arrays
- Extract multiple array elements
===========================================
*/

-- Deepak's Note: Real JSON is often nested - objects within objects!
-- Use dot notation to drill down into nested structures


-- ========================================
-- HANDLING NESTED OBJECTS
-- ========================================

-- Deepak's scenario: Query nested job object
SELECT
    raw_json:job AS job
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Returns entire nested object as VARIANT


-- Deepak's technique: Access nested field with dot notation
SELECT
    raw_json:job.salary::INT AS salary
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's learning: Use dot notation to access nested fields!
-- Syntax: parent.child


-- Deepak's scenario: Extract multiple nested fields
SELECT
    raw_json:first_name::STRING AS first_name,
    raw_json:job.salary::INT AS salary,
    raw_json:job.title::STRING AS job_title
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Can mix top-level and nested fields


-- ========================================
-- HANDLING JSON ARRAYS
-- ========================================

-- Deepak's scenario: Query array of previous companies
SELECT
    raw_json:prev_company AS prev_companies
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Returns entire array as VARIANT


-- Deepak's technique: Access specific array element with [index]
SELECT
    raw_json:prev_company[1]::STRING AS second_company
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's learning: Arrays are 0-indexed!
-- [0] = first element, [1] = second element


-- Deepak's scenario: Count array elements
SELECT
    raw_json:first_name::STRING AS first_name,
    ARRAY_SIZE(raw_json:prev_company) AS num_prev_companies
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: ARRAY_SIZE returns number of elements


-- ========================================
-- FLATTEN ARRAYS WITH UNION ALL
-- ========================================

-- Deepak's challenge: Create one row per previous company
-- Employee with 2 companies → 2 rows

-- Deepak's technique: UNION ALL to flatten array
SELECT
    raw_json:id::INT AS id,
    raw_json:first_name::STRING AS first_name,
    raw_json:prev_company[0]::STRING AS prev_company
FROM deepak_json_db.public.employee_json_raw

UNION ALL

SELECT
    raw_json:id::INT AS id,
    raw_json:first_name::STRING AS first_name,
    raw_json:prev_company[1]::STRING AS prev_company
FROM deepak_json_db.public.employee_json_raw

ORDER BY id;

-- Deepak's learning: UNION ALL creates separate rows for each array element
-- But this only works for fixed-size arrays!


/*
DEEPAK'S NESTED JSON INSIGHTS:
===============================

Nested Objects:

Syntax:
column:parent.child
column:parent.child.grandchild

Examples:
raw:job.title
raw:address.city
raw:contact.phone.mobile

JSON Structure:
{
  "name": "Deepak",
  "job": {
    "title": "Data Engineer",
    "salary": 100000,
    "department": "Analytics"
  }
}

Query:
SELECT
    raw:name::STRING,
    raw:job.title::STRING,
    raw:job.salary::INT,
    raw:job.department::STRING
FROM table;

Multiple Levels:
{
  "employee": {
    "personal": {
      "name": "Deepak",
      "age": 30
    },
    "work": {
      "title": "Engineer"
    }
  }
}

Query:
SELECT
    raw:employee.personal.name::STRING,
    raw:employee.personal.age::INT,
    raw:employee.work.title::STRING
FROM table;

JSON Arrays:

Syntax:
column:array[index]

Index:
- 0-based (first element is [0])
- [0] = first element
- [1] = second element
- [n] = (n+1)th element

Examples:
raw:skills[0]
raw:prev_company[1]
raw:languages[2]

JSON Structure:
{
  "name": "Deepak",
  "skills": ["SQL", "Python", "Snowflake"]
}

Query:
SELECT
    raw:name::STRING,
    raw:skills[0]::STRING AS skill1,
    raw:skills[1]::STRING AS skill2,
    raw:skills[2]::STRING AS skill3
FROM table;

ARRAY_SIZE Function:

Purpose: Count array elements

Syntax:
ARRAY_SIZE(column:array)

Example:
SELECT
    raw:name::STRING,
    ARRAY_SIZE(raw:skills) AS num_skills
FROM table;

Use Cases:
✅ Count array elements
✅ Filter by array size
✅ Validate data
✅ Identify empty arrays

Flattening Arrays (UNION ALL):

Problem: Array with variable elements
Solution: Create one row per element

Manual Approach (Fixed Size):
SELECT id, array[0] FROM table
UNION ALL
SELECT id, array[1] FROM table
UNION ALL
SELECT id, array[2] FROM table;

Limitations:
❌ Only works for known array size
❌ Manual for each element
❌ Doesn't handle variable sizes
❌ Creates NULLs for missing elements

Better Approach: FLATTEN (next file!)

Common Patterns:

1. Nested Object Access:
SELECT
    raw:user.profile.name::STRING,
    raw:user.profile.email::STRING,
    raw:user.settings.theme::STRING
FROM table;

2. Array Element Access:
SELECT
    raw:name::STRING,
    raw:hobbies[0]::STRING AS hobby1,
    raw:hobbies[1]::STRING AS hobby2
FROM table;

3. Array Size Check:
SELECT
    raw:name::STRING,
    ARRAY_SIZE(raw:skills) AS skill_count
FROM table
WHERE ARRAY_SIZE(raw:skills) > 3;

4. Mixed Nested and Array:
SELECT
    raw:employee.name::STRING,
    raw:employee.projects[0].name::STRING,
    raw:employee.projects[0].role::STRING
FROM table;

Error Handling:

-- Handle missing nested fields
SELECT
    COALESCE(raw:job.title::STRING, 'Unknown') AS title
FROM table;

-- Handle empty arrays
SELECT
    CASE
        WHEN ARRAY_SIZE(raw:skills) > 0
        THEN raw:skills[0]::STRING
        ELSE 'No skills'
    END AS first_skill
FROM table;

-- Safe array access
SELECT
    TRY_CAST(raw:array[0] AS STRING) AS first_element
FROM table;

Real-World Example:

JSON:
{
  "employee_id": 101,
  "name": "Deepak Singh",
  "contact": {
    "email": "deepak@example.com",
    "phone": {
      "mobile": "+91-9876543210",
      "office": "+91-2212345678"
    }
  },
  "skills": ["SQL", "Python", "Snowflake", "AWS"],
  "certifications": [
    {"name": "SnowPro Core", "year": 2025},
    {"name": "AWS Solutions Architect", "year": 2024}
  ]
}

Query:
SELECT
    raw:employee_id::INT AS emp_id,
    raw:name::STRING AS name,
    raw:contact.email::STRING AS email,
    raw:contact.phone.mobile::STRING AS mobile,
    raw:contact.phone.office::STRING AS office,
    ARRAY_SIZE(raw:skills) AS num_skills,
    raw:skills[0]::STRING AS top_skill,
    raw:certifications[0].name::STRING AS latest_cert,
    raw:certifications[0].year::INT AS cert_year
FROM employee_raw;

Best Practices:
1. Use dot notation for nested objects
2. Use [index] for array elements
3. Check array size before accessing
4. Handle missing fields with COALESCE
5. Document JSON structure
6. Test with sample data
7. Use FLATTEN for variable arrays (next!)

Limitations of UNION ALL:
❌ Manual for each element
❌ Fixed array size only
❌ Creates NULLs for missing elements
❌ Verbose code
❌ Hard to maintain

Solution: FLATTEN function (covered in next file!)

Deepak's Nested Data Checklist:
✅ Identify nested structure
✅ Use dot notation for objects
✅ Use [index] for arrays
✅ Check array sizes
✅ Handle missing fields
✅ Test thoroughly
✅ Consider FLATTEN for arrays

Key Takeaway:
Use dot notation (parent.child) for nested objects
and [index] for arrays. UNION ALL works for fixed
arrays, but FLATTEN is better for variable sizes!

Practiced: February 2026
Status: ✅ Completed - Mastering nested JSON structures
*/

