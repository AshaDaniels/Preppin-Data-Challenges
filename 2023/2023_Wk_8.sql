-- Techniques
-- 1. Convert numerical strings to numbers
-- 2. REGEXP expressions
-- 3. Filtering on ranks and window functions

-- Input each of the 12 monthly files
-- Create a 'file date' using the month found in the file name
-- The Null value should be replaced as 1
-- Clean the Market Cap value to ensure it is the true value as 'Market Capitalisation'
-- Remove any rows with 'n/a'
-- Categorise the Purchase Price into groupings
    -- 0 to 24,999.99 as 'Low'
    -- 25,000 to 49,999.99 as 'Medium'
    -- 50,000 to 74,999.99 as 'High'
    -- 75,000 to 100,000 as 'Very High'
-- Categorise the Market Cap into groupings
    -- Below $100M as 'Small'
    -- Between $100M and below $1B as 'Medium'
    -- Between $1B and below $100B as 'Large' 
    -- $100B and above as 'Huge'
-- Rank the highest 5 purchases per combination of: file date, Purchase Price Categorisation and Market Capitalisation Categorisation.
-- Output only records with a rank of 1 to 5

WITH ALL_MONTHS AS(
    SELECT *, 'January' AS FILE_DATE FROM pd2023_wk08_01
    UNION ALL
    SELECT *, 'February' AS FILE_DATE FROM pd2023_wk08_02
    UNION ALL
    SELECT *, 'March' AS FILE_DATE FROM pd2023_wk08_03
    UNION ALL
    SELECT *, 'April' AS FILE_DATE FROM pd2023_wk08_04
    UNION ALL
    SELECT *, 'May' AS FILE_DATE FROM pd2023_wk08_05
    UNION ALL
    SELECT *, 'June' AS FILE_DATE FROM pd2023_wk08_06
    UNION ALL
    SELECT *, 'July' AS FILE_DATE FROM pd2023_wk08_07
    UNION ALL
    SELECT *, 'August' AS FILE_DATE FROM pd2023_wk08_08
    UNION ALL
    SELECT *, 'September' AS FILE_DATE FROM pd2023_wk08_09
    UNION ALL
    SELECT *, 'October' AS FILE_DATE FROM pd2023_wk08_10
    UNION ALL
    SELECT *, 'November' AS FILE_DATE FROM pd2023_wk08_11
    UNION ALL
    SELECT *, 'December' AS FILE_DATE FROM pd2023_wk08_12
)
    ,PRE_RANK AS(
    SELECT *EXCLUDE(MARKET_CAP, purchase_price),
    CASE
    WHEN market_cap LIKE '%M'
    THEN CAST(REGEXP_REPLACE(REPLACE(market_cap, 'M', ''), '[^0-9.]', '') AS FLOAT) * 1000000
    WHEN market_cap LIKE '%B'
    THEN CAST(REGEXP_REPLACE(REPLACE(market_cap, 'B', ''), '[^0-9.]', '') AS FLOAT) * 1000000000
    ELSE CAST(REGEXP_REPLACE(REPLACE(market_cap, 'M', ''), '[^0-9.]', '') AS FLOAT)
    END AS MARKET_CAP,
    CAST(REGEXP_REPLACE(purchase_price, '[^0-9.]', '') AS FLOAT) AS purchase_price,
    FROM ALL_MONTHS
    WHERE MARKET_CAP != 'n/a'
    AND MARKET_CAP IS NOT NULL
)

    ,RANKED_PURCHASES AS(
    SELECT *,
        CASE
        WHEN PURCHASE_PRICE < 24999.99 
        THEN 'Low'
        WHEN PURCHASE_PRICE < 49999.99
        THEN 'Medium'
        WHEN PURCHASE_PRICE < 74999.99
        THEN 'High'
        WHEN PURCHASE_PRICE < 100000
        THEN 'Very High'
        END AS PURCHASE_PRICE_GROUPINGS,
        CASE
        WHEN MARKET_CAP < 100000000
        THEN 'Small'
        WHEN MARKET_CAP < 1000000000
        THEN 'Medium'
        WHEN MARKET_CAP < 100000000000
        THEN 'Large'   
        ELSE 'Huge'
        END AS MARKET_CAP_GROUPINGS,
        RANK() OVER(PARTITION BY file_date, PURCHASE_PRICE_GROUPINGS, MARKET_CAP_GROUPINGS ORDER BY purchase_price DESC) AS RANKINGS
    FROM PRE_RANK
)

SELECT
Market_Cap_Groupings,
Purchase_Price_Groupings,
File_Date,
Ticker,
Sector,
Market,
Stock_Name,
Market_Cap,
Purchase_Price,
Rankings
FROM RANKED_PURCHASES
WHERE RANKINGS <= 5
