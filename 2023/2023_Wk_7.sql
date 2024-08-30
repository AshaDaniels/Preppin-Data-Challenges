-- Techniques
-- 1. LATERAL SPLIT_TO_TABLE
-- 2. CONCAT columns and strings
-- 3. Multiple Join clauses

-- For the Transaction Path table:
-- Make sure field naming convention matches the other tables
-- i.e. instead of Account_From it should be Account From
WITH TRANSACTION_PATH AS(
    SELECT *
    FROM pd2023_wk07_transaction_path
)

-- For the Account Information table:
-- Make sure there are no null values in the Account Holder ID
-- Ensure there is one row per Account Holder ID
-- Joint accounts will have 2 Account Holders, we want a row for each of them
    ,ACCOUNT_INFORMATION AS (
    SELECT 
        A.*EXCLUDE(ACCOUNT_HOLDER_ID), 
        REPLACE(F.VALUE, '"', '') AS ACCOUNT_HOLDER_ID
    FROM pd2023_wk07_account_information AS A
    JOIN LATERAL FLATTEN(INPUT => SPLIT(ACCOUNT_HOLDER_ID, ', ')) AS F
    WHERE ACCOUNT_HOLDER_ID IS NOT NULL
)

-- For the Account Holders table:
-- Make sure the phone numbers start with 07
    ,ACCOUNT_HOLDERS AS(
    SELECT *EXCLUDE(CONTACT_NUMBER), '0'||TO_VARCHAR(contact_number) AS CONTACT_NUMBER
    FROM pd2023_wk07_account_holders
    )

-- Bring the tables together
-- Filter out cancelled transactions 
-- Filter to transactions greater than £1,000 in value 
-- Filter out Platinum accounts
SELECT 
DETAIL.*EXCLUDE(TRANSACTION_ID, CANCELLED_), 
TRANSACTION_PATH.*,
ACCOUNT_INFORMATION.*EXCLUDE(ACCOUNT_HOLDER_ID),
ACCOUNT_HOLDERS.*EXCLUDE(ACCOUNT_HOLDER_ID)
FROM TRANSACTION_PATH
JOIN pd2023_wk07_transaction_detail AS DETAIL ON DETAIL.TRANSACTION_ID = TRANSACTION_PATH.TRANSACTION_ID
JOIN ACCOUNT_INFORMATION ON ACCOUNT_FROM = ACCOUNT_NUMBER
JOIN ACCOUNT_HOLDERS ON ACCOUNT_INFORMATION.ACCOUNT_HOLDER_ID = ACCOUNT_HOLDERS.ACCOUNT_HOLDER_ID
WHERE CANCELLED_ = 'N'
AND VALUE >= 1000
AND ACCOUNT_TYPE != 'Platinum'
