import 'package:n_calendar/core/models/bs_day.dart';
import 'package:n_calendar/core/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';

/// Provides today's Bikram Sambat date by looking up today's AD date
/// in the verified calendar data commons.
class TodayService {
  TodayService._();

  static final TodayService instance = TodayService._();

  /// Today's AD date in ISO format (yyyy-MM-dd).
  String get todayAdDate {
    final now = DateTime.now();
    return '${now.year}-${_two(now.month)}-${_two(now.day)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  /// Look up today's [BsDay] in the loaded calendar data.
  BsDay? today() {
    for (final m in BsDataService.instance.months) {
      try {
        return m.days.firstWhere((d) => d.adDate == todayAdDate);
      } on StateError {
        // continue to next month
      }
    }
    return null;
  }

  /// Look up today's [BsMonth] in the loaded calendar data.
  BsMonth? todayMonth() {
    final day = today();
    if (day == null) return null;
    for (final m in BsDataService.instance.months) {
      if (m.bsYear == day.bsYear && m.bsMonth == day.bsMonth) {
        return m;
      }
    }
    return null;
  }
}
