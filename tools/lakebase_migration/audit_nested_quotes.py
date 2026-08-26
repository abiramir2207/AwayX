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
        if not re.match(r'^"[\[\]\w#]+"\s*=', line):
            continue
        eq_idx = line.find("=")
        rhs = line[eq_idx + 1:].strip().rstrip(",").strip()
        # only flag a doubled "" that appears INSIDE a #...# interpolation block -
        # e.g. #query[""Col Name""][row]# (bug). A doubled "" elsewhere on the line
        # (e.g. inside a javaCast("null","") call outside any #...#) is legitimate CFML.
        for hash_m in re.finditer(r"#([^#]*)#", rhs):
            if '""' in hash_m.group(1):
                return True
        # a literal SQL Server bracket-quoted identifier ([col_name]) leaking into the
        # generated key name is also a generator bug (col_name() should have stripped it).
        if re.match(r'^"\[.*\]"\s*=', line):
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

print(f"Total wrappers reverted (nested-quotes audit): {total} across {files_fixed} files")
