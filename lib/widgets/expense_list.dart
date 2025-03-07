import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/utils/expense_calculations.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/widgets/add_expense_form.dart';

class ExpenseList extends ConsumerWidget {
  const ExpenseList({super.key});

  void _showEditExpenseModal(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: AddExpenseForm(expenseToEdit: expense),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final filteredExpenses = selectedDate != null
        ? ExpenseCalculations.filterExpensesForDate(
            expenses,
            selectedDate,
            selectedPeriod,
          )
        : expenses;

    final sortedExpenses = [...filteredExpenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedExpenses.isEmpty) {
      return Center(
        child: Text(
          'No expenses yet',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 80.0,
      ),
      itemCount: sortedExpenses.length,
      itemBuilder: (context, index) {
        final expense = sortedExpenses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Dismissible(
            key: Key(expense.id),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _showEditExpenseModal(context, expense);
                return false;
              }
              return true;
            },
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blue.shade900 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit,
                color: isDarkMode ? Colors.blue.shade300 : Colors.blue,
              ),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.red.shade900 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete,
                color: isDarkMode ? Colors.red.shade300 : Colors.red,
              ),
            ),
            onDismissed: (_) {
              ref.read(expenseProvider.notifier).deleteExpense(expense.id);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF1E1E1E)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                boxShadow: isDarkMode
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().format(expense.date),
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Icons.restaurant;
      case Category.transport:
        return Icons.directions_car;
      case Category.entertainment:
        return Icons.movie;
      case Category.bills:
        return Icons.receipt;
      case Category.other:
        return Icons.more_horiz;
    }
  }
}
