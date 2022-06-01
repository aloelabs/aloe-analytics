SELECT
    blocks_per_user_and_pool.*,
    SUM(COALESCE(deposits.amount, 0) - COALESCE(withdrawals.amount, 0)) over (
        PARTITION BY user_address,
        pool_address
        ORDER BY
            block_number
    ) AS balance
FROM
    {{ ref('blocks_per_user_and_pool') }}
    LEFT JOIN {{ ref('deposits') }} USING (
        block_number,
        user_address,
        pool_address
    )
    LEFT JOIN {{ ref('withdrawals') }} USING (
        block_number,
        user_address,
        pool_address
    )
