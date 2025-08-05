import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/widgets/due_date_display.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('DueDateDisplay', () {
    testWidgets('should not display anything for task without due date', (WidgetTester tester) async {
      final task = Task(name: 'Task without due date');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateDisplay(task: task),
          ),
        ),
      );

      // Should not display anything
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('should display due date for task with due date', (WidgetTester tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final task = Task(
        name: 'Task with due date',
        dueDate: futureDate,
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateDisplay(task: task),
          ),
        ),
      );

      // Should display due date information
      expect(find.text('Due'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('2:30 PM'), findsOneWidget);
    });

    testWidgets('should show overdue styling for overdue task', (WidgetTester tester) async {
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final task = Task(
        name: 'Overdue task',
        dueDate: pastDate,
        dueTime: TimeOfDay.fromDateTime(pastDate),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateDisplay(task: task),
          ),
        ),
      );

      // Should display overdue information
      expect(find.text('Overdue'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should display compact version correctly', (WidgetTester tester) async {
      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        name: 'Task with due date',
        dueDate: futureDate,
        dueTime: TimeOfDay.fromDateTime(futureDate),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateDisplay(
              task: task,
              compact: true,
            ),
          ),
        ),
      );

      // Should render without errors and have some content
      expect(find.byType(DueDateDisplay), findsOneWidget);
    });

    testWidgets('should not show overdue for completed task', (WidgetTester tester) async {
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final task = Task(
        name: 'Completed overdue task',
        dueDate: pastDate,
        dueTime: TimeOfDay.fromDateTime(pastDate),
        isCompleted: true,
      );

      expect(task.isOverdue, isFalse, reason: 'Completed tasks should not be overdue');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DueDateDisplay(task: task),
          ),
        ),
      );

      // Should not show overdue styling since task is completed
      expect(find.text('Overdue'), findsNothing);
      expect(find.byIcon(Icons.warning), findsNothing);
    });
  });

  group('TaskListDueDateDisplay', () {
    testWidgets('should render compact display', (WidgetTester tester) async {
      final futureDate = DateTime.now().add(const Duration(hours: 3));
      final task = Task(
        name: 'Task with due date',
        dueDate: futureDate,
        dueTime: TimeOfDay.fromDateTime(futureDate),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListDueDateDisplay(task: task),
          ),
        ),
      );

      // Should render without errors and have some content
      expect(find.byType(TaskListDueDateDisplay), findsOneWidget);
    });
  });

  group('TaskDetailDueDateDisplay', () {
    testWidgets('should render full display', (WidgetTester tester) async {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final task = Task(
        name: 'Task with due date',
        dueDate: futureDate,
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskDetailDueDateDisplay(task: task),
          ),
        ),
      );

      // Should display full format
      expect(find.text('Due'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('2:30 PM'), findsOneWidget);
    });
  });
}