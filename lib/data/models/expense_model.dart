import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ExpenseType { rent, electricity, water, internet, groceries, other }

class Expense {
  final String id;
  final String title;
  final ExpenseType type;
  final double amount;
  final String paidById;
  final String paidByName;
  final DateTime date;
  final List<String> splitAmong;
  final Map<String, double> customSplit;
  final bool isEqualSplit;

  Expense({
    String? id,
    required this.title,
    required this.type,
    required this.amount,
    required this.paidById,
    required this.paidByName,
    required this.date,
    required this.splitAmong,
    this.customSplit = const {},
    this.isEqualSplit = true,
  }) : id = id ?? const Uuid().v4();

  double shareFor(String userId) {
    if (isEqualSplit) {
      return amount / splitAmong.length;
    }
    return customSplit[userId] ?? 0;
  }

  IconData get icon {
    switch (type) {
      case ExpenseType.rent:
        return Icons.home_rounded;
      case ExpenseType.electricity:
        return Icons.bolt_rounded;
      case ExpenseType.water:
        return Icons.water_drop_rounded;
      case ExpenseType.internet:
        return Icons.wifi_rounded;
      case ExpenseType.groceries:
        return Icons.shopping_cart_rounded;
      case ExpenseType.other:
        return Icons.receipt_rounded;
    }
  }

  Color get color {
    switch (type) {
      case ExpenseType.rent:
        return const Color(0xFF4B39EF);
      case ExpenseType.electricity:
        return const Color(0xFFFFB347);
      case ExpenseType.water:
        return const Color(0xFF00B4D8);
      case ExpenseType.internet:
        return const Color(0xFF06D6A0);
      case ExpenseType.groceries:
        return const Color(0xFFFF6B6B);
      case ExpenseType.other:
        return const Color(0xFF9B8DFF);
    }
  }

  String get typeLabel {
    switch (type) {
      case ExpenseType.rent:
        return 'Rent';
      case ExpenseType.electricity:
        return 'Electricity';
      case ExpenseType.water:
        return 'Water';
      case ExpenseType.internet:
        return 'Internet';
      case ExpenseType.groceries:
        return 'Groceries';
      case ExpenseType.other:
        return 'Other';
    }
  }
}
