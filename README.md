# nCalendar — Bikram Sambat (BS) Calendar on GitHub Pages

**Live site:** https://namunaONE.github.io/nCalendar/

A Flutter web app that renders the [nCalander](https://linear.app/hyamuji/project/ncalander-2bcdeec2a130) Bikram Sambat data commons — open, evidence-tagged Nepali calendar data (BS dates, AD conversion, tithi, festivals) — served via GitHub Pages with GitHub Actions CI/CD.

## Project data (Linear)

Planning, roadmap, and issue tracking live in **Linear** workspace **HyaMuji** → project **nCalander** (P-HYA-13).

- [Linear project: nCalander](https://linear.app/hyamuji/project/ncalander-2bcdeec2a130)
- [Project docs: Linear project overview](docs/linear-project.md)
- [Project docs: Linear issues & phases](docs/linear-issues.md)
- [Keeping Linear data in sync](docs/LINEAR_SYNC.md)

## Roadmap phases (from Linear)

| Phase | Issue | Focus | Status |
|-------|-------|-------|--------|
| Phase 1 | HYA-347 | Dataset repo foundations: invariant checker + codegen | Backlog |
| Phase 2 | HYA-348 | Core Dart engine + test wall (24 anchors) | Backlog |
| Phase 3 | HYA-349 | Publish 1.0.0 (CI matrix, semver data policy) | Backlog |
| Phase 4 | HYA-350 | Ecosystem layer: Flutter date picker / calendar grid / i18n ← **this web app** | Backlog |
| Phase 5 | HYA-351 | Yearly runbook: patro-day SOP + maintenance | Backlog |

## Stack

- **Flutter Web** (3.47.5, Dart 3.13.4), Material 3
- Data: `assets/bs_data.json` (sample of the nCalander commons; replace with the real evidence-tagged export)
- CI/CD: GitHub Actions → `flutter build web` → `actions/deploy-pages` → GitHub Pages

## Getting started

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href "/nCalendar/"
```

## License

The nCalander data commons is intended to be openly licensed (CC0/Apache-2.0) per the Linear project vision — "no Nepali app ever shows the wrong date."
