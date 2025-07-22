import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/main.dart';

void main() {
  group('App Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App should build and display main components', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();

      // Should show main app components
      expect(find.text('Task Manager'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });

    testWidgets('Loading state should be displayed initially', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();

      // Should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading your tasks...'), findsOneWidget);
    });

    testWidgets('Empty state should be displayed when no data', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();
      
      // Wait for loading to complete
      await tester.pump(Duration(seconds: 1));

      // Should show empty state
      expect(find.text('Welcome to Task Manager!'), findsOneWidget);
      expect(find.text('Create Your First Category'), findsOneWidget);
    });

    testWidgets('Theme toggle button should be present and functional', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();

      // Should have theme toggle button
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      
      // Tap theme toggle
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();

      // Should change to light mode icon
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('Menu should be accessible and contain navigation options', (WidgetTester tester) async {
      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();

      // Should have menu button
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      
      // Tap menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Should show menu options
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('App should handle corrupted data gracefully', (WidgetTester tester) async {
      // Set up corrupted data
      SharedPreferences.setMockInitialValues({
        'categories': 'invalid json data'
      });

      await tester.pumpWidget(TaskManagerApp());
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      // Should handle error gracefully and show empty state
      expect(find.text('Welcome to Task Manager!'), findsOneWidget);
    });
  });
}