import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart' show ledgerGroups;

/// Headline numbers for a Money list.
class MoneyTotals {
  final int owedToYouMinor;
  final int youOweMinor;
  final int people;
  final DateTime? oldestOpen;
  const MoneyTotals(this.owedToYouMinor, this.youOweMinor, this.people, this.oldestOpen);

  int get netMinor => owedToYouMinor - youOweMinor;
}

/// Sums people by the direction of their net balance (open entries only).
MoneyTotals moneyTotals(Category c) {
  var owed = 0, owe = 0, people = 0;
  DateTime? oldest;
  for (final g in ledgerGroups(c.copyWith(hideCompleted: false))) {
    final net = g.netMinor;
    if (net > 0) owed += net;
    if (net < 0) owe -= net;
    if (!g.allSettled) people++;
  }
  for (final t in c.tasks) {
    if (t.isCompleted || !t.isLedgerEntry) continue;
    if (oldest == null || t.createdAt.isBefore(oldest)) oldest = t.createdAt;
  }
  return MoneyTotals(owed, owe, people, oldest);
}

/// Money given (+) and taken (−, as a positive number) per month for the
/// last [months] months including the current one, oldest first. Payments
/// recorded on + entries count as money coming back (−).
List<(DateTime month, int plusMinor, int minusMinor)> monthlyFlows(List<Task> entries, DateTime now,
    {int months = 6}) {
  final first = DateTime(now.year, now.month - months + 1);
  final plus = <DateTime, int>{};
  final minus = <DateTime, int>{};
  DateTime key(DateTime d) => DateTime(d.year, d.month);
  for (var i = 0; i < months; i++) {
    final m = DateTime(first.year, first.month + i);
    plus[m] = 0;
    minus[m] = 0;
  }
  void add(Map<DateTime, int> map, DateTime d, int v) {
    final k = key(d);
    if (map.containsKey(k)) map[k] = map[k]! + v;
  }

  for (final t in entries) {
    final a = t.amountMinor ?? 0;
    if (a > 0) {
      add(plus, t.createdAt, a);
      for (final p in t.payments) {
        add(minus, p.paidAt, p.amountMinor);
      }
    } else if (a < 0) {
      add(minus, t.createdAt, -a);
      for (final p in t.payments) {
        add(plus, p.paidAt, p.amountMinor);
      }
    }
  }
  return [for (final m in plus.keys) (m, plus[m]!, minus[m]!)];
}
