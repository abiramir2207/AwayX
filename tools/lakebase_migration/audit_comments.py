import re
from pathlib import Path
root = Path(r"D:\Resers_AwayX\AwayX")
COMMENT_RE = re.compile(r"<!---.*?--->", re.DOTALL)
WRAPPER_RE = re.compile(
    r"<cfset\s+(useLakebaseFor\w+)\s*=\s*application\.oLakebase\.isEnabled\(\).*?"
    r"<cfif\s+NOT\s+\1\s*>\s*(.*?)\s*</cfif>",
    re.DOTALL | re.IGNORECASE,
)

total = 0
files_fixed = 0
for f in list(root.rglob("*.cfm")) + list(root.rglob("*.cfc")):
    if "tools\\lakebase_migration" in str(f) or "tools/lakebase_migration" in str(f):
        continue
    try:
        text = f.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        continue
    if "useLakebaseFor" not in text:
        continue
    changed = False
    out = []
    for m in COMMENT_RE.finditer(text):
        start, end = m.span()
        comment_text = m.group(0)
        if "useLakebaseFor" not in comment_text:
            continue
        new_comment = WRAPPER_RE.sub(lambda wm: wm.group(2), comment_text)
        if new_comment != comment_text:
            out.append((start, end, new_comment))
            changed = True
    if not changed:
        continue
    for start, end, new_comment in sorted(out, key=lambda x: -x[0]):
        text = text[:start] + new_comment + text[end:]
    f.write_text(text, encoding="utf-8")
    n = len(out)
    total += n
    files_fixed += 1
    print(f"FIXED {n} in {f}")
print(f"Total comment-injection fixed: {total} across {files_fixed} files")
