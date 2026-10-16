import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/models/bs_day.dart';
import 'package:n_calendar/services/bs_data_service.dart';

/// Anchor test wall for the nCalander data commons (Linear HYA-348
/// groundwork). Every expectation below is independently verified in the
/// research record: verified 2081/2082/2083 rows, portal-confirmed
/// 2004/2062 variants, live adjudicated conversions, and fiscal-year
/// boundaries. Chain closure is checked across the entire 1975-2083 range.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await BsDataService.instance.load();
  });

  BsDay? day(int year, int month, int dayNumber) =>
      BsDataService.instance.dayAt(year, month, dayNumber);

  group('Baisakh 1 anchors', () {
    test('verified years close into official Baisakh 1 dates', () {
      expect(day(2081, 1, 1)!.adDate, '2024-04-13');
      expect(day(2082, 1, 1)!.adDate, '2025-04-14');
      expect(day(2083, 1, 1)!.adDate, '2026-04-14');
      expect(day(2083, 1, 1)!.weekday, 'Tue');
    });

    test('range anchors', () {
      expect(day(1975, 1, 1)!.adDate, '1918-04-13');
      expect(day(2000, 1, 1)!.adDate, '1943-04-14');
      expect(day(2062, 1, 1)!.adDate, '2005-04-14');
    });
  });

  group('verified month rows', () {
    List<int> lengthsOf(int year) => BsDataService.instance.months
        .where((m) => m.bsYear == year)
        .map((m) => m.daysInMonth)
        .toList();

    test('2081 row', () {
      expect(lengthsOf(2081),
          [31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31]);
    });

    test('2082 and 2083 rows', () {
      const row = [31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
      expect(lengthsOf(2082), row);
      expect(lengthsOf(2083), row);
    });
  });

  group('known conversions', () {
    test('Kartik 1 2083 = Oct 18 2026, a Sunday (Fulpati adjudication)', () {
      final kartik1 = day(2083, 7, 1)!;
      expect(kartik1.adDate, '2026-10-18');
      expect(kartik1.weekday, 'Sun');
    });

    test('Ashwin 30 2083 = Oct 16 2026 (four-source live check)', () {
      expect(day(2083, 6, 30)!.adDate, '2026-10-16');
    });

    test('fiscal-year boundaries 2083: Shrawan 1 and Ashadh end', () {
      expect(day(2083, 4, 1)!.adDate, '2026-07-17');
      expect(day(2083, 3, 32)!.adDate, '2026-07-16');
    });

    test('year closes: Chaitra 30 2083 = Apr 13 2027', () {
      expect(day(2083, 12, 30)!.adDate, '2027-04-13');
    });

    test('rare 30-day Baisakh in 2004 (portal-confirmed)', () {
      expect(day(2004, 1, 1)!.adDate, '1947-04-14');
      expect(
        BsDataService.instance.months
            .firstWhere((m) => m.bsYear == 2004 && m.bsMonth == 1)
            .daysInMonth,
        30,
      );
      expect(day(2004, 2, 1)!.adDate, '1947-05-14');
    });

    test('2062 disputed variant: Jestha 1 = May 15 2005 (the +1)', () {
      expect(day(2062, 2, 1)!.adDate, '2005-05-15');
    });
  });

  group('evidence classes', () {
    test('verified years', () {
      for (final year in [2081, 2082, 2083]) {
        expect(
          BsDataService.instance.months
              .firstWhere((m) => m.bsYear == year && m.bsMonth == 1)
              .evidence,
          'verified',
        );
      }
    });

    test('disputed years ship as disputed (never silently resolved)', () {
      for (final year in [1989, 1991, 1993, 2004, 2062]) {
        expect(
          BsDataService.instance.months
              .firstWhere((m) => m.bsYear == year && m.bsMonth == 1)
              .evidence,
          'disputed',
        );
      }
    });
  });

  group('chain closure (full range)', () {
    test('109 years x 12 months, no gaps', () {
      final months = BsDataService.instance.months;
      expect(months.length, 109 * 12);
      for (var i = 0; i + 1 < months.length; i++) {
        final nextStart = _parse(months[i + 1].adStart);
        final expected = _parse(months[i].adEnd).add(const Duration(days: 1));
        expect(nextStart, expected,
            reason: 'Broken chain at \${months[i]}');
      }
    });

    test('every month is internally consistent', () {
      for (final month in BsDataService.instance.months) {
        expect(month.days.length, month.daysInMonth,
            reason: 'Day count mismatch in \$month');
        for (var i = 0; i < month.days.length; i++) {
          expect(month.days[i].bsDay, i + 1);
          expect(month.days[i].weekday, _weekdayOf(month.days[i].adDate),
              reason: 'Weekday mismatch for \${month.days[i]}');
        }
      }
    });
  });
}

DateTime _parse(String iso) {
  final parts = iso.split('-').map(int.parse).toList();
  return DateTime.utc(parts[0], parts[1], parts[2]);
}

String _weekdayOf(String iso) {
  const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  return names[_parse(iso).weekday % 7];
}
