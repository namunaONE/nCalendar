# nCalendar — Bikram Sambat (BS) Calendar on GitHub Pages

**Live site:** https://namunaONE.github.io/nCalendar/

A Flutter web app that renders the [nCalander](https://linear.app/hyamuji/project/ncalander-2bcdeec2a130) Bikram Sambat data commons — open, evidence-tagged Nepali calendar data (BS dates, AD conversion, festivals) — served via GitHub Pages with GitHub Actions CI/CD.

**Vision:** *No Nepali app should ever show the wrong date.* The data commons
is evidence-tagged per year — `verified` (official panchang), `consensus`
(multiple independent open datasets), `disputed` (competing community variants,
shipped as-is), `projection` (never shipped untagged).

## Project data (Linear)

Planning, roadmap, and issue tracking live in **Linear** workspace **HyaMuji** → project **nCalander** (P-HYA-13).

- [Linear project: nCalander](https://linear.app/hyamuji/project/ncalander-2bcdeec2a130)
- [Linear rounds snapshot (auto-refreshed daily)](docs/05-linear-rounds.md)
- [Keeping Linear data in sync](docs/LINEAR_SYNC.md)

## Roadmap phases (from Linear)

| Phase | Issue | Focus | Status |
|-------|-------|-------|--------|
| Phase 1 | HYA-347 | Dataset repo foundations: invariant checker + codegen | In progress |
| Phase 2 | HYA-348 | Core Dart engine + test wall (24 anchors) | In progress |
| Phase 3 | HYA-349 | Publish 1.0.0 (CI matrix, semver data policy) | Backlog |
| Phase 4 | HYA-350 | Ecosystem layer: Flutter date picker / calendar grid / i18n ← **this web app** | Backlog |
| Phase 5 | HYA-351 | Yearly runbook: patro-day SOP + maintenance | Backlog |

## Data pipeline (generated, never hand-edited)

```
data/calendar.csv  ──scripts/gen_bs_data.py──▶  assets/bs_data.json  ──BsCalendarEngine──▶  BsMonth/BsDay objects
```

1. **`data/calendar.csv`** is the source of truth: one row per BS year
   (1975–2083) with `baisakh1_ad`, twelve month lengths, and
   `evidence` / `sources` / `notes`. Reference dataset:
   [rjach/sambat](https://github.com/rjach/sambat) (Apache-2.0).
2. **`scripts/gen_bs_data.py`** generates the compact asset (schema 2) and
   validates invariants (month lengths, year lengths, contiguous years,
   evidence whitelist). CI runs `python scripts/gen_bs_data.py --check` and
   fails if the committed asset is stale.
3. **`BsCalendarEngine`** expands the compact rows into the full month/day
   grid at runtime, deriving weekday names from the AD dates.

See [docs/data-dictionary.md](docs/data-dictionary.md) for the full field
reference.

## Stack

- **Flutter Web** (3.47.5, Dart 3.13.4), Material 3
- Data: `assets/bs_data.json` (compact schema 2, ~30 KB, generated from `data/calendar.csv`)
- CI/CD: GitHub Actions → `flutter analyze` → data-sync check → `flutter test` → `flutter build web` → GitHub Pages

## Getting started

```bash
flutter pub get
flutter analyze
python scripts/gen_bs_data.py --check   # verify the generated asset is in sync
flutter test
flutter build web --release --base-href "/nCalendar/"
```

To regenerate the asset after editing `data/calendar.csv`:

```bash
python scripts/gen_bs_data.py
```

## License

- **Code:** Apache-2.0 — see [LICENSE](LICENSE).
- **Data:** the Bikram Sambat calendar data (`data/calendar.csv`,
  `assets/bs_data.json`) consists of calendar facts, dedicated to the public
  domain (CC0-equivalent). Cite sources and preserve the evidence tags.
