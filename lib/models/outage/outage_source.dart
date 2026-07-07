/// Тип источника данных.
enum OutageSourceType {
  /// Тестовые данные.
  mock,

  /// API ДТЕК.
  dtek,

  /// API Укренерго.
  ukrenergo,

  /// Пользовательские данные.
  manual,

  /// Другой внешний API.
  external,
}

/// Информация об источнике данных.
class OutageSource {
  /// Тип источника.
  final OutageSourceType type;

  /// Название.
  ///
  /// Например:
  /// "ДТЕК"
  /// "Укренерго"
  /// "Mock Data"
  final String name;

  /// Последнее обновление.
  final DateTime lastUpdated;

  /// Доступен ли источник.
  final bool isAvailable;

  const OutageSource({
    required this.type,
    required this.name,
    required this.lastUpdated,
    this.isAvailable = true,
  });

  /// Тестовый источник.
  factory OutageSource.mock() {
    return OutageSource(
      type: OutageSourceType.mock,
      name: 'Mock Data',
      lastUpdated: DateTime.now(),
    );
  }

  /// ДТЕК.
  factory OutageSource.dtek() {
    return OutageSource(
      type: OutageSourceType.dtek,
      name: 'ДТЕК',
      lastUpdated: DateTime.now(),
    );
  }

  /// Укренерго.
  factory OutageSource.ukrenergo() {
    return OutageSource(
      type: OutageSourceType.ukrenergo,
      name: 'Укренерго',
      lastUpdated: DateTime.now(),
    );
  }

  /// Время с момента последнего обновления.
  Duration get age =>
      DateTime.now().difference(lastUpdated);

  /// Источник устарел?
  bool get isExpired =>
      age.inMinutes > 60;

  OutageSource copyWith({
    OutageSourceType? type,
    String? name,
    DateTime? lastUpdated,
    bool? isAvailable,
  }) {
    return OutageSource(
      type: type ?? this.type,
      name: name ?? this.name,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  String toString() {
    return 'OutageSource('
        'type: $type, '
        'name: $name, '
        'lastUpdated: $lastUpdated, '
        'isAvailable: $isAvailable'
        ')';
  }
}