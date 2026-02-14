/*
===========================================
DEEPAK'S HIERARCHICAL JSON PRACTICE
===========================================
Topic: Flattening Variable-Size Arrays with FLATTEN
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- FLATTEN function for variable-size arrays
- Handle arrays with unknown element count
- Create one row per array element
- Access flattened values with f.value
- Much better than UNION ALL approach
===========================================
*/

-- Deepak's Note: FLATTEN is the game-changer for JSON arrays!
-- Automatically handles variable-size arrays


-- ========================================
-- EXPLORE ARRAY STRUCTURE
-- ========================================

-- Deepak's scenario: Query spoken_languages array
SELECT
    raw_json:spoken_languages AS spoken_languages
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Array of objects with language and level

-- View full raw data
SELECT * FROM deepak_json_db.public.employee_json_raw;


-- Deepak's technique: Check array sizes
SELECT
    raw_json:first_name::STRING AS first_name,
    ARRAY_SIZE(raw_json:spoken_languages) AS num_languages
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Different employees speak different numbers of languages!
-- Some speak 1, some 2, some 3+ languages


-- ========================================
-- MANUAL ARRAY ACCESS (LIMITED)
-- ========================================

-- Deepak's experiment: Access first language
SELECT
    raw_json:spoken_languages[0] AS first_language
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's observation: Returns first language object


-- Deepak's technique: Extract with employee name
SELECT
    raw_json:first_name::STRING AS first_name,
    raw_json:spoken_languages[0] AS first_language
FROM deepak_json_db.public.employee_json_raw;


-- Deepak's scenario: Access nested fields in array element
SELECT
    raw_json:first_name::STRING AS first_name,
    raw_json:spoken_languages[0].language::STRING AS first_language,
    raw_json:spoken_languages[0].level::STRING AS level_spoken
FROM deepak_json_db.public.employee_json_raw;

-- Deepak's learning: Can access nested fields within array elements!


-- ========================================
-- UNION ALL APPROACH (PROBLEMATIC)
-- ========================================

-- Deepak's challenge: Get all languages for all employees
-- Problem: Don't know how many languages each person speaks!

-- Deepak's attempt: UNION ALL for fixed positions
SELECT
    raw_json:id::INT AS id,
    raw_json:first_name::STRING AS first_name,
    raw_json:spoken_languages[0].language::STRING AS language,
    raw_json:spoken_languages[0].level::STRING AS level
FROM deepak_json_db.public.employee_json_raw

UNION ALL

SELECT
    raw_json:id::INT AS id,
    raw_json:first_name::STRING AS first_name,
    raw_json:spoken_languages[1].language::STRING AS language,
    raw_json:spoken_languages[1].level::STRING AS level
FROM deepak_json_db.public.employee_json_raw

UNION ALL

SELECT
    raw_json:id::INT AS id,
    raw_json:first_name::STRING AS first_name,
    raw_json:spoken_languages[2].language::STRING AS language,
    raw_json:spoken_languages[2].level::STRING AS level
FROM deepak_json_db.public.employee_json_raw

ORDER BY id;

-- Deepak's observation: This works but has major problems!
-- ❌ Creates NULLs for missing array elements
-- ❌ Manual for each position
-- ❌ What if someone speaks 5 languages?
-- ❌ Verbose and hard to maintain


-- ========================================
-- FLATTEN FUNCTION (THE RIGHT WAY!)
-- ========================================

-- Deepak's solution: Use FLATTEN table function
SELECT
    raw_json:first_name::STRING AS first_name,
    f.value:language::STRING AS language,
    f.value:level::STRING AS level
FROM deepak_json_db.public.employee_json_raw,
TABLE(FLATTEN(raw_json:spoken_languages)) f;

-- Deepak's learning: FLATTEN is magical! 🎉
-- ✅ Automatically handles variable array sizes
-- ✅ Creates one row per array element
-- ✅ No NULLs for missing elements
-- ✅ Clean and maintainable
-- ✅ Works with any array size


/*
DEEPAK'S FLATTEN INSIGHTS:
===========================

What is FLATTEN?

A table function that expands arrays into rows
- Input: Array with N elements
- Output: N rows (one per element)
- Handles variable-size arrays
- No manual indexing needed

FLATTEN Syntax:

TABLE(FLATTEN(column:array_field))

Example:
FROM table_name,
TABLE(FLATTEN(raw:array_field)) f

Accessing Flattened Values:

f.value           -- The array element
f.value:field     -- Nested field in element
f.index           -- Array index (0-based)
f.seq             -- Sequence number
f.key             -- Object key (for objects)
f.path            -- Path to element

Common Pattern:
SELECT
    raw:id,
    f.value:field1,
    f.value:field2
FROM table,
TABLE(FLATTEN(raw:array)) f;

UNION ALL vs FLATTEN:

UNION ALL Approach:
❌ Manual for each position
❌ Fixed array size only
❌ Creates NULLs
❌ Verbose code
❌ Hard to maintain
❌ Doesn't scale

Example:
SELECT id, array[0] FROM table
UNION ALL
SELECT id, array[1] FROM table
UNION ALL
SELECT id, array[2] FROM table;

FLATTEN Approach:
✅ Automatic
✅ Variable array sizes
✅ No NULLs
✅ Clean code
✅ Easy to maintain
✅ Scales perfectly

Example:
SELECT
    id,
    f.value
FROM table,
TABLE(FLATTEN(array)) f;

When to Use FLATTEN:

✅ Variable-size arrays
✅ Unknown array length
✅ Arrays of objects
✅ Nested arrays
✅ Dynamic data
✅ Production code

Real-World Examples:

1. Simple Array:
JSON: {"skills": ["SQL", "Python", "Snowflake"]}

Query:
SELECT
    raw:name::STRING,
    f.value::STRING AS skill
FROM employees,
TABLE(FLATTEN(raw:skills)) f;

2. Array of Objects:
JSON: {
  "languages": [
    {"name": "English", "level": "Native"},
    {"name": "Hindi", "level": "Fluent"}
  ]
}

Query:
SELECT
    raw:employee_id::INT,
    f.value:name::STRING AS language,
    f.value:level::STRING AS proficiency
FROM employees,
TABLE(FLATTEN(raw:languages)) f;

3. Multiple Arrays:
SELECT
    raw:name::STRING,
    skills.value::STRING AS skill,
    certs.value:name::STRING AS certification
FROM employees,
TABLE(FLATTEN(raw:skills)) skills,
TABLE(FLATTEN(raw:certifications)) certs;

4. With Index:
SELECT
    raw:name::STRING,
    f.index AS position,
    f.value::STRING AS skill
FROM employees,
TABLE(FLATTEN(raw:skills)) f
ORDER BY position;

Advanced FLATTEN Features:

1. RECURSIVE (for nested arrays):
TABLE(FLATTEN(raw:nested_array, RECURSIVE => TRUE))

2. MODE (how to handle input):
TABLE(FLATTEN(raw:array, MODE => 'ARRAY'))

3. OUTER (keep rows with empty arrays):
TABLE(FLATTEN(raw:array, OUTER => TRUE))

Example with OUTER:
SELECT
    raw:name::STRING,
    f.value::STRING AS skill
FROM employees,
TABLE(FLATTEN(raw:skills, OUTER => TRUE)) f;
-- Includes employees with no skills (NULL)

Filtering Flattened Data:

-- Filter by array element
SELECT
    raw:name::STRING,
    f.value:language::STRING
FROM employees,
TABLE(FLATTEN(raw:languages)) f
WHERE f.value:level::STRING = 'Fluent';

-- Filter by array size
SELECT
    raw:name::STRING,
    COUNT(*) AS num_skills
FROM employees,
TABLE(FLATTEN(raw:skills)) f
GROUP BY raw:name
HAVING COUNT(*) > 3;

Performance Considerations:

✅ FLATTEN is optimized by Snowflake
✅ Pushdown predicates when possible
✅ Use clustering for large datasets
✅ Consider materialized views
✅ Filter early in the query

Best Practices:

1. Use meaningful alias for FLATTEN
   TABLE(FLATTEN(raw:skills)) skills

2. Cast flattened values to types
   f.value:field::STRING

3. Filter before FLATTEN when possible
   WHERE raw:active = true

4. Document array structure
   -- Array contains: {name, level}

5. Test with various array sizes
   -- Test: 0, 1, 3, 10+ elements

6. Handle empty arrays
   Use OUTER => TRUE if needed

7. Use index for ordering
   ORDER BY f.index

Common Mistakes:

❌ Forgetting TABLE() wrapper
   FLATTEN(raw:array)  -- Wrong
   TABLE(FLATTEN(raw:array))  -- Correct

❌ Not using alias
   TABLE(FLATTEN(raw:array))  -- Hard to reference
   TABLE(FLATTEN(raw:array)) f  -- Better

❌ Wrong value access
   f:field  -- Wrong
   f.value:field  -- Correct

❌ Not casting types
   f.value:id  -- VARIANT
   f.value:id::INT  -- INT

Complete Example:

-- JSON structure
{
  "employee_id": 101,
  "name": "Deepak Singh",
  "projects": [
    {
      "name": "Data Warehouse",
      "role": "Lead",
      "hours": 160
    },
    {
      "name": "ETL Pipeline",
      "role": "Developer",
      "hours": 80
    }
  ]
}

-- Query with FLATTEN
SELECT
    raw:employee_id::INT AS emp_id,
    raw:name::STRING AS emp_name,
    p.value:name::STRING AS project_name,
    p.value:role::STRING AS project_role,
    p.value:hours::INT AS hours_worked,
    p.index AS project_number
FROM employee_raw,
TABLE(FLATTEN(raw:projects)) p
WHERE p.value:hours::INT > 100
ORDER BY emp_id, p.index;

Deepak's FLATTEN Workflow:
1. Identify array field
2. Check array structure
3. Use FLATTEN with alias
4. Access with f.value:field
5. Cast to proper types
6. Filter and aggregate
7. Test with various sizes

Key Takeaway:
FLATTEN is THE solution for variable-size JSON arrays.
Use TABLE(FLATTEN(array)) f and access values with
f.value:field. Much better than UNION ALL!

Practiced: February 2026
Status: ✅ Completed - Mastering FLATTEN for hierarchical data
*/
