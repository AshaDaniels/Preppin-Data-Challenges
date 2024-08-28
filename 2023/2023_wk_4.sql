-- We want to stack the tables on top of one another, since they have the same fields in each sheet. We can do this one of 2 ways:
-- Drag each table into the canvas and use a union step to stack them on top of one another
-- Use a wildcard union in the input step of one of the tables
-- Some of the fields aren't matching up as we'd expect, due to differences in spelling. Merge these fields together
-- Make a Joining Date field based on the Joining Day, Table Names and the year 2023
-- Now we want to reshape our data so we have a field for each demographic, for each new customer
-- Make sure all the data types are correct for each field
-- Remove duplicates
-- If a customer appears multiple times take their earliest joining date

-- Techniques:
-- 1. UNION and UNION ALL
-- 2. PIVOT columns to rows
-- 3. Using ROW_NUMBER() to remove duplicates
  
WITH CUSTOMER_CTE AS(
    SELECT *, 'pd2023_wk04_january' AS table_name FROM pd2023_wk04_january
    UNION ALL 
    SELECT *, 'pd2023_wk04_february' AS table_name FROM pd2023_wk04_february
    UNION ALL 
    SELECT *, 'pd2023_wk04_march' AS table_name FROM pd2023_wk04_march
    UNION ALL 
    SELECT *, 'pd2023_wk04_april' AS table_name FROM pd2023_wk04_april
    UNION ALL
    SELECT *, 'pd2023_wk04_may' AS table_name FROM pd2023_wk04_may
    UNION ALL
    SELECT *, 'pd2023_wk04_june' AS table_name FROM pd2023_wk04_june
    UNION ALL
    SELECT *, 'pd2023_wk04_july' AS table_name FROM pd2023_wk04_july
    UNION ALL
    SELECT *, 'pd2023_wk04_august' AS table_name FROM pd2023_wk04_august
    UNION ALL
    SELECT *, 'pd2023_wk04_september' AS table_name FROM pd2023_wk04_september
    UNION ALL
    SELECT *, 'pd2023_wk04_october' AS table_name FROM pd2023_wk04_october
    UNION ALL
    SELECT *, 'pd2023_wk04_november' AS table_name FROM pd2023_wk04_november
    UNION ALL
    SELECT *, 'pd2023_wk04_december' AS table_name FROM pd2023_wk04_december)

, CORRECTED_DATE AS(
SELECT *EXCLUDE(joining_day,table_name), DATE_FROM_PARTS(2023,DATE_PART('month',DATE(SPLIT_PART(table_name, '_', 3),'MMMM')), joining_day) as JOINING_DATE
FROM CUSTOMER_CTE)

, PIVOTED_CUSTOMER AS(
SELECT ID, joining_date, ethnicity, account_type, DATE(date_of_birth) as date_of_birth
FROM CORRECTED_DATE
PIVOT(MAX(value) FOR demographic IN('Ethnicity','Account Type','Date of Birth')) AS P(ID, joining_date, ethnicity, account_type, date_of_birth))

SELECT *EXCLUDE(JOINING_DATE), MIN(JOINING_DATE) as JOINING_DATE
FROM PIVOTED_CUSTOMER
GROUP BY ID, date_of_birth, ethnicity, account_type
