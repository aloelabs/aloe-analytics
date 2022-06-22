-- TODO: add support for
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
    {{ ref('balance_changes') }}
