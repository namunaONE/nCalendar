# Challenge Yourself — nCalendar Improvement Challenges

Concrete challenges to level up the Flutter web experience. Tackle them in order.

## Phase 1 — Brand (Quick Win)

1. **Apply secondary brand `#4FD166`**
   - Wire it into `ColorScheme` as `secondary`/`tertiary`
   - Use for festival chips, secondary buttons, "Today" markers
   - File: `lib/theme/n_calendar_theme.dart`, `lib/main.dart`

2. **Extract a design system**
   - Move colors, typography, and shared widgets into `lib/theme/` + `lib/components/`
   - Replace inline `Theme.of(context)` color lookups with design tokens

## Phase 2 — Responsive Layout

3. **True responsive calendar**
   - Wide screens (>900px): show multiple month grids side-by-side using `LayoutBuilder`
   - Mobile: single month at a time
   - Adjust cell density via breakpoint

4. **GoRouter deep linking**
   - URLs like `/calendar/2083/1` so back/forward/refresh work
   - Bookmarkable BS month/year

## Phase 3 — Data & PWA

5. **Replace sample data with verified commons**
   - Convert `calendar.csv (1975–2083, evidence-tagged)` → `assets/bs_data.json`
   - Handle disputed years (1989, 1991, 1993, 2004, 2062) with dual variants labeled

6. **PWA offline support**
   - Complete `web/manifest.json` (theme_color `#002C6D`, 192/512px icons)
   - Service worker so calendar works offline after first load

## Phase 4 — Accessibility & SEO

7. **Keyboard navigation**
   - Tab order through month/year dropdowns and grid cells
   - Logical focus traversal

8. **SEO / meta tags**
   - `<title>`, description, Open Graph tags in `web/index.html`
   - Canonical URLs per calendar month

9. **Linear rounds documentation**
   - Fill `docs/05-linear-rounds.md` with real project data from Linear P-HYA-13

## How to Track

Copy this list into your Linear project or a local `CHALLENGES.md` and check off each item as you complete it. Each challenge maps to a file or feature in the nCalendar repo.
