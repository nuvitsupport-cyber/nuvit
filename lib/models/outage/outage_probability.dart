/// Уровень риска отключения.
enum OutageRiskLevel {
  low,
  medium,
  high,
  critical,
}

/// Общая вероятность отключения электроэнергии.
///
/// Используется:
/// • OutageProbabilityRing;
/// • AI рекомендациями;
/// • карточкой прогноза;
/// • системой уведомлений.
class OutageProbability {
  /// Вероятность (0–100%).
  final int percent;

  /// Уровень риска.
  final OutageRiskLevel level;

  /// Краткое описание.
  ///
  /// Например:
  /// • Низька ймовірність
  /// • Висока ймовірність
  final String label;

  /// Дополнительное описание.
  final String? description;

  const OutageProbability({
    required this.percent,
    required this.level,
    required this.label,
    this.description,
  });

  /// Пустое значение.
  factory OutageProbability.empty() {
    return const OutageProbability(
      percent: 0,
      level: OutageRiskLevel.low,
      label: 'Немає даних',
    );
  }

  /// Автоматическое создание по проценту.
  factory OutageProbability.fromPercent(
    int percent, {
    String? description,
  }) {
    final value = percent.clamp(0, 100);

    if (value < 30) {
      return OutageProbability(
        percent: value,
        level: OutageRiskLevel.low,
        label: 'Низька ймовірність',
        description: description,
      );
    }

    if (value < 60) {
      return OutageProbability(
        percent: value,
        level: OutageRiskLevel.medium,
        label: 'Середня ймовірність',
        description: description,
      );
    }

    if (value < 85) {
      return OutageProbability(
        percent: value,
        level: OutageRiskLevel.high,
        label: 'Висока ймовірність',
        description: description,
      );
    }

    return OutageProbability(
      percent: value,
      level: OutageRiskLevel.critical,
      label: 'Критична ймовірність',
      description: description,
    );
  }

  bool get isLow => level == OutageRiskLevel.low;

  bool get isMedium => level == OutageRiskLevel.medium;

  bool get isHigh => level == OutageRiskLevel.high;

  bool get isCritical => level == OutageRiskLevel.critical;

  /// Значение для индикаторов (0.0–1.0).
  double get progress => percent / 100;

  OutageProbability copyWith({
    int? percent,
    OutageRiskLevel? level,
    String? label,
    String? description,
  }) {
    return OutageProbability(
      percent: percent ?? this.percent,
      level: level ?? this.level,
      label: label ?? this.label,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'OutageProbability('
        'percent: $percent, '
        'level: $level'
        ')';
  }
}