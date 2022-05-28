SELECT
    block_number,
    base AS "symbol",
    price,
    "timestamp"
FROM
    {{ ref('blocks') }}
    INNER JOIN {{ ref("prices") }}
    ON "interval" @> "timestamp" :: TIMESTAMP
