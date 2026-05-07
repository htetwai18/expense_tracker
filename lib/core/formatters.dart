import 'enums.dart';

abstract final class AppFormatters {
  static String amount(double amount) {
    final value = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return value.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  static String currency(double amount) {
    return '\$${AppFormatters.amount(amount)}';
  }

  static String signedAmount({
    required double amount,
    required TransactionTone tone,
  }) {
    final sign = tone == TransactionTone.income ? '+' : '-';
    return '$sign${currency(amount)}';
  }

  static String transactionSubtitle(DateTime dateTime) {
    return '${dateLabel(dateTime)} • ${timeLabel(dateTime)}';
  }

  static String dateLabel(DateTime dateTime) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dateTime.day} ${monthNames[dateTime.month - 1]} ${dateTime.year}';
  }

  static String monthYear(DateTime dateTime) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[dateTime.month - 1]} ${dateTime.year}';
  }

  static String timeLabel(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
