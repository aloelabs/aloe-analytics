WITH user_addresses AS (
    SELECT
        DISTINCT user_address
    FROM
        {{ ref('deposits') }}
),
pool_addresses AS (
    SELECT
        chain_id,
        LOWER(pool_address) AS pool_address
    FROM
        {{ ref('pools') }}
    WHERE
        "type" = 'aloe_blend'
)
SELECT
    blocks.*,
    chain_id,
    user_address,
    pool_address
FROM
    {{ ref('blocks') }},
    user_addresses,
    pool_addresses
