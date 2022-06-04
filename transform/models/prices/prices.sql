{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['interval'],
    'type': 'GIST' }]
) }}

SELECT
    ohlcv.timestamp,
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

{% if is_incremental() %}
WHERE
    ohlcv.timestamp >= (
        SELECT
            MAX(UPPER("interval"))
        FROM
            {{ this }}
        WHERE
            base = base)
        {% endif %}
