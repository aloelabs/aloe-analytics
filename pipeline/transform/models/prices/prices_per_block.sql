{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['block_number', 'symbol'],
    'unique': true }]
) }}

SELECT
    DISTINCT
    ON (
        block_number,
        base
    ) block_number,
    base AS "symbol",
    price,
    blocks."timestamp"
FROM
    {{ ref('blocks') }}
    JOIN {{ ref("prices") }}
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
        ORDER BY
            block_number,
            base,
            UPPER(
                prices."interval"
            ) - LOWER(
                prices."interval"
            ) ASC
