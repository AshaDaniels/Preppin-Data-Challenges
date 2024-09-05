-- Techniques:
-- 1. Cross Joins 
-- 2. Math functions 
-- 3. Row Number Sorting

-- Append the Branch information to the Customer information
-- Transform the latitude and longitude into radians
-- Find the closest Branch for each Customer
-- Make sure Distance is rounded to 2 decimal places
-- For each Branch, assign a Customer Priority rating, the closest customer having a rating of 1

WITH CTE AS(
    SELECT CUSTOMER
    , (ADDRESS_LONG*pi())/180 AS ADDRESS_LONG
    , (ADDRESS_LAT*pi())/180 AS ADDRESS_LAT
    , BRANCH
    , (BRANCH_LONG*pi())/180 AS BRANCH_LONG
    , (BRANCH_LAT*pi())/180 AS BRANCH_LAT
    FROM pd2023_wk11_dsb_customer_locations
    CROSS JOIN pd2023_wk11_dsb_branches
)

, SHORTEST_DISTANCE AS(
    SELECT CUSTOMER, MIN(3963 * acos((sin(ADDRESS_LAT) * sin(BRANCH_LAT)) + cos(ADDRESS_LAT) * cos(BRANCH_LAT) * cos(BRANCH_LONG - ADDRESS_LONG))) AS DISTANCE_MILES
    FROM CTE
    GROUP BY CUSTOMER
)

SELECT CTE.*,
ROUND(DISTANCE_MILES,2) AS DISTANCE_MILES,
RANK() OVER(PARTITION BY BRANCH ORDER BY DISTANCE_MILES ASC) AS CUSTOMER_PRIORITY
FROM SHORTEST_DISTANCE
INNER JOIN CTE ON (3963 * acos((sin(CTE.ADDRESS_LAT) * sin(CTE.BRANCH_LAT)) + cos(CTE.ADDRESS_LAT) * cos(CTE.BRANCH_LAT) * cos(CTE.BRANCH_LONG - CTE.ADDRESS_LONG))) = DISTANCE_MILES
AND SHORTEST_DISTANCE.CUSTOMER = CTE.CUSTOMER
