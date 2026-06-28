import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'ess_models.dart';
import '../device_detector.dart';

class EssSystemLoader {
  const EssSystemLoader._();

  static const String _storageKey = 'tabDevices';

  static Future<EssSystemSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString(_storageKey);

    if (json == null || json.isEmpty) {
      return _emptySettings();
    }

    final decoded = jsonDecode(json);

    final Map<int, List<Map<String, dynamic>>> tabs = {};

    if (decoded is Map) {
      decoded.forEach((key, value) {
        final index = int.tryParse(key.toString()) ?? 0;

        final devices = <Map<String, dynamic>>[];

        if (value is List) {
          for (final item in value) {
            if (item is Map<String, dynamic>) {
              devices.add(item);
            } else if (item is Map) {
              devices.add(Map<String, dynamic>.from(item));
            }
          }
        }

        tabs[index] = devices;
      });
    }

    return _parseTabs(tabs);
  }

  static EssSystemSettings _parseTabs(
    Map<int, List<Map<String, dynamic>>> tabs,
  ) {
    final batteries = <BatterySystem>[];

    final inverters = <InverterSystem>[];

    final solarArrays = <SolarArray>[];

    final mppts = <MpptSystem>[];

    final generators = <GeneratorSystem>[];

    final windGenerators = <WindGeneratorSystem>[];

    final hydroStations = <HydroGeneratorSystem>[];

    final evSystems = <EvBackupSystem>[];

    final balancers = <BalancerSystem>[];

    GridSystem grid = const GridSystem(
      connected: false,
      blackoutHours: 0,
    );

    AtsSystem? ats;

    SmartMeterSystem? smartMeter;

    LoadSheddingSystem? loadShedding;

    PvDiverterSystem? pvDiverter;

    MonitoringSystem? monitoring;

    CoolingSystem? cooling;

    HeatingSystem? heating;

    SohSystem? soh;

    for (final devices in tabs.values) {
      for (final device in devices) {
        final title = _readString(
          device,
          [
            'title',
            'name',
          ],
          '',
        );

        final type = DeviceDetector.detect(title);

        switch (type) {
         case DeviceType.battery:
  {
    final capacity =
        _readDouble(device, ['batCapacity'], 0);

    final voltage =
        _readDouble(device, ['batVoltage'], 51.2);

    final count =
        _readInt(device, ['batCount'], 1);

    final totalCapacityWh =
    _readDouble(
      device,
      ['batCapacityWh'],
      capacity * voltage * count,
    );

    batteries.add(
      BatterySystem(
        capacityWh: totalCapacityWh,
        voltage: voltage,
        soc: 100,
        dod: _readDouble(
          device,
          ['dod'],
          90,
        ),
        soh: 100,
        maxChargeCurrent: _readDouble(
          device,
          ['batChargeCurrent'],
          0,
        ),
        maxDischargeCurrent: _readDouble(
          device,
          ['batDischargeCurrent'],
          0,
        ),
        type: _readString(
          device,
          ['batType'],
          '',
        ),
        hasHeating: _readBool(
          device,
          ['hasBatteryHeating'],
          false,
        ),
        hasCooling: _readBool(
          device,
          ['hasBatteryCooling'],
          false,
        ),
      ),
    );

    break;
  }

case DeviceType.inverter:
  {
    inverters.add(
      InverterSystem(
        powerKw: _readDouble(
          device,
          ['invPower'],
          0,
        ),
        efficiency: _readDouble(
          device,
          ['invKkd'],
          95,
        ),
        idleConsumption: _readDouble(
          device,
          ['invOwn'],
          25,
        ),
        parallel: _readBool(
          device,
          ['isParallel'],
          false,
        ),
        exportEnabled: _readBool(
          device,
          ['isGridExport'],
          false,
        ),
      ),
    );

    break;
  }

case DeviceType.solar:
  {
    solarArrays.add(
      SolarArray(
        peakPowerKw:
            _readDouble(
                  device,
                  ['solarGeneration'],
                  0,
                ) >
                0
            ? _readDouble(
                device,
                ['solarGeneration'],
                0,
              )
            : _readDouble(
                    device,
                    ['solarGenerationW'],
                    0,
                  ) /
                1000,

        orientationFactor: _orientationFactor(
          _readString(
            device,
            ['orientation'],
            '',
          ),
        ),

        tiltFactor: _tiltFactor(
          _readString(
            device,
            ['tilt'],
            '',
          ),
        ),

        shadingFactor: _shadingFactor(
          _readString(
            device,
            ['shading'],
            '',
          ),
        ),

        mountFactor: _mountFactor(
          _readString(
            device,
            ['mountType'],
            '',
          ),
        ),

        lifetimeFactor: _lifetimeFactor(
          _readString(
            device,
            ['lifespan'],
            '',
          ),
        ),

        bifacial: _readBool(
          device,
          ['isBifacial'],
          false,
        ),

        albedoBonus: _readDouble(
          device,
          ['albedoBonus'],
          0,
        ),
      ),
    );

    break;
  }

case DeviceType.mppt:
  {
    mppts.add(
      MpptSystem(
        efficiency: _readDouble(
          device,
          ['mpptEfficiency'],
          98,
        ),
        maxVoltage: _readDouble(
          device,
          ['mpptMaxVoltage'],
          0,
        ),
        maxCurrent: _readDouble(
          device,
          ['mpptMaxCurrent'],
          0,
        ),
      ),
    );

    break;
  }
          case DeviceType.generator:
  {
    generators.add(
      GeneratorSystem(
        powerKw: _readDouble(
          device,
          ['genPower'],
          0,
        ),

        fuelConsumption: _readDouble(
          device,
          ['genConsumption'],
          0,
        ),

        autoStart: _readBool(
          device,
          ['hasAvr'],
          false,
        ),

        startSoc: _readDouble(
          device,
          ['generatorStartSoc'],
          20,
        ),

        stopSoc: _readDouble(
          device,
          ['generatorStopSoc'],
          80,
        ),
      ),
    );

    break;
  }

case DeviceType.windGenerator:
  {
    windGenerators.add(
      WindGeneratorSystem(
        powerKw: _readDouble(
          device,
          ['whPower'],
          0,
        ),

        capacityFactor: _readDouble(
          device,
          ['windCf'],
          0.30,
        ),
      ),
    );

    break;
  }

case DeviceType.microHydro:
  {
    hydroStations.add(
      HydroGeneratorSystem(
        powerKw: _readDouble(
          device,
          ['whPower'],
          0,
        ),

        capacityFactor: _readBool(
          device,
          ['hydro24x7'],
          false,
        )
            ? 1.0
            : _readDouble(
                device,
                ['hydroCf'],
                0.75,
              ),
      ),
    );

    break;
  }

case DeviceType.ev:
  {
    evSystems.add(
      EvBackupSystem(
        enabled: true,

        capacityWh:
            _readDouble(
                  device,
                  ['evCapacity'],
                  0,
                ) *
            1000,

        reserveSoc: _readDouble(
          device,
          ['reservedVehicleSoc'],
          20,
        ),
      ),
    );

    break;
  }
case DeviceType.portableStation:
{
  final capacityWh =
      _readDouble(device, ['portableCapacity'], 0);

  final inverterKw =
      _readDouble(device, ['portableInverter'], 0);

  evSystems.add(
    EvBackupSystem(
      enabled: true,
      capacityWh: capacityWh,
      reserveSoc: 0,
    ),
  );

  inverters.add(
    InverterSystem(
      powerKw: inverterKw,
      efficiency: 90,
      idleConsumption: 10,
      parallel: false,
      exportEnabled: false,
    ),
  );

  break;
}
case DeviceType.evCharger:
{
  monitoring ??= MonitoringSystem(
    selfConsumption: 5,
  );

  break;
}

case DeviceType.grid:
  {
    grid = GridSystem(
      connected: true,

      blackoutHours: 0,
    );

    break;
  }

         case DeviceType.ats:
  {
    ats = AtsSystem(
      transferTimeMs: _readDouble(
        device,
        ['atsTransferTime'],
        0,
      ),
    );

    break;
  }

case DeviceType.smartMeter:
  {
    smartMeter = SmartMeterSystem(
      installed: true,
    );

    break;
  }

case DeviceType.monitoring:
  {
    monitoring = MonitoringSystem(
      selfConsumption: 5,
    );

    break;
  }
case DeviceType.smartAutomation:
{
  monitoring ??= MonitoringSystem(
    selfConsumption: 8,
  );

  break;
}
case DeviceType.loadShedding:
  {
    loadShedding = LoadSheddingSystem(
      secondarySoc: _readDouble(
        device,
        ['secondaryOffSoc'],
        30,
      ),

      importantSoc: _readDouble(
        device,
        ['importantOffSoc'],
        20,
      ),

      emergencySoc: _readDouble(
        device,
        ['emergencyOffSoc'],
        10,
      ),
    );

    break;
  }
case DeviceType.dryContact:
{
  if (generators.isNotEmpty) {
    final gen = generators.last;

    generators[generators.length - 1] =
        GeneratorSystem(
      powerKw: gen.powerKw,
      fuelConsumption: gen.fuelConsumption,
      autoStart: true,
      startSoc: gen.startSoc,
      stopSoc: gen.stopSoc,
    );
  }

  break;
}
case DeviceType.stabilizer:
{
  monitoring ??= MonitoringSystem(
    selfConsumption: 3,
  );

  break;
}

case DeviceType.voltageRelay:
{
  monitoring ??= MonitoringSystem(
    selfConsumption: 2,
  );

  break;
}
case DeviceType.surgeProtection:
{
  break;
}
case DeviceType.rcd:
{
  break;
}
case DeviceType.diverter:
  {
    pvDiverter = PvDiverterSystem(
      enabled: _readBool(
        device,
        ['pvEnabled'],
        false,
      ),

      triggerPower: _readDouble(
        device,
        ['pvTrigger'],
        0,
      ),
    );

    break;
  }

case DeviceType.batteryBalancer:
  {
    balancers.add(
      BalancerSystem(
        enabled: _readBool(
          device,
          ['balancerEnabled'],
          false,
        ),

        power: _readDouble(
          device,
          ['balancerCurrent'],
          0,
        ),
      ),
    );

    break;
  }

case DeviceType.batteryHeater:
  {
    heating = HeatingSystem(
      enabled: _readBool(
        device,
        ['batteryHeaterEnabled'],
        false,
      ),

      power: _readDouble(
        device,
        ['heaterPower'],
        300,
      ),
    );

    break;
  }

case DeviceType.ventilation:
  {
    cooling = CoolingSystem(
      enabled: _readBool(
        device,
        ['coolingEnabled'],
        false,
      ),

      power: 120,
    );

    break;
  }

case DeviceType.batterySohAnalyzer:
  {
    soh = SohSystem(
      value: _readDouble(
        device,
        ['sohWarning'],
        100,
      ),
    );

    break;
  }

          default:
            break;
        }
      }
    }

    // ======================================================
// BATTERY
// ======================================================

final List<BatterySystem> finalBatteries = batteries;

// ======================================================
// INVERTERS
// ======================================================

final List<InverterSystem> finalInverters = inverters;

// ======================================================
// SOLAR
// ======================================================

final List<SolarArray> finalSolar = solarArrays;

// ======================================================
// MPPT
// ======================================================

final List<MpptSystem> finalMppt = mppts;

// ======================================================
// GENERATORS
// ======================================================

final List<GeneratorSystem> finalGenerators = generators;

// ======================================================
// WIND
// ======================================================

final List<WindGeneratorSystem> finalWind =
    windGenerators;

// ======================================================
// HYDRO
// ======================================================

final List<HydroGeneratorSystem> finalHydro =
    hydroStations;

// ======================================================
// EV
// ======================================================

final List<EvBackupSystem> finalEv =
    evSystems;

// ======================================================
// BALANCERS
// ======================================================

final List<BalancerSystem> finalBalancers =
    balancers;

// ======================================================
// RETURN
// ======================================================

return EssSystemSettings(
  batteries: finalBatteries,

  inverters: finalInverters,

  solarArrays: finalSolar,

  mppts: finalMppt,

  generators: finalGenerators,

  windGenerators: finalWind,

  hydroStations: finalHydro,

  evSystems: finalEv,

  grid: grid,

  ats: ats,

  smartMeter: smartMeter,

  loadShedding: loadShedding,

  pvDiverter: pvDiverter,

  monitoring: monitoring,

  cooling: cooling,

  heating: heating,

  balancers: finalBalancers,

  soh: soh,
);
  }

  // =======================================================
  // READERS
  // =======================================================

  static double _readDouble(
    Map<String, dynamic> device,
    List<String> keys,
    double defaultValue,
  ) {
    for (final key in keys) {
      final value = device[key];

      if (value == null) continue;

      if (value is num) {
        return value.toDouble();
      }

      final parsed = double.tryParse(value.toString());

      if (parsed != null) {
        return parsed;
      }
    }

    return defaultValue;
  }

  static int _readInt(
    Map<String, dynamic> device,
    List<String> keys,
    int defaultValue,
  ) {
    for (final key in keys) {
      final value = device[key];

      if (value == null) continue;

      if (value is int) {
        return value;
      }

      final parsed = int.tryParse(value.toString());

      if (parsed != null) {
        return parsed;
      }
    }

    return defaultValue;
  }

  static bool _readBool(
    Map<String, dynamic> device,
    List<String> keys,
    bool defaultValue,
  ) {
    for (final key in keys) {
      final value = device[key];

      if (value == null) continue;

      if (value is bool) {
        return value;
      }

      if (value.toString().toLowerCase() == 'true') {
        return true;
      }

      if (value.toString().toLowerCase() == 'false') {
        return false;
      }
    }

    return defaultValue;
  }

  static String _readString(
    Map<String, dynamic> device,
    List<String> keys,
    String defaultValue,
  ) {
    for (final key in keys) {
      final value = device[key];

      if (value != null) {
        return value.toString();
      }
    }

    return defaultValue;
  }
static double _orientationFactor(String value) {
  switch (value.toLowerCase()) {
    case 'south':
    case 'південь':
      return 1.0;

    case 'south-east':
    case 'south-west':
    case 'південний схід':
    case 'південний захід':
      return 0.96;

    case 'east':
    case 'west':
    case 'схід':
    case 'захід':
      return 0.90;

    case 'north':
    case 'північ':
      return 0.65;

    default:
      return 1.0;
  }
}

static double _tiltFactor(String value) {
  final angle = double.tryParse(value);

  if (angle == null) {
    return 1.0;
  }

  if (angle >= 25 && angle <= 40) {
    return 1.0;
  }

  if (angle >= 15 && angle <= 50) {
    return 0.97;
  }

  return 0.92;
}

static double _shadingFactor(String value) {
  switch (value.toLowerCase()) {
    case 'none':
    case 'немає':
      return 1.0;

    case 'light':
    case 'легке':
      return 0.95;

    case 'medium':
    case 'середнє':
      return 0.80;

    case 'heavy':
    case 'сильне':
      return 0.55;

    default:
      return 1.0;
  }
}

static double _mountFactor(String value) {
  switch (value.toLowerCase()) {
    case 'ground':
      return 1.02;

    case 'roof':
      return 1.0;

    case 'balcony':
      return 0.93;

    default:
      return 1.0;
  }
}

static double _lifetimeFactor(String value) {
  final years = double.tryParse(value);

  if (years == null) {
    return 1.0;
  }

  final loss = years * 0.005;

  return (1 - loss).clamp(0.80, 1.0);
}
static double totalBatteryCapacity(
    List<BatterySystem> batteries,
) {
  return batteries.fold(
    0,
    (sum, battery) => sum + battery.capacityWh,
  );
}

static double totalSolarPower(
    List<SolarArray> arrays,
) {
  return arrays.fold(
    0,
    (sum, panel) => sum + panel.peakPowerKw,
  );
}

static double totalGeneratorPower(
    List<GeneratorSystem> generators,
) {
  return generators.fold(
    0,
    (sum, generator) => sum + generator.powerKw,
  );
}

static double totalWindPower(
    List<WindGeneratorSystem> generators,
) {
  return generators.fold(
    0,
    (sum, generator) => sum + generator.powerKw,
  );
}

static double totalHydroPower(
    List<HydroGeneratorSystem> generators,
) {
  return generators.fold(
    0,
    (sum, generator) => sum + generator.powerKw,
  );
}

static double totalEvCapacity(
    List<EvBackupSystem> vehicles,
) {
  return vehicles.fold(
    0,
    (sum, vehicle) => sum + vehicle.capacityWh,
  );
}

static double averageInverterEfficiency(
    List<InverterSystem> inverters,
) {
  if (inverters.isEmpty) {
    return 95;
  }

  final value = inverters.fold<double>(
    0,
    (sum, inverter) => sum + inverter.efficiency,
  );

  return value / inverters.length;
}

static double inverterIdleConsumption(
    List<InverterSystem> inverters,
) {
  return inverters.fold(
    0,
    (sum, inverter) => sum + inverter.idleConsumption,
  );
}
static double monitoringConsumption(
    MonitoringSystem? monitoring,
) {
  if (monitoring == null) return 0;

  return monitoring.selfConsumption;
}

static double heaterConsumption(
    HeatingSystem? heater,
) {
  if (heater == null) return 0;

  if (!heater.enabled) return 0;

  return heater.power;
}

static double coolingConsumption(
    CoolingSystem? cooling,
) {
  if (cooling == null) return 0;

  if (!cooling.enabled) return 0;

  return cooling.power;
}

static double balancerConsumption(
    List<BalancerSystem> balancers,
) {
  double power = 0;

  for (final b in balancers) {
    if (!b.enabled) continue;

    power += b.power;
  }

  return power;
}

static bool hasLoadShedding(
    LoadSheddingSystem? system,
) {
  return system != null;
}

static bool hasSmartMeter(
    SmartMeterSystem? meter,
) {
  return meter != null;
}

static bool hasATS(
    AtsSystem? ats,
) {
  return ats != null;
}

static bool hasGenerator(
    List<GeneratorSystem> generators,
) {
  return generators.isNotEmpty;
}

static bool hasSolar(
    List<SolarArray> arrays,
) {
  return arrays.isNotEmpty;
}

static bool hasWind(
    List<WindGeneratorSystem> arrays,
) {
  return arrays.isNotEmpty;
}

static bool hasHydro(
    List<HydroGeneratorSystem> arrays,
) {
  return arrays.isNotEmpty;
}

static bool hasBattery(
    List<BatterySystem> batteries,
) {
  return batteries.isNotEmpty;
}
  // =======================================================
  // EMPTY MODEL
  // =======================================================

  static EssSystemSettings _emptySettings() {
    return const EssSystemSettings(
      batteries: const [],
      inverters: [],
      solarArrays: [],
      mppts: [],
      generators: [],
      windGenerators: [],
      hydroStations: [],
      evSystems: [],
      grid: GridSystem(
        connected: false,
        blackoutHours: 0,
      ),
      ats: null,
      smartMeter: null,
      loadShedding: null,
      pvDiverter: null,
      monitoring: null,
      cooling: null,
      heating: null,
      balancers: [],
      soh: null,
    );
  }
  // ======================================================
// HELPERS
// ======================================================

static double totalBatteryWh(
    EssSystemSettings settings) {
  return settings.batteries.fold(
    0,
    (sum, battery) => sum + battery.capacityWh,
  );
}

static double totalSolarKw(
    EssSystemSettings settings) {
  return settings.solarArrays.fold(
    0,
    (sum, solar) => sum + solar.peakPowerKw,
  );
}

static double totalGeneratorKw(
    EssSystemSettings settings) {
  return settings.generators.fold(
    0,
    (sum, generator) => sum + generator.powerKw,
  );
}

static double totalWindKw(
    EssSystemSettings settings) {
  return settings.windGenerators.fold(
    0,
    (sum, wind) => sum + wind.powerKw,
  );
}

static double totalHydroKw(
    EssSystemSettings settings) {
  return settings.hydroStations.fold(
    0,
    (sum, hydro) => sum + hydro.powerKw,
  );
}

static double totalEvWh(
    EssSystemSettings settings) {
  return settings.evSystems.fold(
    0,
    (sum, ev) => sum + ev.capacityWh,
  );
}


}