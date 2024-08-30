-- Techniques:
-- 1. PIVOT and UNPIVOTs
-- 2. Case Statements 
-- 3. Subqueries for Percentage Totals

-- Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
-- Clean the question categories so they don't have the platform in from of them
-- e.g. Mobile App - Ease of Use should be simply Ease of Use
-- Exclude the Overall Ratings, these were incorrectly calculated by the system
-- Calculate the Average Ratings for each platform for each customer 
-- Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
-- Catergorise customers as being:
    -- Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
    -- Mobile App Fans if difference >= 1
    -- Online Interface Fan
    -- Online Interface Superfan
    -- Neutral if difference is between 0 and 1
-- Calculate the Percent of Total customers in each category, rounded to 1 decimal place

WITH MOBILE_APP AS(
    SELECT customer_id
    ,REPLACE(CATEGORIES, 'MOBILE_APP___', '') AS CATEGORIES
    ,MOBILE_APP_VALUE
    FROM pd2023_wk06_dsb_customer_survey
    UNPIVOT(MOBILE_APP_VALUE FOR CATEGORIES 
    IN(mobile_app___ease_of_access, 
    mobile_app___ease_of_use, 
    mobile_app___likelihood_to_recommend, 
    mobile_app___navigation, 
    mobile_app___overall_rating))
)

    ,ONLINE_INTERFACE AS(
    SELECT customer_id
    ,REPLACE(CATEGORIES, 'ONLINE_INTERFACE___', '') AS CATEGORIES
    ,ONLINE_INTERFACE_VALUE
    FROM pd2023_wk06_dsb_customer_survey
    UNPIVOT(ONLINE_INTERFACE_VALUE FOR CATEGORIES 
    IN(online_interface___ease_of_access, 
    online_interface___ease_of_use, 
    online_interface___likelihood_to_recommend, 
    online_interface___navigation, 
    online_interface___overall_rating))
)

    ,FULL_TABLE AS(
    SELECT ONLINE_INTERFACE.*, MOBILE_APP.*EXCLUDE(CUSTOMER_ID,CATEGORIES) 
    FROM MOBILE_APP
    JOIN ONLINE_INTERFACE ON 
    MOBILE_APP.CUSTOMER_ID = ONLINE_INTERFACE.CUSTOMER_ID
    AND MOBILE_APP.CATEGORIES = ONLINE_INTERFACE.CATEGORIES
    WHERE MOBILE_APP.CATEGORIES NOT LIKE 'OVERALL%'
)

    ,AVG_RATINGS AS(
    SELECT CUSTOMER_ID,
    AVG(ONLINE_INTERFACE_VALUE) AS AVG_ONLINE_INTERFACE_VALUES,
    AVG(MOBILE_APP_VALUE) AS AVG_MOBILE_APP_VALUES,
    AVG_ONLINE_INTERFACE_VALUES - AVG_MOBILE_APP_VALUES AS RATING_DIFFERENCE,
        CASE
        WHEN RATING_DIFFERENCE >=2
        THEN 'Mobile App Superfans'
        WHEN RATING_DIFFERENCE >=1
        THEN 'Mobile App Fans'
        WHEN RATING_DIFFERENCE <=-2
        THEN 'Online Interface Superfan'
        WHEN RATING_DIFFERENCE <=-1
        THEN 'Online Interface Fan'
        ELSE 'Neutral'
        END AS CUSTOMER_CATEGORIES
    FROM FULL_TABLE
    GROUP BY CUSTOMER_ID
)

    ,DENOMINATOR AS(
    SELECT COUNT(CUSTOMER_ID) AS DENOMINATOR
    FROM AVG_RATINGS
)

    ,NUMERATOR AS(
    SELECT COUNT(CUSTOMER_ID) AS NUMERATOR, CUSTOMER_CATEGORIES
    FROM AVG_RATINGS
    GROUP BY CUSTOMER_CATEGORIES
)

SELECT CUSTOMER_CATEGORIES, ROUND(NUMERATOR/DENOMINATOR*100,1) AS PERCENT
FROM DENOMINATOR
JOIN NUMERATOR ON 1=1
LIMIT 5



