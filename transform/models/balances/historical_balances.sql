-- TODO: get pool address working better
WITH user_addresses AS (
    SELECT
        DISTINCT user_address
    FROM
        {{ ref('deposits') }}
),
pool_addresses AS (
    SELECT
        DISTINCT LOWER(pool_address) AS pool_address
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
        user_addresses,
        pool_addresses
)
SELECT
    blocks_per_user.*,
    SUM(COALESCE(deposits.amount, 0) - COALESCE(withdrawals.amount, 0)) over (
        PARTITION BY user_address,
        pool_address
        ORDER BY
            block_number
    ) AS balance
FROM
    blocks_per_user
    LEFT JOIN {{ ref('deposits') }} USING (
        block_number,
        user_address,
        pool_address
    )
    LEFT JOIN {{ ref('withdrawals') }} USING (
        block_number,
        user_address,
        pool_address
    )
