{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['from_address'] },{ 'columns': ['to_address'] },]
) }}

SELECT
    "timestamp",
    block_number,
    inputs__amount AS amount,
    inputs__from AS from_address,
    inputs__to AS to_address,
    "address" AS pool_address
FROM
    tap_ethereum.blend_events_transfer
    JOIN {{ ref('blocks') }} USING (block_number)

{% if is_incremental() %}
WHERE
    block_number > (
        SELECT
            MAX(block_number)
        FROM
            {{ this }}
    )
{% endif %}
