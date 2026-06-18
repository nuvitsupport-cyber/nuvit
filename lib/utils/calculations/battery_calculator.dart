import '../app_constants.dart';

class BatteryCalculator {
  // Расчет текущего здоровья батареи (SoH) на основе пройденных циклов
  static double calculateBatteryHealth({
    required String batteryType,
    required double cycleCount,
  }) {
    final int maxCycles = AppConstants.batteryMaxCycles[batteryType] ?? 500;
    if (cycleCount <= 0) return 100.0;
    if (cycleCount >= maxCycles) return 0.0;

    // Линейный износ (при желании сюда можно внедрить нелинейную экспоненту деградации LFP)
    final double health = 100.0 - ((cycleCount / maxCycles) * 100.0);
    return double.parse(health.toStringAsFixed(1));
  }

  // Прогноз оставшегося срока службы АКБ в годах
  static double calculateRemainingYears({
    required String batteryType,
    required double cycleCount,
    required double dailyDepthOfDischarge,
  }) {
    final int maxCycles = AppConstants.batteryMaxCycles[batteryType] ?? 500;
    final double remainingCycles = maxCycles - cycleCount;
    if (remainingCycles <= 0) return 0.0;

    // Коэффициент жесткости эксплуатации (глубокий разряд быстрее убивает АКБ)
    double dodFactor = 1.0;
    if (dailyDepthOfDischarge > 80) {
      dodFactor = 1.5; // Свинец и Гель умирают на 50% быстрее при разряде в ноль
    } else if (dailyDepthOfDischarge < 30) {
      dodFactor = 0.7; // Щадящий режим продлевает жизнь
    }

    // Сколько циклов в таком темпе АКБ проживет в днях
    final double expectedDays = remainingCycles / (dodFactor * (dailyDepthOfDischarge / 100.0));
    final double years = expectedDays / 365.0;
    
    return double.parse(years.toStringAsFixed(1));
  }

// ==========================================
  // Перенесено из connect_equipment_page.dart
  // ==========================================

  static double calculateUsableCapacity({
    required double capacity,
    required double voltage,
    required double count,
    required double dod,
    required double reserveSoc,
    required bool isPowerStation,
  }) {
    double totalKwh;

    if (isPowerStation) {
      totalKwh = capacity * count;
    } else {
      totalKwh = (capacity * voltage * count) / 1000;
    }

    final usable =
        totalKwh * ((dod - reserveSoc) / 100);

    return usable < 0 ? 0 : usable;
  }

  static double calculateTotalCapacity({
    required double capacity,
    required double voltage,
    required double count,
    required bool isPowerStation,
  }) {
    if (isPowerStation) {
      return capacity * count;
    }

    return (capacity * voltage * count) / 1000;
  }

  static int calculateBatteryCycles(
    String batteryType,
  ) {
    switch (batteryType) {
      case 'LiFePO4 (LFP)':
        return 6000;

      case 'LTO (Титанат)':
        return 15000;

      case 'Li-Ion (NMC)':
        return 3000;

      default:
        return 1000;
    }
  }

  static double calculateBatteryYears(
    String batteryType,
  ) {
    switch (batteryType) {
      case 'LiFePO4 (LFP)':
        return 17;

      case 'LTO (Титанат)':
        return 25;

      case 'Li-Ion (NMC)':
        return 10;

      default:
        return 5;
    }
  }
  static double calculatePortableAutonomy({
  required double capacityKwh,
  required double loadW,
}) {
  if (capacityKwh <= 0 || loadW <= 0) {
    return 0;
  }

  return capacityKwh / (loadW / 1000);
}
static double portableLifetimeEnergy({
  required double capacityKwh,
  required double cycles,
}) {
  return capacityKwh * cycles;
}
static double portableLifetimeYears({
  required double cycles,
  double cyclesPerDay = 1,
}) {
  if (cyclesPerDay <= 0) return 0;

  return cycles / cyclesPerDay / 365;
}
}
// ==========================================
// Portable ESS
// ==========================================

