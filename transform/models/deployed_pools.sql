SELECT
    chain_id,
    LOWER(pool_address) AS pool_address
FROM
    {{ ref('pools') }}
WHERE
    pool_type = 'aloe_blend'
