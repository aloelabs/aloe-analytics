SELECT
    pool_address,
    to_address AS user_address,
    amount,
    "timestamp",
    block_number
FROM
    {{ ref('transfers') }}
WHERE
    to_address != '0x0000000000000000000000000000000000000000'
UNION ALL
SELECT
    pool_address,
    from_address AS user_address,- amount AS amount,
    "timestamp",
    block_number
FROM
    {{ ref('transfers') }}
WHERE
    from_address != '0x0000000000000000000000000000000000000000'
