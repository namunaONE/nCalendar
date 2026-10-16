import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:n_calendar/models/bs_day.dart';
import 'package:n_calendar/models/bs_month.dart';

/// Loads the Bikram Sambat data commons from a bundled JSON asset.
///
/// The sample `assets/bs_data.json` ships with the app. To wire this up to
/// the real nCalander commons, replace `assets/bs_data.json` with the
/// evidence-tagged `calendar.csv`/JSON export (see Linear project nCalander,
/// Phase 1–3) and/or switch this loader to fetch from the neutral commons org.
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

  /// Load the JSON asset and parse it into [BsMonth] objects.
  Future<void> load({String asset = 'assets/bs_data.json'}) async {
    if (_loaded) return;
    final jsonString = await rootBundle.loadString(asset);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final monthsList = data['months'] as List<dynamic>;
    _months = monthsList
        .map((e) => BsMonth.fromJson(e as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }

  /// Convenience: load once then return the months.
  Future<List<BsMonth>> getMonths({String asset = 'assets/bs_data.json'}) async {
    await load(asset: asset);
    return months;
  }
}
