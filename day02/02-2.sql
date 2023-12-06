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

, mincubes AS (
    SELECT
        game_id,
        color,
        MAX(n) AS n
    FROM plays
    GROUP BY game_id, color
)

, powers AS (
    SELECT
        game_id,
        product(n) AS pow
    FROM mincubes
    GROUP BY game_id
)

SELECT SUM(pow) FROM powers
