{{ config(
    materialized = 'table'
) }}

SELECT
    (
        SELECT
            COUNT(1)
        FROM
            {{ ref('pools') }}
        WHERE
            pool_type = 'aloe_blend'
    ) AS pool_count,
    (
        SELECT
            COUNT(
                DISTINCT user_address
            )
        FROM
            {{ ref('current_balances') }}
        WHERE
            balance > 0
    ) AS users,
    (
        SELECT
            COALESCE(SUM(total_value_locked), 0)
        FROM
            {{ ref('pool_stats') }}
    ) AS total_value_locked
