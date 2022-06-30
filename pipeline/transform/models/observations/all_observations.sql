SELECT
    *
FROM
    {{ ref("aloe_blend") }}
UNION ALL
SELECT
    *
FROM
    {{ ref("g_uni") }}
UNION ALL
SELECT
    *
FROM
    {{ ref("charm") }}
UNION ALL
SELECT
    *
FROM
    {{ ref("visor") }}
UNION ALL
SELECT
    *
FROM
    {{ ref("uni_v2") }}
UNION ALL
SELECT
    *
FROM
    {{ ref("popsicle") }}
