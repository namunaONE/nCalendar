# Brand System — nCalendar

## Brand Colors

| Token | Name | Hex | Dart Color |
|-------|------|-----|------------|
| Primary | Navy Depth | `#002C6D` | `Color(0xFF002C6D)` |
| Secondary | Growth Green | `#4FD166` | `Color(0xFF4FD166)` |

## Usage Guidelines

### Primary — `#002C6D` (Navy Depth)
- AppBar background
- Primary / Filled buttons
- Active selection states
- Focus rings
- **Text on primary must be white/light** for contrast

### Secondary — `#4FD166` (Growth Green)
- Secondary / tonal buttons
- Festival chips and badges
- "Today" marker on calendar grid
- Accent highlights
- **Text on secondary should be dark** for contrast

### Contrast Rules
- Navy (`#002C6D`) + white text ✅ passes WCAG AA
- Green (`#4FD166`) + dark text ✅ passes WCAG AA
- Never use green text on white without a darker outline — low contrast
- Never use navy on dark backgrounds without a light border

## ThemeData Implementation

```dart
ColorScheme.fromSeed(
  seedColor: const Color(0xFF002C6D),   // primary: navy depth
  secondary: const Color(0xFF4FD166),   // secondary: growth green
  brightness: Brightness.light,
)
```

Dark theme uses the same seeds with `brightness: Brightness.dark`.

## Component Examples

- **Filled button** — primary navy background, white text
- **Tonal button** — secondary green tint, dark text
- **Festival chip** — green background (`primaryContainer`), dark text, rounded pill
- **Today marker** — green dot or green border on the current day cell
