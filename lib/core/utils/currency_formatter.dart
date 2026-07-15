import 'package:intl/intl.dart';

/// Currency formatter — defaults to Indian Rupee (₹).
/// Returns properly formatted strings like "₹1,23,456.00"
abstract class CurrencyFormatter {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Full format: ₹1,23,456.00
  static String format(double amount) => _inrFormat.format(amount);

  /// Compact format without paise: ₹1,23,456
  static String formatCompact(double amount) => _inrCompact.format(amount);

  /// Format large numbers with K/L suffix (for summary displays)
  /// e.g. ₹1.2L, ₹45K
  static String formatShort(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return _inrCompact.format(amount);
  }

  /// Parse a currency string back to double (strips ₹, commas, spaces)
  static double? parse(String input) {
    final cleaned = input
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    return double.tryParse(cleaned);
  }
}
