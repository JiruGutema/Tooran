import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/widgets/due_date_input.dart';

void main() {
  group('DueDateInput', () {
    testWidgets('should display initial values correctly', (WidgetTester tester) async {
      final initialDate = DateTime(2025, 1, 15);
      const initialTime = TimeOfDay(hour: 14, minute: 30);
      DateTime? selectedDate;
      TimeOfDay? selectedTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              initialDate: initialDate,
              initialTime: initialTime,
              onChanged: (date, time) {
                selectedDate = date;
                selectedTime = time;
              },
            ),
          ),
        ),
      );

      // Check that the date button shows the formatted date
      expect(find.text('Jan 15, 2025'), findsOneWidget);
      
      // Check that the time button shows the formatted time
      expect(find.text('2:30 PM'), findsOneWidget);
    });

    testWidgets('should show clear button when date/time is set', (WidgetTester tester) async {
      final initialDate = DateTime(2025, 1, 15);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              initialDate: initialDate,
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Clear button should be visible
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('should not show clear button when no date/time is set', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Clear button should not be visible
      expect(find.text('Clear'), findsNothing);
      
      // Should show placeholder text
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
    });

    testWidgets('should call onChanged when clear is tapped', (WidgetTester tester) async {
      final initialDate = DateTime(2025, 1, 15);
      DateTime? selectedDate = initialDate;
      TimeOfDay? selectedTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              initialDate: initialDate,
              onChanged: (date, time) {
                selectedDate = date;
                selectedTime = time;
              },
            ),
          ),
        ),
      );

      // Tap the clear button
      await tester.tap(find.text('Clear'));
      await tester.pump();

      // Verify that onChanged was called with null values
      expect(selectedDate, isNull);
      expect(selectedTime, isNull);
    });

    testWidgets('should show helper text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Should show helper text for empty state
      expect(find.text('Optional: Set a due date to receive reminders'), findsOneWidget);
    });

    testWidgets('should render correctly when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              enabled: false,
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Should still show the date and time selection UI
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      
      // Should show the helper text
      expect(find.text('Optional: Set a due date to receive reminders'), findsOneWidget);
    });

    testWidgets('should handle date selection', (WidgetTester tester) async {
      DateTime? selectedDate;
      TimeOfDay? selectedTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              onChanged: (date, time) {
                selectedDate = date;
                selectedTime = time;
              },
            ),
          ),
        ),
      );

      // Tap the date selection button
      await tester.tap(find.text('Select Date'));
      await tester.pumpAndSettle();

      // The date picker should be shown (we can't easily test the actual picker interaction)
      // but we can verify the button exists and is tappable
      expect(find.text('Select Date'), findsOneWidget);
    });

    testWidgets('should handle time selection', (WidgetTester tester) async {
      final initialDate = DateTime(2025, 1, 15);
      DateTime? selectedDate;
      TimeOfDay? selectedTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              initialDate: initialDate,
              onChanged: (date, time) {
                selectedDate = date;
                selectedTime = time;
              },
            ),
          ),
        ),
      );

      // Tap the time selection button
      await tester.tap(find.text('Time'));
      await tester.pumpAndSettle();

      // The time picker should be shown (we can't easily test the actual picker interaction)
      // but we can verify the button exists and is tappable
      expect(find.text('Time'), findsOneWidget);
    });

    testWidgets('should render without errors in various states', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Should render without throwing errors
      expect(find.byType(DueDateInput), findsOneWidget);
    });

    testWidgets('should handle partial state (date only)', (WidgetTester tester) async {
      final initialDate = DateTime(2025, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              initialDate: initialDate,
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Should show date but default time text
      expect(find.text('Jan 15, 2025'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('should handle partial state (time only)', (WidgetTester tester) async {
      const initialTime = TimeOfDay(hour: 14, minute: 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              initialTime: initialTime,
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Should show time but default date text
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('2:30 PM'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('should handle edge case times correctly', (WidgetTester tester) async {
      const midnightTime = TimeOfDay(hour: 0, minute: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              initialTime: midnightTime,
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Should show midnight time correctly
      expect(find.text('12:00 AM'), findsOneWidget);
    });

    testWidgets('should handle noon time correctly', (WidgetTester tester) async {
      const noonTime = TimeOfDay(hour: 12, minute: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateInput(
              initialTime: noonTime,
              onChanged: (date, time) {},
            ),
          ),
        ),
      );

      // Should show noon time correctly
      expect(find.text('12:00 PM'), findsOneWidget);
    });
  });
}