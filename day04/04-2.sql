WITH RECURSIVE blocked AS (
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
        CAST(card AS int) AS card,
        [CAST(i AS int) for i in string_split_regex(winning, '\s+')] AS winning,
        [CAST(i AS int) for i in string_split_regex(ours, '\s+')] AS ours
    FROM blocked
)

, pile AS (
    SELECT
        *,
        len(list_intersect(winning, ours)) AS n_wins
    FROM split
)

, deck AS (
    SELECT
        card,
        n_wins,
        0 AS round
    FROM pile

    UNION ALL

    SELECT
        pile.card,
        pile.n_wins,
        deck.round + 1 AS round
    FROM
        deck
        INNER JOIN pile ON (
            pile.card > deck.card AND
            pile.card <= deck.card + deck.n_wins
        )
)

SELECT COUNT(*) FROM deck
