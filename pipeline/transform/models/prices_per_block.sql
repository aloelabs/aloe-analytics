{{ config(
    materialized = 'incremental',
    unique_key = 'id',
    indexes = [ { 'columns': ['symbol', 'block_number'] },{ 'columns': ['_sdc_extracted_at desc'] },]
) }}

SELECT
    DISTINCT
    ON (
        block_number,
        symbol
    ) {{ dbt_utils.surrogate_key([ 'symbol', 'block_number']) }} AS id,
    block_number,
    symbol,
    price,
    blocks."timestamp",
    GREATEST(
        blocks._sdc_extracted_at,
        prices._sdc_extracted_at
    ) AS _sdc_extracted_at
FROM
    {{ ref('blocks') }}
    JOIN {{ ref("prices") }}
    ON prices."interval" @> blocks."timestamp" :: TIMESTAMP

{% if is_incremental() %}
WHERE
    GREATEST(
        blocks._sdc_extracted_at,
        prices._sdc_extracted_at
    ) > (
        SELECT
            MAX(_sdc_extracted_at)
        FROM
            {{ this }}
    )
{% endif %}
ORDER BY
    block_number,
    symbol,
    UPPER(
        prices."interval"
    ) - LOWER(
        prices."interval"
    ) ASC
