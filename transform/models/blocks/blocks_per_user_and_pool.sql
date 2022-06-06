{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['pool_address', 'user_address', 'block_number'] },]
) }}

WITH initial_deposits AS (

    SELECT
        DISTINCT
        ON (
            pool_address,
            user_address
        ) pool_address,
        user_address,
        block_number
    FROM
        {{ ref('deposits') }}
    ORDER BY
        pool_address,
        user_address,
        block_number ASC
)
SELECT
    blocks.*,
    user_address,
    pool_address
FROM
    initial_deposits
    JOIN {{ ref('blocks') }}
    ON blocks.block_number >= initial_deposits.block_number

{% if is_incremental() %}
WHERE
    block_number > (
        SELECT
            MAX(block_number)
        FROM
            {{ this }}
        WHERE
            pool_address = pool_address
    )
{% endif %}
