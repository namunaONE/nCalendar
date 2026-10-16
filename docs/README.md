# nCalendar — Documentation

nCalendar is a Flutter web app that renders the **Bikram Sambat (BS / Nepali) calendar** as an open, evidence-tagged data commons on GitHub Pages.

## Brand Colors

| Token | Hex | Usage |
|-------|-----|-------|
| Primary seed | `#002C6D` | Navy depth — AppBar, primary buttons, active states, focus rings |
| Secondary seed | `#4FD166` | Growth green — secondary actions, festival chips, "Today" markers, accents |

## Documentation Index

| File | Purpose |
|------|---------|
| `01-flutter-web-guidelines.md` | Best rules & guidelines for Flutter Web |
| `02-responsive-adaptive.md` | Native / responsive / adaptive strategy |
| `03-layoutbuilder-design-system.md` | LayoutBuilder + Design System explained |
| `04-brand-system.md` | Brand tokens, ThemeData, accessibility |
| `05-linear-rounds.md` | Linear project rounds & issues (P-HYA-13) |
| `06-challenge-yourself.md` | Suggested improvements & challenges |

## Project Structure

```
lib/
  main.dart                # App shell, MaterialApp, HomePage
  theme/
    n_calendar_theme.dart  # Brand theme (navy + green)
  models/
    bs_day.dart            # Single BS day
    bs_month.dart          # BS month with days
  services/
    bs_data_service.dart   # Singleton JSON loader
  widgets/
    calendar_grid.dart     # Calendar grid (LayoutBuilder-based)
assets/
  bs_data.json             # Verified BS calendar data (1975–2083)
web/
  index.html               # Web entry point + meta tags
  manifest.json            # PWA manifest
  favicon.png
```

## Getting Started

```bash
# Get dependencies
flutter pub get

# Run on web (HTML renderer recommended for text/SEO)
flutter run -d chrome --web-renderer html

# Build for GitHub Pages
flutter build web --web-renderer html --base-href /nCalendar/
```

## License

Open data commons. Calendar data sourced from the verified `calendar.csv` reference (BS 1975–2083, evidence-tagged).
