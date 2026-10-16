#!/usr/bin/env python3
"""Generate assets/bs_data.json (schema 2) from data/calendar.csv.

Usage:
  python scripts/gen_bs_data.py            # regenerate assets/bs_data.json
  python scripts/gen_bs_data.py --check    # exit 1 if the committed asset is stale

Project golden rule: the generated asset is always derived from
data/calendar.csv, never hand-edited. CI runs --check on every build.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = ROOT / 'data' / 'calendar.csv'
OUT_PATH = ROOT / 'assets' / 'bs_data.json'

SCHEMA = 2
SOURCE = ('data/calendar.csv — nCalander Bikram Sambat data commons '
          '(evidence-tagged); reference: rjach/sambat (Apache-2.0)')
ALLOWED_EVIDENCE = {'verified', 'consensus', 'disputed', 'projection'}


def parse_rows():
    lines = CSV_PATH.read_text(encoding="utf-8").splitlines()
    header = lines[0].split(",")
    expected = (["bs_year", "baisakh1_ad"]
                + [f"m{i:02d}" for i in range(1, 13)]
                + ["evidence", "sources", "notes"])
    if header != expected:
        raise SystemExit("Unexpected CSV header: " + str(header))
    rows = []
    for line in lines[1:]:
        if not line.strip():
            continue
        parts = line.split(",")
        if len(parts) != 17:
            raise SystemExit("Bad row ({} fields): {}".format(len(parts), line))
        rows.append({
            "bsYear": int(parts[0]),
            "baisakh1Ad": parts[1],
            "monthLengths": [int(p) for p in parts[2:14]],
            "evidence": parts[14],
            "sources": parts[15],
            "notes": parts[16],
        })
    return rows


def validate(rows):
    for row in rows:
        lengths = row["monthLengths"]
        if len(lengths) != 12:
            raise SystemExit("{}: expected 12 month lengths".format(row["bsYear"]))
        if any(not 29 <= length <= 32 for length in lengths):
            raise SystemExit("{}: month length out of range: {}".format(row["bsYear"], lengths))
        total = sum(lengths)
        if not 364 <= total <= 367:
            raise SystemExit("{}: implausible year length {}".format(row["bsYear"], total))
        if row["evidence"] not in ALLOWED_EVIDENCE:
            raise SystemExit("{}: unknown evidence class {}".format(row["bsYear"], row["evidence"]))
    years = [row["bsYear"] for row in rows]
    if years != list(range(min(years), max(years) + 1)):
        raise SystemExit("Year sequence is not contiguous")


def build():
    rows = parse_rows()
    validate(rows)
    return {"schema": SCHEMA, "source": SOURCE, "years": rows}


def main():
    data = build()
    if "--check" in sys.argv:
        current = json.loads(OUT_PATH.read_text(encoding="utf-8")) if OUT_PATH.exists() else None
        if current != data:
            print("STALE: assets/bs_data.json does not match data/calendar.csv.")
            print("Regenerate with: python scripts/gen_bs_data.py")
            sys.exit(1)
        print("OK: assets/bs_data.json is in sync ({} year rows)".format(len(data["years"])))
        return
    out = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    OUT_PATH.write_text(out, encoding="utf-8")
    print("Wrote {} year rows to {}".format(len(data["years"]), OUT_PATH))


if __name__ == "__main__":
    main()
