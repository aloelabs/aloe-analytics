{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['user_address', 'pool_address'] },{ 'columns': ['block_number'] },]
) }}

SELECT
    pool_address,
    to_address AS user_address,
    CAST(
        amount AS numeric
    ) AS amount,
    "timestamp",
    block_number
FROM
    {{ ref('transfers') }}
WHERE
    to_address != '0x0000000000000000000000000000000000000000'

{% if is_incremental() %}
AND block_number > (
    SELECT
        MAX(block_number)
    FROM
        {{ this }}
    WHERE
        pool_address = pool_address
)
{% endif %}
