{{ config(
    materialized = 'table'
) }}
-- Do we have to build an index on total supply?   
WITH inception AS (

    SELECT
        DISTINCT
        ON (
            pool_address,
            chain_id
        ) *
    FROM
        {{ ref('share_price') }}
    WHERE
        total_supply > 0
        AND LAG(COALESCE(total_supply, 0)) = 0 over (
            PARTITION BY pool_address,
            chain_id
            ORDER BY
                block_number ASC
        )
    ORDER BY
        pool_address,
        chain_id,
        block_number DESC
),
before AS (
    SELECT
        DISTINCT
        ON (
            pool_address,
            chain_id
        ) *
    FROM
        {{ ref('share_price') }}
    WHERE
        inventory0 > 0
        OR inventory1 > 0
),
after AS (
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
            pools.pool_address ILIKE share_price.pool_address
        ORDER BY
            block_number DESC
        LIMIT
            1
    ) AS total_value_locked,
    (
        (
            after.inventory0 + after.inventory1 / (
                after.token1_price / after.token0_price
            )
        ) / (
            inception.inventory0 + inception.inventory1 / (
                after.token1_price / after.token0_price
            )
        ) - 1
    ) * 100 AS performance_since_inception,
    1 AS annual_percentage_rate
FROM
    {{ ref('pools_with_tokens') }}
    pools
    JOIN inception USING (
        pool_address,
        chain_id
    )
    JOIN after USING (
        pool_address,
        chain_id
    )
WHERE
    pool_type = 'aloe_blend'
