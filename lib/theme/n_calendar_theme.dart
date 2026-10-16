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

  static const double breakpointXs = 600;
  static const double breakpointSm = 900;
  static const double breakpointMd = 1200;

  /// How many month grids to show side-by-side given available width.
  static int monthCountForWidth(double width) {
    if (width >= breakpointMd) return 3;
    if (width >= breakpointSm) return 2;
    return 1;
  }

  /// Human-readable breakpoint label.
  static String breakpointLabel(double width) {
    if (width >= breakpointMd) return 'lg';
    if (width >= breakpointSm) return 'md';
    if (width >= breakpointXs) return 'sm';
    return 'xs';
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
