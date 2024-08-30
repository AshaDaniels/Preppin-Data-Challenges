-- Techniques:
-- 1. Date functions
-- 2. Rank functions
-- 3. Common Table Expressions (CTEs)

-- Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
-- Change transaction date to the just be the month of the transaction
-- Total up the transaction values so you have one row for each bank and month combination
-- Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
-- Without losing all of the other data fields, find:
    -- The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
    -- The average transaction value per rank, call this field 'Avg Transaction Value per Rank'

WITH MONTHLY_TRANSACTIONS AS(
    SELECT 
    SPLIT_PART(transaction_code, '-', 1) AS BANK
    , MONTHNAME(DATE(TRANSACTION_DATE, 'DD/MM/YYYY HH24:MI:SS')) AS MONTH
    , SUM(VALUE) AS TOTAL_VALUE
    , RANK() OVER ( PARTITION BY MONTH ORDER BY TOTAL_VALUE DESC) AS MONTH_RANK
    FROM pd2023_wk01
    GROUP BY BANK, MONTH
)

    ,AVG_RANKS AS(
    SELECT AVG(MONTH_RANK) AS AVG_RANK_PER_BANK, BANK
    FROM MONTHLY_TRANSACTIONS
    GROUP BY BANK
)

    ,AVG_TRANSACTIONS AS(
    SELECT AVG(TOTAL_VALUE) AS AVG_VALUE_PER_RANK, MONTH_RANK
    FROM MONTHLY_TRANSACTIONS
    GROUP BY MONTH_RANK
)

SELECT *
FROM MONTHLY_TRANSACTIONS
JOIN AVG_RANKS ON MONTHLY_TRANSACTIONS.BANK = AVG_RANKS.BANK
JOIN AVG_TRANSACTIONS ON AVG_TRANSACTIONS.MONTH_RANK = MONTHLY_TRANSACTIONS.MONTH_RANK
LIMIT 5
