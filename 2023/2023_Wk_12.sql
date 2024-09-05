-- Techniques:
-- 1. Fill in blank rows 
-- 2. Manipulating dates 
-- 3. Running aggregations

-- Fill down the years and create a date field for the UK bank holidays
-- Combine with the UK New Customer dataset
-- Create a Reporting Day flag
-- UK bank holidays are not reporting days
-- Weekends are not reporting days
-- For non-reporting days, assign the customers to the next reporting day
-- Calculate the reporting month, as per the definition above
-- Filter out January 2024 dates
-- Calculate the reporting day, defined as the order of days in the reporting month
-- You'll notice reporting months often have different numbers of days!
-- Now let's focus on ROI data. This has already been through a similar process to the above, but using the ROI bank holidays. We'll have to align it with the UK reporting schedule
-- Rename fields so it's clear which fields are ROI and which are UK
-- Combine with UK data
-- For days which do not align, find the next UK reporting day and assign new customers to that day (for more detail, refer to the above description of the challenge)
-- Make sure null customer values are replaced with 0's
-- Create a flag to find which dates have differing reporting months when using the ROI/UK systems

WITH FILLED_YEARS AS(
    SELECT ROW_NUM, DATE,
    
    CASE 
    WHEN YEAR = ''
    THEN NULL
    ELSE YEAR
    END AS YEAR_FIX,
    
    COALESCE( YEAR_FIX,
    LAG(YEAR_FIX)
    IGNORE NULLS OVER( ORDER BY ROW_NUM ASC)
    )AS YEAR_FILL,
    
    BANK_HOLIDAY
    FROM pd2023_wk12_uk_bank_holidays
)

, NEW_DATES AS(
    SELECT BANK_HOLIDAY,
    DATE_FROM_PARTS(YEAR_FILL,
    MONTH(DATE(LOWER(SPLIT_PART(DATE,'-',2)),'mon'))
    , SPLIT_PART(DATE,'-',1)) AS FIXED_DATE
    FROM FILLED_YEARS
    WHERE BANK_HOLIDAY != ''
)

, REPORTING_FLAG AS(
SELECT 
BANK_HOLIDAY, NEW_CUSTOMERS
,DATE(N.DATE, 'dd/mm/yyyy') AS NEW_DATE
, CASE
WHEN BANK_HOLIDAY != NULL
OR STARTSWITH(DAYNAME(NEW_DATE),'S')
THEN FALSE
ELSE TRUE
END AS REPORTING_DAY

FROM NEW_DATES
RIGHT JOIN pd2023_wk12_new_customers AS N ON 
NEW_DATE = FIXED_DATE
)

, DATE_CALCS AS(
SELECT *, 
CASE
WHEN REPORTING_DAY = FALSE
THEN NULL
ELSE NEW_DATE
END AS DATE,


COALESCE(DATE,LAG(DATE) IGNORE NULLS OVER(ORDER BY NEW_DATE DESC)) AS FILLED_DATES

,CASE
WHEN FILLED_DATES IS NULL
THEN
    CASE
    WHEN DATE_PART('dayofweek',NEW_DATE) = 0
    THEN DATEADD('day',1,NEW_DATE)
    WHEN DATE_PART('dayofweek',NEW_DATE) = 6
    THEN DATEADD('day',2,NEW_DATE)
    END
ELSE FILLED_DATES
END AS REPORTING_DATES
, DATE_TRUNC('month', REPORTING_DATES) AS REPORTING_MONTH
FROM REPORTING_FLAG
)

,FINAL_CUSTOMERS AS(
SELECT REPORTING_MONTH, DENSE_RANK() OVER(PARTITION BY REPORTING_MONTH ORDER BY REPORTING_DATES ASC) AS REPORTING_DAY, REPORTING_DATES, NEW_CUSTOMERS AS UK_NEW_CUSTOMERS
FROM DATE_CALCS
WHERE REPORTING_MONTH != '2024-01-01'::date
)

SELECT DATE_FROM_PARTS(YEAR(DATE(SPLIT_PART(ROI.REPORTING_MONTH, '-', 2),'yy')),MONTH(DATE(SPLIT_PART(ROI.REPORTING_MONTH, '-', 1),'mon')),DAY(DATE('2010-01-01'))) AS ROI_REPORTING_MONTH,
ROI.REPORTING_DAY AS ROI_REPORTING_DAY, MIN(IFNULL(ROI.NEW_CUSTOMERS,0)) AS ROI_NEW_CUSTOMERS, 
REPORTING_DATES, SUM(IFNULL(UK_NEW_CUSTOMERS,0)) AS UK_NEW_CUSTOMERS, FINAL_CUSTOMERS.REPORTING_MONTH,
    CASE
    WHEN DATE_PART('dayofweek',DATE(REPORTING_DATE, 'dd/mm/yyyy')) = 0
    THEN DATEADD('day',1,DATE(REPORTING_DATE, 'dd/mm/yyyy'))
    WHEN DATE_PART('dayofweek',DATE(REPORTING_DATE, 'dd/mm/yyyy')) = 6
    THEN DATEADD('day',2,DATE(REPORTING_DATE, 'dd/mm/yyyy'))
    ELSE DATE(REPORTING_DATE, 'dd/mm/yyyy')
    END AS ROI_REPORTING_DATE,
    CASE
    WHEN ROI_REPORTING_MONTH != FINAL_CUSTOMERS.REPORTING_MONTH
    THEN TRUE
    ELSE FALSE
    END AS MISALIGNMENT_FLAG
FROM pd2023_wk12_roi_new_customers AS ROI
LEFT JOIN FINAL_CUSTOMERS ON ROI_REPORTING_DATE = REPORTING_DATES
GROUP BY ROI_REPORTING_MONTH, ROI_REPORTING_DAY, REPORTING_DATES, FINAL_CUSTOMERS.REPORTING_MONTH, ROI_REPORTING_DATE, MISALIGNMENT_FLAG




    
