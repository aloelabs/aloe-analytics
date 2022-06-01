-- TODO: need calculation for APR and perfInception
SELECT
    LOWER(pool_address) AS pool_address,
    chain_id,
    (
        SELECT
            tvl
        FROM
            {{ ref('share_price') }}
        WHERE
            pool_address = pool_address
        ORDER BY
            block_number DESC
        LIMIT
            1
    ) AS tvl
FROM
    {{ ref('pools') }}
WHERE
    "type" = 'aloe_blend'
