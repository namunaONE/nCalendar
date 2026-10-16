// This is a basic Flutter widget test for nCalendar.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';

import 'package:n_calendar/main.dart';

void main() {
  testWidgets('nCalendar app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NCalendarApp());

    // Verify the app title shows.
    expect(find.text('nCalendar'), findsOneWidget);

    // Pump until the async data load completes and the selector appears.
    await tester.pumpAndSettle();

    // Verify the Bikram Sambat section label shows.
    expect(find.text('Bikram Sambat'), findsOneWidget);
  });
}
