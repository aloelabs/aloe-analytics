SELECT
    chain_id,
    pool_address
FROM
    {{ ref('pools') }}
WHERE
    pool_type = 'aloe_blend'
