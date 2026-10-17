# nbs — pure-Dart Bikram Sambat calendar core

**"No Nepali app should ever show the wrong date."**

`nbs` is a pure-Dart Bikram Sambat (BS — Nepal's official calendar)
core: BS ↔ AD date conversion built on evidence-tagged data, with an
API whose central rule is **honesty** — every lookup outside the loaded
dataset returns `null`. Never a guess. Never an untagged projection
presented as fact.

## What's in the box

- `NbsCalendar` — the facade: `month()`, `day()`, `dayForAdDate()`,
  `adDateOf()`, `supportedYears`.
- `BsYearRow` / `BsMonth` / `BsDay` — evidence-tagged models.
- `BsCalendarEngine` — expands compact year rows (Baisakh 1 AD anchor +
  12 month lengths) into the full month/day grid at runtime.
- `NbsData.parse()` — pure-Dart JSON loader (nCalander schema 2 compact
  and legacy schema 1).

**No data is bundled.** nbs ships the engine; you bring an
evidence-tagged dataset. The nCalander commons (calendar.csv, 109 BS
years 1975-2083, Apache-2.0 code / CC0-equivalent data) is the
reference dataset: https://github.com/namunaONE/nCalendar

## Usage

```dart
import 'package:nbs/nbs.dart';

final calendar = NbsCalendar.parse(myBsDataJson);

final baisakh1 = calendar.day(2083, 1, 1);
print(baisakh1?.adDate); // 2026-04-14 (verified row)

// Out of range — the honesty contract:
print(calendar.day(2084, 1, 1)); // null. Beyond 2083 there is no
// official BS data (only Baisakh 1 2084 is published). nbs will not
// invent it.
```

## Honest accuracy — claims scoped to evidence class

Every year row carries an evidence class; scope every claim to it:

| Class | Meaning |
|---|---|
| `verified` | Official panchang / print or portal-confirmed |
| `consensus` | Multiple independent open datasets agree |
| `disputed` | Two traditional variants exist; one labeled variant ships — never silently resolved |
| `projection` | Derived candidate, ±1 uncertainty — never presented as fact |

Known disputed years in the reference dataset: 1989, 1991, 1993, 2004,
2062 (BS). Resolution requires archival sources, not algorithms.

**Beyond 2083:** `null`. Nepal Panchang Nirnayak Samiti publishes
annually; no machine-readable official data exists beyond ~2084.
Packages that ship decades of projections as fact are the problem this
project exists to fix.

## Status

- **0.1.0 — skeleton.** Extracted from the nCalendar app's pure-Dart
  core (zero behavior change), tested against portal/print-verified
  anchors. Not yet on pub.dev — publication is gated on maintainer
  approval of the name and public claims.
- Roadmap: `nbs_flutter` (widgets) and `nbs_panchang` (tithi/festival
  engines, gated on legal review + full-year audit) later.

## License

Apache-2.0 (code). Calendar facts are facts — the nCalander data
commons ships them CC0-equivalent with provenance tags.
