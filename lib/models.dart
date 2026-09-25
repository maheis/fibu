import 'package:intl/intl.dart';

class FibuAccount {
  const FibuAccount({
    required this.id,
    required this.name,
    required this.credit,
    this.onlineBanking = '',
    this.isSubAccount = false,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double credit;
  final String onlineBanking;
  final bool isSubAccount;
  final DateTime createdAt;

  FibuAccount copyWith({
    String? id,
    String? name,
    double? credit,
    String? onlineBanking,
    bool? isSubAccount,
    DateTime? createdAt,
  }) {
    return FibuAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      credit: credit ?? this.credit,
      onlineBanking: onlineBanking ?? this.onlineBanking,
      isSubAccount: isSubAccount ?? this.isSubAccount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'credit': credit,
    'onlineBanking': onlineBanking,
    'isSubAccount': isSubAccount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FibuAccount.fromJson(Map<String, dynamic> json) {
    return FibuAccount(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      onlineBanking: (json['onlineBanking'] ?? '').toString(),
      isSubAccount: json['isSubAccount'] == true,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class FibuBudget {
  const FibuBudget({
    required this.id,
    required this.name,
    required this.credit,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double credit;
  final DateTime createdAt;

  FibuBudget copyWith({
    String? id,
    String? name,
    double? credit,
    DateTime? createdAt,
  }) {
    return FibuBudget(
      id: id ?? this.id,
      name: name ?? this.name,
      credit: credit ?? this.credit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'credit': credit,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FibuBudget.fromJson(Map<String, dynamic> json) {
    return FibuBudget(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class FibuCategory {
  const FibuCategory({required this.id, required this.name, this.colorValue});

  final String id;
  final String name;
  final int? colorValue;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
  };

  factory FibuCategory.fromJson(Map<String, dynamic> json) {
    return FibuCategory(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      colorValue: (json['colorValue'] as num?)?.toInt(),
    );
  }
}

class FibuBooking {
  const FibuBooking({
    required this.id,
    required this.accountId,
    required this.date,
    required this.whereId,
    required this.whatId,
    this.comment = '',
    required this.amount,
    this.budgetId,
    this.budgetAmount = 0,
  });

  final String id;
  final String accountId;
  final String date;
  final String whereId;
  final String whatId;
  final String comment;
  final double amount;
  final String? budgetId;
  final double budgetAmount;

  bool get isIncome => amount >= 0;

  FibuBooking copyWith({
    String? id,
    String? accountId,
    String? date,
    String? whereId,
    String? whatId,
    String? comment,
    double? amount,
    String? budgetId,
    double? budgetAmount,
  }) {
    return FibuBooking(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      whereId: whereId ?? this.whereId,
      whatId: whatId ?? this.whatId,
      comment: comment ?? this.comment,
      amount: amount ?? this.amount,
      budgetId: budgetId ?? this.budgetId,
      budgetAmount: budgetAmount ?? this.budgetAmount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'accountId': accountId,
    'date': date,
    'whereId': whereId,
    'whatId': whatId,
    'comment': comment,
    'amount': amount,
    'budgetId': budgetId,
    'budgetAmount': budgetAmount,
  };

  factory FibuBooking.fromJson(Map<String, dynamic> json) {
    return FibuBooking(
      id: (json['id'] ?? '').toString(),
      accountId: (json['accountId'] ?? '').toString(),
      date: (json['date'] ?? DateTime.now().toIso8601String().substring(0, 10))
          .toString(),
      whereId: (json['whereId'] ?? '').toString(),
      whatId: (json['whatId'] ?? '').toString(),
      comment: (json['comment'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      budgetId: json['budgetId']?.toString(),
      budgetAmount: (json['budgetAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

String formatMoney(double value) {
  return NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  ).format(value);
}

String shortDate(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('dd.MM.yyyy').format(date);
  } catch (_) {
    return isoDate;
  }
}
