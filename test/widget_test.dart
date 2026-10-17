// Widget smoke tests for nCalendar.
//
// The data service is warmed in setUpAll (outside the fake async zone)
// so the boot path is deterministic; asset correctness is covered by
// test/bs_engine_test.dart and test/data_invariants_test.dart.
//
// The app opens on today's BS month (today-default). The test surface
// is phone-sized (800x600 physical = ~267x200 logical), so the
// responsive grid shows exactly ONE month card: the selected month,
// i.e. today's. All assertions are computed from the real data
// service so they stay valid on any CI date, and fall back to the
// Baisakh 2083 default once today leaves the shipped range (2027+).
//
// The date converter is a dart2js DEFERRED library in the web build
// (C1 bundle diet); loadLibrary() resolves on the test VM, and the
// converter tab test pumps until the deferred future completes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/main.dart';
import 'package:n_calendar/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/services/today_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await BsDataService.instance.load();
  });

  testWidgets('nCalendar app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NCalendarApp());

    // App shell renders.
    expect(find.text('nCalendar'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    // The app must open on today's BS month when today is inside the
    // shipped dataset (BS 1975-2083); post-2027 it falls back to the
    // default selection (Baisakh 2083).
    final today = TodayService.instance.today();
    final expectedHeader = today == null
        ? 'Baisakh 2083'
        : '${BsMonth.monthName(today.bsMonth)} ${today.bsYear}';

    var loaded = false;
    for (var attempt = 0; attempt < 20 && !loaded; attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      loaded = find.text(expectedHeader).evaluate().isNotEmpty;
    }
    await tester.pumpAndSettle();

    expect(loaded, isTrue,
        reason: 'Calendar data did not load within the retry window');

    // The month grid renders with data: the header of today's month
    // plus the first day cell (exact AD anchor from the dataset).
    expect(find.text(expectedHeader), findsWidgets);
    if (today != null) {
      expect(
        find.text(
            'Today: ${today.bsDay} ${BsMonth.monthName(today.bsMonth)} ${today.bsYear}'),
        findsOneWidget,
        reason: 'The app must open on today (today banner visible)',
      );
      expect(
        find.text(
            '${BsMonth.monthName(today.bsMonth)} ${today.bsDay}, ${today.bsYear}'),
        findsOneWidget,
        reason: 'The app bar must show today as a jump-back chip',
      );
      final month = BsDataService.instance.months.firstWhere(
        (m) => m.bsYear == today.bsYear && m.bsMonth == today.bsMonth,
      );
      expect(find.text(month.adStart), findsWidgets);
    }

    // No error state.
    expect(find.text('Failed to load calendar data'), findsNothing);
  });

  testWidgets('Converter tab: deferred library loads and renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NCalendarApp());

    // Wait for boot: the bottom NavigationBar only renders once a
    // month is available.
    var booted = false;
    for (var attempt = 0; attempt < 20 && !booted; attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      booted = find.text('Converter').evaluate().isNotEmpty;
    }
    await tester.pumpAndSettle();
    expect(booted, isTrue, reason: 'Bottom navigation did not render');

    // Switching to the Converter tab kicks off loadLibrary().
    await tester.tap(find.text('Converter'));
    await tester.pump();

    // The deferred-library future resolves outside the fake async zone.
    var visible = false;
    for (var attempt = 0; attempt < 20 && !visible; attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      visible = find.text('AD → BS').evaluate().isNotEmpty;
    }
    await tester.pumpAndSettle();

    expect(visible, isTrue,
        reason: 'Deferred converter library did not load and render');
    expect(find.text('BS → AD'), findsOneWidget);
    expect(find.text('Pick an AD date'), findsOneWidget);
  });
}
