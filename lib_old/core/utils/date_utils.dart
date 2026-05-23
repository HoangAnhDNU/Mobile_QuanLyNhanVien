import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime time) => _timeFormat.format(time);
  static String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);
  static String toIsoDate(DateTime date) => _isoFormat.format(date);

  static DateTime? parseIsoDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return _isoFormat.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays + 1;
  }

  static int workDaysInMonth(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    int workDays = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        workDays++;
      }
    }
    return workDays;
  }

  static bool isExpiringSoon(DateTime startDate, int contractMonths, {int thresholdDays = 30}) {
    final endDate = DateTime(startDate.year, startDate.month + contractMonths, startDate.day);
    final daysRemaining = endDate.difference(DateTime.now()).inDays;
    return daysRemaining > 0 && daysRemaining <= thresholdDays;
  }
}
