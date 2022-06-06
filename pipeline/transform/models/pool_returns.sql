{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['pool_address', 'chain_id'] },{ 'columns': ['block_number'] },{ 'columns': ['block_interval'],
    'type': 'GIST' }]
) }}

SELECT
    observations.block_number,
    blocks.interval AS block_interval,
    blocks.timestamp AS block_timestamp,
    pools.pool_address,
    pools.pool_type,
    pools.chain_id,
    observations.inventory0 / power(
        10,
        pools.token0_decimals
    ) AS inventory0,
    observations.inventory1 / power(
        10,
        pools.token1_decimals
    ) AS inventory1,
    NULLIF(
        observations.total_supply,
        0
    ) / power(
        10,
        18
    ) AS total_supply
FROM
    {{ ref(
        'aloe_blend'
    ) }}
    observations
    JOIN {{ ref('pools_with_tokens') }}
    pools USING (pool_address)
    JOIN {{ ref('blocks') }} USING (block_number)

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
