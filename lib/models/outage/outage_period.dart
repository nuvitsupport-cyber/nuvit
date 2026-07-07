import 'outage_state.dart';

/// Один период графика отключений.
///
/// Например:
///
/// 00:00 - 03:00  → Є світло
///
/// 18:00 - 20:00  → Відключення
///
/// 20:00 - 22:00  → Можливе відключення
class OutagePeriod {
  /// Начало периода.
  final DateTime start;

  /// Конец периода.
  final DateTime end;

  /// Состояние сети.
  final OutageState state;

  /// Вероятность отключения (0-100).
  ///
  /// Для периода со светом обычно 0.
  ///
  /// Для возможного отключения, например, 65.
  ///
  /// Для подтвержденного отключения — 100.
  final int probability;

  /// Дополнительная информация.
  ///
  /// Например:
  /// • Планове відключення
  /// • Аварійні роботи
  /// • Можливі обмеження
  final String? description;

  const OutagePeriod({
    required this.start,
    required this.end,
    required this.state,
    this.probability = 0,
    this.description,
  });

  /// Продолжительность периода.
  Duration get duration => end.difference(start);

  /// Длительность в минутах.
  int get durationMinutes => duration.inMinutes;

  /// Длительность в часах.
  double get durationHours => duration.inMinutes / 60.0;

  /// Активен ли период сейчас.
  bool get isCurrent {
    final now = DateTime.now();

    return now.isAfter(start) &&
        now.isBefore(end);
  }

  /// Уже закончился.
  bool get isPast {
    return DateTime.now().isAfter(end);
  }

  /// Еще не начался.
  bool get isFuture {
    return DateTime.now().isBefore(start);
  }

  /// Есть электроснабжение.
  bool get hasPower =>
      state == OutageState.powerOn;

  /// Есть отключение.
  bool get isOutage =>
      state == OutageState.outage;

  /// Возможное отключение.
  bool get isPossible =>
      state == OutageState.possibleOutage;

  OutagePeriod copyWith({
    DateTime? start,
    DateTime? end,
    OutageState? state,
    int? probability,
    String? description,
  }) {
    return OutagePeriod(
      start: start ?? this.start,
      end: end ?? this.end,
      state: state ?? this.state,
      probability: probability ?? this.probability,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'OutagePeriod('
        'start: $start, '
        'end: $end, '
        'state: $state, '
        'probability: $probability%'
        ')';
  }
}