// lib/utils/autonomy/solar_math_engine.dart

import 'dart:math' as math;

class SolarMathEngine {
  /// Перевод градусов в радианы
  static double _toRadians(double degrees) => degrees * math.pi / 180.0;

  /// Рассчитывает мгновенную солнечную генерацию массива СЕС на основе
  /// точных гео-координат, времени, параметров панелей и погодных факторов.
  static double calculateInstantPower({
    required DateTime time,
    required double latitude,
    required double longitude,
    required double panelTiltDegrees,      // Угол наклона панелей (например, 30)
    required double panelAzimuthDegrees,   // Азимут панелей (0 = Юг, -90 = Восток, 90 = Запад)
    required double peakPowerWatts,        // Пиковая мощность стринга в Вт
    required double cloudiness,            // 0.0 - 100.0
    required double rainMm,
    required double ambientTemp,
    double mpptEfficiency = 0.98,          // КПД контроллера заряда (97-99%)
    double inverterEfficiency = 0.96,      // КПД инвертора
  }) {
    // 1. Расчет дня в году (Day of Year)
    final int dayOfYear = _getDayOfYear(time);

    // 2. Угол склонения Солнца (Solar Declination Angle) в радианы
    // Наклон земной оси меняется от -23.45° до +23.45° в течение года
    final double declination = 0.409 * math.sin((2 * math.pi / 365) * (dayOfYear - 80));

    // 3. Часовой угол Солнца (Hour Angle)
    // 12:00 по солнечному времени = 0 радианов. Каждый час перемещает солнце на 15°
    final double solarHour = time.hour + (time.minute / 60.0) + (time.second / 3600.0);
    // Упрощенная коррекция меридиана (можно расширить уравнением времени)
    final double hourAngle = _toRadians((solarHour - 12.0) * 15.0);

    final double latRad = _toRadians(latitude);

    // 4. Высота солнца над горизонтом (Solar Elevation / Altitude Angle)
    final double sinElevation = math.sin(latRad) * math.sin(declination) +
        math.cos(latRad) * math.cos(declination) * math.cos(hourAngle);
    
    // Если солнце ниже горизонта — генерации нет
    if (sinElevation <= 0) return 0.0;
    
    final double elevation = math.asin(sinElevation);

    // 5. Азимут солнца (Solar Azimuth Angle)
    double cosAzimuth = (math.sin(declination) * math.cos(latRad) -
            math.cos(declination) * math.sin(latRad) * math.cos(hourAngle)) /
        math.cos(elevation);
    cosAzimuth = cosAzimuth.clamp(-1.0, 1.0);
    
    double sunAzimuth = math.acos(cosAzimuth);
    if (hourAngle > 0) {
      sunAzimuth = 2 * math.pi - sunAzimuth; // Коррекция для второй половины дня
    }

    // 6. Динамический расчет угла падения лучей на плоскость панели
    final double tiltRad = _toRadians(panelTiltDegrees);
    // Приводим азимут панелей к стандартной системе (0 = Юг)
    final double panelAzimuthRad = _toRadians(panelAzimuthDegrees); 

    // Главное уравнение трехмерной инсоляции
    double cosTheta = (math.sin(elevation) * math.cos(tiltRad)) +
        (math.cos(elevation) * math.sin(tiltRad) * math.cos(sunAzimuth - panelAzimuthRad));

    if (cosTheta <= 0) return 0.0; // Солнце зашло за плоскость трекера

    // 7. Погодное ослабление (Атмосферная масса + Облака)
    // Базовая интенсивность AM1.5 Чистого неба (~1000 Вт/м²)
    double airMass = 1.0 / math.max(sinElevation, 0.01);
    double clearSkyFactor = math.pow(0.7, math.pow(airMass, 0.678)).toDouble();

    double cloudFactor = _getCloudFactor(cloudiness);
    double rainFactor = _getRainFactor(rainMm);
    double tempFactor = _getTemperatureFactor(ambientTemp, cosTheta * clearSkyFactor);

    // 8. Финальный сбор цепочки преобразования энергии (с учетом MPPT)
    double generatedPower = peakPowerWatts *
        cosTheta *
        clearSkyFactor *
        cloudFactor *
        rainFactor *
        tempFactor *
        mpptEfficiency *
        inverterEfficiency;

    return generatedPower.clamp(0.0, peakPowerWatts);
  }

  static int _getDayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  static double _getCloudFactor(double cloudiness) {
    if (cloudiness <= 0) return 1.0;
    if (cloudiness <= 20) return 1.0 - (cloudiness / 20.0) * 0.05;
    if (cloudiness <= 40) return 0.95 - ((cloudiness - 20.0) / 20.0) * 0.15;
    if (cloudiness <= 60) return 0.80 - ((cloudiness - 40.0) / 20.0) * 0.25;
    if (cloudiness <= 80) return 0.55 - ((cloudiness - 60.0) / 20.0) * 0.30;
    return (0.25 - ((cloudiness - 80.0) / 20.0) * 0.15).clamp(0.05, 1.0);
  }

  static double _getRainFactor(double rainMm) {
    if (rainMm <= 0) return 1.0;
    if (rainMm <= 2.0) return 1.0 - (rainMm / 2.0) * 0.08;
    if (rainMm <= 5.0) return 0.92 - ((rainMm - 2.0) / 3.0) * 0.10;
    return (0.82 - ((rainMm - 5.0) / 5.0) * 0.17).clamp(0.40, 1.0);
  }

  static double _getTemperatureFactor(double ambientTempC, double sunIntensity) {
    double panelTempC = ambientTempC + (sunIntensity * 25.0);
    double tempDifference = panelTempC - 25.0;
    return (1.0 - (tempDifference * 0.004)).clamp(0.65, 1.08);
  }
}