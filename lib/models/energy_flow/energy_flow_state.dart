// lib/models/energy_flow/energy_flow_state.dart

import 'energy_node.dart';
import 'energy_connection.dart';

/// Режимы работы всей энергосистемы
enum SystemMode {
  gridTied,       // Работа параллельно с внешней сетью (обычный режим)
  island,         // Автономный режим / Островной (сеть отключена, питаемся от АКБ/Солнца)
  eco,            // Экономичный режим (максимальный приоритет на собственное потребление)
  emergencyBackup, // Аварийный режим (работает генератор или критический разряд АКБ)
}

class EnergyFlowState {
  /// ├── summary (Мгновенные числовые показатели мощности устройств)
  final EnergySummary summary;

  /// ├── nodes (Список топологических узлов энергосистемы для UI)
  final List<EnergyNode> nodes;

  /// ├── connections (Список линий связи и направлений потоков между узлами)
  final List<EnergyConnection> connections;

  /// └── statistics (Расчетные данные, баланс и временные метки)
  final EnergyStatistics statistics;

  /// Текущий режим работы системы
  final SystemMode systemMode;

  /// Текущий доминирующий источник энергии (например, "Solar + Battery" или "Grid")
  final String currentSource;

  /// Текущий основной потребитель энергии (например, "House Load" или "Battery Charging")
  final String currentConsumer;

  const EnergyFlowState({
    required this.summary,
    required this.nodes,
    required this.connections,
    required this.statistics,
    required this.systemMode,
    required this.currentSource,
    required this.currentConsumer,
  });

  /// Фабричный метод для создания дефолтного (пустого) состояния.
  /// Спасает от ошибок инициализации на первом кадре UI (например, в initState).
  factory EnergyFlowState.empty() {
    return EnergyFlowState(
      summary: const EnergySummary(
        houseConsumptionWatts: 0.0,
        solarGenerationWatts: 0.0,
        gridPowerWatts: 0.0,
        batteryPowerWatts: 0.0,
        generatorPowerWatts: 0.0,
        portablePowerWatts: 0.0,
        batterySoc: 0.0,
      ),
      nodes: const [],
      connections: const [],
      statistics: EnergyStatistics(
        energyBalanceWatts: 0.0,
        timestamp: DateTime.now(),
        isGridConnected: true,
        isGeneratorRunning: false,
        isBatteryCharging: false,
        isPortableActive: false,
        isPortableCharging: false,
      ),
      systemMode: SystemMode.gridTied,
      currentSource: 'None',
      currentConsumer: 'None',
    );
  }

  /// Метод для иммутабельного обновления состояния
  EnergyFlowState copyWith({
    EnergySummary? summary,
    List<EnergyNode>? nodes,
    List<EnergyConnection>? connections,
    EnergyStatistics? statistics,
    SystemMode? systemMode,
    String? currentSource,
    String? currentConsumer,
  }) {
    return EnergyFlowState(
      summary: summary ?? this.summary,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      statistics: statistics ?? this.statistics,
      systemMode: systemMode ?? this.systemMode,
      currentSource: currentSource ?? this.currentSource,
      currentConsumer: currentConsumer ?? this.currentConsumer,
    );
  }
}

// ============================================================================
// Вспомогательные дата-классы для структуры EnergyFlowState
// ============================================================================

/// Группа базовых числовых показателей (Summary)
class EnergySummary {
  final double houseConsumptionWatts;
  final double solarGenerationWatts;
  final double gridPowerWatts;
  final double batteryPowerWatts;
  final double generatorPowerWatts;
  final double portablePowerWatts;
  final double batterySoc;

  const EnergySummary({
    required this.houseConsumptionWatts,
    required this.solarGenerationWatts,
    required this.gridPowerWatts,
    required this.batteryPowerWatts,
    required this.generatorPowerWatts,
    required this.portablePowerWatts,
    required this.batterySoc,
  });

  EnergySummary copyWith({
    double? houseConsumptionWatts,
    double? solarGenerationWatts,
    double? gridPowerWatts,
    double? batteryPowerWatts,
    double? generatorPowerWatts,
    double? portablePowerWatts,
    double? batterySoc,
  }) {
    return EnergySummary(
      houseConsumptionWatts: houseConsumptionWatts ?? this.houseConsumptionWatts,
      solarGenerationWatts: solarGenerationWatts ?? this.solarGenerationWatts,
      gridPowerWatts: gridPowerWatts ?? this.gridPowerWatts,
      batteryPowerWatts: batteryPowerWatts ?? this.batteryPowerWatts,
      generatorPowerWatts: generatorPowerWatts ?? this.generatorPowerWatts,
      portablePowerWatts: portablePowerWatts ?? this.portablePowerWatts,
      batterySoc: batterySoc ?? this.batterySoc,
    );
  }
}

/// Группа расчетных флагов, баланса и аналитики (Statistics)
class EnergyStatistics {
  final double energyBalanceWatts;
  final DateTime timestamp;
  final bool isGridConnected;
  final bool isGeneratorRunning;
  final bool isBatteryCharging;
  final bool isPortableActive;
  final bool isPortableCharging;

  const EnergyStatistics({
    required this.energyBalanceWatts,
    required this.timestamp,
    required this.isGridConnected,
    required this.isGeneratorRunning,
    required this.isBatteryCharging,
    required this.isPortableActive,
    required this.isPortableCharging,
  });

  EnergyStatistics copyWith({
    double? energyBalanceWatts,
    DateTime? timestamp,
    bool? isGridConnected,
    bool? isGeneratorRunning,
    bool? isBatteryCharging,
    bool? isPortableActive,
    bool? isPortableCharging,
  }) {
    return EnergyStatistics(
      energyBalanceWatts: energyBalanceWatts ?? this.energyBalanceWatts,
      timestamp: timestamp ?? this.timestamp,
      isGridConnected: isGridConnected ?? this.isGridConnected,
      isGeneratorRunning: isGeneratorRunning ?? this.isGeneratorRunning,
      isBatteryCharging: isBatteryCharging ?? this.isBatteryCharging,
      isPortableActive: isPortableActive ?? this.isPortableActive,
      isPortableCharging: isPortableCharging ?? this.isPortableCharging,
    );
  }
}