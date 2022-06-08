{{ config(
    materialized = 'incremental',
    unique_key = 'id',
    indexes = [ { 'columns': ['pool_address', 'chain_id', 'block_number'] },{ 'columns': ['interval'],
    'type': 'GIST' },{ 'columns': ['_sdc_extracted_at desc'] }]
) }}

SELECT
    {{ dbt_utils.surrogate_key([ 'pool_address', 'chain_id', 'block_number' ]) }} AS id,
    observations.block_number,
    blocks.interval,
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
    NULLIF(
        observations.total_supply,
        0
    ) / power(
        10,
        18
    ) AS total_supply,
    GREATEST(
        observations._sdc_extracted_at,
        blocks._sdc_extracted_at
    ) AS _sdc_extracted_at
FROM
    {{ ref('observations') }}
    JOIN {{ ref('pools_with_tokens') }}
    pools USING (pool_address)
    JOIN {{ ref('blocks') }} USING (block_number)

{% if is_incremental() %}
WHERE
    GREATEST(
        observations._sdc_extracted_at,
        blocks._sdc_extracted_at
    ) > (
        SELECT
            MAX(_sdc_extracted_at)
        FROM
            {{ this }}
    )
{% endif %}
