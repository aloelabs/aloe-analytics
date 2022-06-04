{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['block_number', 'symbol'],
    'unique': true }]
) }}

SELECT
    block_number,
    base AS "symbol",
    price,
    blocks."timestamp"
FROM
    {{ ref('blocks') }}
    INNER JOIN {{ ref("prices") }}
    ON prices."interval" @> blocks."timestamp" :: TIMESTAMP

{% if is_incremental() %}
WHERE
    block_number > (
        SELECT
            COALESCE(MAX(block_number), 0)
        FROM
            {{ this }}
        WHERE
            symbol = symbol)
        {% endif %}
