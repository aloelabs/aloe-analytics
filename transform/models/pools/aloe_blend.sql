WITH aloe_blend_total_supply AS (
    SELECT
        block_number,
        CAST(
            outputs__ AS bigint
        ) AS total_supply,
        "address"
    FROM
        tap_ethereum.blend_getters_totalsupply
),
aloe_blend_get_inventory AS (
    SELECT
        block_number,
        CAST (
            outputs__inventory0 AS bigint
        ) AS inventory0,
        CAST (
            outputs__inventory1 AS bigint
        ) AS inventory1,
        "address"
    FROM
        tap_ethereum.blend_getters_getinventory
)
SELECT
    *
FROM
    aloe_blend_total_supply
    JOIN aloe_blend_get_inventory USING (
        "address",
        block_number
    )
