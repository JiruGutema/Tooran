import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier, ValueNotifier;

import '../models/category.dart';
import '../models/deleted_category.dart';
import '../models/payment.dart';
import '../models/task.dart';
import '../services/data_service.dart';
import '../utils/date_labels.dart';
import '../utils/recurrence.dart';
import '../utils/rich_text.dart';

enum CategoryNameError { empty, duplicate }

/// A task together with the category it lives in (search results, Today view).
class TaskRef {
  final Category category;
  final Task task;
  const TaskRef(this.category, this.task);
}

/// Per-person balance across all ledger categories of one currency.
class PersonBalance {
  final String person;
  final String currency;
  int owedToMeMinor = 0;
  int iOweMinor = 0;
  final List<TaskRef> entries = [];
  PersonBalance(this.person, this.currency);

  int get netMinor => owedToMeMinor - iOweMinor;
}

/// Single source of truth for categories and tasks, shared by the mobile and
/// desktop layouts. Every mutation persists only the category it touched.
class CategoriesProvider extends ChangeNotifier {
  CategoriesProvider({DataService? dataService, DateTime Function()? clock})
      : _data = dataService ?? DataService(),
        _now = clock ?? DateTime.now;

  final DataService _data;
  final DateTime Function() _now;

  List<Category> _categories = [];
  List<DeletedCategory> _deleted = [];
  bool _loading = true;
  int? _dataVersion;

  /// Called (debounced) after any change — used to refresh reminders and
  /// the home-screen widget.
  void Function(List<Category> categories)? onDataChanged;
  Timer? _debounce;

  /// Set when a save fails so the UI can tell the user.
  final ValueNotifier<String?> errors = ValueNotifier(null);

  bool get isLoading => _loading;
  List<DeletedCategory> get deletedCategories => List.unmodifiable(_deleted);

  /// Categories in display order: pinned first, then by sort order.
  List<Category> get categories {
    final list = List.of(_categories)
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    return List.unmodifiable(list);
  }

  Category? byId(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Task? taskById(String categoryId, String taskId) {
    final c = byId(categoryId);
    if (c == null) return null;
    for (final t in c.tasks) {
      if (t.id == taskId) return t;
    }
    return null;
  }

  // ─── Loading ────────────────────────────────────────────────────────

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _categories = await _data.loadCategoriesWithRecovery();
    _deleted = await _data.loadDeletedCategoriesWithRecovery();
    _normalizeOrder();
    try {
      _dataVersion = await _data.externalDataVersion();
    } catch (_) {}
    _loading = false;
    notifyListeners();
    _scheduleSideEffects();
  }

  /// Reloads when another connection (the home-screen widget) changed the
  /// database while the app was in the background.
  Future<void> reloadIfChangedExternally() async {
    try {
      final v = await _data.externalDataVersion();
      if (_dataVersion != null && v != _dataVersion) await load();
      _dataVersion = v;
    } catch (_) {}
  }

  void _normalizeOrder() {
    _categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (var i = 0; i < _categories.length; i++) {
      _categories[i].sortOrder = i;
    }
  }

  // ─── Persistence helpers ────────────────────────────────────────────

  Future<void> _persist(Category c) async {
    try {
      await _data.saveCategory(c);
    } catch (_) {
      errors.value = 'save';
    }
    notifyListeners();
    _scheduleSideEffects();
  }

  Future<void> _persistOrder() async {
    try {
      await _data.saveCategoryOrder(_categories);
    } catch (_) {
      errors.value = 'save';
    }
    notifyListeners();
    _scheduleSideEffects();
  }

  void _scheduleSideEffects() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      onDataChanged?.call(categories);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    errors.dispose();
    super.dispose();
  }

  // ─── Categories ─────────────────────────────────────────────────────

  CategoryNameError? validateName(String name, {String? exceptId}) {
    final n = name.trim();
    if (n.isEmpty) return CategoryNameError.empty;
    if (_categories.any(
        (c) => c.id != exceptId && c.name.toLowerCase() == n.toLowerCase())) {
      return CategoryNameError.duplicate;
    }
    return null;
  }

  Future<Category?> addCategory(
    String name, {
    CategoryKind kind = CategoryKind.tasks,
    String currency = 'ETB',
    String? emoji,
    int? colorValue,
    String? customType,
    int? targetMinor,
  }) async {
    if (validateName(name) != null) return null;
    final c = Category(
      name: name.trim(),
      sortOrder: _categories.length,
      kind: kind,
      currency: currency,
      customType: customType,
      targetMinor: targetMinor,
      emoji: emoji,
      colorValue: colorValue,
    );
    _categories.add(c);
    await _persist(c);
    return c;
  }

  /// Creates one "Money" list (+ they owe you, − you owe them).
  Future<Category?> addMoneyPreset({required String name, required String currency}) {
    return addCategory(name, kind: CategoryKind.money, currency: currency, emoji: '💰');
  }

  /// Other ledger categories (same currency) that could merge with [c].
  List<Category> mergeCandidates(Category c) => _categories
      .where((x) => x.id != c.id && x.isLedger && x.currency == c.currency)
      .toList();

  /// Merges money lists into one; each person's entries end up together.
  /// The other lists move to History. Returns what's needed to undo.
  Future<MergeUndo?> mergeLedgers(List<String> ids, {required String name}) async {
    final cats = [for (final id in ids) byId(id)].whereType<Category>().toList();
    if (cats.length < 2) return null;
    final target = cats.first;
    final snapshot = Category.fromJson(target.toJson());

    final merged = List<Task>.of(target.tasks);
    for (final other in cats.skip(1)) {
      for (final e in other.tasks) {
        final key = personKey(e);
        final last = merged.lastIndexWhere((x) => personKey(x) == key);
        if (last == -1) {
          merged.add(e);
        } else {
          merged.insert(last + 1, e);
        }
      }
    }
    await updateCategory(target.copyWith(
      name: validateName(name, exceptId: target.id) == null ? name.trim() : target.name,
      kind: CategoryKind.money,
      tasks: merged,
    ));
    final removed = <String>[];
    for (final other in cats.skip(1)) {
      final dc = await deleteCategory(other.id);
      if (dc != null) removed.add(dc.id);
    }
    return MergeUndo(snapshot, removed);
  }

  Future<void> undoMerge(MergeUndo undo) async {
    for (final id in undo.removedIds) {
      await restoreDeletedCategory(id);
    }
    await updateCategory(undo.target);
  }

  /// Another money list where [person] already has entries, for the
  /// duplicate-person hint.
  Category? otherLedgerWithPerson(Category current, String person) {
    final key = person.trim().toLowerCase();
    if (key.isEmpty) return null;
    for (final c in categories) {
      if (c.id == current.id || !c.isLedger || c.currency != current.currency) continue;
      if (c.tasks.any((t) => personKey(t) == key)) return c;
    }
    return null;
  }

  Future<void> updateCategory(Category updated) async {
    final i = _categories.indexWhere((c) => c.id == updated.id);
    if (i == -1) return;
    _categories[i] = updated;
    await _persist(updated);
  }

  Future<DeletedCategory?> deleteCategory(String id) async {
    final c = byId(id);
    if (c == null) return null;
    final dc = DeletedCategory.fromCategory(c);
    _categories.removeWhere((x) => x.id == id);
    _deleted.add(dc);
    _normalizeOrder();
    try {
      await _data.addDeletedCategory(dc);
      await _data.deleteCategoryRow(id);
    } catch (_) {
      errors.value = 'save';
    }
    await _persistOrder();
    return dc;
  }

  Future<void> restoreDeletedCategory(String deletedId) async {
    final i = _deleted.indexWhere((d) => d.id == deletedId);
    if (i == -1) return;
    final dc = _deleted.removeAt(i);
    final restored = dc.toCategory();
    // Put it back where it was, or at the end.
    final at = restored.sortOrder.clamp(0, _categories.length);
    _categories.insert(at, restored);
    for (var k = 0; k < _categories.length; k++) {
      _categories[k].sortOrder = k;
    }
    try {
      await _data.removeDeletedCategory(deletedId);
    } catch (_) {
      errors.value = 'save';
    }
    await _persistOrder();
  }

  Future<void> permanentlyDelete(String deletedId) async {
    _deleted.removeWhere((d) => d.id == deletedId);
    await _data.removeDeletedCategory(deletedId);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _deleted.clear();
    await _data.saveDeletedCategories([]);
    notifyListeners();
  }

  /// Reorders using indices into [categories] (display order).
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final display = List.of(categories);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = display.removeAt(oldIndex);
    display.insert(newIndex, moved);
    for (var i = 0; i < display.length; i++) {
      display[i].sortOrder = i;
    }
    _categories = display;
    await _persistOrder();
  }

  /// Turns a to-do category into a ledger. [entries] maps task id to the
  /// parsed person/amount (amount may be null for entries that had none).
  Future<void> convertToLedger(
    String categoryId,
    CategoryKind kind,
    String currency,
    Map<String, ({String person, int? amountMinor})> entries,
  ) async {
    final c = byId(categoryId);
    if (c == null) return;
    final tasks = c.tasks.map((t) {
      final e = entries[t.id];
      if (e == null) return t;
      return t.copyWith(
        name: e.person,
        person: e.person,
        amountMinor: e.amountMinor ?? 0,
      );
    }).toList();
    await updateCategory(c.copyWith(kind: kind, currency: currency, tasks: tasks));
  }

  // ─── Tasks ──────────────────────────────────────────────────────────

  Future<void> addTask(String categoryId, Task task) async {
    final c = byId(categoryId);
    if (c == null) return;
    // A new entry for someone already in a ledger goes right after their
    // other entries, so each person's entries stay together.
    final person = task.person?.trim().toLowerCase();
    final last = c.isLedger && person != null && person.isNotEmpty
        ? c.tasks.lastIndexWhere((t) => (t.person ?? t.name).trim().toLowerCase() == person)
        : -1;
    if (last == -1) {
      c.tasks.add(task);
    } else {
      c.tasks.insert(last + 1, task);
    }
    await _persist(c);
  }

  Future<void> insertTask(String categoryId, Task task, int index) async {
    final c = byId(categoryId);
    if (c == null) return;
    c.tasks.insert(index.clamp(0, c.tasks.length), task);
    await _persist(c);
  }

  Future<void> updateTask(String categoryId, Task task) async {
    final c = byId(categoryId);
    if (c == null) return;
    var updated = task;
    // Ledger entries are "done" exactly when fully paid.
    if (c.isLedger && updated.isLedgerEntry) {
      final settled = updated.isSettled;
      if (settled != updated.isCompleted) {
        updated = updated.copyWith(
          isCompleted: settled,
          completedAt: settled ? _now() : null,
        );
      }
    }
    c.updateTask(updated);
    await _persist(c);
  }

  /// Removes a task and returns its index so the caller can offer undo.
  Future<int> deleteTask(String categoryId, String taskId) async {
    final c = byId(categoryId);
    if (c == null) return -1;
    final i = c.tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return -1;
    c.tasks.removeAt(i);
    await _persist(c);
    return i;
  }

  /// Completes/reopens a task. Completing a recurring task schedules the
  /// next occurrence; completing a ledger entry records a final payment.
  /// Returns the task as it was before, for undo.
  Future<Task?> toggleTask(String categoryId, String taskId) async {
    final c = byId(categoryId);
    if (c == null) return null;
    final i = c.tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return null;
    final before = c.tasks[i];
    final now = _now();

    if (c.isLedger && before.isLedgerEntry) {
      c.tasks[i] = _toggledEntry(before, now);
      await _persist(c);
      return before;
    }

    final completing = !before.isCompleted;
    c.tasks[i] = before.copyWith(
      isCompleted: completing,
      completedAt: completing ? now : null,
    );
    if (completing && before.isRecurring) {
      final base = before.dueAt ?? now;
      final next = nextOccurrenceAfterNow(base, before.recurrence, now,
          anchorDay: base.day);
      c.tasks.insert(
        i + 1,
        Task(
          name: before.name,
          description: _resetChecklist(before.description),
          dueAt: next,
          dueHasTime: before.dueHasTime,
          recurrence: before.recurrence,
          // Bills keep their amount month to month.
          amountMinor: before.amountMinor,
        ),
      );
      // The completed copy no longer repeats; the new one carries it on.
      c.tasks[i] = c.tasks[i].copyWith(recurrence: Recurrence.none);
    }
    await _persist(c);
    return before;
  }

  /// Settles a money entry with a final payment, or reopens it by dropping
  /// the last payment so something is owed again.
  static Task _toggledEntry(Task before, DateTime now) {
    if (!before.isCompleted) {
      final rest = before.remainingMinor.abs();
      return before.copyWith(
        isCompleted: true,
        completedAt: now,
        payments: [
          ...before.payments,
          if (rest > 0) Payment(amountMinor: rest, paidAt: now),
        ],
      );
    }
    final payments = List.of(before.payments);
    if (payments.isNotEmpty) payments.removeLast();
    return before.copyWith(isCompleted: false, completedAt: null, payments: payments);
  }

  /// Puts back a task snapshot (undo for toggle). Removes a recurrence copy
  /// that the toggle created.
  Future<void> restoreTaskSnapshot(String categoryId, Task snapshot) async {
    final c = byId(categoryId);
    if (c == null) return;
    final i = c.tasks.indexWhere((t) => t.id == snapshot.id);
    if (i == -1) return;
    if (snapshot.isRecurring &&
        !snapshot.isCompleted &&
        i + 1 < c.tasks.length &&
        c.tasks[i + 1].recurrence == snapshot.recurrence &&
        c.tasks[i + 1].name == snapshot.name &&
        !c.tasks[i + 1].isCompleted) {
      c.tasks.removeAt(i + 1);
    }
    c.tasks[i] = snapshot;
    await _persist(c);
  }

  static String _resetChecklist(String text) {
    final lines = parseRich(text);
    var out = text;
    for (final l in lines) {
      if (l.type == RichLineType.check && l.checked) {
        out = toggleCheckAt(out, l.sourceIndex);
      }
    }
    return out;
  }

  /// Reorders using indices into [visibleIds] (what the list shows, which
  /// may hide or re-sort some tasks). Hidden tasks keep their slots.
  Future<void> reorderVisibleTasks(
      String categoryId, List<String> visibleIds, int oldIndex, int newIndex) async {
    final c = byId(categoryId);
    if (c == null) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final ids = List.of(visibleIds);
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);
    final byTaskId = {for (final t in c.tasks) t.id: t};
    final visibleSet = visibleIds.toSet();
    final slots = <int>[
      for (var k = 0; k < c.tasks.length; k++)
        if (visibleSet.contains(c.tasks[k].id)) k
    ];
    final result = List.of(c.tasks);
    for (var k = 0; k < slots.length && k < ids.length; k++) {
      result[slots[k]] = byTaskId[ids[k]]!;
    }
    c.tasks = result;
    await _persist(c);
  }

  /// Removes completed tasks; returns them with their indices for undo.
  Future<List<(int, Task)>> clearCompleted(String categoryId) async {
    final c = byId(categoryId);
    if (c == null) return [];
    final removed = <(int, Task)>[
      for (var k = 0; k < c.tasks.length; k++)
        if (c.tasks[k].isCompleted) (k, c.tasks[k])
    ];
    c.tasks.removeWhere((t) => t.isCompleted);
    await _persist(c);
    return removed;
  }

  Future<void> restoreCleared(String categoryId, List<(int, Task)> removed) async {
    final c = byId(categoryId);
    if (c == null) return;
    for (final (i, t) in removed) {
      c.tasks.insert(i.clamp(0, c.tasks.length), t);
    }
    await _persist(c);
  }

  // ─── Ledger people ──────────────────────────────────────────────────

  static String personKey(Task t) => (t.person ?? t.name).trim().toLowerCase();

  /// Settles every open entry for a person (or reopens them all when all
  /// are settled). Returns the entries as they were, for undo.
  Future<List<Task>> togglePerson(String categoryId, String key) async {
    final c = byId(categoryId);
    if (c == null) return [];
    final allSettled = c.tasks.where((t) => personKey(t) == key).every((t) => t.isCompleted);
    final now = _now();
    final before = <Task>[];
    // Change every entry first, then save and redraw once.
    for (var i = 0; i < c.tasks.length; i++) {
      final t = c.tasks[i];
      if (personKey(t) != key || !(allSettled || !t.isCompleted)) continue;
      before.add(t);
      c.tasks[i] = _toggledEntry(t, now);
    }
    if (before.isNotEmpty) await _persist(c);
    return before;
  }

  /// Puts back entry snapshots (undo for [togglePerson]).
  Future<void> restoreSnapshots(String categoryId, List<Task> snapshots) async {
    final c = byId(categoryId);
    if (c == null) return;
    for (final snap in snapshots) {
      c.updateTask(snap);
    }
    await _persist(c);
  }

  /// Removes all of a person's entries; returns them with indices for undo.
  Future<List<(int, Task)>> deletePerson(String categoryId, String key) async {
    final c = byId(categoryId);
    if (c == null) return [];
    final removed = <(int, Task)>[
      for (var k = 0; k < c.tasks.length; k++)
        if (personKey(c.tasks[k]) == key) (k, c.tasks[k])
    ];
    c.tasks.removeWhere((t) => personKey(t) == key);
    await _persist(c);
    return removed;
  }

  /// Reorders people (indices into [keys], the order shown). Each person's
  /// entries move together; people not shown keep their place at the end.
  Future<void> reorderPeople(String categoryId, List<String> keys, int oldIndex, int newIndex) async {
    final c = byId(categoryId);
    if (c == null) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final order = List.of(keys);
    order.insert(newIndex, order.removeAt(oldIndex));
    final byKey = <String, List<Task>>{};
    for (final t in c.tasks) {
      byKey.putIfAbsent(personKey(t), () => []).add(t);
    }
    c.tasks = [
      for (final k in order) ...?byKey.remove(k),
      for (final rest in byKey.values) ...rest,
    ];
    await _persist(c);
  }

  // ─── Ledger payments ────────────────────────────────────────────────

  Future<void> addPayment(String categoryId, String taskId, Payment payment) async {
    final t = taskById(categoryId, taskId);
    if (t == null) return;
    await updateTask(categoryId, t.copyWith(payments: [...t.payments, payment]));
  }

  Future<void> removePayment(String categoryId, String taskId, String paymentId) async {
    final t = taskById(categoryId, taskId);
    if (t == null) return;
    await updateTask(
        categoryId,
        t.copyWith(
            payments: t.payments.where((p) => p.id != paymentId).toList()));
  }

  // ─── Queries ────────────────────────────────────────────────────────

  /// Case-insensitive search over task names, descriptions and people.
  List<TaskRef> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return [
      for (final c in categories)
        for (final t in c.tasks)
          if (t.name.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q) ||
              (t.person?.toLowerCase().contains(q) ?? false) ||
              c.name.toLowerCase().contains(q))
            TaskRef(c, t)
    ];
  }

  /// Open tasks due today or earlier, soonest first.
  List<TaskRef> dueTodayOrOverdue() {
    final now = _now();
    final endOfToday = startOfDay(now).add(const Duration(days: 1));
    final list = [
      for (final c in categories)
        for (final t in c.tasks)
          if (!t.isCompleted && t.dueAt != null && t.dueAt!.isBefore(endOfToday))
            TaskRef(c, t)
    ]..sort((a, b) => a.task.dueAt!.compareTo(b.task.dueAt!));
    return list;
  }

  /// Net outstanding per currency: positive means others owe the user.
  Map<String, int> ledgerNet() {
    final net = <String, int>{};
    for (final c in _categories.where((c) => c.isLedger)) {
      net[c.currency] = (net[c.currency] ?? 0) + c.signedOutstandingMinor;
    }
    return net;
  }

  bool get hasLedgers => _categories.any((c) => c.isLedger);

  /// Balances per person (and currency) over unsettled entries.
  List<PersonBalance> people() {
    final map = <String, PersonBalance>{};
    for (final c in _categories.where((c) => c.isLedger)) {
      for (final t in c.tasks) {
        if (!t.isLedgerEntry) continue;
        final name = (t.person ?? t.name).trim();
        if (name.isEmpty) continue;
        final key = '${name.toLowerCase()}|${c.currency}';
        final pb = map.putIfAbsent(key, () => PersonBalance(name, c.currency));
        pb.entries.add(TaskRef(c, t));
        if (t.isCompleted) continue;
        final r = t.remainingMinor;
        if (r > 0) {
          pb.owedToMeMinor += r;
        } else {
          pb.iOweMinor -= r;
        }
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => b.netMinor.abs().compareTo(a.netMinor.abs()));
    return list;
  }

  /// Distinct person names used in ledger entries, for autocomplete.
  List<String> knownPeople() {
    final seen = <String, String>{};
    for (final c in _categories.where((c) => c.isLedger)) {
      for (final t in c.tasks) {
        final n = t.person?.trim();
        if (n != null && n.isNotEmpty) seen.putIfAbsent(n.toLowerCase(), () => n);
      }
    }
    return seen.values.toList()..sort();
  }

  // ─── Backup ─────────────────────────────────────────────────────────

  Future<void> importBackup(BackupContents backup, {required bool replace}) async {
    await _data.importBackup(backup, replace: replace);
    await load();
  }
}

/// The order a category's tasks are shown in, and whether some are hidden.
List<Task> visibleTasks(Category c) {
  var list = List.of(c.tasks);
  if (c.isSpending) {
    // Expenses: newest first.
    return list..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  if (c.tracksMoney) {
    int amount(Task t) => (c.isLedger ? t.remainingMinor : (t.amountMinor ?? 0)).abs();
    switch (c.ledgerSort) {
      case LedgerSort.manual:
        break;
      case LedgerSort.largest:
        list.sort((a, b) => amount(b).compareTo(amount(a)));
      case LedgerSort.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case LedgerSort.dueSoonest:
        list.sort((a, b) {
          if (a.dueAt == null && b.dueAt == null) return 0;
          if (a.dueAt == null) return 1;
          if (b.dueAt == null) return -1;
          return a.dueAt!.compareTo(b.dueAt!);
        });
    }
  }
  if (c.hideCompleted) {
    list = list.where((t) => !t.isCompleted).toList();
  } else if (c.sinkCompleted ||
      c.isLedger ||
      c.kind == CategoryKind.shopping ||
      c.kind == CategoryKind.bills) {
    // Settled entries, bought items and paid bills go last.
    final open = list.where((t) => !t.isCompleted);
    final done = list.where((t) => t.isCompleted);
    list = [...open, ...done];
  }
  return list;
}

/// State needed to undo [CategoriesProvider.mergeLedgers].
class MergeUndo {
  final Category target;
  final List<String> removedIds;
  const MergeUndo(this.target, this.removedIds);
}

/// All ledger entries for one person inside a category.
class PersonGroup {
  String get key => person.toLowerCase();
  final String person;
  final List<Task> entries;
  PersonGroup(this.person, this.entries);

  /// Open amount of positive entries.
  int get plusMinor => entries
      .where((t) => !t.isCompleted && t.remainingMinor > 0)
      .fold(0, (s, t) => s + t.remainingMinor);

  /// Open amount of negative entries, as a positive number.
  int get minusMinor => entries
      .where((t) => !t.isCompleted && t.remainingMinor < 0)
      .fold(0, (s, t) => s - t.remainingMinor);

  int get netMinor => plusMinor - minusMinor;
  bool get allSettled => entries.every((t) => t.isCompleted);
  DateTime get earliest =>
      entries.map((t) => t.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
  DateTime? get nextDue {
    final dues = entries.where((t) => !t.isCompleted && t.dueAt != null).map((t) => t.dueAt!);
    return dues.isEmpty ? null : dues.reduce((a, b) => a.isBefore(b) ? a : b);
  }
}

/// Groups a ledger category's entries by person (case-insensitive), newest
/// entry first inside each group. Groups follow the category's sort mode;
/// fully settled people go last (or are hidden with "Hide completed").
List<PersonGroup> ledgerGroups(Category c) {
  final byKey = <String, PersonGroup>{};
  for (final t in c.tasks) {
    if (c.hideCompleted && t.isCompleted) continue;
    final name = (t.person ?? t.name).trim();
    final key = name.toLowerCase();
    byKey.putIfAbsent(key, () => PersonGroup(name, [])).entries.add(t);
  }
  final groups = byKey.values.toList();
  for (final g in groups) {
    g.entries.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
  }
  switch (c.ledgerSort) {
    case LedgerSort.manual:
      break; // order of first appearance
    case LedgerSort.largest:
      groups.sort((a, b) => b.netMinor.abs().compareTo(a.netMinor.abs()));
    case LedgerSort.oldest:
      groups.sort((a, b) => a.earliest.compareTo(b.earliest));
    case LedgerSort.dueSoonest:
      groups.sort((a, b) {
        final x = a.nextDue, y = b.nextDue;
        if (x == null && y == null) return 0;
        if (x == null) return 1;
        if (y == null) return -1;
        return x.compareTo(y);
      });
  }
  final open = groups.where((g) => !g.allSettled);
  final settled = groups.where((g) => g.allSettled);
  return [...open, ...settled];
}
