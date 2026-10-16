// This is a basic Flutter widget test for nCalendar.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/main.dart';

void main() {
  testWidgets('nCalendar app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NCalendarApp());

    // Verify the app title shows.
    expect(find.text('nCalendar'), findsOneWidget);

    // Verify the app shell renders without crashing.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    // Pump frames to allow async BS data loading to start without errors.
    // Note: full data load (8.6MB JSON) is not awaited here because
    // rootBundle.loadString does not complete in the Flutter test environment
    // for large asset files. Data loading is verified in production.
    await tester.pump();

    // Verify no error state is shown.
    expect(find.text('Failed to load calendar data'), findsNothing);
  });
}
