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
