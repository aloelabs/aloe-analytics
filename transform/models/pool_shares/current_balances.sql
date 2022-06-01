WITH total_deposits AS (
    SELECT
        pool_address,
        user_address,
        SUM(
            deposits.amount
        ) over (
            PARTITION BY user_address,
            pool_address
        ) AS amount
    FROM
        {{ ref('deposits') }}
),
total_withdrawals AS (
    SELECT
        pool_address,
        user_address,
        SUM(
            withdrawals.amount
        ) over (
            PARTITION BY user_address,
            pool_address
        ) AS amount
    FROM
        {{ ref('withdrawals') }}
)
SELECT
    user_address,
    pool_address,
    SUM (COALESCE(total_deposits.amount, 0) - COALESCE(total_withdrawals.amount, 0)) over (
        PARTITION BY user_address,
        pool_address
    ) AS balance
FROM
    total_deposits
    LEFT JOIN total_withdrawals USING (
        pool_address,
        user_address
    )
