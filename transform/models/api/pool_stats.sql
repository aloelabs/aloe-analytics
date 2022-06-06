-- TODO: need calculation for APR and perfInception
WITH cte AS (
    SELECT
        *,
        ROW_NUMBER() over (
            PARTITION BY pool_address
            ORDER BY
                block_number ASC
        ) AS rn0,
        ROW_NUMBER() over (
            PARTITION BY pool_address
            ORDER BY
                block_number DESC
        ) AS rn1
    FROM
        {{ ref('share_price') }}
)
SELECT
    LOWER(
        pools.pool_address
    ) AS pool_address,
    pools.chain_id,
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
    JOIN cte AS first_
    ON first_.pool_address = pools.pool_address
    AND first_.rn0 = 1
    JOIN cte AS last
    ON last.pool_address = pools.pool_address
    AND last.rn1 = 1
WHERE
    pool_type = 'aloe_blend'
