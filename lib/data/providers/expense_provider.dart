import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [
    Expense(
      id: 'e1',
      title: 'August Rent',
      type: ExpenseType.rent,
      amount: 2400,
      paidById: '1',
      paidByName: 'Alex Rivera',
      date: DateTime.now().subtract(const Duration(days: 5)),
      splitAmong: ['me', '1', '3'],
      isEqualSplit: true,
    ),
    Expense(
      id: 'e2',
      title: 'Electric Bill',
      type: ExpenseType.electricity,
      amount: 120,
      paidById: 'me',
      paidByName: 'You',
      date: DateTime.now().subtract(const Duration(days: 3)),
      splitAmong: ['me', '1', '3'],
      isEqualSplit: true,
    ),
    Expense(
      id: 'e3',
      title: 'Internet',
      type: ExpenseType.internet,
      amount: 80,
      paidById: '3',
      paidByName: 'Marcus Webb',
      date: DateTime.now().subtract(const Duration(days: 10)),
      splitAmong: ['me', '1', '3'],
      isEqualSplit: true,
    ),
    Expense(
      id: 'e4',
      title: 'Groceries Run',
      type: ExpenseType.groceries,
      amount: 180,
      paidById: 'me',
      paidByName: 'You',
      date: DateTime.now().subtract(const Duration(days: 1)),
      splitAmong: ['me', '1'],
      isEqualSplit: true,
    ),
    Expense(
      id: 'e5',
      title: 'Water Bill',
      type: ExpenseType.water,
      amount: 45,
      paidById: '1',
      paidByName: 'Alex Rivera',
      date: DateTime.now().subtract(const Duration(days: 8)),
      splitAmong: ['me', '1', '3'],
      isEqualSplit: true,
    ),
  ];

  List<String> _currentRoommates = [];

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

