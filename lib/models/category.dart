import 'package:uuid/uuid.dart';
import 'task.dart';

/// What a category holds. The order here is the order shown in the type
/// picker; "other" (a to-do list with a custom type name) stays last.
/// "money" is the people ledger: + they owe you, − you owe them.
enum CategoryKind { tasks, shopping, money, spending, bills, savings, notes, other }

/// How a ledger category orders its entries. `manual` keeps drag order.
enum LedgerSort { manual, largest, oldest, dueSoonest }

CategoryKind categoryKindFromString(String? s) => switch (s) {
      // Earlier builds had one list per direction; both are Money lists now.
      'owedToMe' || 'iOwe' => CategoryKind.money,
      _ => CategoryKind.values.firstWhere((k) => k.name == s, orElse: () => CategoryKind.tasks),
    };

LedgerSort ledgerSortFromString(String? s) =>
    LedgerSort.values.firstWhere((k) => k.name == s, orElse: () => LedgerSort.manual);

const Object _unset = Object();

class Category {
  String id;
  String name;
  List<Task> tasks;
  DateTime createdAt;
  int sortOrder;

  CategoryKind kind;
  String currency;

  /// Name for [CategoryKind.other] lists, e.g. "Recipes".
  String? customType;

  /// Goal for [CategoryKind.savings], in minor units.
  int? targetMinor;

  // ── Personalisation ─────────────────────────────────────────────────
  String? emoji;
  int? colorValue;
  bool pinned;

  // ── Display ─────────────────────────────────────────────────────────
  /// Hide completed tasks (or settled ledger entries) behind a footer row.
  bool hideCompleted;

  /// Show completed tasks after open ones, without changing stored order.
  bool sinkCompleted;
  LedgerSort ledgerSort;

  Category({
    String? id,
    required this.name,
    List<Task>? tasks,
    DateTime? createdAt,
    this.sortOrder = 0,
    this.kind = CategoryKind.tasks,
    this.currency = 'ETB',
    this.customType,
    this.targetMinor,
    this.emoji,
    this.colorValue,
    this.pinned = false,
    this.hideCompleted = false,
    this.sinkCompleted = false,
    this.ledgerSort = LedgerSort.manual,
  }) : id = id ?? const Uuid().v4(),
       tasks = tasks ?? [],
       createdAt = createdAt ?? DateTime.now();

  // Computed properties
  int get completedCount => tasks.where((task) => task.isCompleted).length;

  int get totalCount => tasks.length;

  double get progressPercentage {
    if (totalCount == 0) return 0.0;
    return completedCount / totalCount;
  }

  bool get isCompleted => totalCount > 0 && completedCount == totalCount;

  /// Money others owe the user, or the user owes (person + payments).
  bool get isLedger => kind == CategoryKind.money;

  /// Entries carry an amount (optional for shopping and bills).
  bool get isSpending => kind == CategoryKind.spending;

  bool get tracksMoney =>
      isLedger ||
      isSpending ||
      kind == CategoryKind.shopping ||
      kind == CategoryKind.bills ||
      kind == CategoryKind.savings;

  /// Every entry must have an amount.
  bool get amountRequired => isLedger || isSpending || kind == CategoryKind.savings;

  /// Notes and savings deposits aren't things to tick off.
  bool get hasCheckboxes =>
      kind != CategoryKind.notes && kind != CategoryKind.savings && kind != CategoryKind.spending;

  /// Sum of amounts still open: unbought items, unpaid bills.
  int get openAmountMinor => tasks
      .where((t) => !t.isCompleted && t.amountMinor != null)
      .fold(0, (sum, t) => sum + t.amountMinor!);

  bool get hasAmounts => tasks.any((t) => t.amountMinor != null);

  /// Total deposited into a savings goal.
  int get savedMinor => tasks.fold(0, (sum, t) => sum + (t.amountMinor ?? 0));

  /// Spent in the current calendar month (spending lists).
  int monthSpentMinor([DateTime? now]) {
    final n = now ?? DateTime.now();
    return tasks
        .where((t) => t.createdAt.year == n.year && t.createdAt.month == n.month)
        .fold(0, (s, t) => s + (t.amountMinor ?? 0));
  }

  /// 0..1 progress: saved/target for savings, month spent/budget for
  /// spending, done/total otherwise.
  double get progress {
    if (isSpending) {
      final budget = targetMinor ?? 0;
      return budget <= 0 ? 0 : (monthSpentMinor() / budget).clamp(0.0, 1.0);
    }
    if (kind == CategoryKind.savings) {
      final target = targetMinor ?? 0;
      return target <= 0 ? 0 : (savedMinor / target).clamp(0.0, 1.0);
    }
    return progressPercentage;
  }

  /// Sum still owed across unsettled entries, in minor units.
  int get outstandingMinor => tasks
      .where((t) => t.isLedgerEntry && !t.isCompleted)
      .fold(0, (sum, t) => sum + t.remainingMinor);

  /// Outstanding amount signed from the user's point of view:
  /// positive when others owe the user, negative when the user owes.
  int get signedOutstandingMinor => isLedger ? outstandingMinor : 0;

  factory Category.fromJson(Map<String, dynamic> json) {
    // Old "I owe" lists stored what the user owes as positive amounts; in a
    // Money list that's negative.
    final flip = json['kind'] == 'iOwe';
    return Category(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      tasks: json['tasks'] != null
          ? (json['tasks'] as List).map((taskJson) {
              final t = Task.fromJson(Map<String, dynamic>.from(taskJson));
              return flip && t.amountMinor != null ? t.copyWith(amountMinor: -t.amountMinor!) : t;
            }).toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      sortOrder: json['sortOrder'] ?? 0,
      kind: categoryKindFromString(json['kind'] as String?),
      currency: json['currency'] as String? ?? 'ETB',
      customType: json['customType'] as String?,
      targetMinor: (json['targetMinor'] as num?)?.toInt(),
      emoji: json['emoji'] as String?,
      colorValue: (json['colorValue'] as num?)?.toInt(),
      pinned: json['pinned'] ?? false,
      hideCompleted: json['hideCompleted'] ?? false,
      sinkCompleted: json['sinkCompleted'] ?? false,
      ledgerSort: ledgerSortFromString(json['ledgerSort'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
      'kind': kind.name,
      'currency': currency,
      if (customType != null) 'customType': customType,
      if (targetMinor != null) 'targetMinor': targetMinor,
      if (emoji != null) 'emoji': emoji,
      if (colorValue != null) 'colorValue': colorValue,
      'pinned': pinned,
      'hideCompleted': hideCompleted,
      'sinkCompleted': sinkCompleted,
      'ledgerSort': ledgerSort.name,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    List<Task>? tasks,
    DateTime? createdAt,
    int? sortOrder,
    CategoryKind? kind,
    String? currency,
    Object? customType = _unset,
    Object? targetMinor = _unset,
    Object? emoji = _unset,
    Object? colorValue = _unset,
    bool? pinned,
    bool? hideCompleted,
    bool? sinkCompleted,
    LedgerSort? ledgerSort,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      tasks: tasks ?? List.from(this.tasks),
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      kind: kind ?? this.kind,
      currency: currency ?? this.currency,
      customType: identical(customType, _unset) ? this.customType : customType as String?,
      targetMinor: identical(targetMinor, _unset) ? this.targetMinor : targetMinor as int?,
      emoji: identical(emoji, _unset) ? this.emoji : emoji as String?,
      colorValue:
          identical(colorValue, _unset) ? this.colorValue : colorValue as int?,
      pinned: pinned ?? this.pinned,
      hideCompleted: hideCompleted ?? this.hideCompleted,
      sinkCompleted: sinkCompleted ?? this.sinkCompleted,
      ledgerSort: ledgerSort ?? this.ledgerSort,
    );
  }

  void addTask(Task task) {
    tasks.add(task);
  }

  void removeTask(Task task) {
    tasks.removeWhere((t) => t.id == task.id);
  }

  void updateTask(Task updatedTask) {
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
