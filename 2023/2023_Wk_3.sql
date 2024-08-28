-- Techniques:
-- 1. Aggregating data and GROUP BY
-- 2. Editing strings with REPLACE and converting them to integers (numerical values)
-- 3. Common Table Expressions (CTEs) and multi-key joins

-- For the transactions file:
-- Filter the transactions to just look at DSB 
-- These will be transactions that contain DSB in the Transaction Code field
-- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
-- Change the date to be the quarter 
-- Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) 

-- For the targets file:
-- Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter 
-- Rename the fields
-- Remove the 'Q' from the quarter field and make the data type numeric 
-- Join the two datasets together 
-- You may need more than one join clause!
-- Remove unnecessary fields
-- Calculate the Variance to Target for each row 

WITH TRANSACTION_CTE AS(
    SELECT SUM(value) as total_value,
        CASE
        WHEN online_or_in_person = 1
        THEN 'Online'
        WHEN online_or_in_person = 2
        THEN 'In-Person'
        END AS online_or_in_person,
        QUARTER(TO_TIMESTAMP(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) as Quarter,
    FROM pd2023_wk01 as TRANSACTION
    WHERE STARTSWITH(transaction_code, 'DSB')
    GROUP BY online_or_in_person, quarter
) 

SELECT target.online_or_in_person, CAST(REPLACE(target.quarter,'Q', '') AS INTEGER) AS Quart_Int, Quarterly_Target, total_value, total_value - Quarterly_Target as Variance_to_target
FROM pd2023_wk03_targets AS target
    UNPIVOT(Quarterly_Target FOR target.quarter IN(Q1,Q2,Q3,Q4))
JOIN TRANSACTION_CTE ON Quart_Int = TRANSACTION_CTE.quarter
    AND target.online_or_in_person = TRANSACTION_CTE.online_or_in_person
