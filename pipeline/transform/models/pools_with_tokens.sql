{{ config(
    materialized = 'table',
    indexes = [ { 'columns': ['pool_address'],
    'unique': true }]
) }}

SELECT
    LOWER(pool_address) AS pool_address,
    pool_type,
    p.chain_id,
    LOWER(token0_address) AS token0_address,
    LOWER(token1_address) AS token1_address,
    t0.symbol AS token0_symbol,
    t0.decimals AS token0_decimals,
    t1.symbol AS token1_symbol,
    t1.decimals AS token1_decimals
FROM
    {{ ref('pools') }}
    p
    JOIN {{ ref(
        'tokens'
    ) }}
    t0
    ON p.token0_address ILIKE t0.address
    JOIN {{ ref(
        'tokens'
    ) }}
    t1
    ON p.token1_address ILIKE t1.address
