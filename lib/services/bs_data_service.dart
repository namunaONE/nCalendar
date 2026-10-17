import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nbs/bs_day.dart';
import 'package:nbs/bs_month.dart';
import 'package:nbs/bs_year.dart';
import 'package:nbs/bs_calendar_engine.dart';

/// Loads the Bikram Sambat data commons from a bundled JSON asset.
///
/// Schema 2 (current): assets/bs_data.json ships one compact row per BS
/// year (Baisakh 1 AD anchor + 12 month lengths + evidence tags); the
/// full month/day grid is expanded at runtime by [BsCalendarEngine].
/// Schema 1 (legacy, pre-expanded 'months' list) is still accepted.
///
/// The asset is generated from data/calendar.csv by
/// scripts/gen_bs_data.py — never hand-edited; CI verifies sync.
class BsDataService {
  BsDataService._();

  static final BsDataService instance = BsDataService._();

  List<BsMonth> _months = [];
  bool _loaded = false;

  /// Whether the data has been loaded.
  bool get isLoaded => _loaded;

  /// All loaded BS months.
  List<BsMonth> get months => List.unmodifiable(_months);

  /// Look up a single BS day by (year, month, day).
  BsDay? dayAt(int year, int month, int day) {
    for (final m in _months) {
      if (m.bsYear == year && m.bsMonth == month) {
        try {
          return m.days.firstWhere((d) => d.bsDay == day);
        } on StateError {
          return null;
        }
      }
    }
    return null;
  }

  /// Look up the BS day for an ISO AD date (`yyyy-mm-dd`).
  ///
  /// Exact lookup inside the shipped dataset — months are ordered by
  /// AD start, so the scan stops as soon as the date has been passed.
  /// Returns null outside the supported range — never a guess.
  BsDay? dayForAdDate(String adDate) {
    for (final m in _months) {
      if (adDate.compareTo(m.adStart) < 0) return null;
      if (adDate.compareTo(m.adEnd) <= 0) {
        for (final d in m.days) {
          if (d.adDate == adDate) return d;
        }
        return null;
      }
    }
    return null;
  }

  /// Load the JSON asset and parse it into [BsMonth] objects.
  Future<void> load({String asset = 'assets/bs_data.json'}) async {
    if (_loaded) return;
    final jsonString = await rootBundle.loadString(asset);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final schema = data['schema'] as int? ?? 1;
    if (schema >= 2) {
      final years = (data['years'] as List<dynamic>)
          .map((e) => BsYearRow.fromJson(e as Map<String, dynamic>))
          .toList();
      _months = BsCalendarEngine.expandYears(years);
    } else {
      final monthsList = data['months'] as List<dynamic>;
      _months = monthsList
          .map((e) => BsMonth.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _loaded = true;
  }

  /// Convenience: load once then return the months.
  Future<List<BsMonth>> getMonths({String asset = 'assets/bs_data.json'}) async {
    await load(asset: asset);
    return months;
  }
}
