import re
import sys
from pprint import pprint
from pathlib import Path

import duckdb


re_type = duckdb.typing.DuckDBPyType(list[{"start": int, "end": int, "value": str}])

def regexp_match_indices(string: str, pattern: str, group: int = 0):
    matches = []
    for match in re.finditer(pattern, string):
        matches.append(dict(start=match.start()+1, end=match.end(), value=match[group]))
    return matches

con = duckdb.connect()
con.create_function("regexp_match_indices", regexp_match_indices, [str, str, int], re_type)
con.execute("CREATE TABLE input(line varchar)")
con.execute(f"COPY input (line) FROM '{sys.argv[2]}' (DELIMITER '', ESCAPE '', QUOTE '')")
con.execute(Path(sys.argv[1]).read_text())
pprint(con.fetchall())
