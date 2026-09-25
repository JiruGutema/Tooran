import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart';
import '../utils/money.dart';
import '../utils/text_export.dart';
import 'category_sheet.dart';
import 'common.dart';
import 'task_details_sheet.dart';
import 'task_sheet.dart';

/// Task operations shared by the home list, search, Today, People and
/// the desktop layout — each with the same feedback (haptics, undo).
class TaskActions {
  TaskActions._();

  static Future<void> toggle(BuildContext context, Category c, Task t) async {
    final provider = context.read<CategoriesProvider>();
    final l = context.l10n;
    final before = await provider.toggleTask(c.id, t.id);
    if (before == null || !context.mounted) return;
    final now = provider.taskById(c.id, t.id);
    if (c.isLedger && t.isLedgerEntry && (now?.isCompleted ?? false)) {
      showToast(context, l.ledgerSettledToast,
          onUndo: () => provider.restoreTaskSnapshot(c.id, before));
    } else if (before.isRecurring && !before.isCompleted) {
      showToast(context, l.taskCompleted,
          onUndo: () => provider.restoreTaskSnapshot(c.id, before));
    }
  }

  static Future<void> delete(BuildContext context, Category c, Task t) async {
    final provider = context.read<CategoriesProvider>();
    final l = context.l10n;
    final index = await provider.deleteTask(c.id, t.id);
    if (index < 0 || !context.mounted) return;
    showToast(context, l.taskDeleted, onUndo: () => provider.insertTask(c.id, t, index));
  }

  static Future<void> addTask(BuildContext context, Category c, {String? initialName}) {
    return openSheet(context, TaskSheet(category: c, initialName: initialName));
  }

  static Future<void> edit(BuildContext context, Category c, Task t) {
    return openSheet(context, TaskSheet(category: c, editing: t));
  }

  static Future<void> editCategory(BuildContext context, Category c) {
    return openSheet(context, CategorySheet(editing: c));
  }

  static Future<void> openDetails(BuildContext context, String categoryId, String taskId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, sc) => TaskDetailsSheet(
          categoryId: categoryId,
          taskId: taskId,
          scrollController: sc,
        ),
      ),
    );
  }

  static Future<void> share(Category c, Task t) {
    return SharePlus.instance.share(ShareParams(text: taskToShareText(t, category: c)));
  }

  static Future<void> shareCategory(Category c) {
    return SharePlus.instance.share(ShareParams(text: categoryToShareText(c), subject: c.name));
  }

  /// Opens the share sheet with a polite reminder for a ledger entry.
  static Future<void> remind(BuildContext context, Category c, Task t) {
    final l = context.l10n;
    final msg = l.ledgerRemindMessage(
      t.person ?? t.name,
      formatMoney(t.remainingMinor, c.currency),
      fmtDate(context, t.createdAt, withYear: t.createdAt.year != DateTime.now().year),
    );
    return SharePlus.instance.share(ShareParams(text: msg));
  }

  static Future<void> clearCompleted(BuildContext context, Category c) async {
    final provider = context.read<CategoriesProvider>();
    final l = context.l10n;
    final removed = await provider.clearCompleted(c.id);
    if (removed.isEmpty || !context.mounted) return;
    showToast(context, l.categoryClearedCount(removed.length),
        onUndo: () => provider.restoreCleared(c.id, removed));
  }

  static Future<void> deleteCategory(BuildContext context, Category c) async {
    final l = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l.categoryDeleteTitle,
      body: c.totalCount > 0
          ? l.categoryDeleteBodyTasks(c.name, c.totalCount)
          : l.categoryDeleteBodyEmpty(c.name),
      confirmLabel: l.commonDelete,
    );
    if (!ok || !context.mounted) return;
    final provider = context.read<CategoriesProvider>();
    final dc = await provider.deleteCategory(c.id);
    if (dc == null || !context.mounted) return;
    showToast(context, l.categoryDeleted(c.name),
        onUndo: () => provider.restoreDeletedCategory(dc.id));
  }
}
