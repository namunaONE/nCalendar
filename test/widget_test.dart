// Widget smoke test for nCalendar.
//
// Since the data asset became compact (~40 KB), the test environment
// can load it for real and assert data-driven content renders.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('nCalendar app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NCalendarApp());

    // App shell renders.
    expect(find.text('nCalendar'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    // Let the real asset IO complete (compact schema-2 asset).
    var loaded = false;
    for (var attempt = 0; attempt < 10 && !loaded; attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      loaded = find.text('Baisakh 2083').evaluate().isNotEmpty;
    }
    await tester.pumpAndSettle();

    // The selected month (Baisakh 2083) renders with data.
    expect(loaded, isTrue,
        reason: 'Calendar data did not load within the retry window');
    expect(find.text('Baisakh 2083'), findsWidgets);
    // Baisakh 1 2083 = 2026-04-14 (verified anchor).
    expect(find.text('2026-04-14'), findsWidgets);

    // No error state.
    expect(find.text('Failed to load calendar data'), findsNothing);
  });
}
