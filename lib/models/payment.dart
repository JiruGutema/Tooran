import 'package:uuid/uuid.dart';

/// A single repayment recorded against a ledger entry.
class Payment {
  String id;
  int amountMinor;
  DateTime paidAt;
  String note;

  Payment({
    String? id,
    required this.amountMinor,
    DateTime? paidAt,
    this.note = '',
  })  : id = id ?? const Uuid().v4(),
        paidAt = paidAt ?? DateTime.now();

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String?,
      amountMinor: (json['amountMinor'] as num?)?.toInt() ?? 0,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountMinor': amountMinor,
        'paidAt': paidAt.toIso8601String(),
        'note': note,
      };

  Payment copyWith({int? amountMinor, DateTime? paidAt, String? note}) {
    return Payment(
      id: id,
      amountMinor: amountMinor ?? this.amountMinor,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
    );
  }
}
