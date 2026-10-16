# Linear Project — nCalander / nCalendar

Real data pulled from Linear workspace **HyaMuji** → project **nCalander** (P-HYA-13). This doc is the canonical project-data mirror; keep it in sync with Linear (see `docs/LINEAR_SYNC.md`).

## Project Meta

| Field | Value |
|-------|-------|
| Project ID | P-HYA-13 |
| Team | HyaMuji (key `HYA`) |
| Linear URL | https://linear.app/hyamuji/project/ncalander-2bcdeec2a130 |
| Status | Backlog |
| Priority | No priority |
| Lead | (none set) |

## Vision

> **"No Nepali app should ever show the wrong date."** Open-source freedom of access to accurate BS, panchang, and tithi data so no monopoly can exist in the Nepali market.

**Strategy (the jackpot):** liberate the *data* — evidence-tagged, openly licensed, machine-readable files under a neutral multi-maintainer commons.

## Roadmap phases

| Phase | Linear issue | Focus | Priority | Status |
|-------|--------------|-------|----------|--------|
| Phase 1 | HYA-347 | Dataset repo foundations: invariant checker in CI + codegen | High | Backlog |
| Phase 2 | HYA-348 | Core Dart engine + test wall (24 anchors + property tests) | High | Backlog |
| Phase 3 | HYA-349 | Publish 1.0.0 (pana 140/140, CI matrix, semver data policy) | Medium | Backlog |
| Phase 4 | HYA-350 | Ecosystem layer: Flutter date picker, calendar grid, fiscal toolkit, i18n ← **this web app** | Medium | Backlog |
| Phase 5 | HYA-351 | Yearly runbook: patro-day SOP + maintenance continuity | Medium | Backlog |

## Key issues (all linked to nCalander project)

| Issue | Title | Priority | Status | Owner |
|-------|-------|----------|--------|-------|
| HYA-347 | Phase 1 — Dataset repo foundations: invariant checker in CI + codegen | High | Backlog | realpoudel@duck.com |
| HYA-348 | Phase 2 — Core Dart engine + test wall (24 anchors + property tests) | High | Backlog | realpoudel@duck.com |
| HYA-349 | Phase 3 — Publish 1.0.0 (pana 140/140, CI matrix, semver data policy) | Medium | Backlog | realpoudel@duck.com |
| HYA-350 | Phase 4 — Ecosystem layer: Flutter date picker, fiscal toolkit, i18n | Medium | Backlog | realpoudel@duck.com |
| HYA-351 | Phase 5 — Yearly runbook: patro-day SOP + maintenance continuity | Medium | Backlog | realpoudel@duck.com |
| HYA-352 | Upstream — File nepali_utils data issues (372-day year 2200, variants, TZ hack) | — | Backlog | realpoudel@duck.com |
| HYA-353 | Upstream — Fix @sbmdkl/nepali-datepicker-reactjs embedded 2083 data (live prod bug) | Urgent | Backlog | realpoudel@duck.com |
| HYA-354 | Upstream — Comment evidence on opennp/nepali-dates PR #2 (Mangsir mapping conflict) | High | Backlog | realpoudel@duck.com |
| HYA-355 | Research — Extend the consensus audit script (ancestry-aware weighting, monthly drift job) | Medium | Backlog | realpoudel@duck.com |
| HYA-356 | Research — Obtain printed 2083 panchang photos for the provenance archive | Medium | Backlog | realpoudel@duck.com |
| HYA-357 | Watch — Official 2084 patro publication: add verified row within 7 days | High | Backlog | realpoudel@duck.com |
| HYA-358 | CI — Sankranti-window invariant: every month start ≥ sidereal ingress date (+1 max) | High | Backlog | realpoudel@duck.com |
| HYA-359 | Research — Archival verification of disputed years 1989 / 1991 / 1993 | Medium | Backlog | realpoudel@duck.com |
| HYA-360 | Research — Evaluate Project Parva: sankranti reference data cross-check | Low | Done | realpoudel@duck.com |
| HYA-361 | Commons — Create neutral GitHub org + move calendar.csv; merger talks with rjach/sambat | High | Backlog | realpoudel@duck.com |
| HYA-362 | Commons — Legal review: publishing tithi/panchang reference data (Layer 2) in Nepal | Medium | Backlog | realpoudel@duck.com |
| HYA-363 | Commons — Engage Nepal Panchang Nirnayak Samiti: free digitization + open publication | Medium | Backlog | realpoudel@duck.com |
| HYA-364 | R6 — Reconstruct the +1 rule: lunar (viddha) contamination test on 286 anchors | High | Done | realpoudel@duck.com |
| HYA-365 | Archival verification — 24 pre-1980 anchors + 5 disputed years (Gorkhapatra / NPNS) | Medium | Backlog | realpoudel@duck.com |
| HYA-366 | Publish Commons Layer 1 — sankranti-moments CSV + solar engine + calibration set | High | Backlog | realpoudel@duck.com |
| HYA-367 | Build festival_rules module: tithi-at-sunrise engine, variant rules, NPNS override | Medium | Backlog | realpoudel@duck.com |
| HYA-368 | Annual muhurta transcription pipeline (bibaha / bratabandha / pasni / griha pravesh) | Medium | Backlog | realpoudel@duck.com |
| HYA-369 | SWEPH vs our engine: knife-edge comparison, AGPL facts-out porting plan, tithi audit | Low | Backlog | realpoudel@duck.com |
| HYA-370 | Outreach — Engage Project Parva (dantwoashim): commons alignment, shared fixtures | High | Backlog | realpoudel@duck.com |
| HYA-371 | Resolve Kojagrat Purnima 2083: printed Oct 25 vs R6 web adjudication Oct 26 | High | Backlog | realpoudel@duck.com |
| HYA-372 | Digitize Surya Panchang 2083 daily tables into machine-readable CSV (NPNS override) | Medium | Backlog | realpoudel@duck.com |

### Status summary

| Status | Count | Issues |
|--------|-------|--------|
| Done | 2 | HYA-360, HYA-364 |
| Backlog | ~22 | all others |
| Urgent | 1 | HYA-353 |
| High priority | 9 | HYA-347, 348, 353, 354, 357, 358, 361, 366, 370, 371 |

## Deliverables per phase (mapped to nCalendar code)

| Phase | Linear issue | Deliverable | Files |
|-------|--------------|-------------|-------|
| Phase 1 | HYA-347 | BS data model + JSON loader + invariant checker | `lib/models/bs_day.dart`, `lib/models/bs_month.dart`, `lib/services/bs_data_service.dart`, `assets/bs_data.json` |
| Phase 2 | HYA-348 | Core Dart engine: immutable `BsDate`, `adToBs`/`bsToAd`, `todayInNepal()`, evidence(year), loud errors outside verified range; 24-anchor golden tests + property tests | (planned — not yet implemented) |
| Phase 3 | HYA-349 | Publish 1.0.0: accuracy contract README, GitHub Actions CI on 3 SDK versions, semver data policy | `.github/workflows/pages.yml` |
| Phase 4 | HYA-350 | Flutter web calendar grid + date picker widgets + fiscal toolkit + i18n (Devanagari digits, month spellings) | `lib/main.dart`, `lib/widgets/calendar_grid.dart`, `lib/theme/n_calendar_theme.dart`, `web/index.html` |
| Phase 5 | HYA-351 | Yearly runbook: patro-day SOP, maintenance continuity, <7-day update from NPNS publication | (planned) |

## Related Linear projects (same team `HyaMuji`)

| Project | ID | Focus | Stack |
|---------|-----|-------|-------|
| nKount | P-HYA-12 | Accounting web + mobile | Flutter, Riverpod, SQLite, Supabase |
| nGEO | P-HYA-11 | Nepal local bodies data (753 levels) | Dart package + React explorer |
| nBhumi | P-HYA-10 | Nepal property marketplace | Flutter, Riverpod, Supabase |

## Notes / blockers

- HYA-362 (Commons legal review) is a gate for Layer 2 (tithi/panchang) publication.
- HYA-368 (muhurta pipeline) is behind the HYA-362 legal gate.
- HYA-353 (datepicker embedded-data bug) is **Urgent** — a live production bug in `@sbmdkl/nepali-datepicker-reactjs`.
- Verified BS reference data: `calendar.csv` (1975–2083, evidence-tagged). This repo ships a 2-month **sample** in `assets/bs_data.json`; replace it with the full verified export.

## Next steps

1. Replace `assets/bs_data.json` sample with the full verified `calendar.csv` (BS 1975–2083) export from the nCalander commons.
2. Implement Phase 2 core Dart engine (`adToBs`/`bsToAd` computation) so the web app computes rather than looks up.
3. Link GitHub branches/PRs to Linear issues (e.g. `HYA-350`) so work auto-connects in Linear.
4. Refresh this doc when Linear state changes — see `docs/LINEAR_SYNC.md`.
