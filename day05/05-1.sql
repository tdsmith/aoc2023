WITH RECURSIVE input2 AS (
    SELECT
        row_number() OVER () AS row,
        line
    FROM input
)

, seeds AS (
    SELECT
        UNNEST([
            CAST(i AS bigint) for i in
            string_split(
                string_split(line, ': ')[2],
                ' '
            )
        ]) AS seed_id
    FROM input2
    WHERE row = 1
)

, headings AS (
    SELECT
        row,
        UNNEST(regexp_extract(line, '^(\w+)-to-(\w+) map:', ['source', 'dest']))
    FROM input2
    WHERE regexp_matches(line, '^(\w+)-to-(\w+) map:')
)

, strmaps AS (
    SELECT
        UNNEST(regexp_extract(line, '^(\d+) (\d+) (\d+)$', ['dest_start', 'source_start', 'range_len'])),
        source,
        dest
    FROM (
        SELECT
            line,
            LAG(source, 1 IGNORE NULLS) OVER (ORDER BY row) AS source,
            LAG(dest, 1 IGNORE NULLS) OVER (ORDER BY row) AS dest
        FROM input2
            LEFT JOIN headings USING(row)
    )
    WHERE regexp_matches(line, '^((\d+) )+')
)

, maps AS (
    SELECT
        CAST(dest_start AS bigint) AS dest_start,
        CAST(source_start AS bigint) AS source_start,
        CAST(range_len AS bigint) AS range_len,
        source,
        dest
    FROM strmaps
)

, traverse AS (
    SELECT
        seed_id AS idx,
        'seed' AS source,
        0 AS round
    FROM seeds

    UNION ALL

    SELECT
        COALESCE(
            dest_start + (idx - source_start),
            idx
        ) AS idx,
        headings.dest AS source,
        round + 1 AS round,
    FROM traverse
        INNER JOIN headings ON
            traverse.source = headings.source
        LEFT JOIN maps ON
            traverse.source = maps.source
            AND traverse.idx >= source_start
            AND traverse.idx < source_start + range_len
)

SELECT min(idx) FROM traverse WHERE source = 'location'
