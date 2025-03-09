import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/utils/expense_calculations.dart';
import 'package:intl/intl.dart';

class ExpenseBarChart extends ConsumerWidget {
  const ExpenseBarChart({super.key});

  String _getWeekLabel(DateTime date) {
    // Get the week number (1-4)
    int weekOfMonth = ((date.day - 1) ~/ 7) + 1;
    return 'W$weekOfMonth';
  }

  String _getMonthLabel(DateTime date) {
    return DateFormat('MMM').format(date);
  }

  String _getDayLabel(DateTime date) {
    return DateFormat('E').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Get the maximum expense amount for scaling
    final maxExpense =
        ExpenseCalculations.getMaxExpense(expenses, selectedPeriod);

    // Get grouped expenses by period
    final groupedExpenses = ExpenseCalculations.groupExpensesByPeriod(
      expenses,
      selectedPeriod,
    );

    // Determine number of bars based on period
    final int numberOfBars = selectedPeriod == 'Weekly' ? 4 : 7;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(numberOfBars, (index) {
          final date =
              ExpenseCalculations.getDateForIndex(index, selectedPeriod);
          final amount = groupedExpenses[date] ?? 0.0;
          final barHeight = maxExpense > 0 ? (amount / maxExpense) * 180 : 0.0;

          // Format the label based on the period
          String label;
          switch (selectedPeriod) {
            case 'Daily':
              label = _getDayLabel(date);
              break;
            case 'Weekly':
              label = _getWeekLabel(date);
              break;
            case 'Monthly':
              label = _getMonthLabel(date);
              break;
            default:
              label = '';
          }

          // Check if this bar is selected - only use selectedDate
          final isSelected = selectedDate != null &&
              ExpenseCalculations.isSamePeriod(
                  date, selectedDate, selectedPeriod);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (isSelected) {
                  // If the bar is already selected, deselect it
                  ref.read(selectedDateProvider.notifier).state = null;
                } else {
                  // If the bar is not selected, select it
                  ref.read(selectedDateProvider.notifier).state = date;
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: barHeight.clamp(0.0, 180.0),
                    width: 30,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF9C446E)
                          : isDarkMode
                              ? const Color(0xFF2C2C2C)
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF9C446E)
                            : isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11, // Slightly smaller to fit the new format
                      color: isSelected
                          ? const Color(0xFF9C446E)
                          : isDarkMode
                              ? Colors.grey
                              : Colors.grey.shade600,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
