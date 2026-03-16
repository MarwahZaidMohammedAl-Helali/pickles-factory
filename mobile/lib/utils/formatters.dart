import 'package:intl/intl.dart';

class Formatters {
  // Jordanian Dinar currency symbol
  static const String currencySymbol = 'د.أ'; // JOD symbol
  static const String currencyCode = 'JOD';

  // Format currency with Jordanian Dinar and English numerals
  static String formatCurrency(double amount, [String? customSymbol]) {
    // Use 'en' locale to ensure Western numerals
    final formatter = NumberFormat('#,##0.000', 'en'); // JOD uses 3 decimal places
    final symbol = customSymbol ?? currencySymbol;
    return '${formatter.format(amount)} $symbol';
  }

  // Format currency without symbol (just the number)
  static String formatCurrencyNumber(double amount) {
    final formatter = NumberFormat('#,##0.000', 'en');
    return formatter.format(amount);
  }

  // Format date with Arabic locale but English numerals
  static String formatDate(DateTime date) {
    // Use 'en' locale for Western numerals
    final formatter = DateFormat('yyyy-MM-dd', 'en');
    return formatter.format(date);
  }

  // Format date in Arabic style (day/month/year)
  static String formatDateArabic(DateTime date) {
    // Use 'en' locale for Western numerals but Arabic date format
    final formatter = DateFormat('dd/MM/yyyy', 'en');
    return formatter.format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime dateTime) {
    // Use 'en' locale for Western numerals
    final formatter = DateFormat('yyyy-MM-dd HH:mm', 'en');
    return formatter.format(dateTime);
  }

  // Format number with English numerals
  static String formatNumber(num number) {
    // Use 'en' locale to ensure Western numerals
    final formatter = NumberFormat('#,##0', 'en');
    return formatter.format(number);
  }

  // Format decimal number with English numerals
  static String formatDecimal(double number, {int decimalPlaces = 2}) {
    // Use 'en' locale to ensure Western numerals
    final pattern = '#,##0.${'0' * decimalPlaces}';
    final formatter = NumberFormat(pattern, 'en');
    return formatter.format(number);
  }

  // Format balance with color indicator
  static String formatBalance(double balance) {
    final formatted = formatCurrency(balance);
    return balance >= 0 ? formatted : formatted;
  }

  // Get balance color
  static bool isPositiveBalance(double balance) {
    return balance >= 0;
  }
}
