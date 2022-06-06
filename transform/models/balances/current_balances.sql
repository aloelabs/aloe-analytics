SELECT
    DISTINCT
    ON (
        user_address,
        pool_address
    ) *
FROM
    {{ ref('historical_balances') }}
ORDER BY
    user_address,
    pool_address,
    LOWER("interval") DESC
