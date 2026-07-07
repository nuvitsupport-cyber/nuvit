import 'next_outage_event.dart';
import 'outage_insight.dart';
import 'outage_period.dart';
import 'outage_probability.dart';
import 'outage_source.dart';
import 'outage_statistics.dart';

/// Главная модель прогноза отключений.
///
/// Именно этот объект получает UI.
/// Он объединяет всю информацию:
/// • таймлайн суток;
/// • вероятность отключений;
/// • следующую событие;
/// • статистику;
/// • AI рекомендации;
/// • источник данных.
class OutageForecast {
  /// Периоды суток (24 часа)
  final List<OutagePeriod> periods;

  /// Общая вероятность отключения
  final OutageProbability probability;

  /// Следующее событие
  final NextOutageEvent? nextEvent;

  /// Статистика дня
  final OutageStatistics statistics;

  /// AI рекомендации
  final List<OutageInsight> insights;

  /// Источник информации
  final OutageSource source;

  /// Время обновления прогноза
  final DateTime updatedAt;

  const OutageForecast({
    required this.periods,
    required this.probability,
    required this.nextEvent,
    required this.statistics,
    required this.insights,
    required this.source,
    required this.updatedAt,
  });

  /// Пустой прогноз
  factory OutageForecast.empty() {
    return OutageForecast(
      periods: const [],
      probability: OutageProbability.empty(),
      nextEvent: null,
      statistics: OutageStatistics.empty(),
      insights: const [],
      source: OutageSource.mock(),
      updatedAt: DateTime.now(),
    );
  }

  /// Есть ли данные
  bool get hasData => periods.isNotEmpty;

  /// Есть ли рекомендации
  bool get hasInsights => insights.isNotEmpty;

  /// Есть ли следующее событие
  bool get hasNextEvent => nextEvent != null;

  OutageForecast copyWith({
    List<OutagePeriod>? periods,
    OutageProbability? probability,
    NextOutageEvent? nextEvent,
    OutageStatistics? statistics,
    List<OutageInsight>? insights,
    OutageSource? source,
    DateTime? updatedAt,
  }) {
    return OutageForecast(
      periods: periods ?? this.periods,
      probability: probability ?? this.probability,
      nextEvent: nextEvent ?? this.nextEvent,
      statistics: statistics ?? this.statistics,
      insights: insights ?? this.insights,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return '''
OutageForecast(
  periods: ${periods.length},
  probability: ${probability.percent}%
  nextEvent: $nextEvent
  insights: ${insights.length}
  updatedAt: $updatedAt
)
''';
  }
}