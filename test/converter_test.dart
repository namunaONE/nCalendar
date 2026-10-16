import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/widgets/date_converter.dart';

/// Tests for the AD <-> BS converter (new in 1.2.0).
/// Every date expectation is an anchor already verified in the
/// research record — see test/bs_engine_test.dart for the full wall.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await BsDataService.instance.load();
  });

  group('dayForAdDate: exact reverse lookup', () {
    test('live anchor: 2026-10-16 = Ashwin 30, 2083 (Friday)', () {
      final day = BsDataService.instance.dayForAdDate('2026-10-16')!;
      expect(day.bsYear, 2083);
      expect(day.bsMonth, 6);
      expect(day.bsDay, 30);
      expect(day.weekday, 'Fri');
    });

    test('Baisakh 1 2083 anchor: 2026-04-14', () {
      final day = BsDataService.instance.dayForAdDate('2026-04-14')!;
      expect(day.bsYear, 2083);
      expect(day.bsMonth, 1);
      expect(day.bsDay, 1);
    });

    test('dataset edges', () {
      final first = BsDataService.instance.dayForAdDate('1918-04-13')!;
      expect(first.bsYear, 1975);
      expect(first.bsMonth, 1);
      expect(first.bsDay, 1);

      final last = BsDataService.instance.dayForAdDate('2027-04-13')!;
      expect(last.bsYear, 2083);
      expect(last.bsMonth, 12);
      expect(last.bsDay, 30);
    });

    test('out of range returns null — never a guess', () {
      expect(BsDataService.instance.dayForAdDate('1918-04-12'), isNull);
      expect(BsDataService.instance.dayForAdDate('2027-04-14'), isNull);
      expect(BsDataService.instance.dayForAdDate('2099-01-01'), isNull);
    });

    test('round trip: dayAt -> adDate -> dayForAdDate is identity', () {
      final anchors = [
        [2062, 2, 1],
        [2004, 1, 30],
        [2083, 7, 1],
      ];
      for (final a in anchors) {
        final day = BsDataService.instance.dayAt(a[0], a[1], a[2])!;
        final back = BsDataService.instance.dayForAdDate(day.adDate)!;
        expect(back.bsYear, a[0],
            reason: 'year mismatch for ${day.adDate}');
        expect(back.bsMonth, a[1],
            reason: 'month mismatch for ${day.adDate}');
        expect(back.bsDay, a[2],
            reason: 'day mismatch for ${day.adDate}');
      }
    });
  });

  testWidgets('converter renders a verified anchor as a result card',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DateConverter(initialAdDate: DateTime(2026, 10, 16)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Result card shows the BS date, the AD date, and the weekday.
    expect(find.text('Ashwin 30, 2083'), findsOneWidget);
    expect(find.text('2026-10-16'), findsOneWidget);
    expect(find.text('Friday'), findsOneWidget);
  });
}
