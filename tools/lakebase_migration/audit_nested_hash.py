import re
from pathlib import Path

root = Path(r"D:\Resers_AwayX\AwayX")
# known human work-in-progress files this automation must never touch
EXCLUDE_FILES = {"enter.cfm"}

WRAPPER_RE = re.compile(
    r"<cfset\s+(useLakebaseFor\w+)\s*=\s*application\.oLakebase\.isEnabled\(\).*?"
    r"<cfif\s+NOT\s+\1\s*>\s*(.*?)\s*</cfif>",
    re.DOTALL | re.IGNORECASE,
)


def wrapper_is_broken(wrapper_text: str) -> bool:
    idx = wrapper_text.find("<cfcatch")
    struct_part = wrapper_text[:idx] if idx != -1 else wrapper_text
    for line in struct_part.splitlines():
        line = line.strip()
        if not re.match(r'^"[\w#]+"\s*=', line):
            continue
        eq_idx = line.find("=")
        if eq_idx == -1:
            continue
        rhs = line[eq_idx + 1:].strip().rstrip(",").strip()
        if not (rhs.startswith('"') and rhs.endswith('"')):
            continue
        inner = rhs[1:-1]
        # a clean value has either 0 '#' (plain literal) or exactly 2 (one interpolation).
        # More than 2 means nested/complex expression - not safely representable.
        hash_count = inner.count("#")
        if hash_count not in (0, 2):
            return True
    return False


total = 0
files_fixed = 0
for f in list(root.rglob("*.cfm")) + list(root.rglob("*.cfc")):
    if "tools\\lakebase_migration" in str(f) or "tools/lakebase_migration" in str(f):
        continue
    if f.name in EXCLUDE_FILES:
        continue
    try:
        text = f.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        continue
    if "useLakebaseFor" not in text:
        continue
    count = 0

    def replace(m):
        global count
        whole = m.group(0)
        if wrapper_is_broken(whole):
            count += 1
            return m.group(2)
        return whole

    new_text = WRAPPER_RE.sub(replace, text)
    if count:
        f.write_text(new_text, encoding="utf-8")
        total += count
        files_fixed += 1
        print(f"FIXED {count} in {f}")

print(f"Total wrappers reverted (nested-hash audit): {total} across {files_fixed} files")
