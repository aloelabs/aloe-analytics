WITH balance_changes AS (
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
)
SELECT
    user_address,
    pool_address,
    SUM(amount) over (
        PARTITION BY user_address,
        pool_address
        ORDER BY
            block_number
    ) / power(
        10,
        18
    ) AS balance,
    tsrange(
        "timestamp" :: TIMESTAMP,
        LEAD("timestamp") over (
            PARTITION BY user_address,
            pool_address
            ORDER BY
                "timestamp"
        ) :: TIMESTAMP
    ) AS "interval"
FROM
    balance_changes
