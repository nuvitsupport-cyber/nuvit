// lib/utils/calculations/autonomy_calculator.dart

import '../../models/device_model.dart';

class AutonomyCalculator {
  /// Рахує чисте навантаження від увімкнених приладів
  static int calculateActiveLoad(List<DeviceModel> devices) {
    return devices
        .where((device) => device.enabled)
        .fold(0, (sum, device) => sum + device.watts);
  }

  /// Головний метод розрахунку годин автономності з урахуванням нових реалістичних факторів
  static double calculateAutonomyHours({
    required int batteryCapacity,        // Загальна ємність (Wh)
    required double batteryHealth,       // Здоров'я АКБ (SoH %)
    required int currentSoC,             // Поточний заряд (SoC %)
    required int currentDoD,             // Глибина розряду (DoD %)
    required int activeLoad,             // Навантаження від приладів (W)
    required bool isInverterOn,          // Чи увімкнено інвертор в діагностиці
  }) {
    if (batteryCapacity <= 0) return 0.0;

    // 1. Визначаємо ліміт безпечного розряду (мінімальний % заряду, який треба залишити)
    // Наприклад, якщо DoD = 80%, то мінімальний поріг = 20%
    final int minAllowedSoC = 100 - currentDoD;

    // Якщо поточний заряд уже на рівні або нижче ліміту безпеки — автономності немає
    if (currentSoC <= minAllowedSoC) return 0.0;

    // 2. Рахуємо відсоток ємності, який реально можна використати прямо зараз
    final double usableSoCPercent = (currentSoC - minAllowedSoC) / 100.0;

    // 3. Рахуємо реальну доступну енергію в Вт·год з урахуванням деградації (SoH) та ККД інвертора (90%)
    const double inverterEff = 0.90; 
    final double realAvailableEnergyWh = batteryCapacity * (batteryHealth / 100.0) * usableSoCPercent * inverterEff;

    // 4. Враховуємо власне споживання інвертора на холостому ходу
    // Якщо інвертор активний, він «їсть» ~25 Вт постійно, навіть якщо навантаження 0
    final int inverterIdleLoss = isInverterOn ? 25 : 0;
    final int totalLoad = activeLoad + inverterIdleLoss;

    if (totalLoad <= 0) return 0.0;

    return realAvailableEnergyWh / totalLoad;
  }

  /// Форматування виводу часу для користувача
  static String formatAutonomy({
    required double hours,
    required bool isEmptyBattery,
    required bool isStandby,
    int currentSoC = 100,
    int currentDoD = 100,
  }) {
    if (isEmptyBattery) return '00г 00хв';
    
    final int minAllowedSoC = 100 - currentDoD;
    if (currentSoC <= minAllowedSoC) {
      return 'АКБ РОЗРЯДЖЕНО'; // Повідомлення, якщо впали за ліміт безпеки
    }

    if (isStandby && hours == 0.0) return 'НЕСКІНЧЕННО';

    final int h = hours.floor();
    final int m = ((hours - h) * 60).round();
    
    String hoursStr = h < 10 ? '0$h' : '$h';
    String minsStr = m < 10 ? '0$m' : '$m';
    
    return '${hoursStr}г ${minsStr}хв';
  }
}