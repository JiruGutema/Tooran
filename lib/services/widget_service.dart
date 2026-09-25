import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart';
import '../utils/date_labels.dart';

/// Localized text for the home-screen widget.
class WidgetTexts {
  final String todayTitle;
  final String emptyMessage;
  final String noCategoriesMessage;
  final String Function(int left) leftCount;
  final String Function(String net) netLabel;
  final String Function(DueInfo info, Task task) dueLabel;
  final String Function(int minor, String currency) formatMoney;

  const WidgetTexts({
    required this.todayTitle,
    required this.emptyMessage,
    required this.noCategoriesMessage,
    required this.leftCount,
    required this.netLabel,
    required this.dueLabel,
    required this.formatMoney,
  });
}

/// Pushes data to the Android home-screen widget and handles taps on its
/// checkboxes (which run in a background isolate).
class WidgetService {
  WidgetService._();

  static const String androidProvider =
      'io.github.jirugutema.tooran.TooranWidgetProvider';
  static const int maxItems = 6;

  static bool get supported => !kIsWeb && Platform.isAndroid;

  static Future<void> registerCallbacks() async {
    if (!supported) return;
    await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
  }

  /// Picks what the widget shows: `'today'`, a category id, or (null) the
  /// first category.
  static Future<void> update(
    List<Category> categories, {
    required String? source,
    required WidgetTexts texts,
  }) async {
    if (!supported) return;
    try {
      final now = DateTime.now();
      String title;
      final items = <(Category, Task)>[];
      if (source == 'today') {
        title = texts.todayTitle;
        final endOfToday = startOfDay(now).add(const Duration(days: 1));
        for (final c in categories) {
          for (final t in c.tasks) {
            if (!t.isCompleted && t.dueAt != null && t.dueAt!.isBefore(endOfToday)) {
              items.add((c, t));
            }
          }
        }
        items.sort((a, b) => a.$2.dueAt!.compareTo(b.$2.dueAt!));
      } else {
        Category? c;
        for (final x in categories) {
          if (x.id == source) c = x;
        }
        c ??= categories.isEmpty ? null : categories.first;
        if (c == null) {
          await _write(texts.noCategoriesMessage, '', texts.noCategoriesMessage, const []);
          return;
        }
        title = c.emoji == null ? c.name : '${c.emoji} ${c.name}';
        for (final t in visibleTasks(c)) {
          if (!t.isCompleted) items.add((c, t));
        }
      }

      final left = items.length;
      Category? single;
      for (final x in categories) {
        if (x.id == source) single = x;
      }
      single ??= source == 'today' || categories.isEmpty ? null : categories.first;
      final parts = <String>[
        // A Spending list shows today's total instead of a count.
        if (single != null && single.isSpending)
          texts.formatMoney(
              single.tasks
                  .where((t) => isSameDay(t.createdAt, now))
                  .fold(0, (s, t) => s + (t.amountMinor ?? 0)),
              single.currency)
        else
          texts.leftCount(left),
      ];
      final net = <String, int>{};
      for (final c in categories.where((c) => c.isLedger)) {
        net[c.currency] = (net[c.currency] ?? 0) + c.signedOutstandingMinor;
      }
      if (net.isNotEmpty) {
        parts.add(texts.netLabel(net.entries
            .map((e) => texts.formatMoney(e.value, e.key))
            .join(' · ')));
      }

      final rows = [
        for (final (c, t) in items.take(maxItems))
          (
            c,
            t,
            c.isLedger && t.isLedgerEntry
                ? texts.formatMoney(t.remainingMinor, c.currency)
                : c.tracksMoney && t.amountMinor != null
                    ? texts.formatMoney(t.amountMinor!, c.currency)
                    : t.dueAt != null
                    ? texts.dueLabel(dueInfo(t.dueAt!, now), t)
                    : '',
          )
      ];
      await _write(title, parts.join(' · '), texts.emptyMessage, rows);
    } catch (e) {
      debugPrint('Widget update failed: $e');
    }
  }

  static Future<void> _write(String title, String subtitle, String empty,
      List<(Category, Task, String)> rows) async {
    await HomeWidget.saveWidgetData<String>('w_title', title);
    await HomeWidget.saveWidgetData<String>('w_subtitle', subtitle);
    await HomeWidget.saveWidgetData<String>('w_empty', empty);
    await HomeWidget.saveWidgetData<int>('w_count', rows.length);
    for (var i = 0; i < rows.length; i++) {
      final (c, t, meta) = rows[i];
      await HomeWidget.saveWidgetData<String>('w_item_${i}_text',
          c.isLedger && t.person != null ? t.person! : t.name);
      await HomeWidget.saveWidgetData<String>('w_item_${i}_id', t.id);
      await HomeWidget.saveWidgetData<String>('w_item_${i}_cat', c.id);
      await HomeWidget.saveWidgetData<bool>('w_item_${i}_done', t.isCompleted);
      await HomeWidget.saveWidgetData<String>('w_item_${i}_meta', meta);
    }
    await HomeWidget.updateWidget(qualifiedAndroidName: androidProvider);
  }
}

/// Runs in a background isolate when a widget checkbox is tapped
/// (`tooran://toggle?cat=<id>&task=<id>`). Toggles the task in the database
/// and flips the row in place; the app refreshes everything on next open.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null || uri.host != 'toggle') return;
  final catId = uri.queryParameters['cat'];
  final taskId = uri.queryParameters['task'];
  if (catId == null || taskId == null) return;
  WidgetsFlutterBinding.ensureInitialized();

  final provider = CategoriesProvider();
  await provider.load();
  await provider.toggleTask(catId, taskId);
  final t = provider.taskById(catId, taskId);

  final count = await HomeWidget.getWidgetData<int>('w_count') ?? 0;
  for (var i = 0; i < count; i++) {
    final id = await HomeWidget.getWidgetData<String>('w_item_${i}_id');
    if (id == taskId) {
      await HomeWidget.saveWidgetData<bool>('w_item_${i}_done', t?.isCompleted ?? false);
    }
  }
  await HomeWidget.updateWidget(qualifiedAndroidName: WidgetService.androidProvider);
}
