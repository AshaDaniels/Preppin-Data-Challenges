-- Techniques:
-- 1. Splitting strings with SPLIT_PART
-- 2. Case Statements
-- 3. Converting strings to dates

-- Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction (help)
-- Rename the new field with the Bank code 'Bank'. 
-- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values. 
-- Change the date to be the day of the week (help)
-- Different levels of detail are required in the outputs. You will need to sum up the values of the transactions in three ways (help):

-- 1. Total Values of Transactions by each bank
SELECT SUM(value),
    SPLIT_PART(TRANSACTION_CODE, '-', 1) AS "Bank"
FROM pd2023_wk01
GROUP BY "Bank"
LIMIT 5;

-- 2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
SELECT SUM(value),
    SPLIT_PART(TRANSACTION_CODE, '-', 1) AS "Bank",
    CASE 
        WHEN online_or_in_person = 1 THEN 'Online'
        WHEN online_or_in_person = 2 THEN 'In Person'
    END as online_or_in_person,
    DAYNAME(TO_TIMESTAMP(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) AS day_of_week
FROM pd2023_wk01
GROUP BY 2, 3, 4
LIMIT 5;

-- 3. Total Values by Bank and Customer Code
SELECT SUM(value), customer_code,
    SPLIT_PART(TRANSACTION_CODE, '-', 1) AS "Bank"
FROM pd2023_wk01
GROUP BY "Bank", customer_code
LIMIT 5;
