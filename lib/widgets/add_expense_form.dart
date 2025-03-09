import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';

class AddExpenseForm extends ConsumerStatefulWidget {
  final Expense? expenseToEdit;
  const AddExpenseForm({super.key, this.expenseToEdit});

  @override
  ConsumerState<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends ConsumerState<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  late Category _selectedCategory;
  late DateTime _selectedDate;

  static const Map<Category, IconData> categoryIcons = {
    Category.food: Icons.restaurant,
    Category.transport: Icons.directions_car,
    Category.entertainment: Icons.movie,
    Category.bills: Icons.receipt,
    Category.other: Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.expenseToEdit?.category ?? Category.food;
    _selectedDate = widget.expenseToEdit?.date ?? DateTime.now();
    if (widget.expenseToEdit != null) {
      _nameController.text = widget.expenseToEdit!.name;
      _amountController.text = widget.expenseToEdit!.amount.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: widget.expenseToEdit?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
      );

      final notifier = ref.read(expenseProvider.notifier);
      widget.expenseToEdit != null
          ? notifier.updateExpense(expense)
          : notifier.addExpense(expense);

      Navigator.of(context).pop();
    }
  }

  InputDecoration _buildInputDecoration(String label, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      border: _buildBorder(isDarkMode),
      enabledBorder: _buildBorder(isDarkMode),
      focusedBorder: _buildBorder(isDarkMode, focused: true),
    );
  }

  OutlineInputBorder _buildBorder(bool isDarkMode, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: focused
            ? isDarkMode
                ? Colors.white
                : Colors.black
            : isDarkMode
                ? Colors.grey.shade800
                : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller,
      bool isDarkMode, String? Function(String?) validator,
      {String? prefixText}) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label, isDarkMode).copyWith(
        prefixText: prefixText,
      ),
      validator: validator,
      keyboardType: prefixText != null ? TextInputType.number : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 40,
          height: 5,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.expenseToEdit != null
                          ? 'Edit Expense'
                          : 'New Expense',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    _buildFormField(
                      'Name',
                      _nameController,
                      isDarkMode,
                      (value) =>
                          value?.isEmpty ?? true ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildFormField(
                      'Amount',
                      _amountController,
                      isDarkMode,
                      (value) {
                        if (value?.isEmpty ?? true)
                          return 'Please enter an amount';
                        if (double.tryParse(value!) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      prefixText: '\$ ',
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: _buildInputDecoration('Category', isDarkMode),
                      items: Category.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(categoryIcons[category]),
                              const SizedBox(width: 10),
                              Text(category.name.toUpperCase()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedCategory = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? Colors.white : Colors.black,
                          foregroundColor:
                              isDarkMode ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.expenseToEdit != null
                              ? 'Update Expense'
                              : 'Add Expense',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
