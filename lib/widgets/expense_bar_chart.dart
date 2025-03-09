import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/utils/expense_calculations.dart';
import 'package:intl/intl.dart';

class ExpenseBarChart extends ConsumerWidget {
  const ExpenseBarChart({super.key});

  // Constants
  static const double _maxBarHeight = 180.0;
  static const double _barWidth = 30.0;
  static const double _labelFontSize = 11.0;
  static const Color _selectedColor = Color(0xFF9C446E);

  // Helper methods for labels
  String _getWeekLabel(DateTime date) => 'W${((date.day - 1) ~/ 7) + 1}';
  String _getMonthLabel(DateTime date) => DateFormat('MMM').format(date);
  String _getDayLabel(DateTime date) => DateFormat('E').format(date);

  String _getPeriodLabel(DateTime date, String selectedPeriod) {
    switch (selectedPeriod) {
      case 'Daily':
        return _getDayLabel(date);
      case 'Weekly':
        return _getWeekLabel(date);
      case 'Monthly':
        return _getMonthLabel(date);
      default:
        return '';
    }
  }

  // Bar decoration builder
  BoxDecoration _buildBarDecoration({
    required bool isSelected,
    required bool isDarkMode,
  }) {
    final backgroundColor = isSelected
        ? _selectedColor
        : isDarkMode
            ? const Color(0xFF2C2C2C)
            : Colors.grey.shade200;

    final borderColor = isSelected
        ? _selectedColor
        : isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade300;

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: borderColor,
        width: 1,
      ),
    );
  }

  // Text style builder
  TextStyle _buildLabelStyle({
    required bool isSelected,
    required bool isDarkMode,
  }) {
    return TextStyle(
      fontSize: _labelFontSize,
      color: isSelected
          ? _selectedColor
          : isDarkMode
              ? Colors.grey
              : Colors.grey.shade600,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );
  }

  // Bar builder
  Widget _buildBar({
    required DateTime date,
    required double barHeight,
    required bool isSelected,
    required bool isDarkMode,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: barHeight.clamp(0.0, _maxBarHeight),
              width: _barWidth,
              decoration: _buildBarDecoration(
                isSelected: isSelected,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: _buildLabelStyle(
                isSelected: isSelected,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final maxExpense =
        ExpenseCalculations.getMaxExpense(expenses, selectedPeriod);
    final groupedExpenses = ExpenseCalculations.groupExpensesByPeriod(
      expenses,
      selectedPeriod,
    );
    final numberOfBars = selectedPeriod == 'Weekly' ? 4 : 7;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(numberOfBars, (index) {
          final date =
              ExpenseCalculations.getDateForIndex(index, selectedPeriod);
          final amount = groupedExpenses[date] ?? 0.0;
          final barHeight =
              maxExpense > 0 ? (amount / maxExpense) * _maxBarHeight : 0.0;
          final label = _getPeriodLabel(date, selectedPeriod);
          final isSelected = selectedDate != null &&
              ExpenseCalculations.isSamePeriod(
                  date, selectedDate, selectedPeriod);

          return _buildBar(
            date: date,
            barHeight: barHeight,
            isSelected: isSelected,
            isDarkMode: isDarkMode,
            label: label,
            onTap: () {
              if (isSelected) {
                ref.read(selectedDateProvider.notifier).state = null;
              } else {
                ref.read(selectedDateProvider.notifier).state = date;
              }
            },
          );
        }),
      ),
    );
  }
}
