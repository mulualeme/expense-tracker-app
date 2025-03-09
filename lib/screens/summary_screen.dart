import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/utils/expense_calculations.dart';
import 'package:intl/intl.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  String _selectedReport = 'Weekly'; // Default to weekly report

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate totals
    final dailyTotal =
        ExpenseCalculations.calculateTotalForPeriod(expenses, 'Daily');
    final weeklyTotal =
        ExpenseCalculations.calculateTotalForPeriod(expenses, 'Weekly');
    final monthlyTotal =
        ExpenseCalculations.calculateTotalForPeriod(expenses, 'Monthly');

    // Calculate category totals
    final categoryTotals =
        ExpenseCalculations.calculateCategoryTotals(expenses);
    final totalExpenses =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    // Find highest spending category
    Category highestCategory = Category.food; // Default value
    double highestAmount = 0;
    categoryTotals.forEach((category, amount) {
      if (amount > highestAmount) {
        highestAmount = amount;
        highestCategory = category;
      }
    });

    // Find highest spending day
    final dailyExpenses = ExpenseCalculations.getDailyExpenses(expenses);
    DateTime highestSpendingDay = DateTime.now(); // Default value
    double highestDailyAmount = 0;
    dailyExpenses.forEach((date, amount) {
      if (amount > highestDailyAmount) {
        highestDailyAmount = amount;
        highestSpendingDay = date;
      }
    });

    // Calculate average daily spending
    final daysInMonth =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    final averageDailySpending = monthlyTotal / daysInMonth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          // Report type selector
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Weekly',
                  label: Text('Weekly'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment(
                  value: 'Monthly',
                  label: Text('Monthly'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {_selectedReport},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedReport = newSelection.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Color(0xFF9C446E);
                    }
                    return isDarkMode
                        ? Colors.grey.shade900
                        : Colors.grey.shade200;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Insights Section
              _buildSectionTitle(context, 'Insights'),
              const SizedBox(height: 16),
              if (highestAmount > 0)
                _buildInsightCard(
                  context,
                  'Highest Spending Category',
                  '${highestCategory.name} (Br ${highestAmount.toStringAsFixed(2)})',
                  _getCategoryIcon(highestCategory),
                  isDarkMode,
                ),
              if (highestAmount > 0) const SizedBox(height: 12),
              if (highestDailyAmount > 0)
                _buildInsightCard(
                  context,
                  'Highest Spending Day',
                  '${DateFormat.yMMMd().format(highestSpendingDay)} (Br ${highestDailyAmount.toStringAsFixed(2)})',
                  Icons.calendar_today,
                  isDarkMode,
                ),
              if (highestDailyAmount > 0) const SizedBox(height: 12),
              _buildInsightCard(
                context,
                'Average Daily Spending',
                'Br ${averageDailySpending.toStringAsFixed(2)}',
                Icons.show_chart,
                isDarkMode,
              ),
              const SizedBox(height: 32),

              // Dynamic Report Section
              _buildSectionTitle(
                  context,
                  _selectedReport == 'Weekly'
                      ? 'Weekly Report'
                      : 'Monthly Report'),
              const SizedBox(height: 16),
              _buildReportSection(expenses, isDarkMode),
              const SizedBox(height: 32),

              // Period Totals
              _buildSectionTitle(context, 'Period Totals'),
              const SizedBox(height: 16),
              _buildPeriodCard(
                context,
                'Today',
                dailyTotal,
                Icons.today,
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildPeriodCard(
                context,
                'This Week',
                weeklyTotal,
                Icons.calendar_view_week,
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildPeriodCard(
                context,
                'This Month',
                monthlyTotal,
                Icons.calendar_month,
                isDarkMode,
              ),
              const SizedBox(height: 32),

              // Category Breakdown
              _buildSectionTitle(context, 'Category Breakdown'),
              const SizedBox(height: 16),
              ...Category.values.map((category) {
                final total = categoryTotals[category] ?? 0.0;
                final percentage = totalExpenses > 0
                    ? (total / totalExpenses * 100).toStringAsFixed(1)
                    : '0.0';

                return Column(
                  children: [
                    _buildCategoryCard(
                      context,
                      category,
                      total,
                      percentage,
                      isDarkMode,
                      isHighest: category == highestCategory,
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSection(List<Expense> expenses, bool isDarkMode) {
    if (_selectedReport == 'Weekly') {
      return _buildWeeklyReport(expenses, isDarkMode);
    } else {
      return _buildMonthlyReport(expenses, isDarkMode);
    }
  }

  Widget _buildWeeklyReport(List<Expense> expenses, bool isDarkMode) {
    // Get expenses for each day of the current week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyData = List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      final dayExpenses = expenses.where((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
      final total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
      return {
        'date': date,
        'total': total,
        'expenses': dayExpenses.toList(),
      };
    });

    return Column(
      children: weeklyData.map((day) {
        final date = day['date'] as DateTime;
        final total = day['total'] as double;
        final dayExpenses = day['expenses'] as List<Expense>;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE').format(date),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Br ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              children: dayExpenses
                  .map((expense) => ListTile(
                        leading: Icon(_getCategoryIcon(expense.category)),
                        title: Text(expense.name),
                        trailing:
                            Text('Br ${expense.amount.toStringAsFixed(2)}'),
                      ))
                  .toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyReport(List<Expense> expenses, bool isDarkMode) {
    // Get current month's info
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final lastDayOfMonth = nextMonth.subtract(const Duration(days: 1));

    // Define the week ranges
    final weekRanges = [
      {'start': 1, 'end': 7},
      {'start': 8, 'end': 14},
      {'start': 15, 'end': 21},
      {'start': 22, 'end': lastDayOfMonth.day},
    ];

    return Column(
      children: [
        // Add month header
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            DateFormat('MMMM yyyy').format(now),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        ...weekRanges.map((week) {
          final weekStart = DateTime(now.year, now.month, week['start'] as int);
          final weekEnd = DateTime(now.year, now.month, week['end'] as int);

          // Filter expenses for this week
          final weekExpenses = expenses.where((e) {
            final expenseDate = e.date;
            return expenseDate
                    .isAfter(weekStart.subtract(const Duration(days: 1))) &&
                expenseDate.isBefore(weekEnd.add(const Duration(days: 1))) &&
                expenseDate.month == now.month;
          }).toList();

          // Sort expenses by date, newest first
          weekExpenses.sort((a, b) => b.date.compareTo(a.date));

          final total = weekExpenses.fold(0.0, (sum, e) => sum + e.amount);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Week ${week['start']}-${week['end']}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Br ${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                children: [
                  if (weekExpenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No expenses for this week'),
                    )
                  else
                    ...weekExpenses.map((expense) => ListTile(
                          leading: Icon(_getCategoryIcon(expense.category)),
                          title: Text(expense.name),
                          subtitle:
                              Text(DateFormat('MMM d').format(expense.date)),
                          trailing:
                              Text('Br ${expense.amount.toStringAsFixed(2)}'),
                        )),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String value,
      IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9C446E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF9C446E),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(BuildContext context, String period, double amount,
      IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Text(
                'Br ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category,
      double amount, String percentage, bool isDarkMode,
      {bool isHighest = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighest
              ? const Color(0xFF9C446E)
              : isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighest
                  ? const Color(0xFF9C446E).withOpacity(0.1)
                  : isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: isHighest
                  ? const Color(0xFF9C446E)
                  : isDarkMode
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name.toUpperCase(),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Br ${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey : Colors.grey.shade600,
            ),
          ),
        ],
      ),
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
