import '../models/outage/outage_forecast.dart';
import '../models/outage/outage_settings.dart';
import '../services/outage/outage_provider.dart';

/// Центральный движок модуля графика відключень.
///
/// Отвечает за получение прогноза и подготовку данных
/// для отображения.
///
/// В будущем здесь будут:
/// • объединение данных из нескольких источников;
/// • фильтрация;
/// • нормализация;
/// • расчёт следующего события;
/// • обработка ошибок;
/// • работа с кешем.
class OutageForecastEngine {
  final OutageProvider provider;

  const OutageForecastEngine({
    required this.provider,
  });

  /// Получить прогноз.
  Future<OutageForecast> loadForecast(
    OutageSettings settings,
  ) async {
    final forecast =
        await provider.loadForecast(settings);

    return _processForecast(forecast);
  }

  /// Принудительное обновление.
  Future<OutageForecast> refreshForecast(
    OutageSettings settings,
  ) async {
    final forecast =
        await provider.refreshForecast(settings);

    return _processForecast(forecast);
  }

  /// Проверить доступность источника.
  Future<bool> isAvailable() {
    return provider.isAvailable();
  }

  /// Подготовка прогноза.
  ///
  /// Пока просто возвращает данные без изменений.
  ///
  /// Позже здесь появятся:
  ///
  /// • сортировка периодов;
  /// • объединение интервалов;
  /// • удаление пересечений;
  /// • вычисление статистики;
  /// • поиск следующего события;
  /// • вычисление вероятности;
  /// • генерация AI-инсайтов.
  OutageForecast _processForecast(
    OutageForecast forecast,
  ) {
    return forecast;
  }
}