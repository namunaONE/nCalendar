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
// (C1 bundle diet). In tests the loading unit is shared, so the
// converter test completes it deterministically in a real-async
// window (runAsync) BEFORE booting the app; the app's own
// loadLibrary() then resolves in a microtask instead of gating on
// real IO inside the fake-async test zone.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/main.dart';
import 'package:n_calendar/models/bs_month.dart';
import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/services/today_service.dart';
// The deferred prefix is used below via converter_lib.loadLibrary();
// the analyzer does not count loadLibrary() as member usage and
// flags this as unused — an ignore is the honest fix here.
// ignore: unused_import
import 'package:n_calendar/widgets/date_converter.dart'
    deferred as converter_lib;

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
    // Complete the deferred loading unit in real async BEFORE the
    // app boots; the app's loadLibrary() then resolves in a
    // microtask. (Same loading unit — shared across imports.)
    await tester.runAsync(() => converter_lib.loadLibrary());

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

    // Switching to the Converter tab kicks off the app's
    // loadLibrary(); the unit is already loaded, so this resolves
    // in a microtask at the next pump.
    await tester.tap(find.text('Converter'));
    await tester.pump();

    var visible = false;
    for (var attempt = 0; attempt < 20 && !visible; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
      visible = find.text('AD → BS').evaluate().isNotEmpty;
    }
    await tester.pumpAndSettle();

    if (!visible) {
      // Compact diagnostics — stdout lands in the CI PR comment.
      final errorShown = find
          .textContaining('Converter failed to load')
          .evaluate()
          .isNotEmpty;
      final converterInTree =
          find.text('BS → AD', skipOffstage: false).evaluate().isNotEmpty;
      debugPrint('converter-tab debug: errorShown=$errorShown, '
          'converterWidgetsInTree=$converterInTree');
    }

    expect(visible, isTrue,
        reason: 'Deferred converter library did not load and render '
            '(see converter-tab debug line in the log above)');
    expect(find.text('BS → AD'), findsOneWidget);
    expect(find.text('Pick an AD date'), findsOneWidget);
  });
}
