// lib/utils/constants/ats_constants.dart

/// 🔧 Константи для АВР (Automatic Transfer Switch)

class ATSConstants {
  // ===== Напруга =====
  static const double DEFAULT_MIN_VOLTAGE = 190.0; // В
  static const double DEFAULT_MAX_VOLTAGE = 255.0; // В
  static const double NOMINAL_VOLTAGE = 230.0; // В

  /// Стандартні діапазони напруги
  static const Map<String, List<double>> VOLTAGE_PRESETS = {
    'Суворо': [200.0, 250.0],          // Для чутливої електроніки
    'Стандарт': [190.0, 260.0],        // Для переважної більшості
    'Лояльно': [180.0, 270.0],         // Для стійкої техніки
    'Критично': [160.0, 280.0],        // Крайній випадок
  };

  // ===== Частота =====
  static const double DEFAULT_MIN_FREQUENCY = 49.0; // Гц
  static const double DEFAULT_MAX_FREQUENCY = 51.0; // Гц
  static const double NOMINAL_FREQUENCY = 50.0; // Гц

  /// Стандартні діапазони частоти
  static const Map<String, List<double>> FREQUENCY_PRESETS = {
    'Суворо': [49.5, 50.5],
    'Стандарт': [49.0, 51.0],
    'Лояльно': [48.5, 51.5],
  };

  // ===== Час перемикання =====
  static const int DEFAULT_TRANSFER_TIME_MS = 10; // мс
  static const int MIN_TRANSFER_TIME_MS = 1; // мс
  static const int MAX_TRANSFER_TIME_MS = 100; // мс

  static const Map<String, int> TRANSFER_TIME_PRESETS = {
    'Швидка': 5,      // Для критичної техніки
    'Стандарт': 10,   // Оптимально
    'Звичайна': 20,   // Менш критично
  };

  // ===== Затримки =====
  static const int DEFAULT_RETURN_DELAY_MS = 30000; // мс (30 сек)
  static const int DEFAULT_SWITCH_DELAY_MS = 5000; // мс (5 сек)

  /// Затримки перед перемиканням на генератор
  static const Map<String, int> GENERATOR_START_DELAYS = {
    'Миттєво': 0,
    'Швидко': 500,
    'Стандарт': 1000,
    'Обережно': 2000,
    'З перевіркою': 3000,
  };

  // ===== SOC Генератора =====
  static const double DEFAULT_GENERATOR_START_SOC = 20.0; // %
  static const double MIN_GENERATOR_START_SOC = 5.0; // %
  static const double MAX_GENERATOR_START_SOC = 80.0; // %

  /// Пріоритетні схеми
  static const List<String> PRIORITY_SCHEMES = [
    'Мережа → АКБ → Генератор',      // Максимізація використання мережи
    'Мережа → Генератор → АКБ',      // Економія АКБ за рахунок генератора
    'АКБ → Мережа → Генератор',      // Максимізація автономності
    'Генератор → АКБ → Мережа',      // Мінімізація витрат на мережу
  ];

  /// Резервні джерела
  static const List<String> BACKUP_SOURCES = [
    'Інвертор',
    'Генератор',
    'АКБ',
    'Сонячна генерація',
  ];

  /// Режими роботи
  static const List<String> OPERATING_MODES = [
    'Автоматичний',  // Повна автоматизація
    'Ручний',         // Оператор сам вибирає
    'Віддалений',     // Управління через App
  ];

  /// Типи контролю фаз
  static const List<String> PHASE_MONITORING_TYPES = [
    'Усі фази',            // Контроль всіх 3 фаз
    'Одна фаза',           // Контроль однієї фази
    'Розбалансування',     // Контроль дисбалансу
  ];

  // ===== Якість мережі =====

  /// Поріги відхилення напруги (%)
  static const Map<String, double> VOLTAGE_DEVIATION_THRESHOLDS = {
    'excellent': 5.0,      // < 5% - відмінна
    'good': 10.0,          // < 10% - хороша
    'poor': 15.0,          // < 15% - погана
    'critical': 25.0,      // > 15% - критична
  };

  /// Поріги блекаутів за день
  static const Map<String, int> BLACKOUT_THRESHOLDS = {
    'excellent': 0,        // 0 блекаутів
    'good': 2,             // < 2 блекаутів
    'poor': 5,             // < 5 блекаутів
    'critical': 999,       // > 5 блекаутів
  };

  // ===== Надійність системи =====

  static const Map<String, int> RELIABILITY_BONUSES = {
    'autoTest': 10,        // +10% за автотест
    'remoteControl': 5,    // +5% за віддалене керування
    'allPhases': 15,       // +15% за контроль всіх фаз
  };

  static const int BASE_RELIABILITY = 70; // Базова надійність

  // ===== Рекомендації системи =====

  static const Map<String, String> RECOMMENDATIONS = {
    'excellent_stable':
        '✓ Мережа стабільна. АВР налаштований оптимально.',
    'good_stabilizer':
        '⚠️ Рекомендується встановити стабілізатор напруги',
    'poor_ats_required':
        '🔴 Часті просадки. АВР обов\'язковий!',
    'poor_generator':
        '💡 Резервний генератор значно поліпшить надійність',
    'critical_ups':
        '🚨 КРИТИЧНО: Встановіть УБЖ негайно!',
    'critical_stabilizer':
        '⚠️ Розгляньте монтаж генератора як резерву',
    'transfer_time_high':
        '⏳ Час переходу > 50мс. Розгляньте вдосконалення',
  };

  // ===== Сценарії симуляції =====

  static const List<Map<String, String>> SIMULATION_SCENARIOS = [
    {
      'name': 'Мережа → АКБ',
      'icon': '🔌➡️🔋',
      'description': 'Перехід при відмові мережі',
    },
    {
      'name': 'Мережа → Генератор',
      'icon': '🔌➡️⛽',
      'description': 'Запуск генератора як резерву',
    },
    {
      'name': 'АКБ → Мережа',
      'icon': '🔋➡️✓',
      'description': 'Повернення до мережи',
    },
    {
      'name': 'Генератор → Мережа',
      'icon': '⛽➡️🔄',
      'description': 'Зупинка генератора',
    },
    {
      'name': 'АКБ → Генератор',
      'icon': '🔋➡️⛽',
      'description': 'Переключення джерел',
    },
  ];

  // ===== Відповідь системи =====

  static const Map<String, String> TRANSITION_STATUSES = {
    'ALERT': '🔴 УВАГА',
    'WAIT': '⏳ ОЧІКУВАННЯ',
    'SUCCESS': '✓ УСПІХ',
    'ERROR': '❌ ПОМИЛКА',
  };

  // ===== Кольори для UI =====

  static const Map<String, String> STATUS_COLORS = {
    'grid': '🟢',       // Мережа
    'battery': '🟡',    // АКБ
    'generator': '🔶',  // Генератор
    'solar': '🟠',      // Сонце
  };

  // ===== Тексти та повідомлення =====

  static const Map<String, String> MESSAGES = {
    'transfer_success': 'Успішно переключено на {{source}}',
    'transfer_failed': 'Помилка переключення. Перевірте {{source}}',
    'generator_started': 'Генератор запущено',
    'generator_stopped': 'Генератор зупинений',
    'grid_restored': 'Мережа відновлена',
    'grid_failed': 'Мережа відключена',
    'battery_critical': 'АКБ критична! Залишилось {{soc}}%',
    'system_online': 'АВР готова',
    'system_offline': 'АВР недоступна',
  };

  // ===== Параметри для графіків =====

  static const int CHART_DATA_POINTS = 24; // 24 години
  static const int CHART_REFRESH_INTERVAL_MS = 1000; // 1 сек

  // ===== Заводські налаштування =====

  static const Map<String, dynamic> FACTORY_SETTINGS = {
    'minVoltage': DEFAULT_MIN_VOLTAGE,
    'maxVoltage': DEFAULT_MAX_VOLTAGE,
    'minFrequency': DEFAULT_MIN_FREQUENCY,
    'maxFrequency': DEFAULT_MAX_FREQUENCY,
    'transferTimeMs': DEFAULT_TRANSFER_TIME_MS,
    'returnDelayMs': DEFAULT_RETURN_DELAY_MS,
    'switchDelayMs': DEFAULT_SWITCH_DELAY_MS,
    'generatorStartSOC': DEFAULT_GENERATOR_START_SOC,
    'priorityScheme': 'Мережа → АКБ → Генератор',
    'backupSource': 'Інвертор',
    'atsMode': 'Автоматичний',
    'phaseMonitoring': 'Усі фази',
    'autoReturn': true,
    'autoTest': true,
    'remoteControl': false,
  };

  // ===== Валідація =====

  /// Валідувати напругу
  static bool isValidVoltage(double voltage) {
    return voltage >= 100 && voltage <= 300;
  }

  /// Валідувати частоту
  static bool isValidFrequency(double frequency) {
    return frequency >= 45 && frequency <= 55;
  }

  /// Валідувати час перемикання
  static bool isValidTransferTime(int ms) {
    return ms >= MIN_TRANSFER_TIME_MS && ms <= MAX_TRANSFER_TIME_MS;
  }

  /// Валідувати SOC генератора
  static bool isValidGeneratorStartSOC(double soc) {
    return soc >= MIN_GENERATOR_START_SOC && soc <= MAX_GENERATOR_START_SOC;
  }

  // ===== Рекомендована конфігурація =====

  static Map<String, dynamic> getRecommendedPreset(String scenario) {
    switch (scenario) {
      case 'Компактна квартира':
        return {
          'minVoltage': 200.0,
          'maxVoltage': 250.0,
          'transferTimeMs': 5,
          'priorityScheme': 'Мережа → АКБ → Генератор',
          'backupSource': 'Інвертор',
        };

      case 'Приватний будинок':
        return {
          'minVoltage': 190.0,
          'maxVoltage': 260.0,
          'transferTimeMs': 10,
          'priorityScheme': 'Мережа → Генератор → АКБ',
          'backupSource': 'Генератор',
        };

      case 'Будинок з СЕС':
        return {
          'minVoltage': 195.0,
          'maxVoltage': 245.0,
          'transferTimeMs': 15,
          'priorityScheme': 'АКБ → Мережа → Генератор',
          'backupSource': 'АКБ',
        };

      case 'Критична система':
        return {
          'minVoltage': 210.0,
          'maxVoltage': 230.0,
          'transferTimeMs': 5,
          'priorityScheme': 'Генератор → АКБ → Мережа',
          'backupSource': 'Генератор',
        };

      default:
        return FACTORY_SETTINGS;
    }
  }
}

/// 📌 Хелпер клас для роботи з константами
class ATSPresetHelper {
  /// Отримати пресет за назвою
  static Map<String, List<double>> getVoltagePreset(String presetName) {
    final preset = ATSConstants.VOLTAGE_PRESETS[presetName];
    if (preset != null) {
      return {presetName: preset};
    }
    return {'Стандарт': ATSConstants.VOLTAGE_PRESETS['Стандарт']!};
  }

  /// Визначити якість мережі за напругою
  static String getQualityByVoltageDeviation(double deviation) {
    if (deviation < ATSConstants.VOLTAGE_DEVIATION_THRESHOLDS['excellent']!) {
      return 'excellent';
    } else if (deviation <
        ATSConstants.VOLTAGE_DEVIATION_THRESHOLDS['good']!) {
      return 'good';
    } else if (deviation <
        ATSConstants.VOLTAGE_DEVIATION_THRESHOLDS['poor']!) {
      return 'poor';
    }
    return 'critical';
  }

  /// Отримати рекомендацію за якістю мережі
  static String getRecommendationByQuality(String quality) {
    switch (quality) {
      case 'excellent':
        return ATSConstants.RECOMMENDATIONS['excellent_stable']!;
      case 'good':
        return ATSConstants.RECOMMENDATIONS['good_stabilizer']!;
      case 'poor':
        return ATSConstants.RECOMMENDATIONS['poor_ats_required']!;
      case 'critical':
        return ATSConstants.RECOMMENDATIONS['critical_ups']!;
      default:
        return 'Статус невідомий';
    }
  }

  /// Форматувати час для відображення
  static String formatTransferTime(int ms) {
    if (ms < 1000) {
      return '${ms}мс';
    }
    return '${(ms / 1000).toStringAsFixed(1)}с';
  }

  /// Перевірити чи АВР готова
  static bool isATSReady({
    required bool autoTest,
    required bool isGridHealthy,
    required double batterySOC,
  }) {
    return autoTest && (isGridHealthy || batterySOC > 15);
  }
}