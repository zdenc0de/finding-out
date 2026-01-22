// lib/core/utils/date_formatter.dart
// Utilidades para formateo de fechas

import 'package:intl/intl.dart';

/// Utilidades para formatear fechas en español.
abstract class DateFormatter {
  /// Formatea una fecha como "15 ene"
  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM', 'es').format(date);
  }

  /// Formatea una fecha como "15 de enero"
  static String formatMediumDate(DateTime date) {
    return DateFormat("d 'de' MMMM", 'es').format(date);
  }

  /// Formatea una fecha como "15 de enero de 2024"
  static String formatLongDate(DateTime date) {
    return DateFormat("d 'de' MMMM 'de' y", 'es').format(date);
  }

  /// Formatea solo la hora como "18:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'es').format(date);
  }

  /// Formatea fecha y hora como "15 ene, 18:30"
  static String formatShortDateTime(DateTime date) {
    return DateFormat('d MMM, HH:mm', 'es').format(date);
  }

  /// Retorna si la fecha es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Retorna si la fecha es mañana
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Formatea la fecha de forma relativa ("Hoy", "Mañana", "15 ene")
  static String formatRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Hoy, ${formatTime(date)}';
    } else if (isTomorrow(date)) {
      return 'Mañana, ${formatTime(date)}';
    }
    return formatShortDateTime(date);
  }
}
