import '../../models/outage/next_outage_event.dart';
import '../../models/outage/outage_forecast.dart';
import '../../models/outage/outage_insight.dart';
import '../../models/outage/outage_period.dart';
import '../../models/outage/outage_probability.dart';
import '../../models/outage/outage_settings.dart';
import '../../models/outage/outage_source.dart';
import '../../models/outage/outage_state.dart';
import '../../models/outage/outage_statistics.dart';

import 'outage_provider.dart';

/// Тестовый источник данных.
///
/// Используется во время разработки интерфейса.
/// Позже будет заменён на API ДТЕК или другой сервис.
class MockOutageProvider implements OutageProvider {
  const MockOutageProvider();

  @override
  String get providerName => 'Mock Data';

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<OutageForecast> loadForecast(
    OutageSettings settings,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    return _buildForecast();
  }

  @override
  Future<OutageForecast> refreshForecast(
    OutageSettings settings,
  ) async {
    return loadForecast(settings);
  }

  OutageForecast _buildForecast() {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    return OutageForecast(
      updatedAt: now,

      source: OutageSource.mock(),

      probability: OutageProbability.fromPercent(
        82,
        description:
            'Висока ймовірність вечірнього відключення.',
      ),

      nextEvent: NextOutageEvent(
        start: today.add(const Duration(hours: 18)),
        end: today.add(const Duration(hours: 20)),
        state: OutageState.outage,
        title: 'Планове відключення',
        description:
            'Очікується відключення електроенергії.',
      ),

      statistics: const OutageStatistics(
        powerHours: 18,
        outageHours: 4,
        possibleOutageHours: 2,
        outageCount: 2,
        averageOutageDuration: Duration(hours: 2),
        longestOutageDuration: Duration(hours: 2),
      ),

      insights: [
        OutageInsight(
          type: OutageInsightType.recommendation,
          title: 'Зарядіть АКБ',
          message:
              'До відключення залишилося менше 2 годин. Рекомендується зарядити акумулятори.',
          priority: 90,
          createdAt: now,
        ),
        OutageInsight(
          type: OutageInsightType.info,
          title: 'Сонячна генерація',
          message:
              'Очікується гарна сонячна погода. СЕС частково компенсує споживання.',
          priority: 40,
          createdAt: now,
        ),
      ],

      periods: [
        OutagePeriod(
          start: today,
          end: today.add(const Duration(hours: 6)),
          state: OutageState.powerOn,
        ),

        OutagePeriod(
          start: today.add(const Duration(hours: 6)),
          end: today.add(const Duration(hours: 8)),
          state: OutageState.outage,
          probability: 100,
          description: 'Планове відключення',
        ),

        OutagePeriod(
          start: today.add(const Duration(hours: 8)),
          end: today.add(const Duration(hours: 14)),
          state: OutageState.powerOn,
        ),

        OutagePeriod(
          start: today.add(const Duration(hours: 14)),
          end: today.add(const Duration(hours: 16)),
          state: OutageState.possibleOutage,
          probability: 65,
          description: 'Можливі обмеження',
        ),

        OutagePeriod(
          start: today.add(const Duration(hours: 16)),
          end: today.add(const Duration(hours: 18)),
          state: OutageState.powerOn,
        ),

        OutagePeriod(
          start: today.add(const Duration(hours: 18)),
          end: today.add(const Duration(hours: 20)),
          state: OutageState.outage,
          probability: 100,
          description: 'Планове відключення',
        ),

        OutagePeriod(
          start: today.add(const Duration(hours: 20)),
          end: today.add(const Duration(hours: 24)),
          state: OutageState.powerOn,
        ),
      ],
    );
  }
}