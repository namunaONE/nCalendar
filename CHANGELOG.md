# Changelog

All notable changes to nCalendar are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.1] - 2026-10-17

### Changed — C2b: the nbs package skeleton (Linear HYA-376)

- The pure-Dart core (models + engine) now lives in **packages/nbs** —
  a standalone pure-Dart package (name `nbs`, version 0.1.0, Apache-2.0)
  consumed by the app as a path dependency. Import-path-only change:
  zero behavior, data, or UI edits.
- lib/core is deleted; all app imports now resolve to package:nbs.
- New in nbs: NbsCalendar facade (null-out-of-range honesty contract)
  and NbsData.parse pure-Dart JSON loader; the app's BsDataService is
  now a thin Flutter shim (rootBundle -> NbsData.parse -> engine).
- CI runs the nbs package battery: dart analyze + dart test +
  dart pub publish --dry-run on every PR. Publishing to pub.dev is
  gated on maintainer approval of the name and public claims.
- The lib/core purity guard now walks packages/nbs/lib.

## [1.3.0] - 2026-10-17

### Structural refactor — pure-Dart `lib/core` layer (C2a)

- **Move, not change**: `bs_day`, `bs_month`, `bs_year` and the calendar engine now live under `lib/core/` (models + engine). Zero behavior change — no data, logic, or UI edits; import paths only.
- `lib/core` has **zero Flutter imports** — it is the seed of the future pure-Dart `nbs` package (R10 architecture plan, Linear HYA-375).
- New `test/core_purity_test.dart` purity guard: CI fails if any `lib/core` file ever imports `package:flutter` or `dart:ui`.
- All 28 existing tests pass with import-path updates only (no behavior edits).

## [1.2.2] - 2026-10-17

### Added
- CSS-only loading splash in web/index.html: paints before the JS
  bundle downloads (real first content), brand navy, respects
  prefers-reduced-motion, removed on Flutter's flutter-first-frame
  event.
- Preload hints for flutter_bootstrap.js / flutter.js / main.dart.js
  (relative paths, resolved under the base href) so the browser
  starts fetching the boot chain before the async script tag.

### Fixed
- web/index.html loaded flutter_bootstrap.js twice (head + body);
  the duplicate head tag is removed.

### Note
- No data or logic changes. The splash is a perceived-performance
  improvement; the JS bundle itself is unchanged this release
  (numbers live in the CI bundle size reports).

## [1.2.1] - 2026-10-17

### Changed
- Web bundle diet (cycle C1): the date converter is now a dart2js
  deferred library — it is compiled into a separate part file and
  excluded from the initial JS payload, loading on the first switch to
  the Converter tab. Loading state and an honest error + retry path
  (switch tabs) if the deferred part fails to fetch.
- --tree-shake-icons on both the Pages deploy build and the PR CI
  build: the app uses only 7 const Material icons, so the full icon
  font no longer ships.
- CI (ci.yml) now builds the web bundle on every PR — icon tree-shake
  and deferred-split regressions are caught before merge — and both
  workflows publish a bundle size report (build/web breakdown) to the
  job summary for before/after comparison.

### Fixed
- The converter tab placeholder mounted an indeterminate spinner from
  boot; IndexedStack builds all children, so it animated offstage
  behind the Calendar tab forever (CPU/battery drain on the deployed
  app — caught by CI pumpAndSettle timeouts). The idle state now
  renders nothing; the spinner shows only while the deferred library
  is loading.

### Note
- No data or conversion-logic changes in this release: calendar.csv
  remains the generated source of truth, out-of-range dates still fail
  honestly. Initial-JS reduction is measured in the CI bundle size
  report; the <2 MB initial-JS goal is NOT claimed by this release.

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
