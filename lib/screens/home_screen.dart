import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/widgets/expense_list.dart';
import 'package:expense_tracker/widgets/expense_bar_chart.dart';
import 'package:expense_tracker/widgets/add_expense_form.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/settings_screen.dart';
import 'package:expense_tracker/utils/expense_calculations.dart';
import 'package:expense_tracker/screens/summary_screen.dart';
import 'package:expense_tracker/widgets/report_notification.dart';

// Create a provider to track the selected period
final selectedPeriodProvider = StateProvider<String>((ref) => 'Daily');

// Update the selectedDateProvider to initialize with current date
final selectedDateProvider = StateProvider<DateTime?>((ref) => DateTime.now());

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calculate total spent based on selected period and date
    final totalSpent = selectedDate != null
        ? ExpenseCalculations.calculateTotalForDate(
            expenses, selectedDate, selectedPeriod)
        : ExpenseCalculations.calculateTotalForPeriod(expenses, selectedPeriod);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              value: selectedPeriod,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              underline: Container(),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(selectedPeriodProvider.notifier).state = newValue;
                  ref.read(selectedDateProvider.notifier).state =
                      DateTime.now();
                }
              },
              items: <String>['Daily', 'Weekly', 'Monthly']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: isDarkMode ? Colors.black : Colors.grey.shade100,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // App logo
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/image/money.png',
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 40),
                // Home menu item
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.home_outlined,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 28,
                    ),
                    title: Text(
                      'HOME',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Summary menu item
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.pie_chart_outline,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 28,
                    ),
                    title: Text(
                      'SUMMARY',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SummaryScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Settings menu item
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.settings_outlined,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 28,
                    ),
                    title: Text(
                      'SETTINGS',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Amount Section (Fixed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${totalSpent.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'SPENT THIS ${selectedPeriod.toUpperCase()}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bar Chart Section (Fixed)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: const ExpenseBarChart(),
              ),

              // Selected Date Filter Info (Fixed)
              if (selectedDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing expenses for ${ExpenseCalculations.formatDateForPeriod(selectedDate, selectedPeriod)}',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(selectedDateProvider.notifier).state = null;
                        },
                        child: const Text('Show All'),
                      ),
                    ],
                  ),
                ),

              // Expense List Section (Scrollable)
              Expanded(
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: const ExpenseList(),
                ),
              ),
            ],
          ),
          const ReportNotification(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseModal(context);
        },
        backgroundColor: const Color(0xFF9C446E),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context) {
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
        child: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: AddExpenseForm(),
        ),
      ),
    );
  }
}
