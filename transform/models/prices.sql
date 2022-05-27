WITH blocks AS (
    SELECT
        *
    FROM
        {{ ref('blocks') }}
),
prices AS (
    SELECT
        ohlcv.timestamp,
        ohlcv.exchange,
        ohlcv.base,
        ohlcv.quote,
        (
            ohlcv.open + ohlcv.close
        ) / 2 AS price
    FROM
        tap_ccxt.ohlcv
)
SELECT
    prices.timestamp,
    blocks.timestamp
FROM
    prices
    CROSS JOIN LATERAL (
        SELECT
            blocks.timestamp
        FROM
            blocks
        ORDER BY
            prices.timestamp <-> blocks.timestamp
        LIMIT
            1
    ) AS blocks
