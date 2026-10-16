import 'package:flutter/material.dart';

/// nCalendar design system — brand tokens, breakpoints, and shared theme.
///
/// Primary:   #002C6D  (navy depth)
/// Secondary: #4FD166  (growth green)
class NCalendarTheme {
  NCalendarTheme._();

  // -------------------------------------------------------------------------
  // Brand colors
  // -------------------------------------------------------------------------

  /// Primary seed — navy depth. AppBar, primary buttons, active states, focus rings.
  static const Color primaryNavy = Color(0xFF002C6D);

  /// Secondary seed — growth green. Festival chips, secondary actions, "Today" markers, accents.
  static const Color growthGreen = Color(0xFF4FD166);

  // -------------------------------------------------------------------------
  // Responsive breakpoints (CSS px)
  // -------------------------------------------------------------------------

  /// Extra small — phones portrait (< 480px): single column, large touch targets.
  static const double breakpointXs = 480;

  /// Small — phones landscape / small tablets (480–768px): single column.
  static const double breakpointSm = 768;

  /// Medium — tablets (768–1024px): 2 months side-by-side.
  static const double breakpointMd = 1024;

  /// Large — laptops / small desktops (1024–1400px): 3–4 months side-by-side.
  static const double breakpointLg = 1400;

  /// Extra large — wide desktops (> 1400px): 4–6 months side-by-side.
  static const double breakpointXl = 1400;

  /// How many month grids to show side-by-side given available width.
  static int monthCountForWidth(double width) {
    if (width >= breakpointXl) return 6;
    if (width >= breakpointLg) return 4;
    if (width >= breakpointMd) return 3;
    if (width >= breakpointSm) return 2;
    return 1;
  }

  /// Human-readable breakpoint label.
  static String breakpointLabel(double width) {
    if (width >= breakpointXl) return 'xl';
    if (width >= breakpointLg) return 'lg';
    if (width >= breakpointMd) return 'md';
    if (width >= breakpointSm) return 'sm';
    return 'xs';
  }

  /// Minimum touch target size (44px recommended for web accessibility).
  static const double minTouchTarget = 44.0;

  /// Responsive padding based on screen width.
  static double responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= breakpointLg) return 32.0;
    if (width >= breakpointMd) return 24.0;
    if (width >= breakpointSm) return 20.0;
    return 16.0;
  }

  /// Responsive font scale factor.
  static double responsiveTextScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= breakpointLg) return 1.15;
    if (width >= breakpointMd) return 1.1;
    if (width >= breakpointSm) return 1.05;
    return 1.0;
  }

  // -------------------------------------------------------------------------
  // Light / Dark ThemeData
  // -------------------------------------------------------------------------

  /// Light theme built from brand seeds.
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          secondary: growthGreen,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      );

  /// Dark theme built from the same brand seeds.
  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          secondary: growthGreen,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      );

  // -------------------------------------------------------------------------
  // Convenience token accessors
  // -------------------------------------------------------------------------

  /// Returns the brand `ColorScheme` for the current context.
  static ColorScheme schemeOf(BuildContext context) => Theme.of(context).colorScheme;

  /// Returns the current breakpoint label for the context.
  static String breakpointOf(BuildContext context) =>
      breakpointLabel(MediaQuery.of(context).size.width);
}
