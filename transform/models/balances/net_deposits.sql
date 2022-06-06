WITH net_deposit_changes AS (
    SELECT
        balance_changes.*,
        amount * share_price.price AS net_deposit_change
    FROM
        {{ ref('balance_changes') }}
        JOIN {{ ref('share_price') }}
        ON share_price.block_number = balance_changes.block_number
        AND LOWER(
            share_price.pool_address
        ) = LOWER(
            balance_changes.pool_address
        )
)
SELECT
    tsrange(
        "timestamp" :: TIMESTAMP,
        LEAD("timestamp") over (
            PARTITION BY user_address,
            pool_address
            ORDER BY
                "timestamp"
        ) :: TIMESTAMP
    ) AS "interval",
    user_address,
    pool_address,
    SUM(net_deposit_change) over (
        PARTITION BY user_address,
        pool_address
        ORDER BY
            block_number
    ) AS net_deposit
FROM
    net_deposit_changes
