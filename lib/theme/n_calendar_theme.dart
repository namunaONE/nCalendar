import 'package:flutter/material.dart';

/// nCalendar design system — brand tokens + shared theme.
///
/// Primary:   #002C6D  (navy depth)
/// Secondary: #4FD166  (growth green)
class NCalendarTheme {
  NCalendarTheme._();

  /// Primary seed — navy depth. Used for AppBar, primary buttons, active states.
  static const Color primaryNavy = Color(0xFF002C6D);

  /// Secondary seed — growth green. Used for festival chips, secondary actions,
  /// "Today" markers, accents.
  static const Color growthGreen = Color(0xFF4FD166);

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
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
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
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      );

  // -------------------------------------------------------------------------
  // Convenience token accessors
  // -------------------------------------------------------------------------

  /// Returns the brand `ColorScheme` for the current context.
  static ColorScheme schemeOf(BuildContext context) => Theme.of(context).colorScheme;
}
