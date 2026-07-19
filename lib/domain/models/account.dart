import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final double principalAmount;
  final double lockedAmount;
  final Color color;
  final IconData icon;

  const Account({
    required this.id,
    required this.name,
    required this.principalAmount,
    required this.lockedAmount,
    required this.color,
    required this.icon,
  });

  double get spendableAmount => (principalAmount - lockedAmount).clamp(0, double.infinity);

  Account copyWith({
    String? id,
    String? name,
    double? principalAmount,
    double? lockedAmount,
    Color? color,
    IconData? icon,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      principalAmount: principalAmount ?? this.principalAmount,
      lockedAmount: lockedAmount ?? this.lockedAmount,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
