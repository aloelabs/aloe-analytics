{{ config(
    materialized = 'incremental',
    unique_key = 'id',
    indexes = [ { 'columns': ['pool_address', 'chain_id', 'block_number desc'],},{ 'columns': ['pool_address', 'chain_id', 'block_number', ] },{ 'columns': ['_sdc_extracted_at desc'] },{ 'columns': ['total_supply'] }]
) }}

SELECT
    {{ dbt_utils.surrogate_key([ 'pool_address', 'pools.chain_id', 'pool_returns.block_number' ]) }} AS id,
    pool_returns.block_number,
    pool_returns.interval,
    pool_address,
    total_supply,
    inventory0,
    inventory1,
    pools.chain_id,
    p0.price AS token0_price,
    p1.price AS token1_price,
    (
        inventory0 * p0.price + inventory1 * p1.price
    ) AS tvl,
    (
        inventory0 * p0.price + inventory1 * p1.price
    ) / total_supply AS price,
    GREATEST(
        pool_returns._sdc_extracted_at,
        p0._sdc_extracted_at,
        p1._sdc_extracted_at
    ) AS _sdc_extracted_at
FROM
    {{ ref('pool_returns') }}
    pool_returns
    JOIN {{ ref('pools_with_tokens') }}
    pools USING (pool_address)
    JOIN {{ ref('prices_per_block') }}
    p0
    ON p0.block_number = pool_returns.block_number
    AND pools.token0_symbol = p0.symbol
    JOIN {{ ref('prices_per_block') }}
    p1
    ON p1.block_number = pool_returns.block_number
    AND pools.token1_symbol = p1.symbol
WHERE
    pools.pool_type = 'aloe_blend'

{% if is_incremental() %}
AND GREATEST(
    pool_returns._sdc_extracted_at,
    p0._sdc_extracted_at,
    p1._sdc_extracted_at
) >= (
    SELECT
        MAX(_sdc_extracted_at)
    FROM
        {{ this }}
)
{% endif %}
