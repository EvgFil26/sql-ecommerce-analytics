"""
Run every query from queries/ against shop.db, print the result
and save it to results/<query_name>.csv.

Usage:
    python build_db.py      # once, creates shop.db
    python run_queries.py   # all queries
    python run_queries.py 03   # only queries whose file name starts with 03
"""
import csv
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).parent
QUERIES = ROOT / "queries"
RESULTS = ROOT / "results"


def print_table(header, rows, limit=20):
    widths = [max(len(str(x)) for x in col) for col in zip(header, *rows[:limit])]
    line = "  ".join(f"{h:<{w}}" for h, w in zip(header, widths))
    print(line)
    print("-" * len(line))
    for row in rows[:limit]:
        print("  ".join(f"{str(v):<{w}}" for v, w in zip(row, widths)))
    if len(rows) > limit:
        print(f"... {len(rows) - limit} more rows")


def main() -> None:
    prefix = sys.argv[1] if len(sys.argv) > 1 else ""
    RESULTS.mkdir(exist_ok=True)
    con = sqlite3.connect(ROOT / "shop.db")

    for path in sorted(QUERIES.glob(f"{prefix}*.sql")):
        sql = path.read_text(encoding="utf-8")
        cur = con.execute(sql)
        header = [d[0] for d in cur.description]
        rows = cur.fetchall()

        print(f"\n=== {path.stem} ===")
        print(sql.splitlines()[0])          # first line = comment with the question
        print_table(header, rows)

        with open(RESULTS / f"{path.stem}.csv", "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(header)
            writer.writerows(rows)
    con.close()


if __name__ == "__main__":
    main()
