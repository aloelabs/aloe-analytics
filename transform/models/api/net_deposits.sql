SELECT
    blocks_per_user_and_pool.*
FROM
    {{ ref('blocks_per_user_and_pool') }}
