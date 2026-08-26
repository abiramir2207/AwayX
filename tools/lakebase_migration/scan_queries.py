"""
Scans the AwayX ColdFusion codebase for <cfquery>/<cfstoredproc> blocks and
classifies each one to speed up the SQL Server -> Lakebase REST conversion.

Usage:
    python scan_queries.py [root_dir] [--csv out.csv]

Output: a CSV report (one row per query) plus a summary printed to stdout.

Classification per query:
  - tables: table name(s) extracted from FROM/UPDATE/INSERT INTO/JOIN clauses
  - has_join_or_union: contains JOIN or UNION keywords (join client not supported)
  - has_subquery: contains a nested SELECT (correlated/derived subquery)
  - in_transaction: falls inside a <cftransaction>...</cftransaction> scope
    (Lakebase REST calls cannot participate in that transaction's rollback)
  - already_converted: a "useLakebaseFor<QueryName>" cfset already exists in the file
  - verdict: SAFE_TO_CONVERT / DEFER_JOIN_OR_UNION / DEFER_SUBQUERY /
             DEFER_TRANSACTION / ALREADY_CONVERTED
"""
import argparse
import csv
import re
import sys
from pathlib import Path

QUERY_RE = re.compile(
    r"<cf(query|storedproc)\s+name\s*=\s*[\"']([^\"']+)[\"'][^>]*>(.*?)</cf\1>",
    re.IGNORECASE | re.DOTALL,
)
TXN_RE = re.compile(
    r"<cftransaction\b[^>]*>(.*?)</cftransaction>",
    re.IGNORECASE | re.DOTALL,
)
COMMENT_RE = re.compile(r"<!---.*?--->", re.DOTALL)
JOIN_UNION_RE = re.compile(r"\b(JOIN|UNION)\b", re.IGNORECASE)
FROM_TABLE_RE = re.compile(r"\bFROM\s+([A-Za-z_][A-Za-z0-9_\.]*)", re.IGNORECASE)
UPDATE_TABLE_RE = re.compile(r"\bUPDATE\s+([A-Za-z_][A-Za-z0-9_\.]*)", re.IGNORECASE)
INSERT_TABLE_RE = re.compile(r"\bINSERT\s+INTO\s+([A-Za-z_][A-Za-z0-9_\.]*)", re.IGNORECASE)
SELECT_COUNT_RE = re.compile(r"\bSELECT\b", re.IGNORECASE)
LAKEBASE_CONVERTED_RE = re.compile(r"useLakebaseFor(\w+)", re.IGNORECASE)


def find_tables(sql: str) -> list[str]:
    tables = set()
    for rx in (FROM_TABLE_RE, UPDATE_TABLE_RE, INSERT_TABLE_RE):
        tables.update(m.group(1) for m in rx.finditer(sql))
    return sorted(tables)


def classify_file(path: Path) -> list[dict]:
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return []

    txn_spans = [m.span() for m in TXN_RE.finditer(text)]
    comment_spans = [m.span() for m in COMMENT_RE.finditer(text)]
    converted_names = {m.group(1).lower() for m in LAKEBASE_CONVERTED_RE.finditer(text)}

    rows = []
    for m in QUERY_RE.finditer(text):
        tag, name, sql = m.group(1), m.group(2), m.group(3)
        start = m.start()
        in_txn = any(s <= start < e for s, e in txn_spans)
        in_comment = any(s <= start < e for s, e in comment_spans)
        already = name.replace(".", "_").lower() in converted_names or any(
            name.lower() in cn or cn in name.lower() for cn in converted_names
        )
        has_join_union = bool(JOIN_UNION_RE.search(sql))
        select_count = len(SELECT_COUNT_RE.findall(sql))
        has_subquery = select_count > 1
        tables = find_tables(sql)

        if already:
            verdict = "ALREADY_CONVERTED"
        elif in_comment:
            verdict = "DEFER_COMMENTED_OUT"
        elif in_txn:
            verdict = "DEFER_TRANSACTION"
        elif has_join_union:
            verdict = "DEFER_JOIN_OR_UNION"
        elif has_subquery:
            verdict = "DEFER_SUBQUERY"
        elif len(tables) > 1:
            verdict = "DEFER_MULTI_TABLE"
        else:
            verdict = "SAFE_TO_CONVERT"

        rows.append(
            {
                "file": str(path),
                "tag": tag.lower(),
                "query_name": name,
                "tables": ";".join(tables),
                "has_join_or_union": has_join_union,
                "has_subquery": has_subquery,
                "in_transaction": in_txn,
                "already_converted": already,
                "verdict": verdict,
            }
        )
    return rows


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=r"D:\Resers_AwayX\AwayX")
    parser.add_argument("--csv", default="migration_report.csv")
    args = parser.parse_args()

    root = Path(args.root)
    files = list(root.rglob("*.cfm")) + list(root.rglob("*.cfc"))

    all_rows = []
    for f in files:
        all_rows.extend(classify_file(f))

    out_path = Path(__file__).parent / args.csv
    with out_path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=list(all_rows[0].keys()) if all_rows else [])
        writer.writeheader()
        writer.writerows(all_rows)

    # Summary
    from collections import Counter

    verdict_counts = Counter(r["verdict"] for r in all_rows)
    print(f"Scanned {len(files)} files, found {len(all_rows)} query blocks.")
    print(f"Report written to: {out_path}")
    print()
    for verdict, count in verdict_counts.most_common():
        print(f"  {verdict:24s} {count}")

    safe_by_file = Counter(
        r["file"] for r in all_rows if r["verdict"] == "SAFE_TO_CONVERT"
    )
    print("\nTop 25 files by number of SAFE_TO_CONVERT queries (best quick wins):")
    for file, count in safe_by_file.most_common(25):
        print(f"  {count:3d}  {file}")


if __name__ == "__main__":
    sys.exit(main())
