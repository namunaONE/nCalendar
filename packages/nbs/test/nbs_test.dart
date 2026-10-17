import 'package:nbs/bs_calendar_engine.dart';
import 'package:nbs/bs_year.dart';
import 'package:nbs/nbs_calendar.dart';
import 'package:nbs/nbs_data.dart';
import 'package:test/test.dart';

/// Anchor tests for the nbs core.
///
/// EVIDENCE POLICY: every anchor below is typed from the independent
/// research record (portal triangulation on Hamro Patro date pages,
/// print panchang validation), NOT from calendar.csv alone. Calendar
/// datasets can be wrong; these anchors were verified against sources
/// outside the dataset (nCalander research rounds R1-R8, Oct 2026).
void main() {
  // Verified rows (evidence class: verified — official panchang / print
  // + portal triangulation; the years close into the official
  // Baisakh 1 2084 = Wed, 14 Apr 2027).
  const verified2081 = [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  const verified2082 = [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];

  BsYearRow row(int year, String baisakh1Ad, List<int> lengths,
          {String evidence = 'verified'}) =>
      BsYearRow(
        bsYear: year,
        baisakh1Ad: baisakh1Ad,
        monthLengths: lengths,
        evidence: evidence,
      );

  /// A small fixture dataset: verified 2081 + 2082 (portal/print-verified
  /// rows) plus the disputed 2004 variant (portal-confirmed variant of a
  /// disputed year, incl. the rare 30-day Baisakh).
  final fixtureYears = [
    row(2004, '1947-04-14',
        [30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31],
        evidence: 'disputed'),
    row(2081, '2024-04-13', verified2081),
    row(2082, '2025-04-14', verified2082),
  ];

  NbsCalendar calendarFromRows() {
    final months = BsCalendarEngine.expandYears(fixtureYears);
    return NbsCalendar.fromMonths(months);
  }

  group('Baisakh 1 anchors (portal/print evidence)', () {
    test('verified years close into official Baisakh 1 dates', () {
      final cal = calendarFromRows();
      expect(cal.adDateOf(2081, 1, 1), '2024-04-13');
      expect(cal.adDateOf(2082, 1, 1), '2025-04-14');
    });

    test('2081 year closes into 2082 (chain over the fixture)', () {
      final cal = calendarFromRows();
      expect(cal.adDateOf(2081, 12, 31), '2025-04-13');
      expect(cal.adDateOf(2082, 1, 1), '2025-04-14');
    });
  });

  group('verified month rows', () {
    test('2081 expanded month lengths match the verified row', () {
      final cal = calendarFromRows();
      final lengths = [
        for (var m = 1; m <= 12; m++) cal.month(2081, m)!.daysInMonth,
      ];
      expect(lengths, verified2081);
    });
  });

  group('known conversions (live adjudications, R5/R6)', () {
    test('month chain: Ashwin 2081 starts the day Shrawan ends +1', () {
      final cal = calendarFromRows();
      final shrawan = cal.month(2081, 4)!;
      final ashwin = cal.month(2081, 5)!;
      expect(ashwin.adStart, _dayAfter(shrawan.adEnd));
    });

    test('weekday is derived, not stored: Baisakh 1 2082 = Monday', () {
      final cal = calendarFromRows();
      expect(cal.day(2082, 1, 1)!.weekday, 'Mon');
      expect(cal.day(2082, 1, 1)!.weekdayNepali, 'सोमबार');
    });

    test('rare 30-day Baisakh in 2004 (portal-confirmed variant)', () {
      final cal = calendarFromRows();
      expect(cal.month(2004, 1)!.daysInMonth, 30);
      expect(cal.adDateOf(2004, 2, 1), '1947-05-14');
    });
  });

  group('honesty contract (null, never a guess)', () {
    test('day outside the loaded dataset is null', () {
      final cal = calendarFromRows();
      expect(cal.day(2083, 1, 1), isNull);
      expect(cal.day(2075, 1, 1), isNull);
      expect(cal.month(2083, 1), isNull);
    });

    test('day number beyond the month length is null', () {
      final cal = calendarFromRows();
      expect(cal.day(2004, 1, 31), isNull); // 30-day Baisakh
      expect(cal.day(2081, 9, 30), isNull); // 29-day Poush 2081
    });

    test('AD date outside the loaded range is null', () {
      final cal = calendarFromRows();
      expect(cal.dayForAdDate('2083-04-14'), isNull);
      expect(cal.dayForAdDate('1946-04-14'), isNull);
    });

    test('supportedYears reflects the loaded data only', () {
      expect(calendarFromRows().supportedYears, [2004, 2081, 2082]);
    });
  });

  group('evidence classes travel with the data', () {
    test('disputed year is labeled disputed, never silently resolved', () {
      expect(calendarFromRows().month(2004, 1)!.evidence, 'disputed');
      expect(calendarFromRows().month(2081, 1)!.evidence, 'verified');
    });
  });

  group('NbsData.parse (bring your own JSON)', () {
    test('schema 2 compact format expands via the engine', () {
      final json = '''
      {
        "schema": 2,
        "generated": "test",
        "years": [
          {"bsYear": 2083, "baisakh1Ad": "2026-04-14",
           "monthLengths": [31,31,32,31,31,31,30,29,30,29,30,30],
           "evidence": "verified", "sources": "test", "notes": ""}
        ]
      }
      ''';
      final dataset = NbsData.parse(json);
      expect(dataset.years.length, 1);
      expect(dataset.months.length, 12);
      final cal = NbsCalendar.parse(json);
      // Portal-verified anchor: Baisakh 1 2083 = 14 Apr 2026, a Tuesday.
      expect(cal.adDateOf(2083, 1, 1), '2026-04-14');
      expect(cal.day(2083, 1, 1)!.weekday, 'Tue');
      // Live adjudication (R5/R6): Kartik 1 2083 = Oct 18 2026, Sunday
      // (Fulpati adjudication; Tula sankranti Oct 17 20:20 NPT -> +1).
      expect(cal.adDateOf(2083, 7, 1), '2026-10-18');
      expect(cal.day(2083, 7, 1)!.weekday, 'Sun');
    });

    test('legacy schema 1 (pre-expanded months) still parses', () {
      final json = '''
      {
        "months": [
          {"bsYear": 2083, "bsMonth": 1, "bsMonthName": "Baisakh",
           "bsMonthNameNepali": "बैशाख", "daysInMonth": 30,
           "adStart": "2026-04-14", "adEnd": "2026-05-13",
           "days": [
             {"bsDay": 1, "adDate": "2026-04-14", "weekday": "Tue",
              "weekdayNepali": "मंगलबार", "tithi": "", "festival": null}
           ],
           "evidence": "verified", "sources": "", "notes": ""}
        ]
      }
      ''';
      final cal = NbsCalendar.parse(json);
      expect(cal.adDateOf(2083, 1, 1), '2026-04-14');
      expect(cal.day(2083, 1, 2), isNull); // only 1 day in the fixture
    });

    test('malformed input throws, never guesses', () {
      expect(() => NbsData.parse('not json'), throwsFormatException);
      expect(() => NbsData.parse('[1,2,3]'), throwsFormatException);
    });
  });

  group('expansion invariants', () {
    test('every expanded day count matches the month length and is ordered', () {
      for (final month in BsCalendarEngine.expandYears(fixtureYears)) {
        expect(month.days.length, month.daysInMonth);
        for (var i = 0; i < month.days.length; i++) {
          expect(month.days[i].bsDay, i + 1);
          expect(month.days[i].weekday, _weekdayOf(month.days[i].adDate),
              reason: 'Weekday mismatch for ${month.days[i]}');
        }
      }
    });
  });
}

String _dayAfter(String iso) {
  final parts = iso.split('-').map(int.parse).toList();
  final d = DateTime.utc(parts[0], parts[1], parts[2])
      .add(const Duration(days: 1));
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

String _weekdayOf(String iso) {
  const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final parts = iso.split('-').map(int.parse).toList();
  return names[DateTime.utc(parts[0], parts[1], parts[2]).weekday % 7];
}
