# Responsive & Adaptive — Making Flutter Web Feel Native

Native feel on the web comes from **honoring web conventions**, not from mimicking mobile. A user on a desktop browser expects hover, scrollbars, bookmarkable URLs, and multi-column layouts.

## Strategy for nCalendar

| Viewport | Layout | Behavior |
|----------|--------|----------|
| **xs** (< 600px) | Single month, stacked controls | Large touch targets, vertical scroll |
| **sm** (600–900px) | Single month, side-by-side selector | Mixed touch + mouse |
| **md** (900–1200px) | Two months side-by-side | Hover states, keyboard nav |
| **lg** (> 1200px) | Year view (multiple months grid) | Dense info, hover previews |

## Techniques

### LayoutBuilder (constraint-based)

`LayoutBuilder` reads constraints from its **parent**, not the screen. Use it to size the calendar grid cells to fill available width:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final cellWidth = constraints.maxWidth / 7;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: cellWidth / 96,
      ),
      ...
    );
  },
)
```

### MediaQuery (screen-level)

Use `MediaQuery.of(context).size` to decide *which* layout to render (single month vs. year grid).

### Adaptive density

- **Desktop:** smaller cells, more information density (tithi, festival, AD date visible).
- **Mobile:** larger touch targets, essential info only (BS day, weekday), optional expansion for details.

## Scroll Behavior

Web users expect native scrollbars. Avoid disabling scroll unless you manage it yourself. Use `SingleChildScrollView` or `GridView` with default physics.

## URL State

Sync the viewed month/year to the URL (`/calendar/2083/1`) so Refresh and back/forward preserve state. This is what makes a web app feel like a website, not a wrapped mobile app.
