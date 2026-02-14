/*
===========================================
DEEPAK'S JSON REVIEW DATA PRACTICE
===========================================
Topic: Handling Complex JSON with Date Parsing
Date Practiced: February 14, 2026
Difficulty: ⭐⭐⭐⭐⭐
Key Learnings:
- Query JSON from S3 stage
- Extract multiple JSON attributes
- Handle date conversions (Unix timestamp)
- Parse custom date formats
- Use DATE_FROM_PARTS for complex dates
- Transform JSON during COPY
===========================================
*/

-- Deepak's Note: Real-world JSON often has messy date formats!
-- This example shows how to handle complex date parsing


-- ========================================
-- QUERY RAW JSON FROM STAGE
-- ========================================

-- Deepak's scenario: Product review JSON data from S3
SELECT * FROM @deepak_mgmt_db.external_stages.deepak_json_reviews_stage;

-- Deepak's observation: JSON contains product reviews with various fields


-- ========================================
-- EXTRACT JSON ATTRIBUTES
-- ========================================

-- Deepak's experiment: Extract all review attributes
SELECT
    $1:asin,
    $1:helpful,
    $1:overall,
    $1:reviewText,
    $1:reviewTime,
    $1:reviewerID,
    $1:reviewerName,
    $1:summary,
    $1:unixReviewTime
FROM @deepak_mgmt_db.external_stages.deepak_json_reviews_stage;

-- Deepak's observation: All attributes returned as VARIANT type


-- ========================================
-- CAST TO PROPER DATA TYPES
-- ========================================

-- Deepak's technique: Cast attributes and use DATE function
SELECT
    $1:asin::STRING AS asin,
    $1:helpful AS helpful,
    $1:overall AS overall,
    $1:reviewText::STRING AS review_text,
    $1:reviewTime::STRING AS review_time_string,
    $1:reviewerID::STRING AS reviewer_id,
    $1:reviewerName::STRING AS reviewer_name,
    $1:summary::STRING AS summary,
    DATE($1:unixReviewTime::INT) AS unix_review_date
FROM @deepak_mgmt_db.external_stages.deepak_json_reviews_stage;

-- Deepak's learning: DATE() converts Unix timestamp to date!


-- ========================================
-- CHALLENGE: PARSE CUSTOM DATE FORMAT
-- ========================================

-- Deepak's observation: reviewTime is in format "MM DD, YYYY" or "MM D, YYYY"
-- Example: "02 14, 2026" or "02 5, 2026"
-- Need to parse this into a proper DATE

-- Deepak's approach: Use DATE_FROM_PARTS(year, month, day)
-- DATE_FROM_PARTS( <year>, <month>, <day> )


-- Deepak's experiment: Extract year, month, day from string
SELECT
    $1:asin::STRING AS asin,
    $1:helpful AS helpful,
    $1:overall AS overall,
    $1:reviewText::STRING AS review_text,
    DATE_FROM_PARTS(
        RIGHT($1:reviewTime::STRING, 4),           -- Year (last 4 chars)
        LEFT($1:reviewTime::STRING, 2),            -- Month (first 2 chars)
        SUBSTRING($1:reviewTime::STRING, 4, 2)     -- Day (chars 4-5)
    ) AS parsed_review_date,
    $1:reviewerID::STRING AS reviewer_id,
    $1:reviewerName::STRING AS reviewer_name,
    $1:summary::STRING AS summary,
    DATE($1:unixReviewTime::INT) AS unix_review_date
FROM @deepak_mgmt_db.external_stages.deepak_json_reviews_stage;

-- Deepak's observation: Works for "MM DD, YYYY" but fails for "MM D, YYYY"
-- Single-digit days cause issues!


-- ========================================
-- HANDLE VARIABLE DAY FORMAT
-- ========================================

-- Deepak's solution: Use CASE to handle both formats
SELECT
    $1:asin::STRING AS asin,
    $1:helpful AS helpful,
    $1:overall AS overall,
    $1:reviewText::STRING AS review_text,
    DATE_FROM_PARTS(
        RIGHT($1:reviewTime::STRING, 4),           -- Year
        LEFT($1:reviewTime::STRING, 2),            -- Month
        CASE
            WHEN SUBSTRING($1:reviewTime::STRING, 5, 1) = ','
            THEN SUBSTRING($1:reviewTime::STRING, 4, 1)    -- Single digit day
            ELSE SUBSTRING($1:reviewTime::STRING, 4, 2)    -- Two digit day
        END
    ) AS parsed_review_date,
    $1:reviewerID::STRING AS reviewer_id,
    $1:reviewerName::STRING AS reviewer_name,
    $1:summary::STRING AS summary,
    DATE($1:unixReviewTime::INT) AS unix_review_date
FROM @deepak_mgmt_db.external_stages.deepak_json_reviews_stage;

-- Deepak's learning: CASE statement handles variable day format!
-- Checks if 5th character is comma (single digit) or number (double digit)


-- ========================================
-- CREATE DESTINATION TABLE
-- ========================================

-- Deepak's scenario: Create table for product reviews
CREATE OR REPLACE TABLE deepak_analytics_db.public.product_reviews (
    asin STRING,
    helpful STRING,
    overall NUMBER(2,1),
    review_text STRING,
    review_date DATE,
    reviewer_id STRING,
    reviewer_name STRING,
    summary STRING,
    unix_review_date DATE
)
COMMENT = 'Deepak - Product reviews from JSON with parsed dates';


-- ========================================
-- LOAD TRANSFORMED DATA
-- ========================================

-- Deepak's technique: Transform JSON during COPY
COPY INTO deepak_analytics_db.public.product_reviews
FROM (
    SELECT
        $1:asin::STRING AS asin,
        $1:helpful AS helpful,
        $1:overall AS overall,
        $1:reviewText::STRING AS review_text,
        DATE_FROM_PARTS(
            RIGHT($1:reviewTime::STRING, 4),
            LEFT($1:reviewTime::STRING, 2),
            CASE
                WHEN SUBSTRING($1:reviewTime::STRING, 5, 1) = ','
                THEN SUBSTRING($1:reviewTime::STRING, 4, 1)
                ELSE SUBSTRING($1:reviewTime::STRING, 4, 2)
            END
        ) AS review_date,
        $1:reviewerID::STRING AS reviewer_id,
        $1:reviewerName::STRING AS reviewer_name,
        $1:summary::STRING AS summary,
        DATE($1:unixReviewTime::INT) AS unix_review_date
    FROM @deepak_mgmt_db.external_stages.deepak_json_reviews_stage
);

-- Deepak's learning: Complex date parsing done during COPY!


-- ========================================
-- VALIDATE RESULTS
-- ========================================

-- Deepak's verification: Check loaded data
SELECT * FROM deepak_analytics_db.public.product_reviews;

-- Deepak's observation: Dates properly parsed and loaded!

-- Check date parsing worked correctly
SELECT
    review_date,
    unix_review_date,
    COUNT(*) AS review_count
FROM deepak_analytics_db.public.product_reviews
GROUP BY review_date, unix_review_date
ORDER BY review_date DESC
LIMIT 10;


/*
DEEPAK'S JSON DATE PARSING INSIGHTS:
=====================================

Challenge: Custom Date Formats
- JSON often has non-standard date formats
- Need to parse strings into proper DATE types
- Variable formats (single vs double digit days)
- Multiple date representations

Date Functions Used:

1. DATE(unix_timestamp):
   - Converts Unix timestamp to DATE
   - Example: DATE(1676419200) → 2026-02-14

2. DATE_FROM_PARTS(year, month, day):
   - Constructs DATE from components
   - Example: DATE_FROM_PARTS(2026, 2, 14) → 2026-02-14

String Functions for Parsing:

1. LEFT(string, n):
   - Returns first n characters
   - Example: LEFT('02 14, 2026', 2) → '02'

2. RIGHT(string, n):
   - Returns last n characters
   - Example: RIGHT('02 14, 2026', 4) → '2026'

3. SUBSTRING(string, start, length):
   - Extracts substring
   - Example: SUBSTRING('02 14, 2026', 4, 2) → '14'

Parsing Strategy:

Format: "MM DD, YYYY" or "MM D, YYYY"
Examples: "02 14, 2026" or "02 5, 2026"

Components:
- Year: RIGHT(string, 4) → last 4 chars
- Month: LEFT(string, 2) → first 2 chars
- Day: Variable (1 or 2 digits)

Day Parsing Logic:
CASE
    WHEN SUBSTRING(string, 5, 1) = ','
    THEN SUBSTRING(string, 4, 1)    -- Single digit
    ELSE SUBSTRING(string, 4, 2)    -- Double digit
END

Why This Works:
- Position 5 is comma for single-digit days
- Position 5 is second digit for double-digit days

Examples:
"02 5, 2026" → Position 5 = ',' → Day = '5'
"02 14, 2026" → Position 5 = '4' → Day = '14'

Complete Parsing:
DATE_FROM_PARTS(
    RIGHT(reviewTime, 4),      -- Year: '2026'
    LEFT(reviewTime, 2),       -- Month: '02'
    CASE
        WHEN SUBSTRING(reviewTime, 5, 1) = ','
        THEN SUBSTRING(reviewTime, 4, 1)
        ELSE SUBSTRING(reviewTime, 4, 2)
    END                        -- Day: '14' or '5'
)

Alternative Approaches:

1. TRY_TO_DATE:
SELECT TRY_TO_DATE(reviewTime, 'MM DD, YYYY');
-- May not work with variable format

2. SPLIT_PART:
SELECT
    SPLIT_PART(reviewTime, ' ', 1) AS month,
    SPLIT_PART(reviewTime, ' ', 2) AS day,
    SPLIT_PART(reviewTime, ' ', 3) AS year;

3. REGEXP_REPLACE:
-- Clean and standardize format first

Best Practices:
1. Test date parsing with sample data
2. Handle edge cases (single vs double digits)
3. Use CASE for variable formats
4. Validate parsed dates
5. Keep original string for reference
6. Document parsing logic
7. Test with various date formats

Common Date Formats in JSON:

1. Unix Timestamp:
   1676419200
   → DATE(unix_timestamp)

2. ISO 8601:
   "2026-02-14T10:30:00Z"
   → TRY_TO_TIMESTAMP(string)

3. Custom String:
   "02 14, 2026"
   → DATE_FROM_PARTS(...)

4. Epoch Milliseconds:
   1676419200000
   → DATE(epoch_ms / 1000)

Error Handling:
-- Use TRY_CAST for safety
SELECT
    TRY_CAST(
        DATE_FROM_PARTS(year, month, day)
        AS DATE
    ) AS safe_date;

-- Handle NULLs
SELECT
    COALESCE(parsed_date, CURRENT_DATE()) AS date_with_default;

Real-World Example:
-- Parse various date formats
SELECT
    CASE
        WHEN reviewTime LIKE '%/%/%'
        THEN TRY_TO_DATE(reviewTime, 'MM/DD/YYYY')

        WHEN reviewTime LIKE '% %, %'
        THEN DATE_FROM_PARTS(
            RIGHT(reviewTime, 4),
            LEFT(reviewTime, 2),
            CASE
                WHEN SUBSTRING(reviewTime, 5, 1) = ','
                THEN SUBSTRING(reviewTime, 4, 1)
                ELSE SUBSTRING(reviewTime, 4, 2)
            END
        )

        WHEN TRY_CAST(reviewTime AS INT) IS NOT NULL
        THEN DATE(reviewTime::INT)

        ELSE NULL
    END AS parsed_date
FROM reviews_raw;

Deepak's Date Parsing Checklist:
✅ Identify date format in JSON
✅ Test with sample data
✅ Handle variable formats
✅ Use appropriate functions
✅ Add error handling
✅ Validate results
✅ Document parsing logic
✅ Keep original for reference

Key Takeaway:
Real-world JSON often has messy date formats. Use
string functions (LEFT, RIGHT, SUBSTRING) with
DATE_FROM_PARTS and CASE statements to handle
variable formats. Always test thoroughly!

Practiced: February 2026
Status: ✅ Completed - Mastering complex JSON date parsing
*/
