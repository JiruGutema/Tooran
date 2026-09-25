import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/main.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/payment.dart';
import 'package:tooran/models/task.dart';
import 'package:tooran/providers/categories_provider.dart';
import 'package:tooran/providers/settings_provider.dart';
import 'package:tooran/services/app_intents.dart';
import 'package:tooran/services/data_service.dart';
import 'package:tooran/theme/app_theme.dart';
import 'package:tooran/widgets/category_card.dart';

Future<CategoriesProvider> pumpApp(WidgetTester tester, {List<Category> seed = const []}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final settings = SettingsProvider();
  final categories = CategoriesProvider();
  await tester.runAsync(() async {
    if (seed.isNotEmpty) await DataService().saveCategories(seed);
    await settings.load();
    await categories.load();
  });
  await tester.pumpWidget(TaskManagerApp(
    intents: AppIntents(),
    settings: settings,
    categories: categories,
  ));
  await tester.pumpAndSettle();
  return categories;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'settings': '{"tipsDismissed": true}'});
    DataService.resetForTesting(dbPath: ':memory:');
  });

  testWidgets('shows the empty state and ledger preset on first launch', (tester) async {
    final provider = await pumpApp(tester);
    expect(find.text('No categories yet'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.text('Set up money tracking'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(provider.categories.map((c) => c.name), ['Money']);
    expect(provider.categories.single.kind, CategoryKind.money);
    expect(find.text('Money'), findsOneWidget);
    // The home screen no longer shows total cards.
    expect(find.text('NET'), findsNothing);
    // Let the provider's debounced side-effect timer run out.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('creates a category from the FAB sheet', (tester) async {
    final provider = await pumpApp(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Groceries');
    // Pick a type from the grid, then scroll to the button.
    await tester.tap(find.text('Shopping'));
    await tester.pump();
    await tester.ensureVisible(find.text('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(provider.categories.single.name, 'Groceries');
    expect(provider.categories.single.kind, CategoryKind.shopping);
    expect(find.text('Groceries'), findsOneWidget);
  });

  testWidgets('ticking a checklist item in task details saves it', (tester) async {
    final task = Task(name: 'Shopping', description: '[ ] milk\n[ ] bread');
    final cat = Category(name: 'Home', tasks: [task]);
    final provider = await pumpApp(tester, seed: [cat]);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('☑'), findsNothing);
    expect(find.text('0/2'), findsOneWidget);

    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('milk'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(provider.taskById(cat.id, task.id)!.description, '[x] milk\n[ ] bread');
  });

  testWidgets('swipe left deletes a task with undo', (tester) async {
    final task = Task(name: 'Swipe me');
    final cat = Category(name: 'Home', tasks: [task, Task(name: 'Stay')]);
    final provider = await pumpApp(tester, seed: [cat]);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Swipe me'), const Offset(-600, 0));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(provider.byId(cat.id)!.tasks.map((t) => t.name), ['Stay']);

    await tester.tap(find.text('UNDO'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(provider.byId(cat.id)!.tasks.map((t) => t.name), ['Swipe me', 'Stay']);
  });

  testWidgets('Amharic and Afaan Oromoo load without missing localizations', (tester) async {
    for (final code in ['am', 'om']) {
      SharedPreferences.setMockInitialValues({'settings': '{"tipsDismissed": true, "locale": "$code"}'});
      DataService.resetForTesting(dbPath: ':memory:');
      await pumpApp(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      // Open the date-picker-backed sheet to exercise Material strings.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('menu opens as a side drawer', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Color theme'), findsOneWidget);
  });

  testWidgets('every theme preset renders in light and dark', (tester) async {
    for (final preset in themePresets) {
      for (final mode in ['light', 'dark']) {
        SharedPreferences.setMockInitialValues({
          'settings': '{"tipsDismissed": true, "themePreset": "${preset.id}", "themeMode": "$mode"}',
        });
        DataService.resetForTesting(dbPath: ':memory:');
        await pumpApp(tester, seed: [
          Category(name: 'Home', tasks: [Task(name: 'a')]),
          Category(name: 'Take back', kind: CategoryKind.money, tasks: [
            Task(name: 'Abebe', person: 'Abebe', amountMinor: 50000),
          ]),
        ]);
        expect(tester.takeException(), isNull, reason: '${preset.id}/$mode');
        await tester.pumpWidget(const SizedBox());
      }
    }
  });

  testWidgets('money lists show one row per person; tapping opens their entries', (tester) async {
    final cat = Category(name: 'Take back', kind: CategoryKind.money, tasks: [
      Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 50000, description: 'lunch'),
      Task(name: 'Ephraim', person: 'Ephraim', amountMinor: -20000, description: 'paid back'),
      Task(name: 'Sara', person: 'Sara', amountMinor: 10000),
    ]);
    final provider = await pumpApp(tester, seed: [cat]);
    await tester.tap(find.text('Take back'));
    await tester.pumpAndSettle();
    expect(find.text('Ephraim'), findsOneWidget);
    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('300 ETB'), findsOneWidget); // Ephraim's net
    expect(find.text('owes you'), findsNWidgets(2));

    await tester.tap(find.text('Ephraim'));
    await tester.pumpAndSettle();
    expect(find.text('lunch'), findsOneWidget);
    expect(find.text('paid back'), findsOneWidget);
    expect(find.text('+500 ETB'), findsWidgets);
    expect(find.text('−200 ETB'), findsWidgets);

    await tester.tap(find.text('Add entry'));
    await tester.pumpAndSettle();
    // The person is known: no name field, the cursor starts at the amount.
    expect(find.text('NEW ENTRY FOR EPHRAIM'), findsOneWidget);
    expect(find.text('PERSON'), findsNothing);
    final amount = tester.widget<EditableText>(find.byType(EditableText).first);
    expect(amount.focusNode.hasFocus, isTrue);
    await tester.enterText(find.byType(EditableText).first, '75');
    await tester.enterText(find.byType(EditableText).at(1), 'coffee');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add entry').last);
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    final added = provider.byId(cat.id)!.tasks.firstWhere((t) => t.description == 'coffee');
    expect(added.person, 'Ephraim');
    expect(added.amountMinor, 7500);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('swiping right on the top bar opens the menu; swiping a task does not', (tester) async {
    await pumpApp(tester, seed: [
      Category(name: 'Home', tasks: [Task(name: 'Keep me')]),
    ]);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // A right swipe on a task is a task action, not the menu.
    await tester.drag(find.text('Keep me'), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);

    await tester.fling(find.text('tooran.', findRichText: true), const Offset(250, 0), 800);
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);

    // Swipe left on the menu closes it.
    await tester.fling(find.byType(Drawer), const Offset(-300, 0), 800);
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('adding a name that is in the other money list suggests moving it', (tester) async {
    final takeBack = Category(name: 'Take back', kind: CategoryKind.money, tasks: [
      Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 50000),
    ]);
    final giveBack = Category(name: 'Give back', kind: CategoryKind.money, sortOrder: 1);
    await pumpApp(tester, seed: [takeBack, giveBack]);
    await tester.tap(find.text('Give back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD ENTRY').hitTestable());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'ephraim');
    await tester.pumpAndSettle();
    expect(find.text('ephraim is already in “Take back”.'), findsOneWidget);
    // Every money list reads + / − the same way, so the sign carries over.
    expect(find.text('Add there as + instead'), findsOneWidget);
    await tester.tap(find.text('Add there as + instead'));
    await tester.pumpAndSettle();
    expect(find.text('NEW ENTRY FOR EPHRAIM'), findsOneWidget);
  });

  testWidgets('Enter on the name goes to the notes; it does not add the task', (tester) async {
    final cat = Category(name: 'Home');
    final provider = await pumpApp(tester, seed: [cat]);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD TASK').hitTestable());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Buy milk');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
    expect(provider.byId(cat.id)!.tasks, isEmpty);
    await tester.enterText(find.byType(TextField).at(1), 'two litres');
    await tester.pumpAndSettle();

    // "Add another" saves and keeps the sheet open for the next one.
    await tester.tap(find.text('Add another'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    final t = provider.byId(cat.id)!.tasks.single;
    expect(t.name, 'Buy milk');
    expect(t.description, 'two litres');
    expect(find.text('1 added · keep typing'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('ticking a task does not push the card or the row', (tester) async {
    final task = Task(name: 'Last one', dueAt: DateTime.now().add(const Duration(days: 2)));
    final cat = Category(name: 'Home', tasks: [task]);
    await pumpApp(tester, seed: [cat]);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    final card = find.byType(CategoryCard);
    final row = find.byType(TaskRow);
    final cardBefore = tester.getSize(card);
    final rowBefore = tester.getSize(row);

    await tester.tap(find.bySemanticsLabel('Last one'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    // Mid-animation: the finish pulse and strike-through are playing.
    for (final ms in [100, 250, 400]) {
      await tester.pump(Duration(milliseconds: ms));
      expect(tester.getSize(card), cardBefore, reason: 'card at $ms ms');
      expect(tester.getSize(row), rowBefore, reason: 'row at $ms ms');
    }
    await tester.pumpAndSettle();
    expect(tester.getSize(row), rowBefore);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('logging an expense: amount first, tag, then totals update', (tester) async {
    final cat = Category(name: 'Spending', kind: CategoryKind.spending, targetMinor: 100000);
    final provider = await pumpApp(tester, seed: [cat]);
    await tester.tap(find.text('Spending'));
    await tester.pumpAndSettle();
    expect(find.text('THIS MONTH'), findsOneWidget);

    await tester.tap(find.text('ADD EXPENSE').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('NEW EXPENSE'), findsOneWidget);
    final amount = tester.widget<EditableText>(find.byType(EditableText).first);
    expect(amount.focusNode.hasFocus, isTrue);
    await tester.enterText(find.byType(EditableText).first, '850');
    await tester.tap(find.text('🚕 Transport'));
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    final t = provider.byId(cat.id)!.tasks.single;
    expect(t.amountMinor, 85000);
    expect(t.tag, 'transport');
    expect(t.name, 'Transport');
    // 850 of a 1,000 budget crosses 80%.
    expect(find.text("You've used 85% of this month's budget"), findsOneWidget);
    expect(find.text('150 ETB left of 1,000 ETB'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('spending overview: totals, tag filter, search and calendar drill-down', (tester) async {
    final now = DateTime.now();
    DateTime day(int d) => DateTime(now.year, now.month, d, 12);
    final cat = Category(name: 'Spending', kind: CategoryKind.spending, tasks: [
      Task(name: 'Lunch', amountMinor: 20000, tag: 'food', createdAt: day(1)),
      Task(name: 'Taxi', amountMinor: 5000, tag: 'transport', createdAt: day(1)),
      Task(name: 'Groceries', amountMinor: 30000, tag: 'food', createdAt: day(2), description: 'weekly market'),
    ]);
    await pumpApp(tester, seed: [cat]);
    await tester.tap(find.byTooltip('More').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();

    expect(find.text('OVERVIEW'), findsOneWidget);
    expect(find.text('550 ETB'), findsWidgets); // month total
    expect(find.text('Spending over time'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Calendar'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Calendar'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('OVERVIEW'), -300, scrollable: find.byType(Scrollable).first);

    // Tag filter narrows the totals and the list.
    await tester.tap(find.widgetWithText(FilterChip, '🚕 Transport'));
    await tester.pumpAndSettle();
    expect(find.text('50 ETB'), findsWidgets);
    expect(find.text('Lunch'), findsNothing);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    // Search matches notes too.
    await tester.enterText(find.byType(TextField).first, 'market');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Groceries'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Taxi'), findsNothing);
    await tester.scrollUntilVisible(find.text('Clear filters'), -300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    // Tapping day 1 on the calendar lists only that day.
    await tester.scrollUntilVisible(find.bySemanticsLabel(RegExp(r'^1: ')), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^1: ')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Taxi'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Groceries'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('money overview: totals, charts and open/settled filter', (tester) async {
    final cat = Category(name: 'Money', kind: CategoryKind.money, tasks: [
      Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 50000),
      Task(name: 'Sara', person: 'Sara', amountMinor: -20000),
      Task(name: 'Kebede', person: 'Kebede', amountMinor: 1000, isCompleted: true,
          payments: [Payment(amountMinor: 1000)]),
    ]);
    await pumpApp(tester, seed: [cat]);
    await tester.tap(find.byTooltip('More').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();

    expect(find.text('OWED TO YOU'), findsOneWidget);
    expect(find.text('500 ETB'), findsWidgets);
    expect(find.text('YOU OWE'), findsOneWidget);
    expect(find.text('200 ETB'), findsWidgets);
    expect(find.text('Balance by person'), findsOneWidget);
    expect(find.text('Money flow · last 6 months'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Settled'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Kebede'), findsNothing);
    await tester.tap(find.text('Settled'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Kebede'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Kebede'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
