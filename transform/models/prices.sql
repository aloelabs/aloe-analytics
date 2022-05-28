{{ config(
    materialized = "incremental"
) }}

SELECT
    (
        tsrange(
            ohlcv.timestamp,
            ohlcv.timestamp + INTERVAL '1 minute'
        )
    ) AS "interval",
    ohlcv.exchange,
    ohlcv.base,
    ohlcv.quote,
    (
        ohlcv.open + ohlcv.close
    ) / 2 AS price
FROM
    tap_ccxt.ohlcv
