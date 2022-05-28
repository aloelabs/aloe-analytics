-- Create a mapping from pool address to token
SELECT
    *
FROM
    {{ ref("aloe_blend") }}
