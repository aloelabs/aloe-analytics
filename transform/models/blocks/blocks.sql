{{ config(
    materialized = 'incremental',
    unique_key = 'block_number',
    indexes = [ {'columns': ['block_number'] },{ 'columns': ['timestamp'] }]
) }}

WITH blocks_with_timestamps AS (

    SELECT
        TO_TIMESTAMP(CAST("timestamp" AS bigint)) AS TIMESTAMP,
        CAST(
            "id" AS bigint
        ) AS block_number
    FROM
        tap_thegraph.mainnet_block
)
SELECT
    b0.*,
    tsrange(
        b0.timestamp :: TIMESTAMP,
        b1.timestamp :: TIMESTAMP
    ) AS "interval"
FROM
    blocks_with_timestamps b0
    LEFT JOIN blocks_with_timestamps b1
    ON b0.block_number = b1.block_number - 1

{% if is_incremental() %}
WHERE
    b0.block_number > (
        SELECT
            MAX(block_number)
        FROM
            {{ this }}
    )
{% endif %}
