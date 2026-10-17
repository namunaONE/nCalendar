import 'dart:convert';

import 'bs_calendar_engine.dart';
import 'bs_month.dart';
import 'bs_year.dart';

/// Result of parsing a BS data asset: the compact year rows (wire format)
/// plus the engine-expanded month/day grid.
class NbsDataset {
  final List<BsYearRow> years;
  final List<BsMonth> months;

  const NbsDataset({required this.years, required this.months});
}

/// Pure-Dart parser for the nCalander BS data commons JSON
/// (assets/bs_data.json as generated from data/calendar.csv by
/// scripts/gen_bs_data.py — the asset is never hand-edited).
///
/// Supported schemas:
/// - schema 2 (current, compact): one row per BS year — Baisakh 1 AD anchor
///   + 12 month lengths + evidence tags; the full grid is expanded by
///   [BsCalendarEngine].
/// - schema 1 (legacy, pre-expanded): a `months` list of full month objects.
///
/// This loader has NO Flutter dependencies: bring your own JSON string
/// (rootBundle, File, network — your choice).
class NbsData {
  NbsData._();

  /// Parse a bs_data JSON string into year rows + expanded months.
  ///
  /// Throws [FormatException] on malformed input — the caller decides how
  /// to fail; this package never guesses.
  static NbsDataset parse(String jsonString) {
    final data = jsonDecode(jsonString);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('bs_data: top level must be a JSON object');
    }
    final schema = data['schema'] as int? ?? 1;
    if (schema >= 2) {
      final years = (data['years'] as List<dynamic>)
          .map((e) => BsYearRow.fromJson(e as Map<String, dynamic>))
          .toList();
      return NbsDataset(
          years: years, months: BsCalendarEngine.expandYears(years));
    }
    final monthsList = data['months'] as List<dynamic>;
    final months = monthsList
        .map((e) => BsMonth.fromJson(e as Map<String, dynamic>))
        .toList();
    return NbsDataset(years: const [], months: months);
  }
}
