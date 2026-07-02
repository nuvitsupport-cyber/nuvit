class EnergyFlowState {
  const EnergyFlowState({
    required this.houseConsumptionWatts,
    required this.solarGenerationWatts,
    required this.gridPowerWatts,
    required this.batteryPowerWatts,
    required this.generatorPowerWatts,
    required this.portablePowerWatts,
    required this.batterySoc,
    required this.energyBalanceWatts,
    required this.isGridConnected,
    required this.isGeneratorRunning,
    required this.isBatteryCharging,
    required this.isPortableActive,
    required this.isPortableCharging,
    required this.timestamp,
  });

  /// ===========================
  /// Потоки мощности (Вт)
  /// ===========================

  /// Потребление дома
  final double houseConsumptionWatts;

  /// Генерация солнечных панелей
  final double solarGenerationWatts;

  /// Работа сети
  ///
  /// > 0  → берем из сети
  /// < 0  → экспортируем в сеть
  final double gridPowerWatts;

  /// Работа батареи
  ///
  /// > 0  → батарея разряжается
  /// < 0  → батарея заряжается
  final double batteryPowerWatts;

  /// Работа генератора
  final double generatorPowerWatts;

  /// Работа портативной станции (EV Backup)
  ///
  /// > 0  → разряжается (отдает энергию)
  /// < 0  → заряжается (потребляет энергию)
  final double portablePowerWatts;

  /// ===========================
  /// Состояние оборудования
  /// ===========================

  /// Заряд основной батареи
  final double batterySoc;

  /// Есть ли сеть
  final bool isGridConnected;

  /// Работает ли генератор
  final bool isGeneratorRunning;

  /// Заряжается ли АКБ
  final bool isBatteryCharging;

  /// Активна ли портативная станция
  final bool isPortableActive;

  /// Заряжается ли портативная станция
  final bool isPortableCharging;

  /// ===========================
  /// Баланс системы
  /// ===========================

  /// Итоговый баланс мощности
  ///
  /// > 0 → профицит
  /// < 0 → дефицит
  final double energyBalanceWatts;

  /// Время расчета
  final DateTime timestamp;

  factory EnergyFlowState.empty() {
    return EnergyFlowState(
      houseConsumptionWatts: 0,
      solarGenerationWatts: 0,
      gridPowerWatts: 0,
      batteryPowerWatts: 0,
      generatorPowerWatts: 0,
      portablePowerWatts: 0,
      batterySoc: 100,
      isGridConnected: true,
      isGeneratorRunning: false,
      isBatteryCharging: false,
      isPortableActive: false,
      isPortableCharging: false,
      energyBalanceWatts: 0,
      timestamp: DateTime.now(),
    );
  }

  EnergyFlowState copyWith({
    double? houseConsumptionWatts,
    double? solarGenerationWatts,
    double? gridPowerWatts,
    double? batteryPowerWatts,
    double? generatorPowerWatts,
    double? portablePowerWatts,
    double? batterySoc,
    bool? isGridConnected,
    bool? isGeneratorRunning,
    bool? isBatteryCharging,
    bool? isPortableActive,
    bool? isPortableCharging,
    double? energyBalanceWatts,
    DateTime? timestamp,
  }) {
    return EnergyFlowState(
      houseConsumptionWatts:
          houseConsumptionWatts ?? this.houseConsumptionWatts,
      solarGenerationWatts:
          solarGenerationWatts ?? this.solarGenerationWatts,
      gridPowerWatts:
          gridPowerWatts ?? this.gridPowerWatts,
      batteryPowerWatts:
          batteryPowerWatts ?? this.batteryPowerWatts,
      generatorPowerWatts:
          generatorPowerWatts ?? this.generatorPowerWatts,
      portablePowerWatts:
          portablePowerWatts ?? this.portablePowerWatts,
      batterySoc:
          batterySoc ?? this.batterySoc,
      isGridConnected:
          isGridConnected ?? this.isGridConnected,
      isGeneratorRunning:
          isGeneratorRunning ?? this.isGeneratorRunning,
      isBatteryCharging:
          isBatteryCharging ?? this.isBatteryCharging,
      isPortableActive:
          isPortableActive ?? this.isPortableActive,
      isPortableCharging:
          isPortableCharging ?? this.isPortableCharging,
      energyBalanceWatts:
          energyBalanceWatts ?? this.energyBalanceWatts,
      timestamp:
          timestamp ?? this.timestamp,
    );
  }
}