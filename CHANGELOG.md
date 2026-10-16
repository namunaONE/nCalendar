# Changelog

All notable changes to nCalendar are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-10-16

### Added
- AD <-> BS date converter tab (lib/widgets/date_converter.dart): exact
  lookups in both directions with weekday (English + Nepali), festival,
  and evidence tag; out-of-range dates fail loudly, never guess.
- BsDataService.dayForAdDate() — reverse lookup (ISO AD date -> BS day).
- The app now opens on today's Bikram Sambat month; the app bar shows
  today's BS date and a tap jumps back to it.
- Bottom NavigationBar: Calendar | Converter (Material 3).

### Fixed
- CalendarGrid did not reload when the selected year changed — switching
  years showed stale months. didUpdateWidget now reloads on year change.

## [1.1.0] - 2026-10-16

### Added
- Apache-2.0 LICENSE (code) with a CC0-equivalent data license note for the
  calendar facts — the repo previously had no license, which blocked the open
  data commons strategy.
- data/calendar.csv — the source of truth is now committed to the repo:
  109 evidence-tagged BS years (1975–2083), reference: rjach/sambat (Apache-2.0).
- scripts/gen_bs_data.py — single, portable codegen script with an
  invariant-validation pass and a --check mode used by CI to reject drift
  between data/calendar.csv and the generated asset.
- lib/models/bs_year.dart + lib/services/bs_calendar_engine.dart —
  compact schema-2 data model and a pure-Dart engine that expands year rows
  (Baisakh 1 + 12 month lengths) into the full month/day grid at runtime.
- Anchor test wall (test/bs_engine_test.dart): verified Baisakh-1 anchors,
  verified month rows, fiscal-year boundaries, live adjudicated conversions
  (Kartik 1 2083 = 2026-10-18), rare 30-day Baisakh 2004, and full chain
  closure across all 1,308 months (groundwork for Linear HYA-348).
- CSV invariant tests (test/data_invariants_test.dart): contiguous year
  range, month length bounds, year length bounds, evidence class whitelist,
  chain closure, and asset/CSV sync (groundwork for Linear HYA-347/HYA-358;
  the era-aware sankranti-window check still needs the Commons Layer 1 CSV).
- docs/data-dictionary.md — field-by-field documentation of the data
  schema and evidence classes.
- .github/workflows/ci.yml — analyze + data-sync check + test on every PR.

### Changed
- assets/bs_data.json: 8.6 MB pre-expanded JSON → ~30 KB compact schema 2
  (one row per year; weekday/month names now derived at runtime). Loading is
  now fast enough for tests and first paint.
- BsDataService loads schema 2 via the engine; legacy schema-1 assets are
  still accepted.
- FestivalService corrections for BS 2083 (all chain- or source-verified):
  - Indra Jatra main day = Sep 25 (removed erroneous duplicate Sep 10 entry).
  - Kojagrat Purnima Oct 26 → Oct 25 (printed Surya Panchang vrata window
    11:04→22:33 provisionally wins the evidence ladder; Linear HYA-371 stays
    open for the government holiday list).
  - Mha Puja / Nepal Sambat New Year Nov 9 → Nov 10 (Govardhan Puja stays Nov 9).
  - Nepali New Year 2084 Apr 13 → Apr 14 2027 (chain: Chaitra 30 2083 = Apr 13).
  - Maghe Sankranti / Maghi (Tharu New Year) Jan 14 → Jan 15 2027
    (chain: Magh 1 2083 = Jan 15; Makara sankranti Jan 14 21:16 IST → +1).

### Fixed
- README links to non-existent docs (docs/linear-project.md,
  docs/linear-issues.md) replaced with the real snapshot doc.

### Removed
- Duplicate one-off converters convert_calendar.py / convert_calendar.js
  (Windows hardpaths, CSV-in-markdown parsing) — replaced by
  scripts/gen_bs_data.py.

## [1.0.0] - 2026-10-15

### Added
- Initial Flutter web app: BS calendar grid (month/year views), AD conversion,
  evidence tags in the UI, festival layer for 2083, GitHub Pages CI/CD.
- 8.6 MB pre-expanded bs_data.json (schema 1) generated from the verified
  calendar.csv export.
