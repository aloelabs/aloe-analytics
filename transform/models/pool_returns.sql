-- Create a mapping from pool address to token
-- At every block, what was the price (so match timestamp and calculate holdings)
-- Should I do a SQL course or something?
-- WITH observations_with_timestamps AS(
--     SELECT
--         *
--     FROM
--         {{ ref("aloe_blend") }}
--         JOIN {{ ref("blocks") }} USING (block_number)
-- )
-- SELECT
--     *
-- FROM
--     observations_with_timestamps
--     JOIN {{ ref("prices") }}
--     ON "timestamp" :: TIMESTAMP <@ "interval"
-- aloe_blend.address -> pools.address token
WITH observations AS (
    SELECT
        o.block_number,
        p0.timestamp,
        p0.symbol AS token0_symbol,
        p1.symbol AS token1_symbol,
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
        p1.price AS token1_price
    FROM
        {{ ref(
            'aloe_blend'
        ) }}
        o
        JOIN {{ ref('pools_with_symbols') }}
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
