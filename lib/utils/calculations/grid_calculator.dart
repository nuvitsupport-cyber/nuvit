class GridCalculator {

  static double nightChargeCost({
    required double batteryKwh,
    required double nightTariff,
  }) {
    return batteryKwh * nightTariff;
  }

  static double nightSaving({
    required double batteryKwh,
    required double dayTariff,
    required double nightTariff,
  }) {
    return batteryKwh * (dayTariff - nightTariff);
  }

  static double gridCoverage({
    required double blackoutHoursPerDay,
  }) {
    final blackoutFactor =
        (24 - blackoutHoursPerDay) / 24;

    return blackoutFactor * 100;
  }

}