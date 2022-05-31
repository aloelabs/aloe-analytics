SELECT
    pool_address
FROM
    {{ ref('pools') }}
WHERE
    "type" = 'aloe_blend'
