{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['block_number', 'symbol'],
    'unique': true }]
) }}

SELECT
    block_number,
    base AS "symbol",
    price,
    "timestamp"
FROM
    {{ ref('blocks') }}
    INNER JOIN {{ ref("prices") }}
    ON "interval" @> "timestamp" :: TIMESTAMP

{% if is_incremental() %}
WHERE
    block_number > (
        SELECT
            MAX(block_number)
        FROM
            {{ this }}
        WHERE
            symbol = symbol
    )
{% endif %}
