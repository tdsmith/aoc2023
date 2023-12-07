WITH blocked AS (
    SELECT
        UNNEST(
            regexp_extract(
                line,
                'Card\s+(\d+):\s+([\d ]+)\s+\|\s+([\d ]+)',
                ['card', 'winning', 'ours']
            )
        )
    FROM input
)

, split AS (
    SELECT
        card,
        [CAST(i AS int) for i in string_split_regex(winning, '\s+')] AS winning,
        [CAST(i AS int) for i in string_split_regex(ours, '\s+')] AS ours
    FROM blocked
)

, intersection AS (
    SELECT
        *,
        list_intersect(winning, ours) AS wins
    FROM split
)

, scored AS (
    SELECT
        *,
        2^(len(wins) - 1) AS score
    FROM intersection
    WHERE len(wins) > 0
)

SELECT SUM(score) FROM scored
