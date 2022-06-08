{{ config(
    materialized = 'incremental',
    unique_key = 'id',
    indexes = [ { 'columns': ['from_address'] },{ 'columns': ['to_address'] },{ 'columns': ['_sdc_extracted_at desc'] }]
) }}

SELECT
    {{ dbt_utils.surrogate_key([ 'block_number', 'log_index' ]) }} AS id,
    "timestamp",
    block_number,
    CAST(LOWER(inputs__amount) AS numeric) AS amount,
    LOWER(inputs__from) AS from_address,
    LOWER(inputs__to) AS to_address,
    LOWER("address") AS pool_address,
    log_index,
    GREATEST(
        transfers._sdc_extracted_at,
        blocks._sdc_extracted_at
    ) AS _sdc_extracted_at
FROM
    tap_ethereum.blend_events_transfer transfers
    JOIN {{ ref('blocks') }} USING (block_number)

{% if is_incremental() %}
WHERE
    GREATEST(
        transfers._sdc_extracted_at,
        blocks._sdc_extracted_at
    ) > (
        SELECT
            MAX(_sdc_extracted_at)
        FROM
            {{ this }}
    )
{% endif %}
