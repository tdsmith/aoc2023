WITH tokenized AS (
    SELECT
        CAST(regexp_extract(line, 'Game (\d+):', 1) AS int) AS game_id,
        UNNEST(
            list_transform(
                string_split(string_split(line, ': ')[2], '; '),
                x -> string_split(x, ', ')
            ),
            recursive := TRUE
        ) AS playstr
    FROM input
)

, plays AS (
    SELECT
        game_id,
        CAST(string_split(playstr, ' ')[1] AS int) AS n,
        string_split(playstr, ' ')[2] AS color
    FROM tokenized
)

, illegal AS (
    SELECT DISTINCT game_id
    FROM plays
    WHERE (
        (color = 'red' AND n > 12)
        OR (color = 'green' AND n > 13)
        OR (color = 'blue' AND n > 14)
    )
)

SELECT SUM(DISTINCT game_id)
FROM plays
WHERE game_id NOT IN (SELECT game_id FROM illegal)
