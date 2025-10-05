import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTimeForApi(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  static DateTime? parseApiDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class NumberHelper {
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String formatNumber(num number) {
    return NumberFormat('#,##0').format(number);
  }

  static String formatDecimal(double number, {int decimalPlaces = 2}) {
    return number.toStringAsFixed(decimalPlaces);
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static double? parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }

  static int? parseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }
}

class StringHelper {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static bool isEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isPhoneNumber(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone.replaceAll(RegExp(r'[\s-()]'), ''));
  }

  static String generateInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }
}

class ColorHelper {
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'confirmed':
        return '#2196F3'; // Blue
      case 'processing':
      case 'in progress':
      case 'inprogress':
        return '#FF6B35'; // Primary Orange
      case 'ready':
        return '#9C27B0'; // Purple
      case 'shipped':
        return '#3F51B5'; // Indigo
      case 'delivered':
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      case 'returned':
        return '#795548'; // Brown
      case 'on hold':
      case 'onhold':
        return '#607D8B'; // Blue Grey
      default:
        return '#9E9E9E'; // Grey
    }
  }

  static int getStatusColorInt(String status) {
    final colorString = getStatusColor(status);
    return int.parse(colorString.replaceAll('#', '0xFF'));
  }
}

class ListHelper {
  static List<T> paginate<T>(List<T> list, int page, int pageSize) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, list.length);

    if (startIndex >= list.length) return [];
    return list.sublist(startIndex, endIndex);
  }

  static List<T> searchList<T>(
    List<T> list,
    String query,
    String Function(T) getSearchText,
  ) {
    if (query.isEmpty) return list;

    final lowercaseQuery = query.toLowerCase();
    return list.where((item) =>
      getSearchText(item).toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  static List<T> sortList<T>(
    List<T> list,
    Comparable Function(T) getComparable, {
    bool descending = false,
  }) {
    final sortedList = List<T>.from(list);
    sortedList.sort((a, b) {
      final aVal = getComparable(a);
      final bVal = getComparable(b);
      return descending ? bVal.compareTo(aVal) : aVal.compareTo(bVal);
    });
    return sortedList;
  }
}

class DeviceHelper {
  static bool isTablet(double screenWidth) {
    return screenWidth >= 768;
  }

  static bool isDesktop(double screenWidth) {
    return screenWidth >= 1024;
  }

  static double getResponsivePadding(double screenWidth) {
    if (isDesktop(screenWidth)) return 32.0;
    if (isTablet(screenWidth)) return 24.0;
    return 16.0;
  }

  static int getGridColumns(double screenWidth) {
    if (isDesktop(screenWidth)) return 4;
    if (isTablet(screenWidth)) return 3;
    return 2;
  }
}