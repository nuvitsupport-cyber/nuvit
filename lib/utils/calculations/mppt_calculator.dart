class MpptCalculator {

  static double voltageMargin({
    required double maxVoltage,
    double currentVoltage = 350,
  }) {
    if (maxVoltage <= 0) {
      return 0;
    }

    return ((maxVoltage - currentVoltage) / maxVoltage) * 100;
  }

  static double realEfficiency({
    required double efficiency,
  }) {
    return efficiency;
  }

  static String overloadRisk({
    required double maxCurrent,
    required double strings,
  }) {
    final estimatedCurrent = strings * 15;

    if (estimatedCurrent < maxCurrent * 0.7) {
      return 'Низький';
    }

    if (estimatedCurrent < maxCurrent) {
      return 'Помірний';
    }

    return 'Високий';
  }

  /// Voc всього стрингу
  static double stringVoc({
    required double voc,
    required double seriesPanels,
  }) {
    return voc * seriesPanels;
  }

  /// Робоча напруга стрингу
  static double stringVmp({
    required double vmp,
    required double seriesPanels,
  }) {
    return vmp * seriesPanels;
  }

  /// Струм масиву
  static double arrayCurrent({
    required double imp,
    required double parallelStrings,
  }) {
    return imp * parallelStrings;
  }

  /// Потужність однієї панелі
  static double panelPower({
    required double vmp,
    required double imp,
  }) {
    return vmp * imp;
  }

  /// Потужність всього масиву
  static double arrayPower({
    required double vmp,
    required double imp,
    required double seriesPanels,
    required double parallelStrings,
  }) {
    return vmp *
        imp *
        seriesPanels *
        parallelStrings;
  }

  /// Перевірка напруги
  static bool voltageOk({
    required double maxVoltage,
    required double voc,
    required double seriesPanels,
  }) {
    return (voc * seriesPanels) <= maxVoltage;
  }

  /// Перевірка струму
  static bool currentOk({
    required double maxCurrent,
    required double imp,
    required double parallelStrings,
  }) {
    return (imp * parallelStrings) <= maxCurrent;
  }

  /// Статус сумісності
  static String compatibilityStatus({
    required double maxVoltage,
    required double maxCurrent,
    required double voc,
    required double imp,
    required double seriesPanels,
    required double parallelStrings,
  }) {

    if (voc <= 0 ||
        imp <= 0 ||
        seriesPanels <= 0 ||
        parallelStrings <= 0) {
      return 'ℹ Введіть параметри';
    }

    final voltageValid = voltageOk(
      maxVoltage: maxVoltage,
      voc: voc,
      seriesPanels: seriesPanels,
    );

    final currentValid = currentOk(
      maxCurrent: maxCurrent,
      imp: imp,
      parallelStrings: parallelStrings,
    );

    if (voltageValid && currentValid) {
      return '✅ Сумісно';
    }

    return '❌ Несумісно';
  }

  /// Попередження користувачу
  static String warningMessage({
    required double maxVoltage,
    required double maxCurrent,
    required double voc,
    required double imp,
    required double seriesPanels,
    required double parallelStrings,
  }) {

    if (voc <= 0 ||
        imp <= 0 ||
        seriesPanels <= 0 ||
        parallelStrings <= 0) {
      return '';
    }

    final double stringVoc =
        voc * seriesPanels;

    final double arrayCurrent =
        imp * parallelStrings;

    if (stringVoc > maxVoltage) {
      return '❌ Перевищено Max PV Voltage';
    }

    if (arrayCurrent > maxCurrent) {
      return '❌ Перевищено Max Current';
    }

    if (stringVoc > maxVoltage * 0.9) {
      return '⚠ Напруга близька до межі MPPT';
    }

    return '✅ Конфігурація коректна';
  }
}