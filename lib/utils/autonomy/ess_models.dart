// lib/utils/autonomy/ess_models.dart

class EssSystemSettings {
  const EssSystemSettings({
  required this.batteries,
  required this.inverters,
  required this.solarArrays,
  required this.mppts,
    required this.generators,
    required this.windGenerators,
    required this.hydroStations,
    required this.evSystems,
    required this.grid,
    required this.ats,
    required this.smartMeter,
    required this.loadShedding,
    required this.pvDiverter,
    required this.monitoring,
    required this.cooling,
    required this.heating,
    required this.balancers,
    required this.soh,
  });

  final List<BatterySystem> batteries;

  final List<InverterSystem> inverters;
  final List<SolarArray> solarArrays;
  final List<MpptSystem> mppts;
  final List<GeneratorSystem> generators;
  final List<WindGeneratorSystem> windGenerators;
  final List<HydroGeneratorSystem> hydroStations;
  final List<EvBackupSystem> evSystems;

  final GridSystem grid;

  final AtsSystem? ats;
  final SmartMeterSystem? smartMeter;
  final LoadSheddingSystem? loadShedding;
  final PvDiverterSystem? pvDiverter;
  final MonitoringSystem? monitoring;
  final CoolingSystem? cooling;
  final HeatingSystem? heating;
  final List<BalancerSystem> balancers;
  final SohSystem? soh;
}

////////////////////////////////////////////////////////////////
/// BATTERY
////////////////////////////////////////////////////////////////

class BatterySystem {
  const BatterySystem({
    required this.capacityWh,
    required this.voltage,
    required this.soc,
    required this.dod,
    required this.soh,
    required this.maxChargeCurrent,
    required this.maxDischargeCurrent,
    required this.type,
    required this.hasHeating,
    required this.hasCooling,
  });

  final double capacityWh;
  final double voltage;

  final double soc;
  final double dod;
  final double soh;

  final double maxChargeCurrent;
  final double maxDischargeCurrent;

  final String type;

  final bool hasHeating;
  final bool hasCooling;
}

////////////////////////////////////////////////////////////////
/// INVERTER
////////////////////////////////////////////////////////////////

class InverterSystem {
  const InverterSystem({
    required this.powerKw,
    required this.efficiency,
    required this.idleConsumption,
    required this.parallel,
    required this.exportEnabled,
  });

  final double powerKw;
  final double efficiency;
  final double idleConsumption;

  final bool parallel;
  final bool exportEnabled;
}

////////////////////////////////////////////////////////////////
/// SOLAR
////////////////////////////////////////////////////////////////

class SolarArray {
  const SolarArray({
    required this.peakPowerKw,
    required this.orientationFactor,
    required this.tiltFactor,
    required this.shadingFactor,
    required this.mountFactor,
    required this.lifetimeFactor,
    required this.bifacial,
    required this.albedoBonus,
  });

  final double peakPowerKw;

  final double orientationFactor;
  final double tiltFactor;
  final double shadingFactor;
  final double mountFactor;
  final double lifetimeFactor;

  final bool bifacial;
  final double albedoBonus;
}

////////////////////////////////////////////////////////////////
/// MPPT
////////////////////////////////////////////////////////////////

class MpptSystem {
  const MpptSystem({
    required this.efficiency,
    required this.maxVoltage,
    required this.maxCurrent,
  });

  final double efficiency;
  final double maxVoltage;
  final double maxCurrent;
}

////////////////////////////////////////////////////////////////
/// GENERATOR
////////////////////////////////////////////////////////////////

class GeneratorSystem {
  const GeneratorSystem({
    required this.powerKw,
    required this.fuelConsumption,
    required this.autoStart,
    required this.startSoc,
    required this.stopSoc,
  });

  final double powerKw;

  final double fuelConsumption;

  final bool autoStart;

  final double startSoc;
  final double stopSoc;
}

////////////////////////////////////////////////////////////////
/// WIND
////////////////////////////////////////////////////////////////

class WindGeneratorSystem {
  const WindGeneratorSystem({
    required this.powerKw,
    required this.capacityFactor,
  });

  final double powerKw;
  final double capacityFactor;
}

////////////////////////////////////////////////////////////////
/// HYDRO
////////////////////////////////////////////////////////////////

class HydroGeneratorSystem {
  const HydroGeneratorSystem({
    required this.powerKw,
    required this.capacityFactor,
  });

  final double powerKw;
  final double capacityFactor;
}

////////////////////////////////////////////////////////////////
/// EV
////////////////////////////////////////////////////////////////

class EvBackupSystem {
  const EvBackupSystem({
    required this.enabled,
    required this.capacityWh,
    required this.reserveSoc,
  });

  final bool enabled;
  final double capacityWh;
  final double reserveSoc;
}

////////////////////////////////////////////////////////////////
/// GRID
////////////////////////////////////////////////////////////////

class GridSystem {
  const GridSystem({
    required this.connected,
    required this.blackoutHours,
  });

  final bool connected;
  final double blackoutHours;
}

////////////////////////////////////////////////////////////////
/// ATS
////////////////////////////////////////////////////////////////

class AtsSystem {
  const AtsSystem({
    required this.transferTimeMs,
  });

  final double transferTimeMs;
}

////////////////////////////////////////////////////////////////
/// SMART METER
////////////////////////////////////////////////////////////////

class SmartMeterSystem {
  const SmartMeterSystem({
    required this.installed,
  });

  final bool installed;
}

////////////////////////////////////////////////////////////////
/// LOAD SHEDDING
////////////////////////////////////////////////////////////////

class LoadSheddingSystem {
  const LoadSheddingSystem({
    required this.secondarySoc,
    required this.importantSoc,
    required this.emergencySoc,
  });

  final double secondarySoc;
  final double importantSoc;
  final double emergencySoc;
}

////////////////////////////////////////////////////////////////
/// PV DIVERTER
////////////////////////////////////////////////////////////////

class PvDiverterSystem {
  const PvDiverterSystem({
    required this.enabled,
    required this.triggerPower,
  });

  final bool enabled;
  final double triggerPower;
}

////////////////////////////////////////////////////////////////
/// MONITORING
////////////////////////////////////////////////////////////////

class MonitoringSystem {
  const MonitoringSystem({
    required this.selfConsumption,
  });

  final double selfConsumption;
}

////////////////////////////////////////////////////////////////
/// COOLING
////////////////////////////////////////////////////////////////

class CoolingSystem {
  const CoolingSystem({
    required this.enabled,
    required this.power,
  });

  final bool enabled;
  final double power;
}

////////////////////////////////////////////////////////////////
/// HEATING
////////////////////////////////////////////////////////////////

class HeatingSystem {
  const HeatingSystem({
    required this.enabled,
    required this.power,
  });

  final bool enabled;
  final double power;
}

////////////////////////////////////////////////////////////////
/// BALANCER
////////////////////////////////////////////////////////////////

class BalancerSystem {
  const BalancerSystem({
    required this.enabled,
    required this.power,
  });

  final bool enabled;
  final double power;
}

////////////////////////////////////////////////////////////////
/// SOH
////////////////////////////////////////////////////////////////

class SohSystem {
  const SohSystem({
    required this.value,
  });

  final double value;
}