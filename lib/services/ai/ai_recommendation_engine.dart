import 'package:flutter/material.dart';
import '../../utils/autonomy/ess_models.dart';
import '../../models/generation_forecast.dart';
import '../hybrid_forecast_engine.dart';

/// Рівні важливості для гнучкого налаштування UI
enum AiRecommendationSeverity {
  info,
  success,
  warning,
  critical,
}

/// Розширена модель даних рекомендації, що повертає структуровану аналітику
class AiRecommendation {
  final String title;
  final String message;
  final AiRecommendationSeverity severity;
  final IconData icon;

  // Аналітичні метрики для побудови деталізованого UI
  final double idealGenerationKwh;
  final double expectedGenerationKwh;
  final double lossesKwh;
  final Map<String, int> sourceShares; // Наприклад: {'solar': 65, 'wind': 25, 'hydro': 10}
  final List<String> lossReasons;
  final String? peakSolarInterval;
  final String? peakWindInterval;

  const AiRecommendation({
    required this.title,
    required this.message,
    required this.severity,
    required this.icon,
    this.idealGenerationKwh = 0.0,
    this.expectedGenerationKwh = 0.0,
    this.lossesKwh = 0.0,
    this.sourceShares = const {},
    this.lossReasons = const [],
    this.peakSolarInterval,
    this.peakWindInterval,
  });

  Color getColor(Color defaultNeon) {
    switch (severity) {
      case AiRecommendationSeverity.success:
        return defaultNeon;
      case AiRecommendationSeverity.warning:
        return Colors.orangeAccent;
      case AiRecommendationSeverity.critical:
        return Colors.redAccent;
      case AiRecommendationSeverity.info:
        return Colors.blueAccent;
    }
  }
}

class AiRecommendationEngine {
  final double latitude;

  AiRecommendationEngine({this.latitude = 49.0});

  AiRecommendation generate({
    required EssSystemSettings? settings,
    required SystemForecastSummary? todaySummary,
    required double cloudiness,
    required double rainMm,
    required double snowMm,
    required double windSpeed,
    required double tempC,
    required DateTime todayDate,
  }) {
    // 1. Перевірка складу системи
    if (settings == null) {
      return const AiRecommendation(
        title: 'Систему не налаштовано',
        message: 'Конфігурація обладнання відсутня у вашому профілі Nuvit. Будь ласка, додайте генеруючі пристрої.',
        severity: AiRecommendationSeverity.warning,
        icon: Icons.settings_suggest_rounded,
      );
    }

    final bool hasSolar = settings.solarArrays.isNotEmpty;
    final bool hasWind = settings.windGenerators.isNotEmpty;
    final bool hasHydro = settings.hydroStations.isNotEmpty;

    if (!hasSolar && !hasWind && !hasHydro) {
      return const AiRecommendation(
        title: 'Джерела енергії відсутні',
        message: 'У вашій системі не виявлено активних джерел генерації (СЕС, ВЕС або Міні-ГЕС).',
        severity: AiRecommendationSeverity.warning,
        icon: Icons.lightbulb_outline,
      );
    }

    if (todaySummary == null) {
      return const AiRecommendation(
        title: 'Збір даних...',
        message: 'Очікування результатів метеорологічного прогнозу для виконання розрахунків.',
        severity: AiRecommendationSeverity.info,
        icon: Icons.hourglass_empty_rounded,
      );
    }

    final double totalActualKwh = todaySummary.totalGenerationKwh;

    // 2. Розрахунок відсоткових часток (внесок кожного джерела)
    int solarShare = 0;
    int windShare = 0;
    int hydroShare = 0;

    if (totalActualKwh > 0) {
      solarShare = ((todaySummary.totalSolarKwh / totalActualKwh) * 100).round();
      windShare = ((todaySummary.totalWindKwh / totalActualKwh) * 100).round();
      // Виключаємо похибку округлення до 100%
      hydroShare = (hasHydro) ? (100 - solarShare - windShare).clamp(0, 100) : 0;
      
      if (!hasHydro && (solarShare + windShare) > 0) {
        // Якщо ГЕС немає, коригуємо баланс між сонцем та вітром
        windShare = 100 - solarShare;
      }
    }

    final Map<String, int> sharesMap = {
      if (hasSolar) 'solar': solarShare,
      if (hasWind) 'wind': windShare,
      if (hasHydro) 'hydro': hydroShare,
    };

    // 3. Аналіз часових інтервалів та піків потужності (Погодинний аналіз)
    int peakSolarHour = -1;
    double maxSolarKw = 0.0;
    int peakWindHour = -1;
    double maxWindKw = 0.0;

    for (var point in todaySummary.hourlyPoints) {
      if (point.solarKw > maxSolarKw) {
        maxSolarKw = point.solarKw;
        peakSolarHour = point.time.hour;
      }
      if (point.windKw > maxWindKw) {
        maxWindKw = point.windKw;
        peakWindHour = point.time.hour;
      }
    }

    // Автоматичне визначення ефективних інтервалів (де виробіток > 70% від пікового)
    String? peakSolarInterval;
    if (hasSolar && maxSolarKw > 0.1) {
      int startSolar = -1;
      int endSolar = -1;
      for (var point in todaySummary.hourlyPoints) {
        if (point.solarKw >= maxSolarKw * 0.7) {
          if (startSolar == -1) startSolar = point.time.hour;
          endSolar = point.time.hour;
        }
      }
      peakSolarInterval = '$startSolar:00–${endSolar + 1}:00';
    }

    String? peakWindInterval;
    if (hasWind && maxWindKw > 0.1) {
      int startWind = -1;
      int endWind = -1;
      for (var point in todaySummary.hourlyPoints) {
        if (point.windKw >= maxWindKw * 0.7) {
          if (startWind == -1) startWind = point.time.hour;
          endWind = point.time.hour;
        }
      }
      peakWindInterval = '$startWind:00–${endWind + 1}:00';
    }

    // 4. Розрахунок ідеальної генерації та чистих втрат
    final double idealGenerationKwh = _calculateIdealGeneration(
  settings: settings,
  date: todayDate,
  windSpeed: windSpeed,
  tempC: tempC,
);
    final double lossesKwh = (idealGenerationKwh - totalActualKwh).clamp(0.0, double.infinity);

    // Визначення конкретних причин падіння ефективності
    final List<String> lossReasons = [];
    if (hasSolar) {
      if (cloudiness > 25) lossReasons.add('висока хмарність (${cloudiness.round()}%)');
      if (rainMm > 0.5) lossReasons.add('інтенсивні опади/дощ');
      if (snowMm > 0.1) lossReasons.add('ризик снігового покриву на панелях');
      if (tempC > 26) lossReasons.add('термічний нагрів елементів СЕС (${tempC.round()}°C)');
    }
    if (hasWind && windSpeed < 3.5) {
      lossReasons.add('слабкий повітряний потік для ВЕС (${windSpeed.toStringAsFixed(1)} м/с)');
    }

    // 5. Побудова гібридного комплексного звіту
    final buffer = StringBuffer();
    
    // Блок складу системи
    List<String> compNames = [];
    if (hasSolar) compNames.add('сонячних панелей');
    if (hasWind) compNames.add('вітрогенераторів');
    if (hasHydro) compNames.add('міні-ГЕС');
    buffer.write('Система сьогодні працює в гібридному режимі (${compNames.join(' + ')}). ');

    // Блок балансу та синергії джерел
    if (totalActualKwh > 0) {
      List<String> distributionStrings = [];
      if (hasSolar && todaySummary.totalSolarKwh > 0) {
        distributionStrings.add('СЕС забезпечить $solarShare% (${todaySummary.totalSolarKwh.toStringAsFixed(1)} кВт·год)');
      }
      if (hasWind && todaySummary.totalWindKwh > 0) {
        distributionStrings.add('ВЕС додасть $windShare% (${todaySummary.totalWindKwh.toStringAsFixed(1)} кВт·год)');
      }
      if (hasHydro && todaySummary.totalHydroKwh > 0) {
        distributionStrings.add('Міни-ГЕС згенерує $hydroShare% (${todaySummary.totalHydroKwh.toStringAsFixed(1)} кВт·год)');
      }
      
      buffer.write('Розподіл часток: ${distributionStrings.join(', ')}. ');

      // Опис взаємної компенсації
      if (hasSolar && hasWind && windShare > 20 && peakWindHour > 17) {
        buffer.write('Вдала синергія: вітрогенерація ефективно компенсує спад сонячної активності у вечірній час (пік вітру о $peakWindHour:00). ');
      } else if (hasSolar && hasHydro && hydroShare > 30) {
        buffer.write('Гідростанція гарантує стійку базову потужність, сгладжуючи коливання СЕС через хмарність. ');
      }
    } else {
      buffer.write('Протягом цієї доби генерація відсутня через критичні погодні фактори. ');
    }

    // Блок часових рекомендацій навантажень
    if (peakSolarInterval != null) {
      buffer.write('\n\n⏱ Рекомендація щодо навантаження: перенесіть основні енергоємні процеси (прання, зарядка авто, бойлер) на інтервал піка інсоляції з $peakSolarInterval.');
    } else if (peakWindInterval != null && windShare > 40) {
      buffer.write('\n\n⏱ Рекомендація щодо навантаження: очікується стабільний вітровий коридор. Максимальна потужність доступна в період $peakWindInterval.');
    }

    // Аналіз аномалій для вибору іконки та статусу картки
    AiRecommendationSeverity severity = AiRecommendationSeverity.success;
    IconData mainIcon = Icons.bolt_rounded;

    if (snowMm > 0.5 && hasSolar) {
      severity = AiRecommendationSeverity.critical;
      mainIcon = Icons.ac_unit_rounded;
    } else if (lossesKwh > idealGenerationKwh * 0.45 && totalActualKwh > 0) {
      severity = AiRecommendationSeverity.warning;
      mainIcon = Icons.cloud_queue_rounded;
    } else if (totalActualKwh < 1.0) {
      severity = AiRecommendationSeverity.critical;
      mainIcon = Icons.battery_alert_rounded;
    }

    return AiRecommendation(
      title: _generateDynamicTitle(sharesMap),
      message: buffer.toString(),
      severity: severity,
      icon: mainIcon,
      idealGenerationKwh: idealGenerationKwh,
      expectedGenerationKwh: totalActualKwh,
      lossesKwh: lossesKwh,
      sourceShares: sharesMap,
      lossReasons: lossReasons,
      peakSolarInterval: peakSolarInterval,
      peakWindInterval: peakWindInterval,
    );
  }

  String _generateDynamicTitle(Map<String, int> shares) {
    if (shares.isEmpty) return 'Аналіз генерації';
    
    final sorted = shares.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final primary = sorted.first;

    if (sorted.length == 1) {
      if (primary.key == 'solar') return 'Сонячний день';
      if (primary.key == 'wind') return 'Вітряна доба';
      return 'Базова гідрогенерація';
    }

    if (primary.value >= 50) {
      if (primary.key == 'solar') return 'Гібрид: домінує СЕС (${primary.value}%)';
      if (primary.key == 'wind') return 'Гібрид: домінує ВЕС (${primary.value}%)';
      return 'Гібрид: ГЕС як основа (${primary.value}%)';
    }

    return 'Збалансований гібридний режим';
  }

  double _calculateIdealGeneration({
  required EssSystemSettings settings,
  required DateTime date,
  required double windSpeed,
  required double tempC,
}) {
  final engine = HybridForecastEngine(latitude: latitude);
  List<WeatherHourForecast> idealWeather = [];
  
  for (int hour = 0; hour < 24; hour++) {
    idealWeather.add(WeatherHourForecast(
      dateTime: DateTime(date.year, date.month, date.day, hour),
      cloudCover: 0.0,         // Идеально для СЕС: абсолютно чистое небо
      windSpeed: windSpeed,     // Идеально для ВЕС: текущий стабильный воздушный поток
      accumulatedRain: 0.0,    // Без осадков, снижающих эффективность
      accumulatedSnow: 0.0,
      temperatureC: tempC,     // Текущая температура (важно для учета перегрева панелей)
    ));
  }
  
  final idealSummary = engine.calculate(settings: settings, weatherData: idealWeather);
  return idealSummary.totalGenerationKwh;
}
}