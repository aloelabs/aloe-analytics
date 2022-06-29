SELECT
    *
FROM
    {{ ref("aloe_blend") }}
UNION ALL
SELECT
    *
FROM
    {{ ref("g_uni") }}
