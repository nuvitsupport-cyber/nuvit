/// Настройки модуля графика відключень.
///
/// Хранит пользовательские параметры:
/// • область;
/// • город;
/// • источник данных;
/// • автообновление;
/// • уведомления.
class OutageSettings {
  /// Область.
  final String region;

  /// Город.
  final String city;

  /// Источник данных.
  ///
  /// Например:
  /// "mock"
  /// "dtek"
  /// "ukrenergo"
  final String provider;

  /// Автоматическое обновление.
  final bool autoRefresh;

  /// Интервал обновления.
  final Duration refreshInterval;

  /// Показывать AI рекомендации.
  final bool enableInsights;

  /// Показывать уведомления.
  final bool enableNotifications;

  const OutageSettings({
    required this.region,
    required this.city,
    required this.provider,
    this.autoRefresh = true,
    this.refreshInterval = const Duration(minutes: 30),
    this.enableInsights = true,
    this.enableNotifications = true,
  });

  /// Настройки по умолчанию.
  factory OutageSettings.defaultSettings() {
    return const OutageSettings(
      region: '',
      city: 'Київ',
      provider: 'mock',
    );
  }

  OutageSettings copyWith({
    String? region,
    String? city,
    String? provider,
    bool? autoRefresh,
    Duration? refreshInterval,
    bool? enableInsights,
    bool? enableNotifications,
  }) {
    return OutageSettings(
      region: region ?? this.region,
      city: city ?? this.city,
      provider: provider ?? this.provider,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      enableInsights: enableInsights ?? this.enableInsights,
      enableNotifications:
          enableNotifications ?? this.enableNotifications,
    );
  }

  @override
  String toString() {
    return '''
OutageSettings(
  region: $region,
  city: $city,
  provider: $provider,
  autoRefresh: $autoRefresh,
  refreshInterval: ${refreshInterval.inMinutes} min,
  enableInsights: $enableInsights,
  enableNotifications: $enableNotifications
)
''';
  }
}