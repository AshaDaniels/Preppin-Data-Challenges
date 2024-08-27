-- Query 1: Total Values by Bank
-- This query calculates the total transaction values grouped by bank.
-- It uses the SPLIT_PART function to extract the bank name from the TRANSACTION_CODE.

SELECT SUM(value),
    SPLIT_PART(TRANSACTION_CODE, '-', 1) AS "Bank"
FROM pd2023_wk01
GROUP BY "Bank"
LIMIT 5;

-- Query 2: Total Values by Bank, Day of the Week, and Transaction Type
-- This query calculates the total transaction values grouped by bank, day of the week, 
-- and transaction type (Online or In-Person). It uses the CASE statement to classify transactions
-- and the DAYNAME function to extract the day of the week from the transaction date.

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

-- Query 3: Total Values by Bank and Customer Code
-- This query calculates the total transaction values grouped by bank and customer code.
-- It extracts the bank name from the TRANSACTION_CODE using SPLIT_PART.

SELECT SUM(value), customer_code,
    SPLIT_PART(TRANSACTION_CODE, '-', 1) AS "Bank"
FROM pd2023_wk01
GROUP BY "Bank", customer_code
LIMIT 5;
