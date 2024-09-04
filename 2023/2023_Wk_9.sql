-- Techniques:
-- 1. Common Table Expressions 
-- 2. Unions 
-- 3. Running Sums

-- For the Transaction Path table:
-- Make sure field naming convention matches the other tables
-- i.e. instead of Account_From it should be Account From
-- Filter out the cancelled transactions
-- Split the flow into incoming and outgoing transactions 
-- Bring the data together with the Balance as of 31st Jan 
-- Work out the order that transactions occur for each account
-- Hint: where multiple transactions happen on the same day, assume the highest value transactions happen first
-- Use a running sum to calculate the Balance for each account on each day (hint)
-- The Transaction Value should be null for 31st Jan, as this is the starting balance

WITH INCOMING AS(
    SELECT P.*EXCLUDE(ACCOUNT_TO,ACCOUNT_FROM, TRANSACTION_ID), D.*EXCLUDE(CANCELLED_), A.*
    FROM pd2023_wk07_transaction_path as P
    INNER JOIN pd2023_wk07_transaction_detail AS D ON P.TRANSACTION_ID = D.TRANSACTION_ID
    INNER JOIN pd2023_wk07_account_information AS A ON P.ACCOUNT_TO = A.ACCOUNT_NUMBER
    WHERE CANCELLED_ = 'N'
    )

, OUTGOING AS(
    SELECT P.*EXCLUDE(ACCOUNT_TO,ACCOUNT_FROM, TRANSACTION_ID), D.*EXCLUDE(VALUE,CANCELLED_), -D.VALUE AS VALUE, A.*
    FROM pd2023_wk07_transaction_path as P
    INNER JOIN pd2023_wk07_transaction_detail AS D ON P.TRANSACTION_ID = D.TRANSACTION_ID
    INNER JOIN pd2023_wk07_account_information AS A ON P.ACCOUNT_FROM = A.ACCOUNT_NUMBER
    WHERE CANCELLED_ = 'N'
    )

, ALL_TRANSACTIONS AS(
    SELECT ACCOUNT_NUMBER, TRANSACTION_DATE AS BALANCE_DATE, VALUE AS TRANSACTION_VALUE, NULL AS BALANCE
    FROM INCOMING
    UNION ALL 
    SELECT ACCOUNT_NUMBER, TRANSACTION_DATE AS BALANCE_DATE, VALUE AS TRANSACTION_VALUE, NULL 
    FROM OUTGOING
    UNION ALL
    SELECT ACCOUNT_NUMBER, BALANCE_DATE, NULL, BALANCE
    FROM pd2023_wk07_account_information
    )

, RANKED_TRANSACTIONS AS(
    SELECT ALL_TRANSACTIONS.*,
    RANK() OVER(PARTITION 
    BY ALL_TRANSACTIONS.ACCOUNT_NUMBER 
    ORDER BY ALL_TRANSACTIONS.BALANCE_DATE ASC, TRANSACTION_VALUE DESC ) 
    AS RANK,
    FROM ALL_TRANSACTIONS
    )

SELECT *EXCLUDE(RANK, BALANCE),
SUM(COALESCE(TRANSACTION_VALUE, BALANCE)) OVER (
            PARTITION BY ACCOUNT_NUMBER 
            ORDER BY RANK 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS BALANCE
FROM RANKED_TRANSACTIONS



