import 'dart:math' as math;

class WindMathEngine {
  /// Розраховує миттєву потужність вітрогенератора (у Ватах) 
  /// на основі швидкості вітру та номінальної потужності турбіни.
  static double calculateInstantPower({
    required double windSpeedMs,
    required double nominalPowerKw,
  }) {
    // Стандартні індустріальні константи для малих вітряків (Residential Wind Turbines)
    const double cutInSpeed = 3.0;   // Мінімальна швидкість для старту (м/с)
    const double ratedSpeed = 11.0;  // Швидкість виходу на номінальну потужність (м/с)
    const double cutOutSpeed = 25.0; // Швидкість аварійного гальмування (м/с)

    // Якщо вітру недостатньо для розкручування, або він ураганний (спрацював захист)
    if (windSpeedMs < cutInSpeed || windSpeedMs >= cutOutSpeed) {
      return 0.0;
    }

    // Якщо вітер в ідеальній зоні, видаємо номінал
    if (windSpeedMs >= ratedSpeed) {
      return nominalPowerKw * 1000.0;
    }

    // Кубічна інтерполяція для перехідної зони (від 3 до 11 м/с)
    // Оскільки енергія вітру пропорційна кубу швидкості
    double factor = (math.pow(windSpeedMs, 3) - math.pow(cutInSpeed, 3)) /
                    (math.pow(ratedSpeed, 3) - math.pow(cutInSpeed, 3));

    return (nominalPowerKw * 1000.0) * factor.clamp(0.0, 1.0);
  }
}