#!/usr/bin/env python3
"""
Convert the verified calendar.csv (embedded in the .md file) into
assets/bs_data.json matching BsDataService / BsMonth / BsDay schema.

CSV columns:
  bs_year, baisakh1_ad, m01..m12 (month lengths), evidence, sources, notes

Output JSON:
  {
    "months": [
      {
        "bsYear": int,
        "bsMonth": int (1..12),
        "bsMonthName": str,
        "bsMonthNameNepali": str,
        "daysInMonth": int,
        "adStart": "yyyy-MM-dd",
        "adEnd": "yyyy-MM-dd",
        "days": [
          {"bsDay": int, "adDate": "yyyy-MM-dd", "weekday": str,
           "weekdayNepali": str, "tithi": str, "festival": null|str}
        ],
        "evidence": str,
        "sources": str,
        "notes": str
      },
      ...
    ]
  }

Disputed years (1989, 1991, 1993, 2004, 2062): ship the CSV row as-is
(evidence=disputed) with a note; both variants can be added later.
"""

import json
import re
import sys
from datetime import date, timedelta

MONTH_NAMES = [
    '',  # index 0 unused
    'Baisakh', 'Jestha', 'Ashad', 'Shrawan', 'Bhadra', 'Ashwin',
    'Kartik', 'Mangsir', 'Poush', 'Magh', 'Falgun', 'Chaitra',
]

MONTH_NAMES_NEPALI = [
    '',  # index 0 unused
    'बैशाख', 'जेठ', 'असार', 'श्रावण', 'भाद्रपद', 'असोज',
    'कार्तिक', 'मंसिर', 'पौष', 'माघ', 'फाल्गुन', 'चैत्र',
]

WEEKDAY_EN = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
WEEKDAY_NE = ['आइतबार', 'सोमबार', 'मंगलबार', 'बुधबार', 'बिहिबार', 'शुक्रबार', 'शनिबार']


def parse_csv_block(md_path: str):
    """Extract the ```csv ... ``` block from the markdown file."""
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    match = re.search(r'```csv\n(.*?)\n```', content, re.DOTALL)
    if not match:
        raise SystemExit('ERROR: No ```csv block found in ' + md_path)

    csv_text = match.group(1).strip()
    lines = [ln for ln in csv_text.splitlines() if ln.strip()]
    return lines


def iso_to_date(s: str) -> date:
    y, m, d = map(int, s.split('-'))
    return date(y, m, d)


def build_month_entry(bs_year: int, baisakh1_ad: str, month_lengths: list[int],
                      evidence: str, sources: str, notes: str) -> dict:
    start = iso_to_date(baisakh1_ad)
    months = []
    cursor = start
    for month_idx in range(1, 13):
        length = month_lengths[month_idx - 1]
        ad_start = cursor
        ad_end = cursor + timedelta(days=length - 1)

        days = []
        for day in range(1, length + 1):
            ad_date = cursor + timedelta(days=day - 1)
            wd_idx = ad_date.weekday()  # Monday=0 .. Sunday=6
            # Convert Python weekday (Mon=0) to Sun=0..Sat=6
            sun_based = (wd_idx + 1) % 7
            days.append({
                'bsDay': day,
                'adDate': ad_date.isoformat(),
                'weekday': WEEKDAY_EN[sun_based],
                'weekdayNepali': WEEKDAY_NE[sun_based],
                'tithi': '',
                'festival': None,
            })

        months.append({
            'bsYear': bs_year,
            'bsMonth': month_idx,
            'bsMonthName': MONTH_NAMES[month_idx],
            'bsMonthNameNepali': MONTH_NAMES_NEPALI[month_idx],
            'daysInMonth': length,
            'adStart': ad_start.isoformat(),
            'adEnd': ad_end.isoformat(),
            'days': days,
            'evidence': evidence,
            'sources': sources,
            'notes': notes,
        })

        cursor = ad_end + timedelta(days=1)

    return months


def main():
    md_path = sys.argv[1] if len(sys.argv) > 1 else \
        r"C:\Users\user\Downloads\Raw Data · Verified calendar.csv (1975–2083, evidence-tagged).md"
    out_path = sys.argv[2] if len(sys.argv) > 2 else \
        r"C:\Users\user\Downloads\Project\nCalender\assets\bs_data.json"

    lines = parse_csv_block(md_path)
    header = lines[0].split(',')
    print(f"CSV header: {header}")
    print(f"Data rows: {len(lines) - 1}")

    all_months = []
    for line in lines[1:]:
        parts = line.split(',')
        if len(parts) < 15:
            print(f"SKIP short row: {parts[0] if parts else '?'}")
            continue

        bs_year = int(parts[0])
        baisakh1_ad = parts[1]
        month_lengths = [int(parts[i]) for i in range(2, 14)]
        evidence = parts[14]
        sources = parts[15] if len(parts) > 15 else ''
        notes = parts[16] if len(parts) > 16 else ''

        year_months = build_month_entry(
            bs_year, baisakh1_ad, month_lengths, evidence, sources, notes
        )
        all_months.extend(year_months)

    output = {'months': all_months}
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"Wrote {len(all_months)} months to {out_path}")


if __name__ == '__main__':
    main()
