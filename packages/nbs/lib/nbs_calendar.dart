import 'bs_day.dart';
import 'bs_month.dart';
import 'nbs_data.dart';

/// `NbsCalendar` — the public facade of the nbs package (R10 design, F5).
///
/// The honesty contract is the API: every lookup is an exact query into
/// the loaded dataset, and anything outside it returns **null — never a
/// guess, never a projection presented as fact.** Beyond 2083 there is no
/// official BS data (only Baisakh 1 2084 is published); nbs will not
/// invent it.
///
/// Evidence classes travel with the data: `verified` (official panchang /
/// portal-confirmed), `consensus` (multiple independent open datasets
/// agree), `disputed` (two traditional variants exist — shipped as one
/// labeled variant, never silently resolved), `projection`. Consumers
/// must scope every accuracy claim to the class of the row they read.
class NbsCalendar {
  final List<BsMonth> _months;

  NbsCalendar._(this._months);

  /// Parse a bs_data JSON string (see [NbsData]) and build a calendar.
  factory NbsCalendar.parse(String jsonString) {
    final dataset = NbsData.parse(jsonString);
    return NbsCalendar._(dataset.months);
  }

  /// Build from already-parsed months (e.g. your own loader).
  factory NbsCalendar.fromMonths(List<BsMonth> months) = NbsCalendar._;

  /// All loaded months, in AD order.
  List<BsMonth> get months => List.unmodifiable(_months);

  /// The BS years covered by the loaded data.
  List<int> get supportedYears {
    final years = <int>{for (final m in _months) m.bsYear}.toList()..sort();
    return years;
  }

  /// Look up a BS month. Null when the year/month is not in the data.
  BsMonth? month(int bsYear, int bsMonth) {
    for (final m in _months) {
      if (m.bsYear == bsYear && m.bsMonth == bsMonth) return m;
    }
    return null;
  }

  /// Look up a single BS day by (year, month, day).
  /// Null when out of the dataset or the day exceeds the month length —
  /// never a guess.
  BsDay? day(int bsYear, int bsMonth, int bsDay) {
    final m = month(bsYear, bsMonth);
    if (m == null) return null;
    for (final d in m.days) {
      if (d.bsDay == bsDay) return d;
    }
    return null;
  }

  /// Look up the BS day for an ISO AD date (`yyyy-mm-dd`).
  /// Null outside the supported range — never a guess.
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

  /// Convenience: the ISO AD date (`yyyy-mm-dd`) of a BS date, or null.
  String? adDateOf(int bsYear, int bsMonth, int bsDay) =>
      day(bsYear, bsMonth, bsDay)?.adDate;
}
