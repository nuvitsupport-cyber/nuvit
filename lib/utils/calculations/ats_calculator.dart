class AtsCalculator {

  /// Прогноз автономності
  static double calculateAutonomy({
    required double batteryCapacityAh,
    required double batteryVoltage,
    required int batteryCount,
    required double averageLoad,
  }) {
    if (averageLoad <= 0) return 0;

    final batteryEnergy =
        batteryCapacityAh *
        batteryVoltage *
        batteryCount /
        1000;

    return batteryEnergy / averageLoad;
  }

  /// Запуск генератора
  static bool shouldStartGenerator({
    required double currentSoc,
    required double startSoc,
  }) {
    return currentSoc <= startSoc;
  }

  /// Зупинка генератора
  static bool shouldStopGenerator({
    required double currentSoc,
    required double stopSoc,
  }) {
    return currentSoc >= stopSoc;
  }

  /// Перехід на резерв
  static bool shouldSwitchToBackup({
    required double gridVoltage,
    required double minVoltage,
    required double maxVoltage,
    required double frequency,
    required double minFrequency,
    required double maxFrequency,
  }) {
    return gridVoltage < minVoltage ||
        gridVoltage > maxVoltage ||
        frequency < minFrequency ||
        frequency > maxFrequency;
  }

  /// Якість мережі
  static double calculateProtectionSensitivity({
  required double minVoltage,
  required double maxVoltage,
}) {
  final range = maxVoltage - minVoltage;

  double score =
      100 - ((range - 50) * 1.5);

  return score.clamp(0, 100);
}

  /// Надійність АВР
  static double calculateReliability({
    required bool autoTest,
    required bool remoteControl,
    required String phaseMonitoring,
  }) {
    double score = 70;

    if (autoTest) score += 15;

    if (remoteControl) score += 10;

    if (phaseMonitoring == 'Усі фази') {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  /// Опис логіки АВР
  static String getLogicDescription({
    required String priority,
    required String backupSource,
    required String transferTime,
  }) {
    return '$priority'
        '\nРезерв: $backupSource'
        '\nЧас: $transferTime мс';
  }

  /// Вибраний сценарій
  static String getScenario({
    required String prioritySource,
  }) {
    return prioritySource;
  }
   /// Готовність АВР до роботи
static bool isConfigured({
  required String transferTime,
  required String minVoltage,
  required String maxVoltage,
  required String minFrequency,
  required String maxFrequency,
  required String backupSource,
}) {
  return transferTime.isNotEmpty &&
      minVoltage.isNotEmpty &&
      maxVoltage.isNotEmpty &&
      minFrequency.isNotEmpty &&
      maxFrequency.isNotEmpty &&
      backupSource.isNotEmpty;
}
}