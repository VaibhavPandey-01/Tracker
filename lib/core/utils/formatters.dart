import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

final _currencyFormatterDecimal = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

String formatCurrency(double amount, {bool showDecimal = false}) {
  return showDecimal
      ? _currencyFormatterDecimal.format(amount)
      : _currencyFormatter.format(amount);
}

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);

  if (d == today) return 'Today';
  if (d == yesterday) return 'Yesterday';
  if (now.year == date.year) return DateFormat('d MMM').format(date);
  return DateFormat('d MMM yyyy').format(date);
}

String formatDateFull(DateTime date) => DateFormat('d MMMM yyyy').format(date);

String formatMonth(DateTime date) => DateFormat('MMMM yyyy').format(date);

String formatShortDate(DateTime date) => DateFormat('d MMM').format(date);
