import 'outage_state.dart';

/// Ближайшее событие графика отключений.
///
/// Например:
/// • Следующее отключение
/// • Возвращение электроснабжения
/// • Возможное отключение
class NextOutageEvent {
  /// Начало события
  final DateTime start;

  /// Конец события
  final DateTime end;

  /// Тип события
  final OutageState state;

  /// Заголовок
  ///
  /// Например:
  /// "Планове відключення"
  /// "Можливе відключення"
  /// "Відновлення електропостачання"
  final String title;

  /// Дополнительное описание
  final String? description;

  const NextOutageEvent({
    required this.start,
    required this.end,
    required this.state,
    required this.title,
    this.description,
  });

  /// Продолжительность события
  Duration get duration => end.difference(start);

  /// Длительность в минутах
  int get durationMinutes => duration.inMinutes;

  /// Длительность в часах
  double get durationHours => duration.inMinutes / 60;

  /// Уже началось?
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  /// Уже прошло?
  bool get isFinished {
    return DateTime.now().isAfter(end);
  }

  /// Через сколько начнётся
  Duration get timeUntilStart {
    return start.difference(DateTime.now());
  }

  NextOutageEvent copyWith({
    DateTime? start,
    DateTime? end,
    OutageState? state,
    String? title,
    String? description,
  }) {
    return NextOutageEvent(
      start: start ?? this.start,
      end: end ?? this.end,
      state: state ?? this.state,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'NextOutageEvent('
        'title: $title, '
        'state: $state, '
        'start: $start, '
        'end: $end'
        ')';
  }
}