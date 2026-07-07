import 'package:flutter/material.dart';

enum RecommendationType {
  savings,
  warning,
  solar,
  battery,
  schedule,
}

class RecommendationData {
  final String title;
  final String description;
  final RecommendationType type;

  const RecommendationData({
    required this.title,
    required this.description,
    required this.type,
  });
}

class ConsumptionBreakdownData {
  final String name;
  final double energyKwh;
  final IconData icon;

  const ConsumptionBreakdownData({
    required this.name,
    required this.energyKwh,
    required this.icon,
  });
}

class ForecastData {
  final double generationKwh;
  final double consumptionKwh;
  final int sunshinePercent;
  final String weatherCondition;

  const ForecastData({
    required this.generationKwh,
    required this.consumptionKwh,
    required this.sunshinePercent,
    required this.weatherCondition,
  });
}

class AutonomyResult {
  /// Автономність
  final Duration autonomy;

  /// Поточний заряд АКБ
  final double batteryPercent;

  /// Час завершення автономності
  final DateTime autonomyEndTime;

  /// Добове споживання
  final double dailyConsumptionKwh;

  /// Добова генерація
  final double dailyGenerationKwh;

  /// Покриття від СЕС
  final double solarCoveragePercent;

  /// Прогноз
  final ForecastData forecast;

  /// Деталізація споживання
  final List<ConsumptionBreakdownData> breakdown;

  /// Рекомендації AI
  final List<RecommendationData> recommendations;

  const AutonomyResult({
    required this.autonomy,
    required this.batteryPercent,
    required this.autonomyEndTime,
    required this.dailyConsumptionKwh,
    required this.dailyGenerationKwh,
    required this.solarCoveragePercent,
    required this.forecast,
    required this.breakdown,
    required this.recommendations,
  });

  factory AutonomyResult.demo() {
    return AutonomyResult(
      autonomy: const Duration(
        hours: 9,
        minutes: 24,
      ),

      batteryPercent: 100,

      autonomyEndTime: DateTime.now().add(
        const Duration(
          hours: 9,
          minutes: 24,
        ),
      ),

      dailyConsumptionKwh: 8.7,

      dailyGenerationKwh: 6.3,

      solarCoveragePercent: 72,

      forecast: const ForecastData(
        generationKwh: 6.3,
        consumptionKwh: 8.7,
        sunshinePercent: 82,
        weatherCondition: 'Сонячно',
      ),

      breakdown: const [
        ConsumptionBreakdownData(
          name: 'Бойлер',
          energyKwh: 3.2,
          icon: Icons.hot_tub,
        ),
        ConsumptionBreakdownData(
          name: 'Холодильник',
          energyKwh: 1.8,
          icon: Icons.kitchen,
        ),
        ConsumptionBreakdownData(
          name: 'Освітлення',
          energyKwh: 0.9,
          icon: Icons.lightbulb,
        ),
        ConsumptionBreakdownData(
          name: 'Компʼютер',
          energyKwh: 1.4,
          icon: Icons.computer,
        ),
      ],

      recommendations: const [
        RecommendationData(
          type: RecommendationType.savings,
          title: 'Збільшення автономності',
          description:
              'Вимкнення бойлера збільшить автономність приблизно на 2 години.',
        ),
        RecommendationData(
          type: RecommendationType.solar,
          title: 'Надлишок генерації',
          description:
              'Очікується надлишок генерації між 12:00 та 15:00.',
        ),
      ],
    );
  }
}