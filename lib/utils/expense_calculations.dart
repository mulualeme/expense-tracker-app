import 'package:expense_tracker/models/expense.dart';

/// Utility class for expense-related calculations
class ExpenseCalculations {
  static const _defaultMaxAmount = 100.0;

  /// Calculate the total amount spent for a specific period
  static double calculateTotalForPeriod(List<Expense> expenses, String period) {
    final now = DateTime.now();
    return expenses
        .where((expense) => _isExpenseInPeriod(expense.date, now, period))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Check if an expense date falls within the specified period
  static bool _isExpenseInPeriod(
      DateTime expenseDate, DateTime now, String period) {
    switch (period) {
      case 'Daily':
        return isSameDay(expenseDate, now);
      case 'Weekly':
        final weekStart = getStartOfWeek(now);
        final weekEnd =
            weekStart.add(const Duration(days: 6, hours: 23, minutes: 59));
        return expenseDate
                .isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
            expenseDate.isBefore(weekEnd.add(const Duration(seconds: 1)));
      case 'Monthly':
        return expenseDate.year == now.year && expenseDate.month == now.month;
      default:
        return true;
    }
  }

  /// Group expenses by category and calculate totals
  static Map<Category, double> calculateCategoryTotals(List<Expense> expenses) {
    final categoryTotals = <Category, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  /// Group expenses by period (day, week, month)
  static Map<DateTime, double> groupExpensesByPeriod(
      List<Expense> expenses, String period) {
    final result = <DateTime, double>{};
    final numberOfPeriods = period == 'Weekly' ? 4 : 7;

    // Initialize periods with zero
    for (int i = 0; i < numberOfPeriods; i++) {
      result[getDateForIndex(i, period)] = 0.0;
    }

    // Sum up expenses for each period
    for (final expense in expenses) {
      final periodStart = _getPeriodStart(expense.date, period);
      if (periodStart == null) continue;

      // Find matching period
      for (int i = 0; i < numberOfPeriods; i++) {
        final currentPeriodStart = getDateForIndex(i, period);
        final currentPeriodEnd = getPeriodEndDate(currentPeriodStart, period);

        if (_isDateInPeriod(
            periodStart, currentPeriodStart, currentPeriodEnd)) {
          result[currentPeriodStart] =
              (result[currentPeriodStart] ?? 0) + expense.amount;
          break;
        }
      }
    }

    return result;
  }

  /// Check if a date falls within a period
  static bool _isDateInPeriod(
      DateTime date, DateTime periodStart, DateTime periodEnd) {
    return date.isAtSameMomentAs(periodStart) ||
        (date.isAfter(periodStart) && date.isBefore(periodEnd));
  }

  /// Get the start of a period for a given date
  static DateTime? _getPeriodStart(DateTime date, String period) {
    switch (period) {
      case 'Daily':
        return DateTime(date.year, date.month, date.day);
      case 'Weekly':
        return getStartOfWeek(date);
      case 'Monthly':
        return DateTime(date.year, date.month, 1);
      default:
        return null;
    }
  }

  /// Get the end date for a period
  static DateTime getPeriodEndDate(DateTime start, String period) {
    switch (period) {
      case 'Daily':
        return start.add(const Duration(days: 1));
      case 'Weekly':
        return start.add(const Duration(days: 7));
      case 'Monthly':
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
        return DateTime(now.year, now.month, now.day - (6 - index));
      case 'Weekly':
        final currentWeekStart = getStartOfWeek(now);
        return currentWeekStart.subtract(Duration(days: 7 * (3 - index)));
      case 'Monthly':
        return DateTime(now.year, now.month - (6 - index), 1);
      default:
        return now;
    }
  }

  /// Get the maximum expense amount for a given period
  static double getMaxExpense(List<Expense> expenses, String period) {
    if (expenses.isEmpty) return _defaultMaxAmount;

    final groupedExpenses = groupExpensesByPeriod(expenses, period);
    if (groupedExpenses.isEmpty) return _defaultMaxAmount;

    final maxAmount = groupedExpenses.values
        .reduce((max, amount) => amount > max ? amount : max);

    return maxAmount > 0 ? maxAmount : _defaultMaxAmount;
  }

  /// Calculate total for specific date and period
  static double calculateTotalForDate(
      List<Expense> expenses, DateTime date, String period) {
    return filterExpensesForDate(expenses, date, period)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  /// Filter expenses for a specific date and period
  static List<Expense> filterExpensesForDate(
      List<Expense> expenses, DateTime date, String period) {
    return expenses
        .where((expense) => isSamePeriod(expense.date, date, period))
        .toList();
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if two dates are in the same period
  static bool isSamePeriod(DateTime date1, DateTime date2, String period) {
    switch (period) {
      case 'Daily':
        return isSameDay(date1, date2);
      case 'Weekly':
        return isSameDay(getStartOfWeek(date1), getStartOfWeek(date2));
      case 'Monthly':
        return date1.month == date2.month && date1.year == date2.year;
      default:
        return false;
    }
  }

  /// Get the start of the week for a given date
  static DateTime getStartOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - 1),
    );
  }

  /// Get daily expenses map
  static Map<DateTime, double> getDailyExpenses(List<Expense> expenses) {
    final dailyTotals = <DateTime, double>{};
    for (final expense in expenses) {
      final date =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + expense.amount;
    }
    return dailyTotals;
  }

  /// Format date based on period type
  static String formatDateForPeriod(DateTime date, String period) {
    switch (period) {
      case 'Daily':
        return '${date.month}/${date.day}/${date.year}';
      case 'Weekly':
        final firstDayOfWeek = getStartOfWeek(date);
        final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
        return '${firstDayOfWeek.month}/${firstDayOfWeek.day} - ${lastDayOfWeek.month}/${lastDayOfWeek.day}';
      case 'Monthly':
        return '${date.month}/${date.year}';
      default:
        return '';
    }
  }
}
