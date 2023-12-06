CREATE MACRO extract_part(line) AS
    [
        {
            'start': m.start,
            'end': m.end,
            'part': CAST(m.value AS int)
        }
        for m in regexp_match_indices(line, '\d+', 0)
    ]
;

WITH grid AS (
    SELECT
        row_number() OVER () AS r,
        UNNEST(
            [
                {'c': i, 'v': line[i]}
                for i in generate_series(1, strlen(line))
                if regexp_matches(line[i], '[^\d.]')
            ],
            recursive := TRUE
        )
    FROM input
)

, parts AS (
    SELECT
        row_number() OVER () AS r,
        UNNEST(extract_part(line), recursive := TRUE)
    FROM input
)

, hits AS (
    SELECT DISTINCT
        parts.part,
        parts.r,
        parts.start,
        parts."end"
    FROM
        parts,
        UNNEST([parts.r-1, parts.r, parts.r+1]) AS hrows(hr),
        UNNEST(generate_series(parts.start-1, parts.end+1)) AS hcols(hc)
        INNER JOIN grid ON hr = grid.r AND hc = grid.c
)

SELECT SUM(part) FROM hits
