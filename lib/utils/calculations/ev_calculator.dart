class EvCalculator {

  static double chargeHours({
    required double capacity,
    required double power,
  }) {
    if (power <= 0) return 0;

    return capacity / power;
  }

  static double availableHomeEnergy({
    required double capacity,
    required double reservedSoc,
  }) {
    return capacity * (100 - reservedSoc) / 100;
  }

  static double fullChargeCost({
    required double capacity,
    required double tariff,
  }) {
    return capacity * tariff;
  }

}