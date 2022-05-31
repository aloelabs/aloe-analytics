WITH deposits AS (
    SELECT
        to_address AS "address",
        amount,
        "timestamp",
        block_number
    FROM
        {{ ref('pool_token_transfers') }}
    WHERE
        to_address != '0x0000000000000000000000000000000000000000'
),
withdrawals AS (
    SELECT
        from_address AS "address",- amount AS amount,
        "timestamp",
        block_number
    FROM
        {{ ref('pool_token_transfers') }}
    WHERE
        from_address != '0x0000000000000000000000000000000000000000'
),
-- use a window function
SELECT
    block_number,
    "timestamp",
    deposits.address,
    SUM(
        deposits.amount
    ) over (
        PARTITION BY "address"
        ORDER BY
            block_number
    ) - SUM(
        withdrawals.amount
    ) over (
        PARTITION BY "address"
        ORDER BY
            block_number
    ) AS balance
FROM
    deposits
    OUTER JOIN withdrawals USING (block_number)
