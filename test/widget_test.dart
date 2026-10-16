// Widget smoke test for nCalendar.
//
// Since the data asset became compact (~40 KB), the test environment
// can load it for real and assert data-driven content renders.
//
// The service is warmed in setUpAll (outside the fake async zone, like
// the engine/invariant tests) so the boot path is deterministic:
// expanding 39k days inside the short runAsync retry windows is
// flaky on slow CI runners. Asset correctness itself is covered by
// test/bs_engine_test.dart and test/data_invariants_test.dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/main.dart';
import 'package:n_calendar/services/bs_data_service.dart';

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

    // Let the (already warm) boot microtasks resolve and paint.
    var loaded = false;
    for (var attempt = 0; attempt < 10 && !loaded; attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      loaded = find.text('Baisakh 2083').evaluate().isNotEmpty;
    }
    await tester.pumpAndSettle();

    // The month grid renders with data (Baisakh is shown alongside the
    // today-default selection on md+ viewports).
    expect(loaded, isTrue,
        reason: 'Calendar data did not load within the retry window');
    expect(find.text('Baisakh 2083'), findsWidgets);
    // Baisakh 1 2083 = 2026-04-14 (verified anchor).
    expect(find.text('2026-04-14'), findsWidgets);

    // No error state.
    expect(find.text('Failed to load calendar data'), findsNothing);
  });
}
