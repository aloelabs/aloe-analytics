{{ config(
    materialized = 'incremental',
    unique_key = 'id',
    indexes = [{ 'columns': ['_sdc_extracted_at desc'] },{ 'columns': ['pool_address'] }]
) }}

SELECT
    {{ dbt_utils.surrogate_key([ 'total_supply.address', 'block_number' ]) }} AS id,
    block_number,
    CAST (
        outputs__inventory0 AS numeric
    ) AS inventory0,
    CAST (
        outputs__inventory1 AS numeric
    ) AS inventory1,
    CAST(
        outputs__ AS numeric
    ) AS total_supply,
    "address" AS pool_address,
    total_supply._sdc_extracted_at
FROM
    tap_ethereum.blend_getters_totalsupply AS total_supply
    JOIN tap_ethereum.blend_getters_getinventory AS get_inventory USING (
        "address",
        block_number
    )

{% if is_incremental() %}
WHERE
    total_supply._sdc_extracted_at > (
        SELECT
            MAX(_sdc_extracted_at)
        FROM
            {{ this }}
    )
{% endif %}
