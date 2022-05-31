WITH deposits AS (
    SELECT
        pool_address,
        to_address AS user_address,
        CAST(
            amount AS numeric
        ) AS amount,
        "timestamp",
        block_number
    FROM
        {{ ref('pool_token_transfers') }}
    WHERE
        to_address != '0x0000000000000000000000000000000000000000'
),
withdrawals AS (
    SELECT
        pool_address,
        from_address AS user_address,
        CAST(
            amount AS numeric
        ) AS amount,
        "timestamp",
        block_number
    FROM
        {{ ref('pool_token_transfers') }}
    WHERE
        from_address != '0x0000000000000000000000000000000000000000'
),
users AS (
    SELECT
        DISTINCT user_address
    FROM
        deposits
),
blocks_per_user AS (
    SELECT
        blocks.*,
        user_address
    FROM
        {{ ref('blocks') }},
        users
),
deposits_and_withdrawals AS (
    SELECT
        blocks_per_user.*,
        SUM(
            deposits.amount
        ) over (
            PARTITION BY user_address
            ORDER BY
                block_number ASC rows unbounded preceding
        ) AS net_deposits,
        SUM(
            withdrawals.amount
        ) over (
            PARTITION BY user_address
            ORDER BY
                block_number ASC rows unbounded preceding
        ) AS net_withdrawals
    FROM
        blocks_per_user
        LEFT JOIN deposits USING (
            block_number,
            user_address
        )
        LEFT JOIN withdrawals USING (
            block_number,
            user_address
        )
)
SELECT
    *,
    COALESCE(
        net_deposits,
        0
    ) - COALESCE(
        net_withdrawals,
        0
    ) AS balance
FROM
    deposits_and_withdrawals
