{{ config(
    materialized = 'incremental',
    unique_key = 'block_number',
    indexes = [ {'columns': ['block_number'] },{ 'columns': ['block_number desc'] },{ 'columns': ['_sdc_extracted_at desc'] },{ 'columns': ['timestamp'] }]
) }}

WITH blocks_with_timestamps AS (

    SELECT
        TO_TIMESTAMP(CAST("timestamp" AS bigint)) AS TIMESTAMP,
        CAST(
            "id" AS bigint
        ) AS block_number,
        _sdc_extracted_at
    FROM
        tap_thegraph.mainnet_block
)
SELECT
    *,
    tsrange(
        "timestamp" :: TIMESTAMP,
        LEAD(TIMESTAMP) over (
            ORDER BY
                block_number ASC
        ) :: TIMESTAMP
    ) AS "interval"
FROM
    blocks_with_timestamps

{% if is_incremental() %}
WHERE
    block_number >= (
        SELECT
            MAX(block_number)
        FROM
            {{ this }}
    )
{% endif %}
