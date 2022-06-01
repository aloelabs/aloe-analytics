-- TODO: get pool address working better
WITH users AS (
    SELECT
        DISTINCT user_address
    FROM
        {{ ref('deposits') }}
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
