import 'package:intl/intl.dart';

/// Date & time formatting utilities for the ledger and UI.
abstract class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, h:mm a');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  static final DateFormat _dayFormat = DateFormat('EEE, dd MMM');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// "15 Jul 2026"
  static String formatDate(DateTime dt) => _dateFormat.format(dt);

  /// "15 Jul 2026, 8:00 PM"
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  /// "8:00 PM"
  static String formatTime(DateTime dt) => _timeFormat.format(dt);

  /// "July 2026"
  static String formatMonth(DateTime dt) => _monthFormat.format(dt);

  /// "Tue, 15 Jul"
  static String formatDay(DateTime dt) => _dayFormat.format(dt);

  /// "2026-07-15" (for grouping)
  static String isoDate(DateTime dt) => _isoDate.format(dt);

  /// Relative label: "Today", "Yesterday", or formatted date
  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    return formatDate(dt);
  }

  /// Whether a datetime is within the current calendar month
  static bool isThisMonth(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month;
  }

  /// Start of current month
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// End of current month
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }
}
