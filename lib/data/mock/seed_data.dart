import 'package:flutter/material.dart';
import '../../domain/models/account.dart';
import '../../domain/models/category.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/recurring_rule.dart';

final seedAccounts = <Account>[
  Account(
    id: 'acc_1',
    name: 'HDFC Salary',
    principalAmount: 85000,
    lockedAmount: 60000,
    color: const Color(0xFF6366F1),
    icon: Icons.account_balance,
  ),
  Account(
    id: 'acc_2',
    name: 'Savings Account',
    principalAmount: 120000,
    lockedAmount: 100000,
    color: const Color(0xFF10B981),
    icon: Icons.savings,
  ),
  Account(
    id: 'acc_3',
    name: 'Cash Wallet',
    principalAmount: 5000,
    lockedAmount: 0,
    color: const Color(0xFFF59E0B),
    icon: Icons.account_balance_wallet,
  ),
];

final seedCategories = <Category>[
  Category(id: 'cat_1', name: 'Food & Dining', icon: Icons.restaurant, color: const Color(0xFFEF4444)),
  Category(id: 'cat_2', name: 'Transport', icon: Icons.directions_car, color: const Color(0xFF3B82F6)),
  Category(id: 'cat_3', name: 'Shopping', icon: Icons.shopping_bag, color: const Color(0xFFEC4899)),
  Category(id: 'cat_4', name: 'Entertainment', icon: Icons.movie, color: const Color(0xFF8B5CF6)),
  Category(id: 'cat_5', name: 'Health', icon: Icons.local_hospital, color: const Color(0xFF10B981)),
  Category(id: 'cat_6', name: 'Bills', icon: Icons.receipt_long, color: const Color(0xFFF59E0B)),
  Category(id: 'cat_7', name: 'Groceries', icon: Icons.shopping_cart, color: const Color(0xFF84CC16)),
  Category(id: 'cat_8', name: 'Education', icon: Icons.school, color: const Color(0xFF06B6D4)),
  Category(id: 'cat_9', name: 'Travel', icon: Icons.flight, color: const Color(0xFFFF6B6B)),
  Category(id: 'cat_10', name: 'Personal Care', icon: Icons.spa, color: const Color(0xFFA78BFA)),
];

final seedTransactions = <Transaction>[
  Transaction(id: 'txn_1', accountId: 'acc_1', categoryId: 'cat_1', amount: 450, note: 'Lunch at Cafe Coffee Day', date: DateTime(2026, 7, 16)),
  Transaction(id: 'txn_2', accountId: 'acc_1', categoryId: 'cat_2', amount: 280, note: 'Uber to office', date: DateTime(2026, 7, 15)),
  Transaction(id: 'txn_3', accountId: 'acc_3', categoryId: 'cat_7', amount: 1200, note: 'Weekly groceries', date: DateTime(2026, 7, 14)),
  Transaction(id: 'txn_4', accountId: 'acc_1', categoryId: 'cat_6', amount: 999, note: 'Netflix subscription', date: DateTime(2026, 7, 13), isRecurring: true),
  Transaction(id: 'txn_5', accountId: 'acc_2', categoryId: 'cat_5', amount: 500, note: 'Pharmacy', date: DateTime(2026, 7, 12)),
  Transaction(id: 'txn_6', accountId: 'acc_1', categoryId: 'cat_3', amount: 2500, note: 'New shoes', date: DateTime(2026, 7, 10)),
  Transaction(id: 'txn_7', accountId: 'acc_3', categoryId: 'cat_1', amount: 350, note: 'Dinner with friends', date: DateTime(2026, 7, 9)),
  Transaction(id: 'txn_8', accountId: 'acc_1', categoryId: 'cat_4', amount: 800, note: 'Movie tickets', date: DateTime(2026, 7, 8)),
  Transaction(id: 'txn_9', accountId: 'acc_2', categoryId: 'cat_6', amount: 1499, note: 'Gym membership', date: DateTime(2026, 7, 7), isRecurring: true),
  Transaction(id: 'txn_10', accountId: 'acc_1', categoryId: 'cat_2', amount: 180, note: 'Auto rickshaw', date: DateTime(2026, 7, 6)),
  Transaction(id: 'txn_11', accountId: 'acc_1', categoryId: 'cat_7', amount: 950, note: 'Supermarket haul', date: DateTime(2026, 7, 4)),
  Transaction(id: 'txn_12', accountId: 'acc_3', categoryId: 'cat_10', amount: 600, note: 'Haircut + grooming', date: DateTime(2026, 7, 3)),
  Transaction(id: 'txn_13', accountId: 'acc_1', categoryId: 'cat_8', amount: 3000, note: 'Udemy course bundle', date: DateTime(2026, 7, 2)),
  Transaction(id: 'txn_14', accountId: 'acc_2', categoryId: 'cat_6', amount: 1200, note: 'Internet bill', date: DateTime(2026, 7, 1), isRecurring: true),
  Transaction(id: 'txn_15', accountId: 'acc_1', categoryId: 'cat_9', amount: 8500, note: 'Train tickets to Goa', date: DateTime(2026, 6, 28)),
  Transaction(id: 'txn_16', accountId: 'acc_1', categoryId: 'cat_1', amount: 680, note: 'Anniversary dinner', date: DateTime(2026, 6, 25)),
  Transaction(id: 'txn_17', accountId: 'acc_3', categoryId: 'cat_2', amount: 350, note: 'Petrol', date: DateTime(2026, 6, 22)),
  Transaction(id: 'txn_18', accountId: 'acc_1', categoryId: 'cat_3', amount: 1800, note: 'Amazon order', date: DateTime(2026, 6, 20)),
  Transaction(id: 'txn_19', accountId: 'acc_2', categoryId: 'cat_5', amount: 2200, note: 'Doctor consultation', date: DateTime(2026, 6, 18)),
  Transaction(id: 'txn_20', accountId: 'acc_1', categoryId: 'cat_4', amount: 450, note: 'Spotify + Prime', date: DateTime(2026, 6, 15)),
];

final seedRecurringRules = <RecurringRule>[
  RecurringRule(
    id: 'rec_1',
    accountId: 'acc_1',
    categoryId: 'cat_6',
    amount: 999,
    note: 'Netflix subscription',
    frequency: RecurringFrequency.monthly,
    nextDate: DateTime(2026, 8, 13),
  ),
  RecurringRule(
    id: 'rec_2',
    accountId: 'acc_2',
    categoryId: 'cat_6',
    amount: 1499,
    note: 'Gym membership',
    frequency: RecurringFrequency.monthly,
    nextDate: DateTime(2026, 8, 7),
  ),
  RecurringRule(
    id: 'rec_3',
    accountId: 'acc_2',
    categoryId: 'cat_6',
    amount: 1200,
    note: 'Internet bill',
    frequency: RecurringFrequency.monthly,
    nextDate: DateTime(2026, 8, 1),
  ),
];
