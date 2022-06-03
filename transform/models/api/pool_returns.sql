{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['block_number', 'pool_address'],
    'unique': true }]
) }}

SELECT
    observations.block_number,
    blocks.timestamp,
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
    observations.total_supply
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
