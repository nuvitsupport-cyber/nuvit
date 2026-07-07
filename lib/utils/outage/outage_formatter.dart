import '../../models/outage/next_outage_event.dart';
import '../../models/outage/outage_period.dart';

/// Форматирование данных для модуля "Графік відключень".
///
/// Здесь находится только отображение данных.
/// Никакой бизнес-логики.
class OutageFormatter {
  OutageFormatter._();

  // ==========================================================
  // Время
  // ==========================================================

  /// 18:30
  static String time(DateTime value) {
    return '${_two(value.hour)}:${_two(value.minute)}';
  }

  /// 18:00 - 20:00
  static String period(OutagePeriod period) {
    return '${time(period.start)} - ${time(period.end)}';
  }

  /// Следующее событие
  static String nextEvent(NextOutageEvent event) {
    return '${time(event.start)} - ${time(event.end)}';
  }

  // ==========================================================
  // Длительность
  // ==========================================================

  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return '$minutes хв';
    }

    if (minutes == 0) {
      return '$hours год';
    }

    return '$hours год $minutes хв';
  }

  // ==========================================================
  // Проценты
  // ==========================================================

  static String percent(num value) {
    return '${value.round()}%';
  }

  // ==========================================================
  // Часы
  // ==========================================================

  static String hours(double hours) {
    if (hours == hours.roundToDouble()) {
      return '${hours.toInt()} год';
    }

    return '${hours.toStringAsFixed(1)} год';
  }

  // ==========================================================
  // Дата
  // ==========================================================

  static String shortDate(DateTime value) {
    return '${_two(value.day)}.${_two(value.month)}';
  }

  /// 26.06 18:00
  static String dateTime(DateTime value) {
    return '${shortDate(value)} ${time(value)}';
  }

  // ==========================================================
  // Последнее обновление
  // ==========================================================

  static String updated(DateTime updatedAt) {
    final difference = DateTime.now().difference(updatedAt);

    if (difference.inMinutes < 1) {
      return 'щойно';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} хв тому';
    }

    if (difference.inDays < 1) {
      return '${difference.inHours} год тому';
    }

    return '${difference.inDays} дн тому';
  }

  // ==========================================================
  // Helpers
  // ==========================================================

  static String _two(int value) {
    return value.toString().padLeft(2, '0');
  }
}