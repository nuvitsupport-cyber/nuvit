import '../../models/outage/outage_forecast.dart';
import '../../models/outage/outage_settings.dart';

/// Базовый интерфейс источника данных
/// для модуля графика відключень.
///
/// Реализации:
///
/// • MockOutageProvider
/// • DtekOutageProvider
/// • UkrenergoOutageProvider
/// • ApiOutageProvider
abstract class OutageProvider {
  const OutageProvider();

  /// Загружает прогноз отключений
  /// согласно текущим настройкам пользователя.
  Future<OutageForecast> loadForecast(
    OutageSettings settings,
  );

  /// Принудительное обновление данных.
  Future<OutageForecast> refreshForecast(
    OutageSettings settings,
  );

  /// Возвращает true, если источник доступен.
  Future<bool> isAvailable();

  /// Название источника.
  String get providerName;
}