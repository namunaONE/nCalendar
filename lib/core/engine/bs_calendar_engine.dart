import 'package:n_calendar/core/models/bs_day.dart';
import 'package:n_calendar/core/models/bs_month.dart';
import 'package:n_calendar/core/models/bs_year.dart';

/// Expands compact BS year rows (Baisakh 1 AD anchor + 12 month lengths)
/// into the full [BsMonth] / [BsDay] object graph consumed by the UI.
///
/// Month AD spans, per-day AD dates, and weekday names are all derived
/// from the anchor and month lengths, so the shipped asset stays ~40 KB
/// instead of ~8.6 MB while the public model API is unchanged.
///
/// Weekday conversion: Dart's DateTime.weekday is Monday=1..Sunday=7;
/// modulo 7 yields the Sun=0..Sat=6 indexing used by the name tables.
class BsCalendarEngine {
  BsCalendarEngine._();

  static const List<String> _weekdayEn = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
  ];

  static const List<String> _weekdayNe = [
    'आइतबार', 'सोमबार', 'मंगलबार', 'बुधबार', 'बिहिबार', 'शुक्रबार', 'शनिबार',
  ];

  /// Expand a full dataset of year rows into month objects, in order.
  static List<BsMonth> expandYears(List<BsYearRow> years) =>
      [for (final year in years) ...expandYear(year)];

  /// Expand one year row into its twelve [BsMonth] objects.
  static List<BsMonth> expandYear(BsYearRow row) {
    var cursor = _parseIso(row.baisakh1Ad);
    final months = <BsMonth>[];
    for (var monthIdx = 1; monthIdx <= 12; monthIdx++) {
      final length = row.monthLengths[monthIdx - 1];
      final adEnd = cursor.add(Duration(days: length - 1));
      final days = <BsDay>[];
      for (var day = 1; day <= length; day++) {
        final ad = cursor.add(Duration(days: day - 1));
        final weekdayIndex = ad.weekday % 7; // Sun=0..Sat=6
        days.add(BsDay(
          bsDay: day,
          adDate: _iso(ad),
          weekday: _weekdayEn[weekdayIndex],
          weekdayNepali: _weekdayNe[weekdayIndex],
          tithi: '',
        ));
      }
      final month = BsMonth(
        bsYear: row.bsYear,
        bsMonth: monthIdx,
        bsMonthName: BsMonth.monthName(monthIdx),
        bsMonthNameNepali: BsMonth.monthNameNepali(monthIdx),
        daysInMonth: length,
        adStart: _iso(cursor),
        adEnd: _iso(adEnd),
        days: days,
        evidence: row.evidence,
        sources: row.sources,
        notes: row.notes,
      );
      for (final day in month.days) {
        day.setMonthContext(month.bsYear, month.bsMonth);
      }
      months.add(month);
      cursor = adEnd.add(const Duration(days: 1));
    }
    return months;
  }

  static DateTime _parseIso(String iso) {
    final parts = iso.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], parts[2]);
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
