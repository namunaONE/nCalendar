# LayoutBuilder & Design System

## LayoutBuilder

`LayoutBuilder` builds itself based on the **constraints from its parent** (`maxWidth`/`maxHeight`), not the physical screen size.

### How nCalendar uses it

In `lib/widgets/calendar_grid.dart`, `LayoutBuilder` computes `cellWidth = constraints.maxWidth / 7` so the 7-day calendar grid always fills the available width, then derives `childAspectRatio` from that width:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final cellWidth = constraints.maxWidth / 7;
    // ... GridView with childAspectRatio: cellWidth / 96
  },
)
```

### Rule

- **Screen-level decisions** (which layout to show): `MediaQuery.of(context).size`
- **Container-level decisions** (how to size children): `LayoutBuilder`

## Design System

A design system = **tokens + components + guidelines**.

### Tokens (brand)

| Token | Hex | Dart | Usage |
|-------|-----|------|-------|
| Primary seed | `#002C6D` | `Color(0xFF002C6D)` | AppBar, primary buttons, active states |
| Secondary seed | `#4FD166` | `Color(0xFF4FD166)` | Secondary actions, festival chips, "Today" |
| Surface / onPrimary | derived | Material 3 `ColorScheme.fromSeed` | Backgrounds, text on primary |

### Implementation

Create `lib/theme/n_calendar_theme.dart` with:

- `NCalendarTheme.light()` / `NCalendarTheme.dark()` — `ThemeData` built from `ColorScheme.fromSeed(seedColor: navy, secondary: green)`
- Component factories: `NCalendarDayCell`, `NCalendarMonthHeader`, `NCalendarChip` — shared across screens so every view looks identical

### Current state

`lib/main.dart` already seeds `#002C6D` for light and dark themes. Missing:
- `#4FD166` wired as secondary/tertiary
- Shared theme file extracted from `main.dart`
- Reusable component widgets

### Example ThemeData

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF002C6D),
    secondary: const Color(0xFF4FD166),
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
)
```
