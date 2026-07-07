import 'dart:math' as math;
import '../utils/autonomy/ess_models.dart';
import '../utils/autonomy/ess_system_loader.dart';
import '../models/generation_forecast.dart';

class WeatherHourForecast {
  final DateTime dateTime;
  final double cloudCover;      
  final double windSpeed;       
  final double accumulatedRain; 
  final double accumulatedSnow; 
  final double temperatureC;    

  const WeatherHourForecast({
    required this.dateTime,
    required this.cloudCover,
    required this.windSpeed,
    required this.accumulatedRain,
    required this.accumulatedSnow,
    required this.temperatureC,
  });
}

class HybridForecastEngine {
  final double latitude;
  
  HybridForecastEngine({this.latitude = 49.0});

  // --- ОСНОВНОЙ МЕТОД РАСЧЕТА ---
  // Изменение 1: Вынесли начальное состояние бассейна во входные параметры (initialHydroCatchmentLevel)
  SystemForecastSummary calculate({
    required EssSystemSettings settings,
    required List<WeatherHourForecast> weatherData,
    double initialHydroCatchmentLevel = 20.0,
  }) {
    if (weatherData.isEmpty) {
      return const SystemForecastSummary(
        hourlyPoints: [],
        totalSolarKwh: 0.0,
        totalWindKwh: 0.0,
        totalHydroKwh: 0.0,
      );
    }

    final points = <HourlyForecastPoint>[];
    final invEfficiency = EssSystemLoader.averageInverterEfficiency(settings.inverters) / 100.0;
    double hydroCatchmentLevel = initialHydroCatchmentLevel;

    for (int i = 0; i < weatherData.length; i++) {
      final currentHourData = weatherData[i];

      // Изменение 2: Зафиксировали шаг симуляции гидрологии в 1 час при переменном шаге данных
      if (i == 0) {
        // Для самой первой точки выполняем один стандартный базовый шаг
        final double recentRainSum = _getRecentRainSum48h(weatherData, i);
        hydroCatchmentLevel = _updateHydroCatchment(
          currentLevel: hydroCatchmentLevel,
          hour: currentHourData,
          recentRainSum: recentRainSum,
        );
      } else {
        final prevHourData = weatherData[i - 1];
        final double hoursDiff = currentHourData.dateTime.difference(prevHourData.dateTime).inMinutes / 60.0;
        final int steps = hoursDiff.round();

        // Микро-цикл с фиксированным шагом симуляции в 1 час
        for (int step = 1; step <= steps; step++) {
          final double fraction = step / steps;
          
          // Интерполируем погодные метрики для промежуточного часа
          final interpolatedHour = _interpolateWeather(prevHourData, currentHourData, fraction);
          
          // Изменение 3: Считаем сумму осадков за последние 48 часов для текущего момента времени
          final double recentRainSum = _getRecentRainSum48h(weatherData, i);

          hydroCatchmentLevel = _updateHydroCatchment(
            currentLevel: hydroCatchmentLevel,
            hour: interpolatedHour,
            recentRainSum: recentRainSum,
          );
        }
      }

      // Расчет мгновенной генерации для результирующей точки прогноза
      final hourSolarKw = _calculateSolarHourly(settings.solarArrays, currentHourData) * invEfficiency;
      final hourWindKw = _calculateWindHourly(settings.windGenerators, currentHourData);
      final hourHydroKw = _calculateHydroHourly(settings.hydroStations, hydroCatchmentLevel);

      points.add(HourlyForecastPoint(
        time: currentHourData.dateTime,
        solarKw: hourSolarKw,
        windKw: hourWindKw,
        hydroKw: hourHydroKw,
      ));
    }

    // Интегрирование методом трапеций (оригинальная логика сохранения баланса энергии)
    double totalSolar = 0.0;
    double totalWind = 0.0;
    double totalHydro = 0.0;

    if (points.isNotEmpty) {
      if (points.length == 1) {
        totalSolar = points[0].solarKw * 3.0; 
        totalWind = points[0].windKw * 3.0;
        totalHydro = points[0].hydroKw * 3.0;
      } else {
        for (int i = 0; i < points.length - 1; i++) {
          final p1 = points[i];
          final p2 = points[i + 1];
          final double hoursDiff = p2.time.difference(p1.time).inMinutes / 60.0;

          totalSolar += (p1.solarKw + p2.solarKw) / 2.0 * hoursDiff;
          totalWind += (p1.windKw + p2.windKw) / 2.0 * hoursDiff;
          totalHydro += (p1.hydroKw + p2.hydroKw) / 2.0 * hoursDiff;
        }
      }
    }

    return SystemForecastSummary(
      hourlyPoints: points,
      totalSolarKwh: totalSolar,
      totalWindKwh: totalWind,
      totalHydroKwh: totalHydro,
    );
  }

  // --- МЕТОД ЛИНЕЙНОЙ ИНТЕРПОЛЯЦИИ ПОГОДЫ ---
  WeatherHourForecast _interpolateWeather(WeatherHourForecast w1, WeatherHourForecast w2, double fraction) {
    final totalMinutes = w2.dateTime.difference(w1.dateTime).inMinutes;
    final targetTime = w1.dateTime.add(Duration(minutes: (totalMinutes * fraction).round()));

    return WeatherHourForecast(
      dateTime: targetTime,
      cloudCover: w1.cloudCover + (w2.cloudCover - w1.cloudCover) * fraction,
      windSpeed: w1.windSpeed + (w2.windSpeed - w1.windSpeed) * fraction,
      accumulatedRain: w1.accumulatedRain + (w2.accumulatedRain - w1.accumulatedRain) * fraction,
      accumulatedSnow: w1.accumulatedSnow + (w2.accumulatedSnow - w1.accumulatedSnow) * fraction,
      temperatureC: w1.temperatureC + (w2.temperatureC - w1.temperatureC) * fraction,
    );
  }

  // --- МЕТОД ПОЛУЧЕНИЯ ИСТОРИЧЕСКИХ ОСАДКОВ ЗА 48 ЧАСОВ ---
  double _getRecentRainSum48h(List<WeatherHourForecast> weatherData, int currentIndex) {
    double sum = 0.0;
    final targetTime = weatherData[currentIndex].dateTime;
    final limitTime = targetTime.subtract(const Duration(hours: 48));

    // Проходим назад по массиву данных, пока укладываемся в окно 48 часов
    for (int j = currentIndex; j >= 0; j--) {
      if (weatherData[j].dateTime.isBefore(limitTime)) {
        break;
      }
      sum += weatherData[j].accumulatedRain;
    }
    return sum;
  }

  // --- МОДУЛЬ СОЛНЕЧНОЙ ГЕНЕРАЦИИ ---
  double _calculateSolarHourly(List<dynamic> arrays, WeatherHourForecast hour) {
    if (arrays.isEmpty) return 0.0;

    double psh = _getEffectiveSunHours(latitude, hour.dateTime);
    double baseFactor = _getHourlySunFactor(latitude, hour.dateTime, psh);

    if (baseFactor <= 0) return 0.0;

    double cloud = _getCloudFactor(hour.cloudCover);
    double rain = _getRainFactor(hour.accumulatedRain);
    
    double totalSolar = 0.0;
    for (var array in arrays) {
      double temp = _getTemperatureFactor(hour.temperatureC, baseFactor * cloud, hour.windSpeed);
      double snow = _getSnowFactor(hour.accumulatedSnow, array.tiltFactor);
      
      totalSolar += _calculateArrayEnergy(array, baseFactor, cloud, rain, snow, temp, hour.accumulatedSnow);
    }

    return totalSolar;
  }

  double _calculateArrayEnergy(
    dynamic array, 
    double baseFactor, 
    double cloud, 
    double rain, 
    double snowFactor, 
    double temp,
    double accumulatedSnow,
  ) {
    double baseEfficiency = array.orientationFactor * array.tiltFactor * array.shadingFactor * array.mountFactor * array.lifetimeFactor;
                             
    double currentAlbedoBonus = array.albedoBonus;

    if (accumulatedSnow > 0 && cloud > 0.15) {
      currentAlbedoBonus *= 3.0; 
    }

    double finalEfficiency;
    if (array.bifacial) {
      finalEfficiency = (baseEfficiency * snowFactor) + (currentAlbedoBonus * 0.1);
    } else {
      finalEfficiency = baseEfficiency * snowFactor;
    }

    return array.peakPowerKw * baseFactor * finalEfficiency * cloud * rain * temp;
  }

  // --- ЗИМНИЙ ФАКТОР (СНЕГ) ---
  double _getSnowFactor(double snowMm, double tiltFactor) {
    if (snowMm <= 0) return 1.0;
    
    double effectiveSnow = snowMm * tiltFactor; 

    if (effectiveSnow <= 0.5) return 1.0 - (effectiveSnow * 0.8); 
    return 0.0; 
  }

  // --- МОДУЛЬ ВЕТРОВОЙ ГЕНЕРАЦИИ ---
  double _calculateWindHourly(List<dynamic> windGenerators, WeatherHourForecast hour) {
    if (windGenerators.isEmpty) return 0.0;
    
    double hourWindKw = 0.0;
    final double temperatureKelvin = hour.temperatureC + 273.15;
    final double airDensity = 353.05 / temperatureKelvin;
    final double densityCorrectionFactor = airDensity / 1.225;
    
    // Переводимо швидкість вітру з км/год у м/с, оскільки крива _getWindCurveFactor працює з м/с.
    // Примітка: Якщо погодне API вже повертає значення в м/с, замініть на: final double speedMps = hour.windSpeed;
    final double speedMps = hour.windSpeed ;
    
    for (final wind in windGenerators) {
      if (wind == null) continue;

      double powerKw = 0.0;
      double capacityFactorFromUi = 0.0;
      double hubHeight = 10.0;
      double alpha = 0.143;

      if (wind is Map) {
        powerKw = (wind['powerKw'] as num?)?.toDouble() ?? 0.0;
        capacityFactorFromUi = (wind['capacityFactor'] as num?)?.toDouble() ?? 0.0;
        hubHeight = (wind['hubHeight'] as num?)?.toDouble() ?? 10.0;
        alpha = (wind['hellmannExponent'] as num?)?.toDouble() ?? 0.143;
      } else {
        try { powerKw = (wind.powerKw as num?)?.toDouble() ?? 0.0; } catch(_) {}
        try { capacityFactorFromUi = (wind.capacityFactor as num?)?.toDouble() ?? 0.0; } catch(_) {}
        try { hubHeight = (wind.hubHeight as num?)?.toDouble() ?? 10.0; } catch(_) {}
        try { alpha = (wind.hellmannExponent as num?)?.toDouble() ?? 0.143; } catch(_) {}
      }
      
      // Розрахунок швидкості вітру з урахуванням висоти щогли (за законом Хеллмана)
      double adjustedWindSpeed = speedMps * math.pow((hubHeight / 10.0), alpha);
      final windCurveFactor = _getWindCurveFactor(adjustedWindSpeed);
      
      // Трактуємо введене значення як ефективність системи (втрати в кабелях, ККД інвертора)
      // Переводимо відсотки у частки одиниці (наприклад, 30% -> 0.3). Якщо 0, ставимо базовий ККД 0.85
      final double efficiencyFactor = capacityFactorFromUi > 0 
          ? (capacityFactorFromUi / 100.0).clamp(0.0, 1.0) 
          : 0.85;
      
      // Підсумковий розрахунок: Номінал * Коефіцієнт кривої * ККД * Поправка на густину повітря
      hourWindKw += powerKw * windCurveFactor * efficiencyFactor * densityCorrectionFactor;
    }
    
    return hourWindKw;
  }

  // --- МОДУЛЬ ГИДРОГЕНЕРАЦИИ ---
  double _calculateHydroHourly(List<dynamic> hydroStations, double catchmentLevel) {
    if (hydroStations.isEmpty) return 0.0;

    double hourHydroKw = 0.0;
    final turbineMultiplier = _getHydroTurbineMultiplier(catchmentLevel);
    
    for (final hydro in hydroStations) {
      if (hydro == null) continue;
      
      double powerKw = 0.0;
      double capacityFactor = 0.75;

      if (hydro is Map) {
        powerKw = (hydro['powerKw'] as num?)?.toDouble() ?? 0.0;
        capacityFactor = (hydro['capacityFactor'] as num?)?.toDouble() ?? 0.75;
      } else {
        try { powerKw = (hydro.powerKw as num?)?.toDouble() ?? 0.0; } catch(_) {}
        try { capacityFactor = (hydro.capacityFactor as num?)?.toDouble() ?? 0.75; } catch(_) {}
      }

      hourHydroKw += powerKw * capacityFactor * turbineMultiplier;
    }
    
    return hourHydroKw;
  }

  /// Изменение 3 (интеграция): Обновляет уровень воды с учетом коэффициента насыщения почвы осадками
  double _updateHydroCatchment({
    required double currentLevel,
    required WeatherHourForecast hour,
    required double recentRainSum,
  }) {
    double effectiveRain = 0.0;
    double snowMelt = 0.0;

    if (hour.temperatureC > 0) {
      effectiveRain = hour.accumulatedRain;
      
      if (hour.accumulatedSnow > 0) {
        snowMelt = math.min(hour.accumulatedSnow, hour.temperatureC * 0.25);
      }
    } else {
      effectiveRain = 0.0;
      snowMelt = 0.0;
    }

    // Рассчитываем исторический множитель осадков (насыщение почвы)
    final double rainMultiplier = _getHydroRainMultiplier(recentRainSum);

    // Применяем множитель к притоку (влажная почва дает больший процент стока в реку)
    final double hourlyInflow = (effectiveRain + snowMelt) * rainMultiplier;

    double evaporationLoss = 0.0;
    if (hour.temperatureC > 20.0) {
      evaporationLoss = (hour.temperatureC - 20.0) * 0.04;
    }

    const double retentionFactor = 0.965; // Рассчитан ровно на 1 час
    
    double newLevel = (currentLevel * retentionFactor) + hourlyInflow - evaporationLoss;

    // Базовый уровень грунтовых вод также динамически увеличивается при сильных затяжных дождях
    final double dynamicBaseLevel = 4.0 * rainMultiplier;

    return math.max(dynamicBaseLevel, newLevel);
  }

  /// Физическая кривая КПД гидротурбины в зависимости от объема/давления потока
  double _getHydroTurbineMultiplier(double catchmentLevel) {
    const double nominalLevel = 20.0;  
    const double cutInLevel = 7.0;     
    const double maxDesignLevel = 45.0; 
    const double floodCritical = 75.0; 

    if (catchmentLevel < cutInLevel) {
      return 0.0; 
    }

    if (catchmentLevel < nominalLevel) {
      final double normalized = (catchmentLevel - cutInLevel) / (nominalLevel - cutInLevel);
      return math.pow(normalized, 1.5).toDouble(); 
    }

    if (catchmentLevel <= maxDesignLevel) {
      final double normalized = (catchmentLevel - nominalLevel) / (maxDesignLevel - nominalLevel);
      return 1.0 + (normalized * 0.25);
    }

    if (catchmentLevel <= floodCritical) {
      final double normalized = (catchmentLevel - maxDesignLevel) / (floodCritical - maxDesignLevel);
      return 1.25 - (normalized * 0.45); 
    }

    return 0.30; 
  }

  // --- АСТРОНОМИЧЕСКИЕ И МАТЕМАТИЧЕСКИЕ ФУНКЦИИ ---
  double _getEffectiveSunHours(double lat, DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final int dayOfYear = date.difference(startOfYear).inDays + 1;

    double declinationDeg = 23.45 * math.sin((360.0 / 365.0) * (dayOfYear - 81.0) * math.pi / 180.0);
    double declinationRad = declinationDeg * math.pi / 180.0;
    double latRad = lat * math.pi / 180.0;

    double tanLat = math.tan(latRad);
    double tanDecl = math.tan(declinationRad);
    double cosOmega = -tanLat * tanDecl;
    cosOmega = cosOmega.clamp(-1.0, 1.0); 
    double omega = math.acos(cosOmega);

    double daylightHours = (2.0 * omega * 180.0 / math.pi) / 15.0;

    double maxElevationDeg = 90.0 - (lat - declinationDeg).abs();
    double maxElevationRad = maxElevationDeg * math.pi / 180.0;

    double psh = daylightHours * math.sin(maxElevationRad) * 0.45;

    return psh.clamp(0.5, 8.0); 
  }

  double _getHourlySunFactor(double lat, DateTime date, double psh) {
    final startOfYear = DateTime(date.year, 1, 1);
    final int dayOfYear = date.difference(startOfYear).inDays + 1;

    double declinationDeg = 23.45 * math.sin((360.0 / 365.0) * (dayOfYear - 81.0) * math.pi / 180.0);
    double declinationRad = declinationDeg * math.pi / 180.0;
    double latRad = lat * math.pi / 180.0;

    double tanLat = math.tan(latRad);
    double tanDecl = math.tan(declinationRad);
    double cosOmega = -tanLat * tanDecl;
    cosOmega = cosOmega.clamp(-1.0, 1.0); 
    double omega = math.acos(cosOmega);

    double daylightHours = (2.0 * omega * 180.0 / math.pi) / 15.0;
    if (daylightHours <= 0) return 0.0; 

    double sunriseHour = 12.0 - (daylightHours / 2.0);
    double sunsetHour = 12.0 + (daylightHours / 2.0);
    double hourOfDay = date.hour.toDouble();

    if (hourOfDay >= sunriseHour && hourOfDay <= sunsetHour) {
      double progress = (hourOfDay - sunriseHour) / daylightHours;
      double peakPowerFactor = (psh * math.pi) / (2.0 * daylightHours);
      return peakPowerFactor * math.sin(progress * math.pi);
    }
    
    return 0.0;
  }

  double _getCloudFactor(double cloudiness) {
    if (cloudiness <= 0) return 1.0;
    if (cloudiness <= 20) return 1.0 - (cloudiness / 20.0) * 0.05;          
    if (cloudiness <= 40) return 0.95 - ((cloudiness - 20.0) / 20.0) * 0.15; 
    if (cloudiness <= 60) return 0.80 - ((cloudiness - 40.0) / 20.0) * 0.25; 
    if (cloudiness <= 80) return 0.55 - ((cloudiness - 60.0) / 20.0) * 0.30; 
    if (cloudiness <= 100) return 0.25 - ((cloudiness - 80.0) / 20.0) * 0.15;
    return 0.10;
  }

  double _getRainFactor(double rainMm) {
    if (rainMm <= 0) return 1.0;
    if (rainMm <= 2.0) return 1.0 - (rainMm / 2.0) * 0.08;          
    if (rainMm <= 5.0) return 0.92 - ((rainMm - 2.0) / 3.0) * 0.10; 
    if (rainMm <= 10.0) return 0.82 - ((rainMm - 5.0) / 5.0) * 0.17; 
    return 0.65 - ((rainMm - 10.0).clamp(0.0, 20.0) / 20.0) * 0.15; 
  }

  double _getTemperatureFactor(double ambientTempC, double sunIntensity, double windSpeed) {
    double panelTempC = ambientTempC + (sunIntensity * 25.0);
    double windCoolingEffect = windSpeed * 1.2; 
    panelTempC -= windCoolingEffect;
    panelTempC = math.max(ambientTempC, panelTempC);

    double tempDifference = panelTempC - 25.0;
    double factor = 1.0 - (tempDifference * 0.004); 
    return factor.clamp(0.70, 1.08); 
  }

  double _getWindCurveFactor(double speed) {
    const double cutIn = 2.0;
    const double rated = 11.5;
    const double stormStart = 23.0; 
    const double cutOut = 25.0; 

    if (speed < cutIn || speed > cutOut) return 0.0;
    if (speed >= rated && speed <= stormStart) return 1.0;
    
    if (speed > stormStart && speed <= cutOut) {
      return 1.0 - (speed - stormStart) / (cutOut - stormStart);
    }
    
    final double normalizedSpeed = (speed - cutIn) / (rated - cutIn);
    return math.pow(normalizedSpeed, 3).toDouble().clamp(0.0, 1.0);
  }

  // Скользящий исторический множитель интенсивности осадков
  double _getHydroRainMultiplier(double recentRainSum) {
    if (recentRainSum < 5.0) return 0.85; // Пересыхание грунта, слабая проточность
    if (recentRainSum > 50.0) return 1.20; // Высокая степень насыщения, паводок стока
    
    return 0.85 + ((recentRainSum - 5.0) / 45.0) * 0.35; 
  }
}