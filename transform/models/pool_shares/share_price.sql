{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['block_number', 'pool_address'],
    'unique': true }]
) }}

WITH final_ AS (

    SELECT
        pool_returns.block_number,
        pool_address,
        total_supply,
        p0.price AS token0_price,
        p1.price AS token1_price,
        (
            inventory0 * p0.price + inventory1 * p1.price
        ) AS tvl,
        (
            inventory0 * p0.price + inventory1 * p1.price
        ) / total_supply AS price
    FROM
        {{ ref('pool_returns') }}
        pool_returns
        JOIN {{ ref('pools_with_tokens') }}
        pools USING (pool_address)
        JOIN {{ ref('prices_per_block') }}
        p0
        ON pool_returns.block_number = p0.block_number
        AND pools.token0_symbol = p0.symbol
        JOIN {{ ref('prices_per_block') }}
        p1
        ON pool_returns.block_number = p1.block_number
        AND pools.token1_symbol = p1.symbol
    WHERE
        pools.pool_type = 'aloe_blend'
)
SELECT
    *
FROM
    final_

{% if is_incremental() %}
WHERE
    block_number > (
        SELECT
            MAX(block_number)
        FROM
            {{ this }}
        WHERE
            pool_address = pool_address
    )
{% endif %}
