"""
Generates Lakebase conversion wrappers for queries classified SAFE_TO_CONVERT
by scan_queries.py, WITHOUT touching the original source files (this repo has
no git / version control, so bulk in-place edits are not applied automatically).

For each SAFE_TO_CONVERT query it attempts to parse:
  - SELECT col1,col2 FROM table WHERE a='x' AND b=1 [AND c IN (...)] [ORDER BY ...] [TOP N]
  - UPDATE table SET col=val, col2=val2 WHERE a='x' AND b=1
  - INSERT INTO table (col1,col2) VALUES (val1,val2)

Only simple, flat (AND-only, no OR/parens/functions-on-columns) WHERE clauses
are auto-generated. Anything else is marked NEEDS_MANUAL_REVIEW with a reason.

Output: writes one <file>.PROPOSED.txt per source file next to this script
(under proposed/ mirroring the relative path) containing, for each query:
  - the original <cfquery> block
  - the generated wrapper (if auto-generatable) or the reason it was skipped

Nothing is written back into the AwayX source tree. A human (or a follow-up
"apply" pass, after this repo is put under version control) applies the
proposed changes.

Usage:
    python generate_conversions.py [--csv migration_report.csv] [--root D:\\Resers_AwayX\\AwayX]
"""
import argparse
import csv
import re
from pathlib import Path

QUERY_RE_TMPL = r"<cf(query|storedproc)\s+name\s*=\s*[\"']{name}[\"'][^>]*>(.*?)</cf\1>"

SELECT_RE = re.compile(
    r"SELECT\s+(?:(?:DISTINCT|TOP\s+\d+)\s+)*(.*?)\s+FROM\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:WHERE\s+(.*?))?(?:\s+ORDER\s+BY\s+(.*?))?\s*;?\s*$",
    re.IGNORECASE | re.DOTALL,
)
TOP_N_RE = re.compile(r"SELECT\s+(?:DISTINCT\s+)?TOP\s+(\d+)", re.IGNORECASE)
UPDATE_RE = re.compile(
    r"UPDATE\s+([A-Za-z_][A-Za-z0-9_]*)\s+SET\s+(.*?)\s+WHERE\s+(.*?)\s*;?\s*$",
    re.IGNORECASE | re.DOTALL,
)
INSERT_HEADER_RE = re.compile(r"INSERT\s+INTO\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.IGNORECASE)
DELETE_RE = re.compile(
    r"DELETE\s+FROM\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:WHERE\s+(.*?))?\s*;?\s*$",
    re.IGNORECASE | re.DOTALL,
)
# Single "belongs-to" join: main table joined to exactly one lookup/reference table
# on a simple equality, with WHERE/ORDER BY only referencing the main table's alias.
JOIN_SELECT_RE = re.compile(
    r"SELECT\s+(?:(?:DISTINCT|TOP\s+\d+)\s+)*(.*?)\s+FROM\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\s+(?:AS\s+)?([A-Za-z_][A-Za-z0-9_]*)\s+"
    r"(INNER|LEFT(?:\s+OUTER)?)\s+JOIN\s+"
    r"([A-Za-z_][A-Za-z0-9_]*)\s+(?:AS\s+)?([A-Za-z_][A-Za-z0-9_]*)\s+"
    r"ON\s+([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)"
    r"(?:\s+WHERE\s+(.*?))?(?:\s+ORDER\s+BY\s+(.*?))?\s*;?\s*$",
    re.IGNORECASE | re.DOTALL,
)


def extract_paren_group(s: str, open_idx: int) -> tuple[str, int]:
    """s[open_idx] must be '('. Returns (inner_content, index_after_closing_paren), or (None, -1)."""
    depth = 0
    for i in range(open_idx, len(s)):
        if s[i] == "(":
            depth += 1
        elif s[i] == ")":
            depth -= 1
            if depth == 0:
                return s[open_idx + 1 : i], i + 1
    return None, -1

# Reject WHERE/SET clauses containing these - too risky to auto-generate.
UNSAFE_RE = re.compile(
    r"\bOR\b|\(|\)|CASE\b|CAST\s*\(|CONVERT\s*\(|LEN\s*\(|TRIM\s*\(|COALESCE\s*\(|ISNULL\s*\(|SUM\s*\(|COUNT\s*\(",
    re.IGNORECASE,
)
# Any embedded CFML tag/comment anywhere in the query body means the SQL is
# built conditionally at runtime - never safe to auto-generate a wrapper for.
EMBEDDED_CFML_RE = re.compile(r"<cf\w+|<!---", re.IGNORECASE)
CF_COMMENT_RE = re.compile(r"<!---.*?--->", re.DOTALL)
SQL_COMMENT_RE = re.compile(r"/\*.*?\*/", re.DOTALL)
# A value is only safe to auto-generate if it's a literal/NULL/CF-interpolation/
# GetDate() - anything else (bare column refs, arithmetic like "col + 1",
# concatenation, function calls) must be rejected rather than guessed at.
SIMPLE_VALUE_RE = re.compile(r"^(NULL|'[^']*'|-?\d+(\.\d+)?|#[^#]*#|GetDate\s*\(\s*\))$", re.IGNORECASE)


def is_simple_value(v: str) -> bool:
    """Stricter than SIMPLE_VALUE_RE alone: also rejects quoted strings whose inner
    content contains nested CFML complexity (multiple #...# segments, function calls
    like evaluate()) that a bare apostrophe-free check would otherwise let through."""
    if not SIMPLE_VALUE_RE.match(v):
        return False
    if v.startswith("'") and v.endswith("'"):
        inner = v[1:-1]
    elif v.startswith("#") and v.endswith("#"):
        inner = v[1:-1]
    else:
        return True
    if inner.count("#") not in (0, 2):
        return False
    if re.search(r"\b[A-Za-z_]\w*\s*\(", inner):
        return False
    return True


def strip_cf_comments(sql: str) -> str:
    """CF comments are inert - safe to remove before parsing/dynamic-SQL checks."""
    return CF_COMMENT_RE.sub(" ", sql)


def strip_sql_comments(sql: str) -> str:
    """SQL /* ... */ comments are inert - safe to remove before parsing."""
    return SQL_COMMENT_RE.sub(" ", sql)


def split_top_level(s: str, sep_word: str) -> list[str]:
    """Split on a bare AND/comma at paren-depth 0."""
    parts, depth, buf = [], 0, ""
    tokens = re.split(r"(\(|\))", s)
    joined = "".join(tokens)
    pattern = re.compile(rf"\s+{sep_word}\s+", re.IGNORECASE) if sep_word == "AND" else re.compile(r",")
    pos = 0
    for m in pattern.finditer(joined):
        chunk = joined[pos : m.start()]
        if joined[:m.start()].count("(") == joined[:m.start()].count(")"):
            parts.append(chunk)
            pos = m.end()
    parts.append(joined[pos:])
    return [p.strip() for p in parts if p.strip()]


COND_RE = re.compile(
    r"^([A-Za-z_][A-Za-z0-9_\.]*)\s*(=|<>|!=|IS\s+NOT\s+NULL|IS\s+NULL|IN)\s*(.*)$",
    re.IGNORECASE | re.DOTALL,
)


def col_name(qualified: str) -> str:
    return qualified.strip().split(".")[-1].lower()


def has_dynamic_identifier(*parts: str) -> bool:
    """True if any table/column name contains '#' - a CFML variable used as a
    dynamic SQL identifier (not a value), which the simple REST client can't express."""
    return any("#" in p for p in parts)


def sql_value_to_cf(v: str) -> str:
    v = v.strip()
    if v.upper() == "NULL":
        return None
    if re.match(r"GetDate\s*\(\s*\)", v, re.IGNORECASE):
        return "#now()#"
    if v.startswith("'") and v.endswith("'"):
        v = v[1:-1]
    # values get embedded in a double-quoted CFML string literal in the generated
    # wrapper - any literal " in the value must be escaped as "" or it breaks the parser.
    return v.replace('"', '""')


def parse_where_to_filters(where: str):
    """Returns dict of postgrest filters, or None if unsafe/unsupported."""
    if UNSAFE_RE.search(where):
        return None
    conds = split_top_level(where, "AND")
    filters = {}
    for c in conds:
        m = COND_RE.match(c.strip())
        if not m:
            return None
        col, op, rest = m.group(1), m.group(2).upper().replace("  ", " "), m.group(3).strip()
        pg_col = col_name(col)
        if op == "=":
            if not is_simple_value(rest) or sql_value_to_cf(rest) is None:
                return None
            filters[pg_col] = f'"eq.{sql_value_to_cf(rest)}"'
        elif op in ("<>", "!="):
            if not is_simple_value(rest) or sql_value_to_cf(rest) is None:
                return None
            filters[pg_col] = f'"neq.{sql_value_to_cf(rest)}"'
        elif op.startswith("IS NOT"):
            filters[pg_col] = '"not.is.null"'
        elif op.startswith("IS"):
            filters[pg_col] = '"is.null"'
        elif op == "IN":
            inner = rest.strip()
            if inner.startswith("(") and inner.endswith(")"):
                inner = inner[1:-1]
            filters[pg_col] = f'"in.({inner})"'
        else:
            return None
    return filters


def gen_select_wrapper(query_name: str, sql: str) -> tuple[str, str]:
    sql = strip_sql_comments(strip_cf_comments(sql))
    if EMBEDDED_CFML_RE.search(sql):
        return None, "query body contains embedded CFML tags (dynamic SQL) - review manually"
    top_m = TOP_N_RE.search(sql)
    m = SELECT_RE.search(sql.strip())
    if not m:
        return None, "SELECT pattern did not match parser"
    cols_raw, table, where, order_by = m.group(1), m.group(2), m.group(3), m.group(4)
    if UNSAFE_RE.search(cols_raw):
        return None, "SELECT column list contains functions/CASE - review manually"
    if re.search(r"\bAS\b", cols_raw, re.IGNORECASE) or '"' in cols_raw:
        return None, "SELECT column list uses aliasing (AS) - review manually"
    cols = [c.strip() for c in cols_raw.split(",")]
    is_star = cols_raw.strip() == "*"
    if has_dynamic_identifier(table, *cols):
        return None, "table/column name is a dynamic CFML variable (#...#) - review manually"
    pg_table = table.lower()
    filters = {}
    if where:
        filters = parse_where_to_filters(where)
        if filters is None:
            return None, "WHERE clause too complex (OR/parens/functions) - review manually"
    if order_by:
        order_by = order_by.strip()
        if UNSAFE_RE.search(order_by) or "," in order_by or has_dynamic_identifier(order_by):
            return None, "ORDER BY too complex - review manually"
        parts = order_by.split()
        ocol = col_name(parts[0])
        odir = "desc" if len(parts) > 1 and parts[1].upper() == "DESC" else "asc"
        filters["order"] = f'"{ocol}.{odir}"'
    if top_m:
        filters["limit"] = f'"{top_m.group(1)}"'
    if not is_star:
        filters["select"] = '"' + ",".join(col_name(c) for c in cols) + '"'

    var_name = f"useLakebaseFor{query_name.replace('.', '_')}"
    params_lines = "\n".join(f'\t\t\t\t"{k}" = {v},' for k, v in filters.items())
    params_block = "{\n" + params_lines.rstrip(",") + "\n\t\t\t}" if filters else "{}"
    select_cols_arg = ("," + ",".join(col_name(c) for c in cols)) if not is_star else ""
    to_query_cols = ', "' + ",".join(col_name(c) for c in cols) + '"' if not is_star else ""

    wrapper = f'''<cfset {var_name} = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("{pg_table}")>
<cfif {var_name}>
\t<cftry>
\t\t<cfset {query_name} = application.oLakebase.toQuery(
\t\t\tapplication.oLakebase.selectRows("{pg_table}", {params_block}){to_query_cols}
\t\t)>
\t\t<cfcatch type="any">
\t\t\t<cfset {var_name} = false>
\t\t</cfcatch>
\t</cftry>
</cfif>
<cfif NOT {var_name}>
-- ORIGINAL QUERY BLOCK GOES HERE (kept from source) --
</cfif>'''
    return wrapper, None


def gen_join_select_wrapper(query_name: str, sql: str) -> tuple[str, str]:
    """Handles exactly one supported shape: SELECT ... FROM main a JOIN lookup b
    ON a.fk = b.pk [WHERE <a-only conditions>] [ORDER BY <a-only column>].
    Uses application.oLakebase.selectRowsJoin() - a two-query belongs-to join that
    doesn't depend on any server-side FK/embed configuration. Rejects anything with
    more than one JOIN, aggregates/DISTINCT/GROUP BY, or WHERE/ORDER BY referencing
    the lookup table's alias (those need a human to decide semantics)."""
    sql = strip_sql_comments(strip_cf_comments(sql))
    if EMBEDDED_CFML_RE.search(sql):
        return None, "query body contains embedded CFML tags (dynamic SQL) - review manually"
    sql_stripped = sql.strip()
    if len(re.findall(r"\bJOIN\b", sql_stripped, re.IGNORECASE)) != 1:
        return None, "more than one JOIN - review manually"
    if re.search(r"\bGROUP\s+BY\b|\bDISTINCT\b|\bUNION\b|\bHAVING\b", sql_stripped, re.IGNORECASE):
        return None, "GROUP BY/DISTINCT/UNION/HAVING with a join - review manually"
    m = JOIN_SELECT_RE.search(sql_stripped)
    if not m:
        return None, "JOIN SELECT pattern did not match parser (multi-condition ON, self-join, etc.) - review manually"
    (cols_raw, table1, alias1, jointype, table2, alias2,
     on_a, on_a_col, on_b, on_b_col, where, order_by) = m.groups()
    if UNSAFE_RE.search(cols_raw):
        return None, "SELECT column list contains functions/CASE - review manually"
    if re.search(r"\bAS\b", cols_raw, re.IGNORECASE) or '"' in cols_raw:
        return None, "SELECT column list uses aliasing (AS) - review manually"
    if has_dynamic_identifier(table1, table2, cols_raw):
        return None, "table/column name is a dynamic CFML variable (#...#) - review manually"
    if alias1.lower() == alias2.lower():
        return None, "ambiguous aliases - review manually"

    # figure out which alias is on which side of the ON condition
    if on_a.lower() == alias1.lower() and on_b.lower() == alias2.lower():
        fk_col, lookup_key_col = on_a_col, on_b_col
    elif on_a.lower() == alias2.lower() and on_b.lower() == alias1.lower():
        fk_col, lookup_key_col = on_b_col, on_a_col
    else:
        return None, "ON condition does not reference both aliases directly - review manually"

    # WHERE/ORDER BY must only touch the main table's alias
    if where and re.search(rf"\b{re.escape(alias2)}\.", where, re.IGNORECASE):
        return None, "WHERE clause references the joined/lookup table - review manually"
    if order_by and re.search(rf"\b{re.escape(alias2)}\.", order_by, re.IGNORECASE):
        return None, "ORDER BY references the joined/lookup table - review manually"

    cols = [c.strip() for c in cols_raw.split(",")]
    main_cols, lookup_cols = [], []
    for c in cols:
        if "." not in c:
            return None, "SELECT column without a table alias prefix - review manually"
        c_alias, c_col = c.split(".", 1)
        if c_alias.lower() == alias1.lower():
            main_cols.append(c_col.strip())
        elif c_alias.lower() == alias2.lower():
            lookup_cols.append(c_col.strip())
        else:
            return None, "SELECT column references an unknown alias - review manually"
    if not lookup_cols:
        return None, "no columns selected from the joined table - review manually"
    main_col_names = {col_name(c) for c in main_cols}
    lookup_col_names = {col_name(c) for c in lookup_cols}
    if main_col_names & lookup_col_names:
        return None, "main/lookup column name collision - review manually"

    filters = {}
    if where:
        filters = parse_where_to_filters(where)
        if filters is None:
            return None, "WHERE clause too complex (OR/parens/functions) - review manually"
    if order_by:
        order_by = order_by.strip()
        if UNSAFE_RE.search(order_by) or "," in order_by or has_dynamic_identifier(order_by):
            return None, "ORDER BY too complex - review manually"
        parts = order_by.split()
        ocol = col_name(parts[0].split(".")[-1])
        odir = "desc" if len(parts) > 1 and parts[1].upper() == "DESC" else "asc"
        filters["order"] = f'"{ocol}.{odir}"'

    fk_col_pg = col_name(fk_col)
    all_main_select_cols = sorted(main_col_names | {fk_col_pg})
    filters["select"] = '"' + ",".join(all_main_select_cols) + '"'

    var_name = f"useLakebaseFor{query_name.replace('.', '_')}"
    pg_table1 = table1.lower()
    pg_table2 = table2.lower()
    params_lines = "\n".join(f'\t\t\t\t"{k}" = {v},' for k, v in filters.items())
    params_block = "{\n" + params_lines.rstrip(",") + "\n\t\t\t}" if filters else "{}"
    all_cols = sorted(main_col_names) + sorted(lookup_col_names)
    to_query_cols = ', "' + ",".join(all_cols) + '"'
    lookup_select = ",".join(sorted(lookup_col_names))

    wrapper = f'''<cfset {var_name} = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("{pg_table1}") AND application.oLakebase.isTableMigrated("{pg_table2}")>
<cfif {var_name}>
\t<cftry>
\t\t<cfset {query_name} = application.oLakebase.toQuery(
\t\t\tapplication.oLakebase.selectRowsJoin("{pg_table1}", {params_block}, "{fk_col_pg}", "{pg_table2}", "{col_name(lookup_key_col)}", "{lookup_select}"){to_query_cols}
\t\t)>
\t\t<cfcatch type="any">
\t\t\t<cfset {var_name} = false>
\t\t</cfcatch>
\t</cftry>
</cfif>
<cfif NOT {var_name}>
-- ORIGINAL QUERY BLOCK GOES HERE (kept from source) --
</cfif>'''
    return wrapper, None


def gen_update_wrapper(query_name: str, sql: str) -> tuple[str, str]:
    sql = strip_sql_comments(strip_cf_comments(sql))
    if EMBEDDED_CFML_RE.search(sql):
        return None, "query body contains embedded CFML tags (dynamic SQL) - review manually"
    m = UPDATE_RE.search(sql.strip())
    if not m:
        return None, "UPDATE pattern did not match parser"
    table, set_clause, where = m.group(1), m.group(2), m.group(3)
    if has_dynamic_identifier(table):
        return None, "table name is a dynamic CFML variable (#...#) - review manually"
    filters = parse_where_to_filters(where)
    if filters is None:
        return None, "WHERE clause too complex - review manually"
    sets = split_top_level(set_clause, ",")
    data = {}
    for s in sets:
        if "=" not in s:
            return None, "Could not parse SET assignment"
        col, val = s.split("=", 1)
        val = val.strip()
        if has_dynamic_identifier(col):
            return None, "SET column name is a dynamic CFML variable (#...#) - review manually"
        if not is_simple_value(val):
            return None, "SET clause too complex - review manually"
        data[col_name(col)] = sql_value_to_cf(val)

    var_name = f"useLakebaseFor{query_name.replace('.', '_')}"
    pg_table = table.lower()
    filter_lines = "\n".join(f'\t\t\t\t"{k}" = {v},' for k, v in filters.items())
    data_lines = "\n".join(
        f'\t\t\t\t"{k}" = javaCast("null",""),' if v is None else f'\t\t\t\t"{k}" = "{v}",'
        for k, v in data.items()
    )
    wrapper = f'''<cfset {var_name} = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("{pg_table}")>
<cfif {var_name}>
\t<cftry>
\t\t<cfset application.oLakebase.updateRows("{pg_table}",
\t\t\t{{
{filter_lines.rstrip(",")}
\t\t\t}},
\t\t\t{{
{data_lines.rstrip(",")}
\t\t\t}}
\t\t)>
\t\t<cfcatch type="any">
\t\t\t<cfset {var_name} = false>
\t\t</cfcatch>
\t</cftry>
</cfif>
<cfif NOT {var_name}>
-- ORIGINAL QUERY BLOCK GOES HERE (kept from source) --
</cfif>'''
    return wrapper, None


def gen_insert_wrapper(query_name: str, sql: str) -> tuple[str, str]:
    sql = strip_sql_comments(strip_cf_comments(sql))
    if EMBEDDED_CFML_RE.search(sql):
        return None, "query body contains embedded CFML tags (dynamic SQL) - review manually"
    m = INSERT_HEADER_RE.search(sql.strip())
    if not m:
        return None, "INSERT pattern did not match parser"
    table = m.group(1)
    cols_raw, after_cols_idx = extract_paren_group(sql, m.end() - 1)
    if cols_raw is None:
        return None, "could not find balanced INSERT column list"
    remainder = sql[after_cols_idx:]
    vm = re.search(r"VALUES\s*\(", remainder, re.IGNORECASE)
    if not vm:
        return None, "VALUES clause not found"
    vals_raw, _ = extract_paren_group(remainder, vm.end() - 1)
    if vals_raw is None:
        return None, "could not find balanced VALUES list"

    cols = [c.strip() for c in cols_raw.split(",")]
    vals = split_top_level(vals_raw, ",")
    if len(cols) != len(vals):
        return None, "INSERT column/value count mismatch - review manually"
    if any(not is_simple_value(v.strip()) for v in vals):
        return None, "INSERT VALUES contain functions/expressions - review manually"
    if has_dynamic_identifier(table, *cols):
        return None, "table/column name is a dynamic CFML variable (#...#) - review manually"

    var_name = f"useLakebaseFor{query_name.replace('.', '_')}"
    pg_table = table.lower()
    data = {col_name(c): sql_value_to_cf(v) for c, v in zip(cols, vals)}
    data_lines = "\n".join(
        f'\t\t\t"{k}" = javaCast("null",""),' if v is None else f'\t\t\t"{k}" = "{v}",'
        for k, v in data.items()
    )
    wrapper = f'''<cfset {var_name} = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("{pg_table}")>
<cfif {var_name}>
\t<cftry>
\t\t<cfset application.oLakebase.insertRow("{pg_table}", {{
{data_lines.rstrip(",")}
\t\t}})>
\t\t<cfcatch type="any">
\t\t\t<cfset {var_name} = false>
\t\t</cfcatch>
\t</cftry>
</cfif>
<cfif NOT {var_name}>
-- ORIGINAL QUERY BLOCK GOES HERE (kept from source) --
</cfif>'''
    return wrapper, None


def gen_delete_wrapper(query_name: str, sql: str) -> tuple[str, str]:
    sql = strip_sql_comments(strip_cf_comments(sql))
    if EMBEDDED_CFML_RE.search(sql):
        return None, "query body contains embedded CFML tags (dynamic SQL) - review manually"
    m = DELETE_RE.match(sql.strip())
    if not m:
        return None, "DELETE pattern did not match parser"
    table, where = m.group(1), m.group(2)
    if has_dynamic_identifier(table):
        return None, "table name is a dynamic CFML variable (#...#) - review manually"
    filters = {}
    if where:
        filters = parse_where_to_filters(where)
        if filters is None:
            return None, "WHERE clause too complex (OR/parens/functions) - review manually"

    var_name = f"useLakebaseFor{query_name.replace('.', '_')}"
    pg_table = table.lower()
    filter_lines = "\n".join(f'\t\t\t"{k}" = {v},' for k, v in filters.items())
    filter_block = "{\n" + filter_lines.rstrip(",") + "\n\t\t}" if filters else "{}"
    wrapper = f'''<cfset {var_name} = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("{pg_table}")>
<cfif {var_name}>
\t<cftry>
\t\t<cfset application.oLakebase.deleteRows("{pg_table}", {filter_block})>
\t\t<cfcatch type="any">
\t\t\t<cfset {var_name} = false>
\t\t</cfcatch>
\t</cftry>
</cfif>
<cfif NOT {var_name}>
-- ORIGINAL QUERY BLOCK GOES HERE (kept from source) --
</cfif>'''
    return wrapper, None


def process_file(root: Path, out_root: Path, file_rel: str, query_names: list[str]):
    src = root / file_rel
    try:
        text = src.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return 0, 0, []

    comment_spans = [m.span() for m in re.finditer(r"<!---.*?--->", text, re.DOTALL)]

    generated, skipped, details = 0, 0, []
    for qname in query_names:
        if "#" in qname:
            skipped += 1
            details.append((qname, None, "query name itself is a dynamic CFML variable (#...#) - review manually"))
            continue
        rx = re.compile(QUERY_RE_TMPL.format(name=re.escape(qname)), re.IGNORECASE | re.DOTALL)
        m = rx.search(text)
        if not m:
            skipped += 1
            details.append((qname, None, "query block not found (name reused/dynamic?)"))
            continue
        if any(s <= m.start() < e for s, e in comment_spans):
            skipped += 1
            details.append((qname, None, "query is inside an HTML/CF comment (dead code) - skipped"))
            continue
        sql = m.group(2)
        sql_stripped = sql.strip()
        if re.match(r"SELECT", sql_stripped, re.IGNORECASE):
            if re.search(r"\bJOIN\b", sql_stripped, re.IGNORECASE):
                wrapper, reason = gen_join_select_wrapper(qname, sql_stripped)
            else:
                wrapper, reason = gen_select_wrapper(qname, sql_stripped)
        elif re.match(r"UPDATE", sql_stripped, re.IGNORECASE):
            wrapper, reason = gen_update_wrapper(qname, sql_stripped)
        elif re.match(r"INSERT", sql_stripped, re.IGNORECASE):
            wrapper, reason = gen_insert_wrapper(qname, sql_stripped)
        elif re.match(r"DELETE", sql_stripped, re.IGNORECASE):
            wrapper, reason = gen_delete_wrapper(qname, sql_stripped)
        else:
            wrapper, reason = None, "unsupported statement type - review manually"

        if wrapper:
            generated += 1
        else:
            skipped += 1
        details.append((qname, wrapper, reason))

    if details:
        out_path = out_root / (file_rel + ".PROPOSED.txt")
        out_path.parent.mkdir(parents=True, exist_ok=True)
        with out_path.open("w", encoding="utf-8") as fh:
            for qname, wrapper, reason in details:
                fh.write(f"===== QUERY: {qname} =====\n")
                if wrapper:
                    fh.write("STATUS: AUTO-GENERATED (review before applying)\n\n")
                    fh.write(wrapper + "\n\n")
                else:
                    fh.write(f"STATUS: NEEDS_MANUAL_REVIEW - {reason}\n\n")
    return generated, skipped, details


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", default="migration_report.csv")
    parser.add_argument("--root", default=r"D:\Resers_AwayX\AwayX")
    args = parser.parse_args()

    script_dir = Path(__file__).parent
    csv_path = script_dir / args.csv
    root = Path(args.root)
    out_root = script_dir / "proposed"

    by_file: dict[str, list[str]] = {}
    with csv_path.open(encoding="utf-8") as fh:
        for row in csv.DictReader(fh):
            if row["verdict"] == "SAFE_TO_CONVERT":
                rel = str(Path(row["file"]).relative_to(root))
                by_file.setdefault(rel, []).append(row["query_name"])
            elif row["verdict"] == "DEFER_JOIN_OR_UNION" and row["has_subquery"] != "True":
                # let gen_join_select_wrapper's strict regex decide if this is the one
                # supported single-belongs-to-join shape; everything else safely falls
                # through to NEEDS_MANUAL_REVIEW without side effects.
                rel = str(Path(row["file"]).relative_to(root))
                by_file.setdefault(rel, []).append(row["query_name"])

    total_gen, total_skip = 0, 0
    for rel, qnames in by_file.items():
        gen, skip, _ = process_file(root, out_root, rel, qnames)
        total_gen += gen
        total_skip += skip

    print(f"Files processed: {len(by_file)}")
    print(f"Queries auto-generated: {total_gen}")
    print(f"Queries needing manual review: {total_skip}")
    print(f"Proposed output written under: {out_root}")


if __name__ == "__main__":
    main()
