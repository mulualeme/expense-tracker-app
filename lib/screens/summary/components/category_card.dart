import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/utils/category_icons.dart';

class CategoryCard extends StatelessWidget {
  static const _accentColor = Color(0xFF9C446E);

  final Category category;
  final double amount;
  final String percentage;
  final bool isDarkMode;
  final bool isHighest;

  const CategoryCard({
    super.key,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.isDarkMode,
    this.isHighest = false,
  });

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isHighest
            ? _accentColor
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
    );
  }

  BoxDecoration _buildIconContainerDecoration() {
    return BoxDecoration(
      color: isHighest
          ? _accentColor.withOpacity(0.1)
          : isDarkMode
              ? Colors.grey.shade900
              : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Color _getIconColor() {
    return isHighest
        ? _accentColor
        : isDarkMode
            ? Colors.white
            : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: _buildIconContainerDecoration(),
            child: Icon(
              CategoryIcons.getIcon(category),
              color: _getIconColor(),
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
}
