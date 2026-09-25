import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/payment.dart';
import 'package:tooran/models/task.dart';
import 'package:tooran/utils/money_stats.dart';

void main() {
  final now = DateTime(2026, 9, 25);

  test('totals split people by the direction of their net', () {
    final c = Category(name: 'Money', kind: CategoryKind.money, tasks: [
      Task(name: 'Ephraim', person: 'Ephraim', amountMinor: 50000, createdAt: DateTime(2026, 7, 1)),
      Task(name: 'Ephraim', person: 'Ephraim', amountMinor: -20000, createdAt: DateTime(2026, 8, 1)),
      Task(name: 'Sara', person: 'Sara', amountMinor: -10000, createdAt: DateTime(2026, 9, 1)),
      Task(name: 'Done', person: 'Done', amountMinor: 999, isCompleted: true, createdAt: DateTime(2026, 1, 1)),
    ]);
    final t = moneyTotals(c);
    expect(t.owedToYouMinor, 30000);
    expect(t.youOweMinor, 10000);
    expect(t.netMinor, 20000);
    expect(t.people, 2);
    expect(t.oldestOpen, DateTime(2026, 7, 1));
  });

  test('monthly flows: + given, − taken, payments count the other way', () {
    final entries = [
      Task(name: 'a', amountMinor: 50000, createdAt: DateTime(2026, 8, 3),
          payments: [Payment(amountMinor: 20000, paidAt: DateTime(2026, 9, 2))]),
      Task(name: 'b', amountMinor: -30000, createdAt: DateTime(2026, 9, 10)),
      Task(name: 'old', amountMinor: 70000, createdAt: DateTime(2025, 1, 1)),
    ];
    final f = monthlyFlows(entries, now);
    expect(f.length, 6);
    expect(f.first.$1, DateTime(2026, 4));
    expect(f.last, (DateTime(2026, 9), 0, 50000));
    expect(f[4], (DateTime(2026, 8), 50000, 0));
  });
}
