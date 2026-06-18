import 'package:flutter/material.dart';

enum DevicePriority {
  critical,
  high,
  normal,
  low,
}
enum PropertyType {
  apartment,
  house,
}
enum InstallationLocation {
  indoor,
  outdoor,
  garage,
  basement,
  garden,
  technicalRoom,
  roof,
}

class DeviceInfo {
  /// =========================
  /// Основна інформація
  /// =========================

  /// Назва пристрою
  final String name;

  /// Категорія
  final String category;

  /// Підкатегорія
  final String? subCategory;

  /// Іконка
  final IconData icon;

  /// Виробник
  final String manufacturer;

  /// Модель
  final String model;
/// Для каких типов жилья подходит
final List<PropertyType> supportedProperties;

/// Место установки
final List<InstallationLocation> installationLocations;
  /// =========================
  /// Потужність
  /// =========================

  /// Типове споживання (W)
  final double typicalPower;

  /// Мінімальна потужність (W)
  final double minPower;

  /// Максимальна потужність (W)
  final double maxPower;

  /// Пікова потужність (W)
  final double peakPower;

  /// Потужність у режимі очікування (W)
  final double standbyPower;

  /// Коефіцієнт потужності
  final double powerFactor;

  /// Змінне споживання
  final bool variablePower;

  /// Можливість обмеження потужності
  final bool powerLimiting;

  /// =========================
  /// Електродвигуни
  /// =========================

  /// Наявність двигуна
  final bool hasMotor;

  /// Кратність пускового струму
  final double startupMultiplier;

  /// =========================
  /// Використання
  /// =========================

  /// Кількість за замовчуванням
  final int defaultQuantity;

  /// Годин на добу
  final double defaultHoursPerDay;

  /// Добове споживання (кВт·год)
  final double dailyEnergy;

  /// Циклічна робота
  final bool cyclicOperation;

  /// Тривалість циклу (хв)
  final int cycleDuration;

  /// =========================
  /// Пріоритети
  /// =========================

  final DevicePriority priority;

  /// Критичне навантаження
  final bool critical;

  /// Можна переносити по часу
  final bool shiftable;

  /// Планування
  final bool supportsScheduling;

  /// Підтримка резервного живлення
  final bool supportsBackup;

  /// Робота від надлишків PV
  final bool supportsPVExcess;

  /// Тільки від сонця
  final bool solarOnly;

  /// Відкладений запуск
  final bool deferredStart;

  /// Мінімальний SOC АКБ
  final double minBatterySoc;

  /// Враховувати в розрахунках автономності
  final bool includeInBackupCalculation;

  /// =========================
  /// Smart Home
  /// =========================

  final bool smartDevice;

  final bool homeAssistantSupported;

  final bool mqttSupported;

  final bool modbusSupported;

  final bool zigbeeSupported;

  final bool wifiSupported;

  final bool bluetoothSupported;

  /// =========================
  /// AI
  /// =========================

  /// Важливість для AI (0-100)
  final int aiImportance;

  /// Автоматичне вимкнення
  final bool allowAutoShutdown;

  /// Автоматичний запуск
  final bool allowAutoStart;

  /// =========================
  /// Додатково
  /// =========================

  final bool noisy;

  final bool tariffSensitive;

  final List<int> preferredHours;

  final List<int> preferredMonths;

  final bool generatesHeat;

  final bool generatesCooling;

  final bool generatesHotWater;

  final bool generatesVibration;

  const DeviceInfo({
    // Основне
    required this.name,
    required this.category,
    this.subCategory,
    required this.icon,
    this.manufacturer = '',
    this.model = '',
this.supportedProperties = const [
  PropertyType.apartment,
  PropertyType.house,
],

this.installationLocations = const [
  InstallationLocation.indoor,
],
    // Потужність
    required this.typicalPower,
    this.minPower = 0,
    required this.maxPower,
    required this.peakPower,
    this.standbyPower = 0,
    this.powerFactor = 1.0,
    this.variablePower = false,
    this.powerLimiting = false,

    // Двигун
    this.hasMotor = false,
    this.startupMultiplier = 1.0,

    // Використання
    this.defaultQuantity = 1,
    this.defaultHoursPerDay = 1,
    this.dailyEnergy = 0,
    this.cyclicOperation = false,
    this.cycleDuration = 0,

    // Пріоритет
    this.priority = DevicePriority.normal,
    this.critical = false,
    this.shiftable = false,
    this.supportsScheduling = false,
    this.supportsBackup = true,
    this.supportsPVExcess = false,
    this.solarOnly = false,
    this.deferredStart = false,
    this.minBatterySoc = 0,
    this.includeInBackupCalculation = true,

    // Smart Home
    this.smartDevice = false,
    this.homeAssistantSupported = false,
    this.mqttSupported = false,
    this.modbusSupported = false,
    this.zigbeeSupported = false,
    this.wifiSupported = false,
    this.bluetoothSupported = false,

    // AI
    this.aiImportance = 50,
    this.allowAutoShutdown = false,
    this.allowAutoStart = false,

    // Додатково
    this.noisy = false,
    this.tariffSensitive = false,
    this.preferredHours = const [],
    this.preferredMonths = const [],
    this.generatesHeat = false,
    this.generatesCooling = false,
    this.generatesHotWater = false,
    this.generatesVibration = false,
  });

  /// Добове споживання за типовими параметрами
  double get estimatedDailyEnergy =>
      (typicalPower * defaultHoursPerDay * defaultQuantity) / 1000;

  /// Пускова потужність
  double get startupPower =>
      peakPower * startupMultiplier;

  /// Середня потужність
  double get averagePower =>
      (minPower + maxPower) / 2;

  /// Чи можна автоматично керувати
  bool get canBeAutomated =>
      supportsScheduling ||
      supportsPVExcess ||
      allowAutoShutdown ||
      allowAutoStart;

  /// Чи є Smart пристроєм
  bool get isSmart =>
      smartDevice ||
      homeAssistantSupported ||
      mqttSupported ||
      modbusSupported ||
      zigbeeSupported ||
      wifiSupported ||
      bluetoothSupported;

  /// Чи є високопотужним
  bool get isHighPower =>
      peakPower >= 2000;

  /// Чи є моторним навантаженням
  bool get isMotorLoad =>
      hasMotor;

  /// Чи підходить для PV Diverter
  bool get isPvExcessCandidate =>
      supportsPVExcess;

  /// Чи є критичним навантаженням
  bool get isCriticalLoad =>
      critical;

  /// Чи шумний
  bool get isNoisy =>
      noisy;

  /// Чи залежить від тарифів
  bool get isTariffSensitive =>
      tariffSensitive;
Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'typicalPower': typicalPower,
      'maxPower': maxPower,
      'peakPower': peakPower,
      'defaultQuantity': defaultQuantity,
      'defaultHoursPerDay': defaultHoursPerDay,
      'iconCodePoint': icon.codePoint,
    };
  }

  factory DeviceInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return DeviceInfo(
      name: json['name'],
      category: json['category'],
      icon: IconData(
        json['iconCodePoint'],
        fontFamily: 'MaterialIcons',
      ),
      typicalPower:
          (json['typicalPower'] as num).toDouble(),
      maxPower:
          (json['maxPower'] as num).toDouble(),
      peakPower:
          (json['peakPower'] as num).toDouble(),
      defaultQuantity: json['defaultQuantity'],
      defaultHoursPerDay:
          (json['defaultHoursPerDay'] as num)
              .toDouble(),
    );
  }
}