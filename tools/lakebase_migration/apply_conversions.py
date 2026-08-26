"""
Applies AUTO-GENERATED proposals from a proposed/<rel-path>/<file>.PROPOSED.txt
report (produced by generate_conversions.py) back into the real source file,
by wrapping the original <cfquery>/<cfstoredproc> block with the standard
useLakebaseForX / <cftry> / <cfcatch> idiom.

Only proposals with STATUS: AUTO-GENERATED are applied. NEEDS_MANUAL_REVIEW
entries are left untouched (still SQL-only).

Safe to re-run: skips any query that already has a matching
"useLakebaseFor<QueryName>" cfset in the file.

Usage:
    python apply_conversions.py <relative-folder-under-AwayX-root>
    e.g. python apply_conversions.py DEDUCTIONS
"""
import argparse
import re
from pathlib import Path

PROPOSAL_HEADER_RE = re.compile(
    r"===== QUERY: (.+?) =====\nSTATUS: (AUTO-GENERATED[^\n]*|NEEDS_MANUAL_REVIEW[^\n]*)\n\n",
)
QUERY_TAG_RE_TMPL = r"(<cf(query|storedproc)\s+name\s*=\s*[\"']{name}[\"'][^>]*>.*?</cf\2>)"

# known human work-in-progress files this automation must never touch
EXCLUDE_FILES = {"enter.cfm"}


def load_proposals(proposal_file: Path):
    # Body length varies (NEEDS_MANUAL_REVIEW entries have none) so we can't rely on
    # a fixed trailing-newline count to find each block's end - find header positions
    # independently first, then slice the body between consecutive headers.
    text = proposal_file.read_text(encoding="utf-8", errors="ignore")
    headers = list(PROPOSAL_HEADER_RE.finditer(text))
    out = []
    for i, m in enumerate(headers):
        name, status = m.group(1), m.group(2)
        body_start = m.end()
        body_end = headers[i + 1].start() if i + 1 < len(headers) else len(text)
        body = text[body_start:body_end].strip()
        if status.startswith("AUTO-GENERATED"):
            out.append((name, body))
    return out



def apply_to_file(src_path: Path, proposals: list[tuple[str, str]]) -> tuple[int, int]:
    text = src_path.read_text(encoding="utf-8", errors="ignore")
    applied, skipped = 0, 0
    for name, wrapper in proposals:
        var_name = f"useLakebaseFor{name.replace('.', '_')}"
        if var_name in text:
            skipped += 1
            continue
        rx = re.compile(QUERY_TAG_RE_TMPL.format(name=re.escape(name)), re.IGNORECASE | re.DOTALL)
        m = rx.search(text)
        if not m:
            skipped += 1
            continue
        original_block = m.group(1)
        new_block = wrapper.replace(
            "-- ORIGINAL QUERY BLOCK GOES HERE (kept from source) --", original_block
        )
        text = text[: m.start(1)] + new_block + text[m.end(1) :]
        applied += 1
    if applied:
        src_path.write_text(text, encoding="utf-8")
    return applied, skipped


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("subfolder", help="relative folder under AwayX root, e.g. DEDUCTIONS")
    parser.add_argument("--root", default=r"D:\Resers_AwayX\AwayX")
    args = parser.parse_args()

    root = Path(args.root)
    proposed_root = Path(__file__).parent / "proposed"
    target_dir = root / args.subfolder

    total_applied, total_skipped, files_touched = 0, 0, 0
    for proposal_file in proposed_root.rglob("*.PROPOSED.txt"):
        rel = proposal_file.relative_to(proposed_root)
        src_rel = Path(str(rel)[: -len(".PROPOSED.txt")])
        src_path = root / src_rel
        if target_dir not in src_path.parents and src_path.parent != target_dir:
            continue
        if not src_path.exists():
            continue
        if src_path.name in EXCLUDE_FILES:
            continue
        proposals = load_proposals(proposal_file)
        if not proposals:
            continue
        applied, skipped = apply_to_file(src_path, proposals)
        if applied:
            files_touched += 1
        total_applied += applied
        total_skipped += skipped

    print(f"Files touched: {files_touched}")
    print(f"Queries applied: {total_applied}")
    print(f"Queries skipped (already converted / not found): {total_skipped}")


if __name__ == "__main__":
    main()
