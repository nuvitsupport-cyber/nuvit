/// Тип AI-рекомендации.
enum OutageInsightType {
  /// Общая информация.
  info,

  /// Рекомендация.
  recommendation,

  /// Предупреждение.
  warning,

  /// Критическое уведомление.
  critical,
}

/// AI-инсайт или рекомендация.
///
/// Примеры:
///
/// • Зарядіть АКБ до 90%
/// • Перенесіть запуск пральної машини на 22:00
/// • Очікується тривале відключення
/// • Сьогодні сонячна генерація компенсує вечірнє споживання
class OutageInsight {
  /// Тип сообщения.
  final OutageInsightType type;

  /// Заголовок.
  final String title;

  /// Основной текст.
  final String message;

  /// Насколько рекомендация важна.
  ///
  /// От 0 до 100.
  final int priority;

  /// Время создания.
  final DateTime createdAt;

  const OutageInsight({
    required this.type,
    required this.title,
    required this.message,
    this.priority = 50,
    required this.createdAt,
  });

  /// Низкий приоритет.
  bool get isLowPriority => priority < 30;

  /// Средний приоритет.
  bool get isMediumPriority =>
      priority >= 30 && priority < 70;

  /// Высокий приоритет.
  bool get isHighPriority => priority >= 70;

  /// Критическое сообщение.
  bool get isCritical =>
      type == OutageInsightType.critical;

  OutageInsight copyWith({
    OutageInsightType? type,
    String? title,
    String? message,
    int? priority,
    DateTime? createdAt,
  }) {
    return OutageInsight(
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'OutageInsight('
        'type: $type, '
        'priority: $priority, '
        'title: $title'
        ')';
  }
}