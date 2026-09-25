// Renders the README screenshots from the real app with demo data.
//
//   make screenshots
//
// (= flutter test tool/screenshots --update-goldens). Output: README/screens/*.png
// at phone size (1080×2340). Needs the Noto Color Emoji font installed
// (/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf) for emoji.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:tooran/utils/recurrence.dart';
import 'package:tooran/widgets/category_card.dart';

const _emojiFont = '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(Future.value(ByteData.view(File(p).readAsBytesSync().buffer)));
  }
  await loader.load();
}

Future<void> _loadFonts() async {
  final sdk = '${Platform.environment['HOME']}/development/flutter/bin/cache/artifacts/material_fonts';
  await _loadFont('Inter', [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
  ]);
  await _loadFont('MaterialIcons', ['$sdk/MaterialIcons-Regular.otf']);
  if (File(_emojiFont).existsSync()) {
    await _loadFont('NotoColorEmoji', [_emojiFont]);
    AppTheme.fontFallback = ['NotoColorEmoji'];
  }
}

// ── Demo data (made up; relative to today) ────────────────────────────

DateTime _ago(int days, [int hour = 12]) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day - days, hour);
}

final _today = Category(
  id: 'today',
  name: 'This week',
  emoji: '📋',
  sortOrder: 0,
  tasks: [
    Task(
      name: 'Prepare the project report',
      description: '## Outline\n[x] Collect results\n[x] Draw the charts\n[ ] Write the summary\n[ ] Send to **Dr. Alemu**',
      dueAt: _ago(-1, 17),
      dueHasTime: true,
    ),
    Task(name: 'Pay the internet bill', dueAt: _ago(0), recurrence: Recurrence.monthly),
    Task(name: 'Call grandma', isCompleted: true, completedAt: _ago(0, 9)),
    Task(name: 'Book the bus to Adama', description: 'Selam bus, morning trip'),
  ],
);

final _groceries = Category(
  id: 'groceries',
  name: 'Groceries',
  emoji: '🛒',
  kind: CategoryKind.shopping,
  sortOrder: 1,
  tasks: [
    Task(name: 'Teff', amountMinor: 45000),
    Task(name: 'Coffee beans', amountMinor: 32000),
    Task(name: 'Onions', amountMinor: 6000, isCompleted: true),
  ],
);

final _money = Category(
  id: 'money',
  name: 'Money',
  emoji: '💰',
  kind: CategoryKind.money,
  sortOrder: 2,
  tasks: [
    Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 150000, description: 'Laptop repair', createdAt: _ago(20)),
    Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 30000, description: 'Lunch', createdAt: _ago(6)),
    Task(name: 'Ephraim', person: 'Ephraim', amountMinor: -50000, description: 'Paid me back', createdAt: _ago(2)),
    Task(name: 'Hana', person: 'Hana', amountMinor: -80000, description: 'Rent share', createdAt: _ago(12)),
    Task(
      name: 'Abebe',
      person: 'Abebe',
      amountMinor: 60000,
      description: 'Taxi fares',
      createdAt: _ago(30),
      payments: [Payment(amountMinor: 20000, paidAt: _ago(10))],
    ),
    Task(name: 'Sara', person: 'Sara', amountMinor: 25000, createdAt: _ago(40), isCompleted: true,
        payments: [Payment(amountMinor: 25000, paidAt: _ago(5))]),
  ],
);

List<Task> _expenses() {
  const pattern = [
    ('Breakfast', 'food', 12000), ('Taxi', 'transport', 6000), ('Groceries', 'shopping', 48000),
    ('Lunch', 'food', 25000), ('Pharmacy', 'health', 18000), ('Coffee with friends', 'fun', 15000),
    ('Minibus', 'transport', 3000), ('Books', 'education', 42000), ('Dinner', 'food', 32000),
  ];
  final out = <Task>[];
  for (var d = 0; d < 70; d++) {
    for (var k = 0; k < 1 + (d * 7) % 3; k++) {
      final (name, tag, amount) = pattern[(d * 3 + k) % pattern.length];
      out.add(Task(
        name: name,
        tag: tag,
        amountMinor: amount + (d % 5) * 1000,
        createdAt: _ago(d, 8 + k * 4),
      ));
    }
  }
  return out;
}

final _spending = Category(
  id: 'spending',
  name: 'Spending',
  kind: CategoryKind.spending,
  targetMinor: 1500000,
  sortOrder: 3,
  tasks: _expenses(),
);

final _ideas = Category(
  id: 'ideas',
  name: 'Ideas',
  emoji: '💡',
  kind: CategoryKind.notes,
  sortOrder: 4,
  tasks: [Task(name: 'App feature list', description: '- Widgets\n- Budgets')],
);

// ── Harness ──────────────────────────────────────────────────────────

Future<void> _pump(
  WidgetTester tester, {
  String preset = 'horizon',
  String mode = 'light',
  List<String> expanded = const [],
}) async {
  // Tests draw shadows as solid outlines unless told otherwise (restored in _shot).
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  // This file is a test run by `make screenshots`, just outside test/.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({
    'settings': '{"tipsDismissed": true, "themePreset": "$preset", "themeMode": "$mode",'
        ' "expanded": ${expanded.map((e) => '"$e"').toList()}}',
  });
  DataService.resetForTesting(dbPath: ':memory:');
  final settings = SettingsProvider();
  final categories = CategoriesProvider();
  await tester.runAsync(() async {
    await DataService().saveCategories([_today, _groceries, _money, _spending, _ideas]);
    await settings.load();
    await categories.load();
  });
  await tester.pumpWidget(TaskManagerApp(intents: AppIntents(), settings: settings, categories: categories));
  await tester.pumpAndSettle();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('../../README/screens/$name.png'));
  // Let debounced saves/timers finish before the test ends.
  await tester.pump(const Duration(seconds: 2));
  debugDisableShadows = true;
}

Finder _menuOf(String category) =>
    find.descendant(of: find.widgetWithText(CategoryCard, category), matching: find.byTooltip('More'));

void main() {
  setUpAll(_loadFonts);

  testWidgets('home', (t) async {
    await _pump(t, expanded: ['today']);
    await _shot(t, '01-home');
  });

  testWidgets('task details with checklist and markdown', (t) async {
    await _pump(t, expanded: ['today']);
    await t.tap(find.text('Prepare the project report'));
    await _shot(t, '02-task');
  });

  testWidgets('money list (dark)', (t) async {
    await _pump(t, mode: 'dark', expanded: ['money']);
    await t.drag(find.byType(Scrollable).first, const Offset(0, -330));
    await _shot(t, '03-money');
  });

  testWidgets('a person page (dark)', (t) async {
    await _pump(t, mode: 'dark', expanded: ['money']);
    await t.drag(find.byType(Scrollable).first, const Offset(0, -330));
    await t.pumpAndSettle();
    await t.tap(find.text('Ephraim'));
    await _shot(t, '04-person');
  });

  testWidgets('spending', (t) async {
    await _pump(t, preset: 'ocean', expanded: ['spending']);
    await t.drag(find.byType(Scrollable).first, const Offset(0, -270));
    await _shot(t, '05-spending');
  });

  testWidgets('spending overview', (t) async {
    await _pump(t, preset: 'ocean');
    await t.tap(_menuOf('Spending'));
    await t.pumpAndSettle();
    await t.tap(find.text('Overview'));
    await t.pumpAndSettle();
    await t.drag(find.byType(Scrollable).first, const Offset(0, -330));
    await _shot(t, '06-overview');
  });

  testWidgets('side menu', (t) async {
    await _pump(t, preset: 'lavender');
    await t.tap(find.byTooltip('Menu'));
    await _shot(t, '07-menu');
  });

  testWidgets('themes', (t) async {
    await _pump(t, preset: 'sunset', mode: 'dark');
    await t.tap(find.byTooltip('Menu'));
    await t.pumpAndSettle();
    await t.tap(find.text('Settings'));
    await _shot(t, '08-themes');
  });
}
