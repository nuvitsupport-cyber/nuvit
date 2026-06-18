class MeterCalculator {

  static double calculateInstantPower({
    required double voltage,
    required double current,
  }) {
    return (voltage * current) / 1000;
  }

  static double calculateDailyImport({
    required double importedEnergy,
  }) {
    return importedEnergy;
  }

  static double calculateDailyExport({
    required double exportedEnergy,
  }) {
    return exportedEnergy;
  }

  static double calculateEnergyBalance({
    required double importedEnergy,
    required double exportedEnergy,
  }) {
    return importedEnergy - exportedEnergy;
  }
}