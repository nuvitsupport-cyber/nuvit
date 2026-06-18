// lib/models/device_model.dart

/// Модель пристрою для системи NUVIT.
/// Зберігає стан приладу, його енергоспоживання, категорію та пріоритет важливості.
class DeviceModel {
  final String name;
  final int watts;
  final bool enabled;
  final String category;
  final int priority;

  DeviceModel({
    required this.name,
    required this.watts,
    required this.enabled,
    required this.category,
    required this.priority,
  });

  /// Створення копії пристрою з оновленими полями (забезпечує імутабельність стану)
  DeviceModel copyWith({
    String? name,
    int? watts,
    bool? enabled,
    String? category,
    int? priority,
  }) {
    return DeviceModel(
      name: name ?? this.name,
      watts: watts ?? this.watts,
      enabled: enabled ?? this.enabled,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  /// Серіалізація в JSON (для збереження через SharedPreferences у StorageService)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'watts': watts,
      'enabled': enabled,
      'category': category,
      'priority': priority,
    };
  }

  /// Десеріалізація з JSON (для завантаження профілю в додаток)
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      name: json['name'] as String,
      watts: json['watts'] as int,
      enabled: json['enabled'] as bool,
      category: json['category'] as String,
      priority: json['priority'] as int,
    );
  }
}