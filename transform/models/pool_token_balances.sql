-- TODO: get pool address working better
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
pools AS (
    SELECT
        DISTINCT pool_address
    FROM
        {{ ref('pools') }}
    WHERE
        "type" = 'aloe_blend'
),
blocks_per_user AS (
    SELECT
        blocks.*,
        user_address,
        pool_address
    FROM
        {{ ref('blocks') }},
        users,
        pools
)
SELECT
    blocks_per_user.*,
    SUM(COALESCE(deposits.amount, 0)) over (
        PARTITION BY user_address,
        pool_address
        ORDER BY
            block_number ASC rows unbounded preceding
    ) - SUM(COALESCE(withdrawals.amount, 0)) over (
        PARTITION BY user_address,
        pool_address
        ORDER BY
            block_number ASC rows unbounded preceding
    ) AS balance
FROM
    blocks_per_user
    LEFT JOIN deposits USING (
        block_number,
        user_address,
        pool_address
    )
    LEFT JOIN withdrawals USING (
        block_number,
        user_address,
        pool_address
    )
