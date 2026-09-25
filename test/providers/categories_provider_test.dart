import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/payment.dart';
import 'package:tooran/models/task.dart';
import 'package:tooran/providers/categories_provider.dart';
import 'package:tooran/services/data_service.dart';
import 'package:tooran/utils/recurrence.dart';

void main() {
  late CategoriesProvider p;
  var now = DateTime(2026, 9, 25, 10);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DataService.resetForTesting(dbPath: ':memory:');
    now = DateTime(2026, 9, 25, 10);
    p = CategoriesProvider(clock: () => now);
    await p.load();
  });

  Future<CategoriesProvider> reloaded() async {
    final fresh = CategoriesProvider(clock: () => now);
    await fresh.load();
    return fresh;
  }

  group('categories', () {
    test('validates names and persists new categories', () async {
      expect(p.validateName('  '), CategoryNameError.empty);
      final c = await p.addCategory('Groceries');
      expect(c, isNotNull);
      expect(p.validateName('groceries'), CategoryNameError.duplicate);
      expect(p.validateName('groceries', exceptId: c!.id), isNull);
      expect((await reloaded()).categories.single.name, 'Groceries');
    });

    test('pinned categories sort first; reorder uses display order', () async {
      final a = (await p.addCategory('A'))!;
      await p.addCategory('B');
      final c = (await p.addCategory('C'))!;
      await p.updateCategory(c.copyWith(pinned: true));
      expect(p.categories.map((x) => x.name), ['C', 'A', 'B']);
      await p.reorderCategories(2, 1); // move B above A
      expect(p.categories.map((x) => x.name), ['C', 'B', 'A']);
      expect((await reloaded()).categories.map((x) => x.name), ['C', 'B', 'A']);
      expect(p.byId(a.id)!.sortOrder, 2);
    });

    test('delete and restore keeps ledger settings', () async {
      final c = (await p.addCategory('Take back', kind: CategoryKind.money, currency: 'USD', emoji: '💰'))!;
      final dc = await p.deleteCategory(c.id);
      expect(p.categories, isEmpty);
      expect(p.deletedCategories.single.name, 'Take back');
      await p.restoreDeletedCategory(dc!.id);
      final back = p.categories.single;
      expect(back.kind, CategoryKind.money);
      expect(back.currency, 'USD');
      expect(back.emoji, '💰');
      expect(p.deletedCategories, isEmpty);
    });

    test('money lists from earlier builds load as Money, "I owe" amounts as −', () {
      final owed = Category.fromJson({
        'name': 'Take back', 'kind': 'owedToMe',
        'tasks': [Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 500).toJson()],
      });
      final owe = Category.fromJson({
        'name': 'Give back', 'kind': 'iOwe',
        'tasks': [Task(name: 'Sara', person: 'Sara', amountMinor: 300).toJson()],
      });
      expect(owed.kind, CategoryKind.money);
      expect(owed.tasks.single.amountMinor, 500);
      expect(owe.kind, CategoryKind.money);
      expect(owe.tasks.single.amountMinor, -300);
      // Saving writes the new format, so it isn't flipped twice.
      final again = Category.fromJson(owe.toJson());
      expect(again.tasks.single.amountMinor, -300);
    });
  });

  group('tasks', () {
    late Category c;
    setUp(() async {
      c = (await p.addCategory('Home'))!;
    });

    test('delete returns index for undo and insert restores it', () async {
      final t1 = Task(name: 'one');
      final t2 = Task(name: 'two');
      await p.addTask(c.id, t1);
      await p.addTask(c.id, t2);
      final i = await p.deleteTask(c.id, t1.id);
      expect(i, 0);
      await p.insertTask(c.id, t1, i);
      expect(p.byId(c.id)!.tasks.map((t) => t.name), ['one', 'two']);
    });

    test('completing a recurring task creates the next occurrence', () async {
      final t = Task(
        name: 'Rent',
        description: '[x] transfer\n[ ] receipt',
        dueAt: DateTime(2026, 9, 1),
        recurrence: Recurrence.monthly,
      );
      await p.addTask(c.id, t);
      final before = await p.toggleTask(c.id, t.id);
      final tasks = p.byId(c.id)!.tasks;
      expect(tasks.length, 2);
      expect(tasks[0].isCompleted, isTrue);
      expect(tasks[0].recurrence, Recurrence.none);
      expect(tasks[1].isCompleted, isFalse);
      expect(tasks[1].recurrence, Recurrence.monthly);
      // Overdue since Sep 1; next one lands after "now" (Sep 25).
      expect(tasks[1].dueAt, DateTime(2026, 10, 1));
      // Checklist resets on the new occurrence.
      expect(tasks[1].description, '[ ] transfer\n[ ] receipt');

      await p.restoreTaskSnapshot(c.id, before!);
      final after = p.byId(c.id)!.tasks;
      expect(after.length, 1);
      expect(after.single.isCompleted, isFalse);
      expect(after.single.recurrence, Recurrence.monthly);
    });

    test('reorder with hidden completed tasks keeps hidden slots', () async {
      final a = Task(name: 'a');
      final done = Task(name: 'done', isCompleted: true);
      final b = Task(name: 'b');
      final cc = Task(name: 'c');
      for (final t in [a, done, b, cc]) {
        await p.addTask(c.id, t);
      }
      await p.updateCategory(p.byId(c.id)!.copyWith(hideCompleted: true));
      final visible = visibleTasks(p.byId(c.id)!).map((t) => t.id).toList();
      expect(visible, [a.id, b.id, cc.id]);
      await p.reorderVisibleTasks(c.id, visible, 2, 0); // c to top
      expect(p.byId(c.id)!.tasks.map((t) => t.name), ['c', 'done', 'a', 'b']);
    });

    test('sinkCompleted shows open tasks first without changing storage', () async {
      final a = Task(name: 'a', isCompleted: true);
      final b = Task(name: 'b');
      await p.addTask(c.id, a);
      await p.addTask(c.id, b);
      await p.updateCategory(p.byId(c.id)!.copyWith(sinkCompleted: true));
      expect(visibleTasks(p.byId(c.id)!).map((t) => t.name), ['b', 'a']);
      expect(p.byId(c.id)!.tasks.map((t) => t.name), ['a', 'b']);
    });

    test('clear completed can be undone in place', () async {
      for (final n in ['a', 'b', 'c']) {
        await p.addTask(c.id, Task(name: n, isCompleted: n == 'b'));
      }
      final removed = await p.clearCompleted(c.id);
      expect(p.byId(c.id)!.tasks.map((t) => t.name), ['a', 'c']);
      await p.restoreCleared(c.id, removed);
      expect(p.byId(c.id)!.tasks.map((t) => t.name), ['a', 'b', 'c']);
    });

    test('search matches names, descriptions and people', () async {
      await p.addTask(c.id, Task(name: 'Buy milk', description: 'from the shop'));
      await p.addTask(c.id, Task(name: 'Call mom'));
      expect(p.search('MILK').single.task.name, 'Buy milk');
      expect(p.search('shop').single.task.name, 'Buy milk');
      expect(p.search('   '), isEmpty);
    });

    test('Today lists overdue and due-today open tasks, soonest first', () async {
      await p.addTask(c.id, Task(name: 'later', dueAt: DateTime(2026, 9, 30)));
      await p.addTask(c.id, Task(name: 'today', dueAt: DateTime(2026, 9, 25, 18), dueHasTime: true));
      await p.addTask(c.id, Task(name: 'overdue', dueAt: DateTime(2026, 9, 20)));
      await p.addTask(c.id, Task(name: 'done', dueAt: DateTime(2026, 9, 20), isCompleted: true));
      expect(p.dueTodayOrOverdue().map((r) => r.task.name), ['overdue', 'today']);
    });
  });

  group('ledger', () {
    late Category owed;
    late Category owe;
    setUp(() async {
      owed = (await p.addCategory('Take back', kind: CategoryKind.money))!;
      owe = (await p.addCategory('Give back', kind: CategoryKind.money))!;
    });

    test('payments reduce the remaining amount and settle when paid', () async {
      final t = Task(name: 'Abebe', person: 'Abebe', amountMinor: 50000);
      await p.addTask(owed.id, t);
      await p.addPayment(owed.id, t.id, Payment(amountMinor: 20000));
      var now = p.taskById(owed.id, t.id)!;
      expect(now.remainingMinor, 30000);
      expect(now.isCompleted, isFalse);
      await p.addPayment(owed.id, t.id, Payment(amountMinor: 30000));
      now = p.taskById(owed.id, t.id)!;
      expect(now.isCompleted, isTrue);
      expect(now.completedAt, isNotNull);
    });

    test('toggle settles with a final payment, reopen removes it', () async {
      final t = Task(name: 'Abebe', person: 'Abebe', amountMinor: 50000, payments: [Payment(amountMinor: 10000)]);
      await p.addTask(owed.id, t);
      await p.toggleTask(owed.id, t.id);
      var now = p.taskById(owed.id, t.id)!;
      expect(now.isCompleted, isTrue);
      expect(now.payments.length, 2);
      expect(now.payments.last.amountMinor, 40000);
      await p.toggleTask(owed.id, t.id);
      now = p.taskById(owed.id, t.id)!;
      expect(now.isCompleted, isFalse);
      expect(now.remainingMinor, 40000);
    });

    test('net and people balances ignore settled entries', () async {
      await p.addTask(owed.id, Task(name: 'Abebe', person: 'Abebe', amountMinor: 50000));
      await p.addTask(owed.id, Task(name: 'Sara', person: 'Sara', amountMinor: 20000));
      await p.addTask(owe.id, Task(name: 'abebe', person: 'abebe', amountMinor: -15000));
      final settled = Task(name: 'Kebede', person: 'Kebede', amountMinor: 99900);
      await p.addTask(owed.id, settled);
      await p.toggleTask(owed.id, settled.id);

      expect(p.ledgerNet(), {'ETB': 50000 + 20000 - 15000});
      final abebe = p.people().firstWhere((x) => x.person.toLowerCase() == 'abebe');
      expect(abebe.owedToMeMinor, 50000);
      expect(abebe.iOweMinor, 15000);
      expect(abebe.netMinor, 35000);
      expect(p.knownPeople(), containsAll(['Abebe', 'Sara', 'Kebede']));
    });

    test('ledger sort orders by largest remaining, settled last', () async {
      await p.addTask(owed.id, Task(name: 'small', person: 'small', amountMinor: 100));
      await p.addTask(owed.id, Task(name: 'big', person: 'big', amountMinor: 900));
      final paid = Task(name: 'paid', person: 'paid', amountMinor: 5000);
      await p.addTask(owed.id, paid);
      await p.toggleTask(owed.id, paid.id);
      await p.updateCategory(p.byId(owed.id)!.copyWith(ledgerSort: LedgerSort.largest));
      expect(visibleTasks(p.byId(owed.id)!).map((t) => t.name), ['big', 'small', 'paid']);
    });

    test('convertToLedger splits names into person and amount', () async {
      final c = (await p.addCategory('Old list'))!;
      final t = Task(name: 'Abebe – 500');
      await p.addTask(c.id, t);
      await p.convertToLedger(c.id, CategoryKind.money, 'ETB', {
        t.id: (person: 'Abebe', amountMinor: 50000),
      });
      final converted = p.byId(c.id)!;
      expect(converted.kind, CategoryKind.money);
      expect(converted.tasks.single.person, 'Abebe');
      expect(converted.outstandingMinor, 50000);
    });
  });

  group('category types', () {
    test('shopping totals open prices and sinks bought items', () async {
      final c = (await p.addCategory('Groceries', kind: CategoryKind.shopping))!;
      await p.addTask(c.id, Task(name: 'milk', amountMinor: 4500, isCompleted: true));
      await p.addTask(c.id, Task(name: 'bread', amountMinor: 3000));
      await p.addTask(c.id, Task(name: 'salt'));
      final cat = p.byId(c.id)!;
      expect(cat.tracksMoney, isTrue);
      expect(cat.amountRequired, isFalse);
      expect(cat.openAmountMinor, 3000);
      expect(visibleTasks(cat).map((t) => t.name), ['bread', 'salt', 'milk']);
    });

    test('paying a monthly bill schedules next month', () async {
      final c = (await p.addCategory('Bills', kind: CategoryKind.bills))!;
      final t = Task(name: 'Internet', amountMinor: 150000, dueAt: DateTime(2026, 9, 30), recurrence: Recurrence.monthly);
      await p.addTask(c.id, t);
      await p.toggleTask(c.id, t.id);
      final tasks = p.byId(c.id)!.tasks;
      expect(tasks.length, 2);
      expect(tasks[1].dueAt, DateTime(2026, 10, 30));
      expect(tasks[1].amountMinor, 150000);
      expect(tasks[1].isCompleted, isFalse);
      expect(p.byId(c.id)!.openAmountMinor, 150000);
    });

    test('savings progress is saved over target', () async {
      final c = (await p.addCategory('Laptop', kind: CategoryKind.savings, targetMinor: 1000000))!;
      await p.addTask(c.id, Task(name: 'Deposit', amountMinor: 250000));
      await p.addTask(c.id, Task(name: 'Deposit', amountMinor: 250000));
      final cat = p.byId(c.id)!;
      expect(cat.savedMinor, 500000);
      expect(cat.progress, 0.5);
      expect(cat.hasCheckboxes, isFalse);
      expect((await reloaded()).byId(c.id)!.targetMinor, 1000000);
    });

    test('notes have no checkboxes; other keeps its custom type name', () async {
      final n = (await p.addCategory('Ideas', kind: CategoryKind.notes))!;
      final o = (await p.addCategory('Books', kind: CategoryKind.other, customType: 'Reading list'))!;
      expect(p.byId(n.id)!.hasCheckboxes, isFalse);
      final back = (await reloaded()).byId(o.id)!;
      expect(back.kind, CategoryKind.other);
      expect(back.customType, 'Reading list');
      expect(back.isLedger, isFalse);
    });
  });

  group('signed ledger entries', () {
    late Category owed;
    setUp(() async {
      owed = (await p.addCategory('Take back', kind: CategoryKind.money))!;
    });

    test('one person can have many entries, + and − tracked separately', () async {
      await p.addTask(owed.id, Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 50000, description: 'lunch'));
      await p.addTask(owed.id, Task(name: 'Ephraim', person: 'ephraim', amountMinor: 20000, description: 'taxi'));
      await p.addTask(owed.id, Task(name: 'Ephraim', person: 'Ephraim', amountMinor: -15000, description: 'paid me back'));
      await p.addTask(owed.id, Task(name: 'Sara', person: 'Sara', amountMinor: 10000));

      final groups = ledgerGroups(p.byId(owed.id)!);
      expect(groups.map((g) => g.person), ['Ephraim', 'Sara']);
      final e = groups.first;
      expect(e.entries.length, 3);
      expect(e.plusMinor, 70000);
      expect(e.minusMinor, 15000);
      expect(e.netMinor, 55000);
      expect(p.byId(owed.id)!.outstandingMinor, 65000);
      expect(p.ledgerNet(), {'ETB': 65000});
    });

    test('a new entry for an existing person lands after their entries', () async {
      await p.addTask(owed.id, Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 100));
      await p.addTask(owed.id, Task(name: 'Sara', person: 'Sara', amountMinor: 200));
      await p.addTask(owed.id, Task(name: 'ephraim', person: 'ephraim', amountMinor: 300));
      expect(p.byId(owed.id)!.tasks.map((t) => t.amountMinor), [100, 300, 200]);
    });

    test('settle, delete and reorder act on a whole person', () async {
      await p.addTask(owed.id, Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 100));
      await p.addTask(owed.id, Task(name: 'Sara', person: 'Sara', amountMinor: 200));
      await p.addTask(owed.id, Task(name: 'Ephraim', person: 'Ephraim', amountMinor: -50));

      final before = await p.togglePerson(owed.id, 'ephraim');
      expect(before.length, 2);
      expect(ledgerGroups(p.byId(owed.id)!).firstWhere((g) => g.key == 'ephraim').allSettled, isTrue);
      await p.restoreSnapshots(owed.id, before);
      expect(ledgerGroups(p.byId(owed.id)!).firstWhere((g) => g.key == 'ephraim').netMinor, 50);

      await p.reorderPeople(owed.id, ['ephraim', 'sara'], 1, 0);
      expect(p.byId(owed.id)!.tasks.map((t) => t.person), ['Sara', 'Ephraim', 'Ephraim']);

      final removed = await p.deletePerson(owed.id, 'ephraim');
      expect(p.byId(owed.id)!.tasks.map((t) => t.person), ['Sara']);
      await p.restoreCleared(owed.id, removed);
      expect(p.byId(owed.id)!.tasks.length, 3);
    });

    test('a negative entry settles by its size and keeps its sign', () async {
      final t = Task(name: 'Abebe', person: 'Abebe', amountMinor: -30000);
      await p.addTask(owed.id, t);
      expect(p.taskById(owed.id, t.id)!.remainingMinor, -30000);
      await p.addPayment(owed.id, t.id, Payment(amountMinor: 10000));
      expect(p.taskById(owed.id, t.id)!.remainingMinor, -20000);
      await p.toggleTask(owed.id, t.id);
      final done = p.taskById(owed.id, t.id)!;
      expect(done.isCompleted, isTrue);
      expect(done.payments.last.amountMinor, 20000);
      expect(done.remainingMinor, 0);
    });

    test('fully settled people sort after open ones and hide with hideCompleted', () async {
      final paid = Task(name: 'Aster', person: 'Aster', amountMinor: 1000);
      await p.addTask(owed.id, paid);
      await p.addTask(owed.id, Task(name: 'Bekele', person: 'Bekele', amountMinor: 2000));
      await p.toggleTask(owed.id, paid.id);
      expect(ledgerGroups(p.byId(owed.id)!).map((g) => g.person), ['Bekele', 'Aster']);
      await p.updateCategory(p.byId(owed.id)!.copyWith(hideCompleted: true));
      expect(ledgerGroups(p.byId(owed.id)!).map((g) => g.person), ['Bekele']);
    });
  });

  group('one money list', () {
    test('money preset: + means they owe you, − means you owe them', () async {
      final m = (await p.addMoneyPreset(name: 'Money', currency: 'ETB'))!;
      expect(m.kind, CategoryKind.money);
      expect(m.isLedger, isTrue);
      await p.addTask(m.id, Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 50000));
      await p.addTask(m.id, Task(name: 'Sara', person: 'Sara', amountMinor: -20000));
      expect(p.ledgerNet(), {'ETB': 30000});
      final sara = p.people().firstWhere((x) => x.person == 'Sara');
      expect(sara.netMinor, -20000);
    });

    test('merging joins people across money lists and can be undone', () async {
      final a = (await p.addCategory('Take back', kind: CategoryKind.money))!;
      final b = (await p.addCategory('Give back', kind: CategoryKind.money))!;
      await p.addTask(a.id, Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 50000));
      await p.addTask(a.id, Task(name: 'Sara', person: 'Sara', amountMinor: 10000));
      await p.addTask(b.id, Task(name: 'ephraim', person: 'ephraim', amountMinor: -20000,
          payments: [Payment(amountMinor: 5000)]));
      final netBefore = p.ledgerNet();

      final undo = await p.mergeLedgers([a.id, b.id], name: 'Money');
      expect(p.categories.map((c) => c.name), ['Money']);
      final merged = p.categories.single;
      expect(merged.tasks.map((t) => t.amountMinor), [50000, -20000, 10000]);
      expect(merged.tasks[1].payments.single.amountMinor, 5000);
      expect(p.ledgerNet(), netBefore, reason: 'merging never changes who owes what');
      expect(p.deletedCategories.single.name, 'Give back');

      await p.undoMerge(undo!);
      expect(p.categories.map((c) => c.name), ['Take back', 'Give back']);
      expect(p.byId(a.id)!.tasks.length, 2);
      expect(p.byId(b.id)!.tasks.single.amountMinor, -20000);
      expect(p.ledgerNet(), netBefore);
    });

    test('finds a person in another money list of the same currency', () async {
      final owed = (await p.addCategory('Take back', kind: CategoryKind.money))!;
      final owe = (await p.addCategory('Give back', kind: CategoryKind.money))!;
      final usd = (await p.addCategory('USD loans', kind: CategoryKind.money, currency: 'USD'))!;
      await p.addTask(owed.id, Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 100));
      await p.addTask(usd.id, Task(name: 'Sara', person: 'Sara', amountMinor: 100));
      expect(p.otherLedgerWithPerson(p.byId(owe.id)!, ' EPHRAIM ')?.id, owed.id);
      expect(p.otherLedgerWithPerson(p.byId(owed.id)!, 'Ephraim'), isNull);
      expect(p.otherLedgerWithPerson(p.byId(owe.id)!, 'Sara'), isNull, reason: 'different currency');
      expect(p.mergeCandidates(p.byId(owed.id)!).map((c) => c.name), ['Give back']);
    });
  });
}
