import '../../models/energy_flow/energy_flow_state.dart';
import '../autonomy/ess_models.dart';

class EnergyFlowEngine {
  const EnergyFlowEngine();

  /// Формирует текущее состояние энергосистемы.
  ///
  /// Сюда переносится математика из AutonomyCalculatorWidget,
  /// включая логику работы портативных станций (через evSystems).
  EnergyFlowState calculate({
    required EssSystemSettings settings,
    required double houseConsumptionWatts,
    required double solarGenerationWatts,
    required double batteryPowerWatts,
    required double generatorPowerWatts,
    required double gridPowerWatts,
    double portablePowerWatts = 0.0,
  }) {
    //----------------------------------------------------------------------
    // SOC батареи
    //----------------------------------------------------------------------

    double batterySoc = 100;

    if (settings.batteries.isNotEmpty) {
      batterySoc = settings.batteries.first.soc;
    }

    //----------------------------------------------------------------------
    // Наличие портативной станции (в системе это EvBackupSystem)
    //----------------------------------------------------------------------
    
    final hasPortableStation = settings.evSystems.isNotEmpty;

    //----------------------------------------------------------------------
    // Баланс системы
    //----------------------------------------------------------------------

    final energyBalanceWatts =
        solarGenerationWatts +
        generatorPowerWatts -
        houseConsumptionWatts -
        batteryPowerWatts -
        portablePowerWatts - 
        gridPowerWatts;

    //----------------------------------------------------------------------
    // Состояния
    //----------------------------------------------------------------------

    final isGridConnected = settings.grid.connected;

    final isGeneratorRunning = generatorPowerWatts > 0;

    final isBatteryCharging = batteryPowerWatts < 0;

    final isPortableActive = hasPortableStation && portablePowerWatts != 0;
    
    final isPortableCharging = portablePowerWatts < 0;

    //----------------------------------------------------------------------
    // Финальный объект
    //----------------------------------------------------------------------

    return EnergyFlowState(
      houseConsumptionWatts: houseConsumptionWatts,
      solarGenerationWatts: solarGenerationWatts,
      gridPowerWatts: gridPowerWatts,
      batteryPowerWatts: batteryPowerWatts,
      generatorPowerWatts: generatorPowerWatts,
      portablePowerWatts: portablePowerWatts,
      batterySoc: batterySoc,
      isGridConnected: isGridConnected,
      isGeneratorRunning: isGeneratorRunning,
      isBatteryCharging: isBatteryCharging,
      isPortableActive: isPortableActive,
      isPortableCharging: isPortableCharging,
      energyBalanceWatts: energyBalanceWatts,
      timestamp: DateTime.now(),
    );
  }
}