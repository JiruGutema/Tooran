import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/category.dart';
import '../utils/money.dart';
import '../utils/spending.dart';

/// Icon, name and wording for each category type, in one place.
IconData kindIcon(CategoryKind k) => switch (k) {
      CategoryKind.tasks => Icons.check_circle_outline,
      CategoryKind.shopping => Icons.shopping_cart_outlined,
      CategoryKind.money => Icons.account_balance_wallet_outlined,
      CategoryKind.spending => Icons.payments_outlined,
      CategoryKind.bills => Icons.receipt_long_outlined,
      CategoryKind.savings => Icons.savings_outlined,
      CategoryKind.notes => Icons.sticky_note_2_outlined,
      CategoryKind.other => Icons.category_outlined,
    };

String kindName(AppLocalizations l, CategoryKind k) => switch (k) {
      CategoryKind.tasks => l.categoryTypeTasks,
      CategoryKind.shopping => l.categoryTypeShopping,
      CategoryKind.money => l.categoryTypeMoney,
      CategoryKind.spending => l.categoryTypeSpending,
      CategoryKind.bills => l.categoryTypeBills,
      CategoryKind.savings => l.categoryTypeSavings,
      CategoryKind.notes => l.categoryTypeNotes,
      CategoryKind.other => l.categoryTypeOther,
    };

String kindDescription(AppLocalizations l, CategoryKind k) => switch (k) {
      CategoryKind.tasks => l.typeTasksDesc,
      CategoryKind.shopping => l.typeShoppingDesc,
      CategoryKind.money => l.typeMoneyDesc,
      CategoryKind.spending => l.typeSpendingDesc,
      CategoryKind.bills => l.typeBillsDesc,
      CategoryKind.savings => l.typeSavingsDesc,
      CategoryKind.notes => l.typeNotesDesc,
      CategoryKind.other => l.typeOtherDesc,
    };

/// The type label shown for a category ("Other" shows its custom name).
String categoryTypeLabel(AppLocalizations l, Category c) =>
    c.kind == CategoryKind.other && (c.customType?.trim().isNotEmpty ?? false)
        ? c.customType!.trim()
        : kindName(l, c.kind);

/// One-line status under a category name. Ledgers show their own money row.
String categorySummary(AppLocalizations l, Category c) {
  final total = c.totalCount;
  final done = c.completedCount;
  switch (c.kind) {
    case CategoryKind.shopping:
      if (c.hasAmounts && total > done) {
        return l.summaryShopping(done, total, formatMoney(c.openAmountMinor, c.currency));
      }
    case CategoryKind.bills:
      if (total > 0) {
        return l.summaryBills(total - done, formatMoney(c.openAmountMinor, c.currency));
      }
    case CategoryKind.savings:
      final saved = formatMoney(c.savedMinor, c.currency);
      final target = c.targetMinor;
      return target == null || target <= 0
          ? l.summarySavingsNoTarget(saved)
          : l.summarySavings(saved, formatMoney(target, c.currency));
    case CategoryKind.notes:
      return l.summaryNotes(total);
    case CategoryKind.spending:
      final st = spendingStats(c.tasks, DateTime.now());
      final today = formatMoney(st.todayMinor, c.currency);
      final month = formatMoney(st.monthMinor, c.currency);
      final budget = c.targetMinor;
      return budget == null || budget <= 0
          ? l.summarySpending(today, month)
          : l.summarySpendingBudget(today, month, formatMoney(budget, c.currency));
    default:
      break;
  }
  return total == 0 ? l.categoryNoTasks : l.categoryProgress(done, total, total - done);
}

String addEntryLabel(AppLocalizations l, Category c) => switch (c.kind) {
      CategoryKind.money => l.categoryAddEntry,
      CategoryKind.spending => l.addExpense,
      CategoryKind.shopping => l.addItem,
      CategoryKind.bills => l.addBill,
      CategoryKind.savings => l.addDeposit,
      CategoryKind.notes => l.addNote,
      _ => l.categoryAddTask,
    };

String newEntryTitle(AppLocalizations l, Category c) => switch (c.kind) {
      CategoryKind.money => l.ledgerNewEntry,
      CategoryKind.spending => l.newExpense,
      CategoryKind.shopping => l.newItem,
      CategoryKind.bills => l.newBill,
      CategoryKind.savings => l.newDeposit,
      CategoryKind.notes => l.newNote,
      _ => l.taskNew,
    };

String spendingTagName(AppLocalizations l, String? tag) => switch (tag) {
      'food' => l.tagFood,
      'transport' => l.tagTransport,
      'home' => l.tagHome,
      'bills' => l.tagBills,
      'shopping' => l.tagShopping,
      'health' => l.tagHealth,
      'fun' => l.tagFun,
      'family' => l.tagFamily,
      'education' => l.tagEducation,
      _ => l.tagOther,
    };

String spendingTagLabel(AppLocalizations l, String? tag) =>
    '${spendingTagEmoji[tag ?? 'other'] ?? '•'} ${spendingTagName(l, tag)}';
