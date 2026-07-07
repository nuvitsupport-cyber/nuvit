/// Статистика графика отключений за сутки.
///
/// Все значения уже рассчитаны движком
/// OutageStatisticsEngine.
class OutageStatistics {
  /// Часов со светом.
  final double powerHours;

  /// Часов без света.
  final double outageHours;

  /// Часов с возможными отключениями.
  final double possibleOutageHours;

  /// Количество отключений.
  final int outageCount;

  /// Средняя продолжительность отключения.
  final Duration averageOutageDuration;

  /// Самое длительное отключение.
  final Duration longestOutageDuration;

  const OutageStatistics({
    required this.powerHours,
    required this.outageHours,
    required this.possibleOutageHours,
    required this.outageCount,
    required this.averageOutageDuration,
    required this.longestOutageDuration,
  });

  /// Пустая статистика.
  factory OutageStatistics.empty() {
    return const OutageStatistics(
      powerHours: 0,
      outageHours: 0,
      possibleOutageHours: 0,
      outageCount: 0,
      averageOutageDuration: Duration.zero,
      longestOutageDuration: Duration.zero,
    );
  }

  /// Общее количество часов.
  double get totalHours =>
      powerHours + outageHours + possibleOutageHours;

  /// Процент времени со светом.
  double get powerPercent {
    if (totalHours == 0) return 0;
    return (powerHours / totalHours) * 100;
  }

  /// Процент времени без света.
  double get outagePercent {
    if (totalHours == 0) return 0;
    return (outageHours / totalHours) * 100;
  }

  /// Есть отключения?
  bool get hasOutages => outageCount > 0;

  OutageStatistics copyWith({
    double? powerHours,
    double? outageHours,
    double? possibleOutageHours,
    int? outageCount,
    Duration? averageOutageDuration,
    Duration? longestOutageDuration,
  }) {
    return OutageStatistics(
      powerHours: powerHours ?? this.powerHours,
      outageHours: outageHours ?? this.outageHours,
      possibleOutageHours:
          possibleOutageHours ?? this.possibleOutageHours,
      outageCount: outageCount ?? this.outageCount,
      averageOutageDuration:
          averageOutageDuration ?? this.averageOutageDuration,
      longestOutageDuration:
          longestOutageDuration ?? this.longestOutageDuration,
    );
  }

  @override
  String toString() {
    return '''
OutageStatistics(
  powerHours: $powerHours,
  outageHours: $outageHours,
  possibleOutageHours: $possibleOutageHours,
  outageCount: $outageCount,
  averageOutageDuration: $averageOutageDuration,
  longestOutageDuration: $longestOutageDuration
)
''';
  }
}