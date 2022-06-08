{{ config(
    materialized = 'table',
    indexes = [ { 'columns': ['pool_address'],
    'unique': true }]
) }}

SELECT
    p.*,
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
    ON LOWER(
        p.token0_address
    ) = LOWER(
        t0.address
    )
    JOIN {{ ref(
        'tokens'
    ) }}
    t1
    ON LOWER(
        p.token1_address
    ) = LOWER(
        t1.address
    )
