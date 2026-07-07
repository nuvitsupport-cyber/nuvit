class HourlyForecastPoint {
  final DateTime time;
  final double solarKw;
  final double windKw;
  final double hydroKw;

  const HourlyForecastPoint({
    required this.time,
    required this.solarKw,
    required this.windKw,
    required this.hydroKw,
  });

  // Сумма генерации всех источников за конкретный час
  double get totalKw => solarKw + windKw + hydroKw;
}

class SystemForecastSummary {
  final List<HourlyForecastPoint> hourlyPoints;
  final double totalSolarKwh;
  final double totalWindKwh;
  final double totalHydroKwh;

  const SystemForecastSummary({
    required this.hourlyPoints,
    required this.totalSolarKwh,
    required this.totalWindKwh,
    required this.totalHydroKwh,
  });

  // Общая прогнозируемая генерация всей системы за период
  double get totalGenerationKwh => totalSolarKwh + totalWindKwh + totalHydroKwh;
}