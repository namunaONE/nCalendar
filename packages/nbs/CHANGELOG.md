# Changelog

All notable changes to nbs are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-10-17

### Added
- First public skeleton of the nbs core, extracted verbatim from the
  nCalendar app's pure-Dart `lib/core` (C2a, Linear HYA-375) — zero
  behavior change to the models or engine.
- `NbsCalendar` facade: `month` / `day` / `dayForAdDate` / `adDateOf`,
  with the honesty contract as the API — out-of-range lookups return
  null, never a guess or an untagged projection.
- `NbsData.parse` — pure-Dart JSON loader for the nCalander data commons
  (schema 2 compact + legacy schema 1). The package ships no data;
  apps bring their own evidence-tagged dataset.
- Evidence classes (verified / consensus / disputed / projection)
  travel with every year row; disputed years are never silently resolved.
- Pure-Dart test battery with anchors cited to portal/print evidence,
  not to the dataset itself (research rounds R1-R8).

### Not done (honest)
- Not yet published to pub.dev — publishing awaits maintainer approval
  of the package name and public claims (Linear HYA-376).
- No festival, tithi, or panchang data (future nbs_panchang, gated on
  legal review + full-year audit).
