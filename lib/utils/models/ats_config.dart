// lib/utils/models/ats_config.dart

class ATSConfig {
  final double minVoltage;
  final double maxVoltage;
  final double minFrequency;
  final double maxFrequency;
  final int transferTimeMs;
  final String priorityScheme;

  ATSConfig({
    required this.minVoltage,
    required this.maxVoltage,
    required this.minFrequency,
    required this.maxFrequency,
    required this.transferTimeMs,
    required this.priorityScheme,
  });

  // Простая сериализация без JSON
  factory ATSConfig.fromMap(Map<String, dynamic> map) {
    return ATSConfig(
      minVoltage: map['minVoltage'] ?? 190.0,
      maxVoltage: map['maxVoltage'] ?? 255.0,
      minFrequency: map['minFrequency'] ?? 49.0,
      maxFrequency: map['maxFrequency'] ?? 51.0,
      transferTimeMs: map['transferTimeMs'] ?? 10,
      priorityScheme: map['priorityScheme'] ?? 'Мережа → АКБ → Генератор',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minVoltage': minVoltage,
      'maxVoltage': maxVoltage,
      'minFrequency': minFrequency,
      'maxFrequency': maxFrequency,
      'transferTimeMs': transferTimeMs,
      'priorityScheme': priorityScheme,
    };
  }
}