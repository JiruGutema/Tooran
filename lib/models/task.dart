import 'package:uuid/uuid.dart';

import '../utils/recurrence.dart';
import 'payment.dart';

/// Sentinel so `copyWith` can tell "not passed" apart from an explicit null.
const Object _unset = Object();

class Task {
  String id;
  String name;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;

  // ── Scheduling ──────────────────────────────────────────────────────
  DateTime? dueAt;

  /// False means the task is due "some time that day" (all-day).
  bool dueHasTime;
  Recurrence recurrence;

  // ── Ledger (only used inside ledger categories) ─────────────────────
  String? person;
  int? amountMinor;
  List<Payment> payments;

  /// Spending lists: what kind of expense this was (see utils/spending.dart).
  String? tag;

  Task({
    String? id,
    required this.name,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.dueAt,
    this.dueHasTime = false,
    this.recurrence = Recurrence.none,
    this.person,
    this.amountMinor,
    List<Payment>? payments,
    this.tag,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        payments = payments ?? [];

  // ── Ledger math ─────────────────────────────────────────────────────
  bool get isLedgerEntry => amountMinor != null;
  int get paidMinor => payments.fold(0, (sum, p) => sum + p.amountMinor);
  /// Ledger entries are signed: positive adds to what is owed, negative
  /// takes away from it. Payments settle the entry's size either way, and
  /// the result keeps the entry's sign.
  bool get isNegative => (amountMinor ?? 0) < 0;

  int get remainingMinor {
    final a = amountMinor ?? 0;
    final left = a.abs() - paidMinor;
    final r = left < 0 ? 0 : left;
    return a < 0 ? -r : r;
  }

  bool get isSettled => isLedgerEntry && remainingMinor == 0;

  bool get isRecurring => recurrence != Recurrence.none;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      dueAt: json['dueAt'] != null ? DateTime.parse(json['dueAt']) : null,
      dueHasTime: json['dueHasTime'] ?? false,
      recurrence: recurrenceFromString(json['recurrence'] as String?),
      person: json['person'] as String?,
      amountMinor: (json['amountMinor'] as num?)?.toInt(),
      payments: json['payments'] != null
          ? (json['payments'] as List)
              .map((p) => Payment.fromJson(Map<String, dynamic>.from(p)))
              .toList()
          : [],
      tag: json['tag'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      if (dueAt != null) 'dueAt': dueAt!.toIso8601String(),
      if (dueAt != null) 'dueHasTime': dueHasTime,
      if (recurrence != Recurrence.none)
        'recurrence': recurrenceToString(recurrence),
      if (person != null) 'person': person,
      if (amountMinor != null) 'amountMinor': amountMinor,
      if (payments.isNotEmpty)
        'payments': payments.map((p) => p.toJson()).toList(),
      if (tag != null) 'tag': tag,
    };
  }

  /// Nullable fields (`completedAt`, `dueAt`, `person`, `amountMinor`) are
  /// cleared when passed an explicit `null`, and kept when omitted.
  Task copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    Object? completedAt = _unset,
    Object? dueAt = _unset,
    bool? dueHasTime,
    Recurrence? recurrence,
    Object? person = _unset,
    Object? amountMinor = _unset,
    List<Payment>? payments,
    Object? tag = _unset,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: identical(completedAt, _unset)
          ? this.completedAt
          : completedAt as DateTime?,
      dueAt: identical(dueAt, _unset) ? this.dueAt : dueAt as DateTime?,
      dueHasTime: dueHasTime ?? this.dueHasTime,
      recurrence: recurrence ?? this.recurrence,
      person: identical(person, _unset) ? this.person : person as String?,
      amountMinor: identical(amountMinor, _unset)
          ? this.amountMinor
          : amountMinor as int?,
      payments: payments ?? List.of(this.payments),
      tag: identical(tag, _unset) ? this.tag : tag as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
