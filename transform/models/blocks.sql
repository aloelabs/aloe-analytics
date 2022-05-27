{{ config(
    materialized = "incremental"
) }}

SELECT
    TO_TIMESTAMP(CAST(mainnet_block.timestamp AS bigint)) AS TIMESTAMP,
    CAST(
        mainnet_block.id AS bigint
    ) AS block_number
FROM
    tap_thegraph.mainnet_block -- TODO: fix the replication key for tap-thegraph (it always starts from the beginning)
