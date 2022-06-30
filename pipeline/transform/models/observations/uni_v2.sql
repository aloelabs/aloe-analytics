{{ config(
    materialized = 'incremental',
    unique_key = 'id',
    indexes = [{ 'columns': ['_sdc_extracted_at desc'] },{ 'columns': ['pool_address'] }]
) }}

SELECT
    {{ dbt_utils.surrogate_key([ 'total_supply.address', 'block_number' ]) }} AS id,
    block_number,
    CAST (
        get_inventory.outputs___reserve0 AS numeric
    ) AS inventory0,
    CAST (
        get_inventory.outputs___reserve1 AS numeric
    ) AS inventory1,
    CAST(
        total_supply.outputs__ AS numeric
    ) AS total_supply,
    LOWER("address") AS pool_address,
    total_supply._sdc_extracted_at
FROM
    tap_ethereum.v2_getters_totalsupply AS total_supply
    JOIN tap_ethereum.v2_getters_getreserves AS get_inventory USING (
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
