import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/models/expense.dart';

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  return ExpenseNotifier();
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final box = Hive.box<Expense>('expenses');
    state = box.values.toList();
  }

  void addExpense(Expense expense) {
    final box = Hive.box<Expense>('expenses');
    box.put(expense.id, expense);

    state = [...state, expense];
  }

  void updateExpense(Expense updatedExpense) {
    final box = Hive.box<Expense>('expenses');
    box.put(updatedExpense.id, updatedExpense);

    state = state.map((expense) {
      if (expense.id == updatedExpense.id) {
        return updatedExpense;
      }
      return expense;
    }).toList();
  }

  void deleteExpense(String id) {
    final box = Hive.box<Expense>('expenses');
    box.delete(id);

    state = state.where((expense) => expense.id != id).toList();
  }
}
