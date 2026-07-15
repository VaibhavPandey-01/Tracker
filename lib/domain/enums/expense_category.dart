import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Expense category enum with display metadata.
enum ExpenseCategory {
  food('food', 'Food & Drinks', Icons.restaurant_rounded),
  transport('transport', 'Transport', Icons.directions_bus_rounded),
  essentials('essentials', 'Essentials', Icons.home_rounded),
  shopping('shopping', 'Shopping', Icons.shopping_bag_rounded),
  entertainment('entertainment', 'Entertainment', Icons.movie_rounded),
  health('health', 'Health', Icons.medical_services_rounded),
  other('other', 'Other', Icons.more_horiz_rounded);

  const ExpenseCategory(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.catFood;
      case ExpenseCategory.transport:
        return AppColors.catTransport;
      case ExpenseCategory.essentials:
        return AppColors.catEssentials;
      case ExpenseCategory.shopping:
        return AppColors.catShopping;
      case ExpenseCategory.entertainment:
        return AppColors.catEntertainment;
      case ExpenseCategory.health:
        return AppColors.catHealth;
      case ExpenseCategory.other:
        return AppColors.catOther;
    }
  }

  static ExpenseCategory fromValue(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}
