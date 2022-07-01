{{ config(
    materialized = 'table'
) }}
-- Do we have to build an index on total supply?
WITH latest AS (

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
),
share_price_with_lag AS (
    SELECT
        *,
        LAG(total_supply) over (
            PARTITION BY pool_address,
            chain_id
            ORDER BY
                block_number ASC
        ) AS prev_total_supply
    FROM
        {{ ref('share_price') }}
),
inception AS (
    SELECT
        DISTINCT
        ON (
            pool_address,
            chain_id
        ) *
    FROM
        share_price_with_lag
    WHERE
        total_supply > 0
        AND COALESCE(
            prev_total_supply,
            0
        ) = 0
    ORDER BY
        pool_address,
        chain_id,
        block_number DESC
),
apr_before AS (
    SELECT
        DISTINCT
        ON (
            pool_address,
            chain_id
        ) *
    FROM
        {{ ref('share_price') }}
    WHERE
        "interval" @> (now() - INTERVAL '{{ var("apr_days") }} DAYS') :: TIMESTAMP
    ORDER BY
        pool_address,
        chain_id,
        block_number ASC)
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
                latest.inventory0 + latest.inventory1 / (
                    latest.token1_price / latest.token0_price
                )
            ) / (
                inception.inventory0 + inception.inventory1 / (
                    latest.token1_price / latest.token0_price
                )
            ) - 1
        ) * 100 AS performance_since_inception,
        (
            (
                (
                    apr_before.inventory0 * latest.token0_price + apr_before.inventory1 * latest.token1_price
                ) / apr_before.total_supply
            ) / (
                (
                    latest.inventory0 * latest.token0_price + latest.inventory1 * latest.token1_price
                ) / latest.total_supply
            ) - 1
        ) / {{ var("apr_days") }} * 365 AS annual_percentage_rate
    FROM
        {{ ref('pools_with_tokens') }}
        pools
        JOIN apr_before USING (
            pool_address,
            chain_id
        )
        JOIN inception USING (
            pool_address,
            chain_id
        )
        JOIN latest USING (
            pool_address,
            chain_id
        )
    WHERE
        pool_type = 'aloe_blend'
