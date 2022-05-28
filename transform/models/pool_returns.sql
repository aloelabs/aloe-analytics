-- Create a mapping from pool address to token
-- At every block, what was the price (so match timestamp and calculate holdings)
-- Should I do a SQL course or something?
-- WITH observations_with_timestamps AS(
--     SELECT
--         *
--     FROM
--         {{ ref("aloe_blend") }}
--         JOIN {{ ref("blocks") }} USING (block_number)
-- )
-- SELECT
--     *
-- FROM
--     observations_with_timestamps
--     JOIN {{ ref("prices") }}
--     ON "timestamp" :: TIMESTAMP <@ "interval"
SELECT
    *
FROM
    {{ ref("prices_per_block") }}
