WITH latest AS (
    SELECT
        MAX(block_number) AS block_number
    FROM
        {{ ref('blocks') }}
)
SELECT
    (
        SELECT
            COUNT(1)
        FROM
            {{ ref('pools') }}
        WHERE
            "type" = 'aloe_blend'
    ) AS pool_count,
    -- (
    --     SELECT
    --         COUNT(1)
    --     FROM
    --         {{ ref('pool_token_balances') }}
    --     WHERE
    --         block_number = latest.block_number
    --         AND balance > 0
    -- ) AS users,(
    (
        SELECT
            COALESCE(SUM(tvl), 0)
        FROM
            {{ ref('pool_returns') }}
        WHERE
            block_number = latest.block_number
            AND "type" = 'aloe_blend'
    ) AS tvl
FROM
    latest
