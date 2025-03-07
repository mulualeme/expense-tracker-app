import 'package:expense_tracker/models/expense.dart';

/// Utility class for expense-related calculations
class ExpenseCalculations {
  /// Calculate the total amount spent for a specific period
  static double calculateTotalForPeriod(List<Expense> expenses, String period) {
    final now = DateTime.now();
    final filteredExpenses = expenses.where((expense) {
      final expenseDate = expense.date;

      switch (period) {
        case 'Daily':
          return expenseDate.year == now.year &&
              expenseDate.month == now.month &&
              expenseDate.day == now.day;
        case 'Weekly':
          // Get the start of the current week (Monday)
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekStartDate =
              DateTime(weekStart.year, weekStart.month, weekStart.day);
          // Get the end of the current week (Sunday)
          final weekEndDate = weekStartDate.add(
              const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

          // Check if the expense date is within the current week
          return expenseDate.isAfter(
                  weekStartDate.subtract(const Duration(seconds: 1))) &&
              expenseDate.isBefore(weekEndDate.add(const Duration(seconds: 1)));
        case 'Monthly':
          return expenseDate.year == now.year && expenseDate.month == now.month;
        default:
          return true;
      }
    });

    return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Group expenses by category and calculate totals
  static Map<Category, double> calculateCategoryTotals(List<Expense> expenses) {
    final Map<Category, double> categoryTotals = {};

    for (final expense in expenses) {
      final category = expense.category;
      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  /// Group expenses by period (day, week, month)
  static Map<DateTime, double> groupExpensesByPeriod(
      List<Expense> expenses, String period) {
    final Map<DateTime, double> result = {};

    // Initialize all dates with zero
    final numberOfPeriods = period == 'Weekly' ? 4 : 7;
    for (int i = 0; i < numberOfPeriods; i++) {
      final date = getDateForIndex(i, period);
      result[date] = 0.0;
    }

    // Sum up expenses for each period
    for (final expense in expenses) {
      DateTime key;
      switch (period) {
        case 'Daily':
          key = DateTime(
            expense.date.year,
            expense.date.month,
            expense.date.day,
          );
          break;
        case 'Weekly':
          // Calculate the start of the week for the expense date
          final weekStart =
              expense.date.subtract(Duration(days: expense.date.weekday - 1));
          key = DateTime(weekStart.year, weekStart.month, weekStart.day);
          break;
        case 'Monthly':
          key = DateTime(expense.date.year, expense.date.month, 1);
          break;
        default:
          continue;
      }

      // Find which period this expense belongs to
      for (int i = 0; i < numberOfPeriods; i++) {
        final periodStart = getDateForIndex(i, period);
        final periodEnd = getPeriodEndDate(periodStart, period);

        if (key.isAtSameMomentAs(periodStart) ||
            (key.isAfter(periodStart) && key.isBefore(periodEnd))) {
          result[periodStart] = (result[periodStart] ?? 0) + expense.amount;
          break;
        }
      }
    }

    return result;
  }

  /// Get the end date for a period
  static DateTime getPeriodEndDate(DateTime start, String period) {
    switch (period) {
      case 'Daily':
        return start.add(const Duration(days: 1));
      case 'Weekly':
        return start.add(const Duration(days: 7));
      case 'Monthly':
        // Go to first day of next month, then subtract one day
        final nextMonth = DateTime(start.year, start.month + 1, 1);
        return nextMonth.subtract(const Duration(days: 1));
      default:
        return start;
    }
  }

  /// Get the date for a specific index based on the period
  static DateTime getDateForIndex(int index, String period) {
    final now = DateTime.now();

    switch (period) {
      case 'Daily':
        return DateTime(
          now.year,
          now.month,
          now.day - (6 - index),
        );
      case 'Weekly':
        // Get the start of the current week
        final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
        // Go back 3 weeks and then forward by index weeks (for 4 weeks total)
        final date = currentWeekStart.subtract(Duration(days: 7 * (3 - index)));
        return DateTime(date.year, date.month, date.day);
      case 'Monthly':
        return DateTime(now.year, now.month - (6 - index), 1);
      default:
        return now;
    }
  }

  /// Get the maximum expense amount for a given period
  static double getMaxExpense(List<Expense> expenses, String period) {
    if (expenses.isEmpty) return 100;

    final groupedExpenses = groupExpensesByPeriod(expenses, period);
    if (groupedExpenses.isEmpty) return 100;

    final maxAmount = groupedExpenses.values
        .fold(0.0, (max, amount) => amount > max ? amount : max);

    return maxAmount > 0 ? maxAmount : 100;
  }

  static double calculateTotalForDate(
    List<Expense> expenses,
    DateTime date,
    String period,
  ) {
    final filteredExpenses = filterExpensesForDate(expenses, date, period);
    return filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  static List<Expense> filterExpensesForDate(
    List<Expense> expenses,
    DateTime date,
    String period,
  ) {
    return expenses.where((expense) {
      switch (period) {
        case 'Daily':
          return isSameDay(expense.date, date);
        case 'Weekly':
          return isSameWeek(expense.date, date);
        case 'Monthly':
          return expense.date.year == date.year &&
              expense.date.month == date.month;
        default:
          return false;
      }
    }).toList();
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isSameWeek(DateTime date1, DateTime date2) {
    // Find the first day of the week for both dates
    final firstDay1 = date1.subtract(Duration(days: date1.weekday - 1));
    final firstDay2 = date2.subtract(Duration(days: date2.weekday - 1));
    return isSameDay(firstDay1, firstDay2);
  }

  static String formatDateForPeriod(DateTime date, String period) {
    switch (period) {
      case 'Daily':
        return '${date.month}/${date.day}/${date.year}';
      case 'Weekly':
        final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
        final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
        return '${firstDayOfWeek.month}/${firstDayOfWeek.day} - ${lastDayOfWeek.month}/${lastDayOfWeek.day}';
      case 'Monthly':
        return '${date.month}/${date.year}';
      default:
        return '';
    }
  }

  static Map<DateTime, double> getDailyExpenses(List<Expense> expenses) {
    final Map<DateTime, double> dailyTotals = {};

    for (final expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0) + expense.amount;
    }

    return dailyTotals;
  }
}
