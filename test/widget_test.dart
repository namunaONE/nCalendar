// Widget smoke test for nCalendar — diagnostic build: dumps the visible
// widget tree into the failure reason so CI failures are self-explaining.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/main.dart';
import 'package:n_calendar/services/bs_data_service.dart';
import 'package:n_calendar/widgets/calendar_grid.dart';
import 'package:n_calendar/widgets/date_converter.dart';

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
    for (var attempt = 0; attempt < 20 && !loaded; attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      loaded = find.text('Baisakh 2083').evaluate().isNotEmpty;
    }
    await tester.pumpAndSettle();

    expect(
      loaded,
      isTrue,
      reason: _diagnostics(tester),
    );

    // The month grid renders with data.
    expect(find.text('Baisakh 2083'), findsWidgets);
    // Baisakh 1 2083 = 2026-04-14 (verified anchor).
    expect(find.text('2026-04-14'), findsWidgets);

    // No error state.
    expect(find.text('Failed to load calendar data'), findsNothing);
  });
}

String _diagnostics(WidgetTester tester) {
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>()
      .take(60)
      .toList();
  return 'Calendar did not render within the retry window. '
      'isLoaded=${BsDataService.instance.isLoaded} '
      'months=${BsDataService.instance.months.length} '
      'grids=${find.byType(CalendarGrid).evaluate().length} '
      'converters=${find.byType(DateConverter).evaluate().length} '
      'spinners=${find.byType(CircularProgressIndicator).evaluate().length} '
      'texts=${texts.join(' | ')}';
}
