class GeneratorCalculator {

  static double hoursFromTank({
    required double tankVolume,
    required double consumption,
  }) {
    if (consumption <= 0) {
      return 0;
    }

    return tankVolume / consumption;
  }

  static double costPerKwh({
    required double generatorPower,
    required double fuelConsumption,
    required double fuelPrice,
  }) {
    if (generatorPower <= 0 || fuelConsumption <= 0) {
      return 0;
    }

    return (fuelConsumption / generatorPower) * fuelPrice;
  }
static double fuelPerDay({
  required double consumption,
  required double hoursPerDay,
}) {
  return consumption * hoursPerDay;
}
static double fuelPerMonth({
  required double consumption,
  required double hoursPerDay,
}) {
  return consumption * hoursPerDay * 30;
}
static double monthlyFuelCost({
  required double consumption,
  required double hoursPerDay,
  required double fuelPrice,
}) {
  return consumption *
      hoursPerDay *
      30 *
      fuelPrice;
}
static double autonomyWithReserve({
  required double tankVolume,
  required double reserveFuel,
  required double consumption,
}) {
  if (consumption <= 0) return 0;

  return (tankVolume + reserveFuel) /
      consumption;
}
static double engineLifeDays({
  required double resourceHours,
  required double hoursPerDay,
}) {
  if (hoursPerDay <= 0) return 0;

  return resourceHours / hoursPerDay;
}
}