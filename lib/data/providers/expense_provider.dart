import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [
    Expense(
      id: 'dummy_1',
      title: 'Internet Bill',
      type: ExpenseType.internet,
      amount: 60.0,
      paidById: 'me',
      paidByName: 'Me',
      date: DateTime.now().subtract(const Duration(days: 2)),
      splitAmong: ['me', 'user1'],
      isEqualSplit: true,
    ),
    Expense(
      id: 'dummy_2',
      title: 'Groceries',
      type: ExpenseType.groceries,
      amount: 150.0,
      paidById: 'user1',
      paidByName: 'Roommate',
      date: DateTime.now().subtract(const Duration(days: 5)),
      splitAmong: ['me', 'user1'],
      isEqualSplit: true,
    ),
  ];

  List<String> _currentRoommates = ['user1'];

  void updateRoommates(List<String> roommates) {
    if (roommates.length == _currentRoommates.length &&
        roommates.every((r) => _currentRoommates.contains(r))) {
      return;
    }
    _currentRoommates = List.from(roommates);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  List<Expense> get expenses {
    final members = ['me', ..._currentRoommates];
    return _expenses
        .where((e) => _currentRoommates.isNotEmpty || e.paidById == 'me')
        .map((expense) {
      return Expense(
        id: expense.id,
        title: expense.title,
        type: expense.type,
        amount: expense.amount,
        paidById: expense.paidById,
        paidByName: expense.paidByName,
        date: expense.date,
        splitAmong: members,
        isEqualSplit: expense.isEqualSplit,
        customSplit: expense.customSplit,
      );
    }).toList();
  }

  double get totalOwed {
    double owed = 0;
    for (var expense in expenses) {
      if (expense.paidById != 'me' && expense.splitAmong.contains('me')) {
        owed += expense.shareFor('me');
      }
    }
    return owed;
  }

  double get totalLent {
    double lent = 0;
    for (var expense in expenses) {
      if (expense.paidById == 'me') {
        for (var member in expense.splitAmong) {
          if (member != 'me') {
            lent += expense.shareFor(member);
          }
        }
      }
    }
    return lent;
  }

  double get netBalance => totalLent - totalOwed;

  void addExpense(Expense expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  Map<ExpenseType, double> get expensesByCategory {
    final map = <ExpenseType, double>{};
    for (var expense in expenses) {
      map[expense.type] = (map[expense.type] ?? 0) + expense.amount;
    }
    return map;
  }
}

