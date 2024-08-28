-- Techniques:
-- 1. Removing substrings with REPLACE()
-- 2. Joining tables
-- 3. Concatenations

-- In the Transactions table, there is a Sort Code field which contains dashes. We need to remove these so just have a 6 digit string
-- Use the SWIFT Bank Code lookup table to bring in additional information about the SWIFT code and Check Digits of the receiving bank account
-- Add a field for the Country Code
-- Hint: all these transactions take place in the UK so the Country Code should be GB
-- Create the IBAN as above
-- Hint: watch out for trying to combine sting fields with numeric fields - check data types
-- Remove unnecessary fields

SELECT 
    'GB' || CHECK_DIGITS || SWIFT_CODE || REPLACE(SORT_CODE, '-', '') || TO_VARCHAR(ACCOUNT_NUMBER) AS CONCATENATED_SORT_CODE
FROM 
    PD2023_WK02_TRANSACTIONS AS TRANSACTIONS
INNER JOIN 
    PD2023_WK02_SWIFT_CODES AS SWIFT_CODES 
    ON SWIFT_CODES.BANK = TRANSACTIONS.BANK
LIMIT 5;
