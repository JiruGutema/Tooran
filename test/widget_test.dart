import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/main.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(TaskManagerApp());

      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Home page should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();

      // Verify that the home page elements are present
      expect(find.text('Task Manager'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('App should have proper theme structure', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();

      // Verify theme toggle button exists
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      
      // Verify menu button exists
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('Loading state should display initially', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading your tasks...'), findsOneWidget);
    });

    testWidgets('App bar should have proper title and icon', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();

      // Verify app bar elements
      expect(find.text('Task Manager'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });
  });
}