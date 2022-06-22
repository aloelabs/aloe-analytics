{{ config(
    materialized = 'incremental',
    unique_key = 'id',
    indexes = [ { 'columns': ['interval'],
    'type': 'GIST' },{ 'columns': ['symbol', 'timestamp'] },{ 'columns': ['_sdc_extracted_at desc'] }]
) }}

SELECT
    {{ dbt_utils.surrogate_key([ 'symbol', 'timestamp']) }} AS id,
    ohlcv.timestamp,
    LOWER(
        tokens.address
    ) AS token_address,
    tokens.chain_id,
    (
        tsrange(
            ohlcv.timestamp,
            ohlcv.timestamp + ohlcv.timeframe :: INTERVAL
        )
    ) AS "interval",
    ohlcv.timeframe,
    ohlcv.exchange,
    ohlcv.base AS symbol,
    (
        ohlcv.open + ohlcv.close
    ) / 2 AS price,
    _sdc_extracted_at
FROM
    tap_ccxt.ohlcv
    JOIN {{ ref('tokens') }}
    ON base = symbol

{% if is_incremental() %}
WHERE
    ohlcv._sdc_extracted_at >= (
        SELECT
            MAX(_sdc_extracted_at)
        FROM
            {{ this }}
    )
{% endif %}
