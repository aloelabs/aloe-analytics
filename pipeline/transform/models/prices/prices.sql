{{ config(
    materialized = 'incremental',
    indexes = [ { 'columns': ['interval'],
    'type': 'GIST' }]
) }}

SELECT
    ohlcv.timestamp,
    tokens.address AS token_address,
    tokens.chain_id,
    (
        tsrange(
            ohlcv.timestamp,
            ohlcv.timestamp + ohlcv.timeframe :: INTERVAL
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
    JOIN {{ ref('tokens') }}
    ON base = symbol

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
