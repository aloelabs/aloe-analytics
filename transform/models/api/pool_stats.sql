-- TODO: need calculation for APR and perfInception
WITH first_ AS (
    SELECT
        DISTINCT
        ON (
            pool_address,
            chain_id
        ) *
    FROM
        {{ ref('share_price') }}
    ORDER BY
        pool_address,
        chain_id,
        block_number ASC
),
last AS (
    SELECT
        DISTINCT
        ON (
            pool_address,
            chain_id
        ) *
    FROM
        {{ ref('share_price') }}
    ORDER BY
        pool_address,
        chain_id,
        block_number DESC
)
SELECT
    LOWER(pool_address) AS pool_address,
    chain_id,
    (
        SELECT
            tvl
        FROM
            {{ ref('share_price') }}
        WHERE
            pools.pool_address = share_price.pool_address
        ORDER BY
            block_number DESC
        LIMIT
            1
    ) AS total_value_locked,
    (
        (
            last.inventory0 + last.inventory1 / (
                last.token1_price / last.token0_price
            )
        ) / (
            first_.inventory0 + first_.inventory1 / (
                last.token1_price / last.token0_price
            )
        ) - 1
    ) * 100 AS performance_since_inception,
    1 AS annual_percentage_rate
FROM
    {{ ref('pools') }}
    JOIN first_ USING (
        pool_address,
        chain_id
    )
    JOIN last USING (
        pool_address,
        chain_id
    )
WHERE
    pool_type = 'aloe_blend'
