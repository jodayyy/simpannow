import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double balance;
  final String description;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.description,
    required this.createdAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Account copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    double? balance,
    String? description,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Account type constants
  static const String typeSpending = 'Spending';
  static const String typeSavings = 'Savings';
  static const String typeInvestment = 'Investment';
  static const String typeCash = 'Cash';
  static const String typeEWallet = 'E-Wallet';

  static const List<String> accountTypes = [
    typeSpending,
    typeSavings,
    typeInvestment,
    typeCash,
    typeEWallet,
  ];

  // Account type icons
  static const Map<String, String> typeIcons = {
    typeSpending: '💳',
    typeSavings: '🏦',
    typeInvestment: '📈',
    typeCash: '💵',
    typeEWallet: '📱',
  };

  static String getTypeIcon(String type) {
    return typeIcons[type] ?? '💰';
  }
}
