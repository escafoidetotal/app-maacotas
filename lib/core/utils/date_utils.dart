import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'pt_BR');
  static final DateFormat _dayMonth = DateFormat('dd MMM', 'pt_BR');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  static String formatDayMonth(DateTime date) {
    return _dayMonth.format(date);
  }

  static DateTime? tryParse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return _dateFormat.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  static int calculateAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    return months;
  }

  static String formatAge(DateTime birthDate) {
    final months = calculateAgeInMonths(birthDate);
    if (months < 12) {
      return '$months ${months == 1 ? 'mês' : 'meses'}';
    }
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) {
      return '$years ${years == 1 ? 'ano' : 'anos'}';
    }
    return '$years ${years == 1 ? 'ano' : 'anos'} e $remainingMonths ${remainingMonths == 1 ? 'mês' : 'meses'}';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static int daysDifference(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  static String timeUntil(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) {
      final absDiff = now.difference(date);
      if (absDiff.inDays == 0) return 'Hoje';
      if (absDiff.inDays == 1) return 'Ontem';
      return 'Há ${absDiff.inDays} dias';
    }
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Amanhã';
    if (diff.inDays < 30) return 'Em ${diff.inDays} dias';
    if (diff.inDays < 365) return 'Em ${diff.inDays ~/ 30} meses';
    return 'Em ${diff.inDays ~/ 365} anos';
  }
}
