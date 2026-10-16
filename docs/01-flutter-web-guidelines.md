# Flutter Web — Best Rules & Guidelines

These rules apply to nCalendar and any Flutter web project that needs to feel professional, accessible, and deployable on static hosting (GitHub Pages).

## 1. Renderer Choice

| Renderer | When to Use |
|----------|-------------|
| **HTML** (`--web-renderer html`) | Default for nCalendar. Text-heavy, SEO-friendly, smaller bundle, accessible DOM. |
| CanvasKit | Complex custom painting, animations, or pixel-perfect graphics across browsers. Not needed for a calendar grid. |

**Command:** `flutter build web --web-renderer html`

Test the app in both renderers before release. Some plugins behave differently under CanvasKit.

## 2. Responsive Breakpoints

Define breakpoints and adapt layout via `MediaQuery` + `LayoutBuilder`. Never assume a phone viewport on web.

```dart
enum Breakpoint { xs, sm, md, lg }

Breakpoint breakpointOf(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 1200) return Breakpoint.lg;
  if (width >= 900)  return Breakpoint.md;
  if (width >= 600)  return Breakpoint.sm;
  return Breakpoint.xs;
}
```

- `xs` < 600px — single column, large touch targets
- `sm` 600–900px — two columns where sensible
- `md` 900–1200px — multi-month calendar grid
- `lg` > 1200px — year view, dense information

## 3. Navigation & URLs

Use **GoRouter** with real URL paths so browser back/forward, refresh, and deep links work:

- `/calendar/2083/1` — Baisakh 2083
- `/calendar/2083/5` — Shrawan 2083

Avoid hiding all state behind opaque in-memory routes. The URL should be the source of truth for the currently viewed month/year.

## 4. Performance

- Defer offscreen images and assets.
- Lazy-load heavy packages.
- Keep the initial JS bundle small — tree-shake unused code.
- Use `const` constructors everywhere possible.
- Profile with Flutter DevTools performance view.
- For large calendar data commons, fetch from CDN/API with caching instead of shipping everything in the build.

## 5. Accessibility

- Provide `Semantics` widgets for custom controls.
- Ensure sufficient color contrast. Primary `#002C6D` needs white/light text; secondary `#4FD166` needs dark text.
- Logical focus traversal order (Tab).
- `Tooltip` / `Semantics` labels for icon buttons.
- Tap targets ≥ 44×44 CSS px.

## 6. SEO / Meta

Set in `web/index.html`:
- `<title>` — descriptive per page/route
- `<meta name="description">`
- Open Graph tags (`og:title`, `og:description`, `og:image`)
- Canonical URL

For GitHub Pages discoverability, consider a static pre-render step or server-side rendering for public calendar pages.

## 7. PWA (Progressive Web App)

- Complete `web/manifest.json`: name, short_name, start_url, display, theme_color (`#002C6D`), icons (192px & 512px).
- `meta name="mobile-web-app-capable" content="yes"` (already present).
- Register a service worker for offline calendar viewing after first load.

## 8. Interaction (Web Conventions)

- Hover states (`MouseRegion`, `InkWell`) for mouse users — not just tap.
- Keyboard navigation (Tab order through dropdowns and grid).
- Support both tap and click.
- Native scrollbars and momentum scrolling — avoid `NeverScrollableScrollPhysics()` unless you manage scrolling yourself.

## 9. Asset Loading

- Bundle `assets/bs_data.json` via `rootBundle` (current approach).
- For large data commons, fetch from CDN/API with caching instead of shipping everything.

## 10. Flutter Version

- SDK: `^3.13.4`
- Material 3 enabled (`useMaterial3: true`)
- `flutter_lints: ^6.0.0` for analysis rules
