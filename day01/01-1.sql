WITH calibration AS (
    SELECT
        CAST(
            regexp_extract(line, '[^\d]*(\d).*', 1) ||
            regexp_extract(line, '.*(\d)[^\d]*$', 1)
            AS int
        ) AS value
    FROM input
    WHERE len(line) > 0
)

SELECT SUM(value) FROM calibration
