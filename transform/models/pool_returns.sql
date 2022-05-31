WITH observations AS (
    SELECT
        o.block_number,
        p0.timestamp,
        pools.*,
        o.address,
        o.inventory0 / power(
            10,
            pools.token0_decimals
        ) AS inventory0,
        o.inventory1 / power(
            10,
            pools.token1_decimals
        ) AS inventory1,
        p0.price AS token0_price,
        p1.price AS token1_price,
        o.total_supply
    FROM
        {{ ref(
            'aloe_blend'
        ) }}
        o
        JOIN {{ ref('pools_with_tokens') }}
        pools
        ON o.address = pools.pool_address
        JOIN {{ ref('prices_per_block') }}
        p0
        ON o.block_number = p0.block_number
        AND pools.token0_symbol = p0.symbol
        JOIN {{ ref('prices_per_block') }}
        p1
        ON o.block_number = p1.block_number
        AND pools.token1_symbol = p1.symbol
)
SELECT
    *,
    (
        inventory0 * token0_price + inventory1 * token1_price
    ) AS tvl
FROM
    observations
