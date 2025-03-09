import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';

class CategoryIcons {
  static IconData getIcon(Category category) {
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
