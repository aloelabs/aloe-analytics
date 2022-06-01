{{ config(
    materialized = 'incremental',
    unique_key = 'block_number',
    indexes = [ {'columns': ['block_number'] },{ 'columns': ['timestamp'] }]
) }}

SELECT
    TO_TIMESTAMP(CAST("timestamp" AS bigint)) AS TIMESTAMP,
    CAST(
        "id" AS bigint
    ) AS block_number
FROM
    tap_thegraph.mainnet_block

{% if is_incremental() %}
WHERE
    CAST(
        "id" AS bigint
    ) > (
        SELECT
            MAX(block_number)
        FROM
            {{ this }}
    )
{% endif %}
