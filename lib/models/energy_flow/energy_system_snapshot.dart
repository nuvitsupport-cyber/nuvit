// lib/models/energy_flow/energy_system_snapshot.dart

class EnergySystemSnapshot {
  // === Нагрузка (Load) ===
  final double houseLoadWatts;

  // === Генерация (Generation) ===
  final double solarGenerationWatts;
  final double windPowerWatts;
  final double hydroPowerWatts;

  // === Батарея (Battery ESS) ===
  final double batterySocPercent;
  final double batteryPowerWatts; // > 0: Разряд (Discharge), < 0: Заряд (Charge)
  final double batteryChargeLimitWatts;
  final double batteryDischargeLimitWatts;

  // === Внешняя сеть (Grid) ===
  final bool isGridAvailable;
  final double gridPowerWatts; // > 0: Берем из сети (Import), < 0: Отдаем в сеть (Export)
  final double gridImportLimitWatts;
  final double gridExportLimitWatts;

  // === Генератор (Generator) ===
  final bool isGeneratorRunning;
  final double generatorPowerWatts;
  final double generatorMaxPowerWatts;

  // === Дополнительные источники ===
  final double portableStationWatts; // > 0: Разряд, < 0: Заряд
  final double evBackupWatts;        // V2G / V2H / V2L

  // === Контекст (Environment) ===
  final DateTime timestamp;
  final WeatherData weather; // Можно вынести в отдельный класс
final List<ForecastPoint> forecast;
  const EnergySystemSnapshot({
    required this.houseLoadWatts,
    required this.solarGenerationWatts,
    this.windPowerWatts = 0.0,
    this.hydroPowerWatts = 0.0,
    required this.batterySocPercent,
    required this.batteryPowerWatts,
    required this.batteryChargeLimitWatts,
    required this.batteryDischargeLimitWatts,
    required this.isGridAvailable,
    this.gridPowerWatts = 0.0,
    required this.gridImportLimitWatts,
    required this.gridExportLimitWatts,
    required this.isGeneratorRunning,
    required this.generatorPowerWatts,
    required this.generatorMaxPowerWatts,
    this.portableStationWatts = 0.0,
    this.evBackupWatts = 0.0,
    required this.timestamp,
    required this.weather,
    this.forecast = const [],
  });

  // Удобный геттер для понимания баланса системы
  double get energyBalanceWatts => 
      (solarGenerationWatts + windPowerWatts + hydroPowerWatts + generatorPowerWatts) - houseLoadWatts;
}
class ForecastPoint {
  final DateTime time;
  final double expectedSolarGenerationWatts;
  final double expectedCloudiness;

  const ForecastPoint({
    required this.time,
    required this.expectedSolarGenerationWatts,
    required this.expectedCloudiness,
  });
}
class WeatherData {
  final double ambientTemp;
  final double cloudiness;
  final double rainMm;

  const WeatherData({
    required this.ambientTemp,
    required this.cloudiness,
    required this.rainMm,
  });
}