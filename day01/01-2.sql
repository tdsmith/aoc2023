CREATE MACRO as_value(s) AS
    CASE s
    WHEN 'one' THEN '1'
    WHEN 'two' THEN '2'
    WHEN 'three' THEN '3'
    WHEN 'four' THEN '4'
    WHEN 'five' THEN '5'
    WHEN 'six' THEN '6'
    WHEN 'seven' THEN '7'
    WHEN 'eight' THEN '8'
    WHEN 'nine' THEN '9'
    ELSE s
END;

CREATE MACRO nre() AS '(one|two|three|four|five|six|seven|eight|nine|[0-9])';

WITH calibration AS (
    SELECT
        CAST(
            as_value(regexp_extract(line, '^.*?' || nre(), 1)) ||
            as_value(regexp_extract(line, '^.*' || nre() || '.*?$', 1))
            AS int
        ) AS value
    FROM input
    WHERE len(line) > 0
)

SELECT SUM(value) FROM calibration
