import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:nuvit/utils/calculations/ev_calculator.dart';
import 'package:nuvit/utils/calculations/mppt_calculator.dart';
import 'package:nuvit/utils/calculations/generator_calculator.dart';
import 'package:nuvit/utils/calculations/grid_calculator.dart';
import '../../utils/calculations/battery_calculator.dart';
import '../../utils/calculations/ats_calculator.dart';
import '../../utils/calculations/meter_calculator.dart';
import '../../utils/device_detector.dart';
import '../../utils/constants/solar_constants.dart';
import '../../utils/constants/inverter_presets.dart';
import '../../utils/constants/device_catalog.dart';
import '../../utils/models/device_info.dart';
import 'package:nuvit/utils/constants/dropdown_options.dart';


class ConnectEquipmentPage extends StatelessWidget {
  final int categoryIndex;
  final int propertyType; // 0 - Квартира, 1 - Приватний будинок
  final bool hasSolarPanels; // Контролює відображення сонячного обладнання
  final List<String> connectedDeviceNames; // Список імен вже підключеного обладнання для блокування дублікатів
List<Map<String, dynamic>> _deviceInfoToMap(
  List<DeviceInfo> devices,
) {
  return devices
      .map(
        (e) => {
          'name': e.name,
          'desc': e.description,
          'icon': e.icon,
          'allowedInApartment': e.allowedInApartment,
        },
      )
      .toList();
}
  const ConnectEquipmentPage({
    super.key,
    required this.categoryIndex,
    required this.propertyType,
    required this.hasSolarPanels,
    required this.connectedDeviceNames,
  });

  static const Color brandBg = Color(0xFF020D2D);
  static const Color brandCard = Color(0xFF0A153A);
  static const Color brandInnerBg = Color(0xFF051033);

  static const List<String> categoryTitles = [
    'Джерела живлення та генерація',
    'Захист та стабілізація мережі',
    'Автоматизація та смарт керування',
    'Оптимізація та обслуговування',
  ];

  List<Map<String, dynamic>> _getAvailableDevices() {
  switch (categoryIndex) {
    case 0:
      return _deviceInfoToMap(
        DeviceCatalog.powerSources(
          propertyType: propertyType,
        ),
      );

    case 1:
      return _deviceInfoToMap(
        DeviceCatalog.protectionDevices(
          hasSolarPanels: hasSolarPanels,
        ),
      );

    case 2:
      return _deviceInfoToMap(
        DeviceCatalog.automationDevices(
          hasSolarPanels: hasSolarPanels,
        ),
      );

    case 3:
      return _deviceInfoToMap(
        DeviceCatalog.maintenanceDevices(),
      );

    default:
      return [];
  }
}

  static Future<Map<String, dynamic>?> openDeviceSetupBottomSheet(BuildContext context, Map<String, dynamic> item, {bool isEditing = false}) async {
   
   final deviceName =
    (item['name'] ??
     item['title'] ??
     '')
        .toString();
       
  
final deviceType =
    DeviceDetector.detect(deviceName);
    // ================= ДЖЕРЕЛА ЖИВЛЕННЯ =================
    final isSolar =
    deviceType == DeviceType.solar;

final isInverter =
    deviceType == DeviceType.inverter;

final isBattery =
    deviceType == DeviceType.battery;

final isPortableStation =
    deviceType == DeviceType.portableStation;

final isGenerator =
    deviceType == DeviceType.generator;

final isWind =
    deviceType == DeviceType.windGenerator;

final isHydro =
    deviceType == DeviceType.microHydro;

final isEvRelated =
    deviceType == DeviceType.ev;

final isGrid =
    deviceType == DeviceType.grid;
    // ================= ЗАХИСТ =================
    final isStabilizer =
    deviceType == DeviceType.stabilizer;
final isMppt =
    deviceType == DeviceType.mppt;
final isVoltageRelay =
    deviceType == DeviceType.voltageRelay;

final isSurgeProtection =
    deviceType == DeviceType.surgeProtection;

final isRcd =
    deviceType == DeviceType.rcd;
    // ================= АВТОМАТИЗАЦІЯ =================
    final isSmartAutomation =
    deviceType == DeviceType.smartAutomation;

final isDryContact =
    deviceType == DeviceType.dryContact;

final isLoadShedding =
    deviceType == DeviceType.loadShedding;
    final isSmartMeter = deviceType == DeviceType.smartMeter;
final isAts = deviceType == DeviceType.ats;
final isEvCharger =
    deviceType == DeviceType.evCharger;

final isPvDiverter = deviceType == DeviceType.diverter;

    final isMonitoring =
    deviceType == DeviceType.monitoring;
// =========================
// Оптимизация и сервис
// =========================
final isBatteryBalancer =
    deviceType == DeviceType.batteryBalancer;

final isBatteryHeater =
    deviceType == DeviceType.batteryHeater;

final isBatterySohAnalyzer =
    deviceType == DeviceType.batterySohAnalyzer;


final isVentilation =
    deviceType == DeviceType.ventilation;

final nameLower =
    deviceName.toLowerCase();

  // ======================================================
// ⚡ ДЖЕРЕЛА ЖИВЛЕННЯ ТА ГЕНЕРАЦІЯ
// ======================================================

// ☀️ Сонячні панелі
final TextEditingController qtyController = TextEditingController(text: item['qty']?.toString() ?? '10');
final TextEditingController powerController = TextEditingController(text: item['power']?.toString() ?? '450');
String selectedOrientation = item['orientation'] as String? ?? 'Південь (100%)';
String selectedTilt = item['tilt'] as String? ?? '35° (Стандартний даховий, топ для літа)';
String selectedInverterType = item['inverterType'] as String? ?? 'Гібридний (Живлення будинку + заряд АКБ)';
String selectedMountType = item['mountType'] as String? ?? 'Дах скатний (Оптимальна природна вентиляція, 100%)';
String selectedShading = item['shading'] as String? ?? 'Чистий горизонт (Затінення повністю відсутнє, 100%)';
String selectedLifespan = item['lifespan'] as String? ?? 'Нові модулі (До 3 років роботи, деградація кристалу 0%)';
bool isZeroExport = item['isZeroExport'] as bool? ?? false;
bool isBifacial = item['isBifacial'] as bool? ?? false;
double selectedAlbedoBonus = (item['albedoBonus'] as num?)?.toDouble() ?? 0.08;

// 🔄 Інвертор
final TextEditingController invPowerController = TextEditingController(text: item['invPower']?.toString() ?? InverterPresets.presets[0]['power']?.toString() ?? '5.0');
final TextEditingController invKkdController = TextEditingController(text: item['invKkd']?.toString() ?? InverterPresets.presets[0]['kkd']?.toString() ?? '98');
final TextEditingController invOwnController = TextEditingController(text: item['invOwn']?.toString() ?? InverterPresets.presets[0]['ownConsumption']?.toString() ?? '50');
final TextEditingController invChargeController = TextEditingController(text: item['invCharge']?.toString() ?? InverterPresets.presets[0]['chargeCurrent']?.toString() ?? '100');
final TextEditingController invDischargeController = TextEditingController(text: item['invDischarge']?.toString() ?? InverterPresets.presets[0]['dischargeCurrent']?.toString() ?? '100'); 
String selectedPreset = item['selectedPreset'] as String? ?? InverterPresets.presets[0]['name'];  
bool isParallel = item['isParallel'] as bool? ?? false;
bool isGridExport = item['isGridExport'] as bool? ?? false;


  // 🔋 АКБ
  final TextEditingController batCapacityController = TextEditingController(text: item['batCapacity']?.toString() ?? (nameLower.contains('станція') ? '2.4' : '100'));
  final TextEditingController batVoltageController = TextEditingController(text: item['batVoltage']?.toString() ?? (nameLower.contains('станція') ? '48' : '51.2'));
  final TextEditingController batCountController = TextEditingController(text: item['batCount']?.toString() ?? '1',);
  final TextEditingController batChargeCurrentController = TextEditingController(text: item['batChargeCurrent']?.toString() ?? '100',);
  final TextEditingController batDischargeCurrentController = TextEditingController(text: item['batDischargeCurrent']?.toString() ?? '100',);
  String selectedBatType = item['batType'] as String? ?? 'LiFePO4 (LFP)';
  String selectedBms = item['bmsType'] as String? ?? 'JK BMS';
  String selectedBatteryProtocol = item['batteryProtocol'] as String? ?? 'CAN';
  bool hasBatteryHeating = item['hasBatteryHeating'] as bool? ?? false;
  bool hasBatteryCooling = item['hasBatteryCooling'] as bool? ?? false;

  // 🔌 Портативна станція
  final TextEditingController portableCyclesController = TextEditingController(text: item['portableCycles']?.toString() ?? '3500',);
  final TextEditingController portableInverterController = TextEditingController(text: item['portableInverter']?.toString() ?? '2400',);
  final TextEditingController portablePvController = TextEditingController(text: item['portablePv']?.toString() ?? '800',);
  final TextEditingController portableAcChargeController = TextEditingController(text: item['portableAcCharge']?.toString() ?? '1200',);
  final TextEditingController portableUpsController = TextEditingController(text: item['portableUps']?.toString() ?? '20',);
  final TextEditingController portableCapacityController = TextEditingController(text: item['portableCapacity']?.toString() ?? '2',);
  String selectedPortableBrand = item['portableBrand'] as String? ?? 'EcoFlow';
  String selectedPortableBatteryType = item['portableBatteryType'] as String? ??'LiFePO4';
  String selectedWaveType = item['waveType'] as String? ?? 'Чиста синусоїда';
  String selectedPvConnector = item['pvConnector'] as String? ?? 'MC4';
  bool isBoilerUps = item['isBoilerUps'] as bool? ?? true;

  // ⛽ Генератор
final Map<String, double> fuelPrices = {'Бензин А-95 Преміум': 79.36,'Бензин А-95': 75.82,'Бензин А-92': 69.72,'Дизельне паливо': 85.39,'Газ (LPG)': 46.39,};
final TextEditingController genPowerController = TextEditingController(text: item['genPower']?.toString() ?? '5.5');
final TextEditingController genTankController = TextEditingController(text: item['genTank']?.toString() ?? '15');
final TextEditingController genConsumptionController = TextEditingController(text: item['genConsumption']?.toString() ?? '1.6');
final TextEditingController genNoiseController = TextEditingController(text: item['genNoise']?.toString() ?? '68',);
final TextEditingController genResourceController = TextEditingController(text: item['genResource']?.toString() ?? '5000',);
String selectedFuelType = item['fuelType'] as String? ?? 'Бензин А-95';
final TextEditingController genFuelPriceController = TextEditingController(text: item['genFuelPrice']?.toString() ?? '${fuelPrices[selectedFuelType] ?? 75.82}',);
final TextEditingController genDailyHoursController = TextEditingController(text: item['genDailyHours']?.toString() ?? '8',);
final TextEditingController genReserveFuelController = TextEditingController(text: item['genReserveFuel']?.toString() ?? '20',);
String selectedGeneratorPhase = item['generatorPhase'] as String? ?? '1 Фаза (230В)';
bool hasAvr = item['hasAvr'] as bool? ?? false;
bool isEcoMode = item['isEcoMode'] as bool? ?? true;
bool isAtsReady = item['isAtsReady'] as bool? ?? false;

// 🌪 Вітрогенератор 
final TextEditingController windSpeedController = TextEditingController(text: item['windSpeed']?.toString() ?? '6',);
final TextEditingController mastHeightController = TextEditingController(text: item['mastHeight']?.toString() ?? '12',);
final TextEditingController rotorDiameterController = TextEditingController(text: item['rotorDiameter']?.toString() ?? '3',);
final TextEditingController windCfController = TextEditingController(text: item['windCf']?.toString() ?? '25',);
final TextEditingController windStartSpeedController = TextEditingController(text: item['windStartSpeed']?.toString() ?? '3',);
final TextEditingController windCutoffSpeedController = TextEditingController(text: item['windCutoffSpeed']?.toString() ?? '25',);
final TextEditingController whPowerController = TextEditingController(text: item['whPower']?.toString() ?? '2.5');
final TextEditingController whEfficiencyController = TextEditingController(text: item['whEfficiency']?.toString() ?? '40');
String selectedWindType = item['windType'] as String? ??'Горизонтальна вісь (HAWT)';
String selectedWindZone = item['windZone'] as String? ?? 'Середня';
bool hasWindMppt = item['hasWindMppt'] as bool? ?? true;

// 💧 Мікро ГЕС
final TextEditingController hydroFlowController = TextEditingController(text: item['hydroFlow']?.toString() ?? '50',);
final TextEditingController hydroHeadController = TextEditingController(text: item['hydroHead']?.toString() ?? '5',);
final TextEditingController hydroEfficiencyController = TextEditingController(text: item['hydroEfficiency']?.toString() ?? '85',);
final TextEditingController hydroCfController = TextEditingController(text: item['hydroCf']?.toString() ?? '90',);
String selectedHydroTurbine = item['hydroTurbine'] as String? ?? 'Pelton';
String selectedHydroSource = item['hydroSource'] as String? ?? 'Річка';
String selectedHydroGeneratorType = item['hydroGeneratorType'] as String? ??'PM Generator';
String selectedHydroOutput = item['hydroOutput'] as String? ?? 'Через АКБ';
String selectedHydroSeason = item['hydroSeason'] as String? ?? 'Стабільний цілий рік';
bool hydro24x7 = item['hydro24x7'] as bool? ?? true;
// 🚗 EV / V2H
final TextEditingController evPowerController = TextEditingController(text: item['evPower']?.toString() ?? '7.4');
final TextEditingController evCapacityController = TextEditingController(text: item['evCapacity']?.toString() ?? '60');
final TextEditingController evMaxCurrentController = TextEditingController(text: item['evMaxCurrent']?.toString() ?? '32',);
String selectedConnectorType = item['connectorType'] as String? ?? 'Type 2';
String selectedChargingMode = item['chargingMode'] as String? ?? 'Одностороння (G2V)';
String selectedChargePriority = item['chargePriority'] as String? ?? 'Надлишок сонця';
double reservedVehicleSoc = (item['reservedVehicleSoc'] as num?)?.toDouble() ?? 20;
// 🏙 Центральна мережа
final TextEditingController gridLimitController = TextEditingController(text: item['gridLimit']?.toString() ?? '10.0');
final TextEditingController gridVoltageController = TextEditingController(text: item['gridVoltage']?.toString() ?? '230');
final TextEditingController gridDayTariffController = TextEditingController(text: item['gridDayTariff']?.toString() ?? '4.32');
final TextEditingController gridNightTariffController = TextEditingController(text: item['gridNightTariff']?.toString() ?? '2.16');
final TextEditingController gridMainBreakerController = TextEditingController(text: item['gridMainBreaker']?.toString() ?? '32');
String selectedTariffZones = item['tariffZones'] as String? ?? '2-зонний (День / Ніч)';
String selectedPhaseType = item['phaseType'] as String? ?? '1 Фаза (230В)';
String selectedGridQuality = item['gridQuality'] as String? ?? 'Стабільна мережа';
double blackoutHoursPerDay =(item['blackoutHours'] as num?)?.toDouble() ?? 0;

// ======================================================
// 🛡 ЗАХИСТ ТА СТАБІЛІЗАЦІЯ
// ======================================================

// ⚡ Стабілізатор 
final stabilizerPowerController = TextEditingController(text: (item['stabilizerPower'] ?? '10').toString(),);
final stabilizerMinVoltageController = TextEditingController(text: (item['stabilizerMinVoltage'] ?? '140').toString(),);
final stabilizerMaxVoltageController = TextEditingController(text: (item['stabilizerMaxVoltage'] ?? '260').toString(),);
String selectedStabilizerType =(item['stabilizerType'] ?? 'electronic').toString();
bool stabilizerBypass = item['stabilizerBypass'] as bool? ?? false;

// ⚡ MPPT
final TextEditingController mpptMaxVoltageController = TextEditingController(text: item['mpptMaxVoltage']?.toString() ?? '450',);
final TextEditingController mpptMaxCurrentController = TextEditingController(text: item['mpptMaxCurrent']?.toString() ?? '60',);
final TextEditingController mpptStringsController = TextEditingController(text: item['mpptStrings']?.toString() ?? '2',);
final TextEditingController mpptEfficiencyController = TextEditingController(text: item['mpptEfficiency']?.toString() ?? '98',);
final mpptVocController = TextEditingController(text: item['mpptVoc']?.toString() ?? '',);
final mpptVmpController = TextEditingController(text: item['mpptVmp']?.toString() ?? '',);
final mpptIscController = TextEditingController(text: item['mpptIsc']?.toString() ?? '',);
final mpptImpController = TextEditingController(text: item['mpptImp']?.toString() ?? '',);
final mpptSeriesPanelsController = TextEditingController(text: item['mpptSeriesPanels']?.toString() ?? '',);
final mpptParallelStringsController = TextEditingController(text: item['mpptParallelStrings']?.toString() ?? '',);
String selectedMpptBatteryType = item['mpptBatteryType'] as String? ??'LiFePO4';

// ⚠️ Реле напруги
final relayMinVoltageController = TextEditingController(text: (item['relayMinVoltage'] ?? '180').toString(),);
final relayMaxVoltageController = TextEditingController(text: (item['relayMaxVoltage'] ?? '260').toString(),);
final relayDelayController = TextEditingController(text: (item['relayDelay'] ?? '10').toString(),);

// ⚡ ПЗІП
String selectedSpdType = (item['spdType'] ?? 'T2').toString();
final groundResistanceController = TextEditingController(text: (item['groundResistance'] ?? '10').toString(),);

// 🛡 ПЗВ   
final rcdCurrentController = TextEditingController(text: (item['rcdCurrent'] ?? '25').toString(),);
String selectedRcdSensitivity = (item['rcdSensitivity'] ?? '30').toString();
String selectedRcdType = (item['rcdType'] ?? 'A').toString();    
  
// ======================================================
// 🤖 АВТОМАТИЗАЦІЯ ТА МОНІТОРИНГ
// ======================================================

// ⚡ АВР (Автоматичне введення резерву)
final TextEditingController atsTransferTimeController = TextEditingController(text:item['atsTransferTime']?.toString() ??'10',);  
final TextEditingController atsMinGridVoltageController = TextEditingController(text:item['atsMinGridVoltage']?.toString() ??'190',);
String selectedAtsPriority = item['atsPriority']as String? ?? 'Мережа → АКБ → Генератор';   
final TextEditingController atsMaxGridVoltageController = TextEditingController(text: item['atsMaxGridVoltage']?.toString() ?? '255',);
final TextEditingController atsReturnDelayController = TextEditingController(text: item['atsReturnDelay']?.toString() ?? '30',);
String selectedBackupSource = item['backupSource'] as String? ?? 'Інвертор';
String selectedAtsMode = item['atsMode'] as String? ?? 'Автоматичний';
String selectedPhaseMonitoring = item['phaseMonitoring'] as String? ?? 'Усі фази';
bool atsRemoteControl = item['atsRemoteControl'] as bool? ?? false;
bool atsAutoTest = item['atsAutoTest'] as bool? ?? true;
final TextEditingController atsMinFrequencyController = TextEditingController(text:item['atsMinFrequency']?.toString() ??'49',);
final TextEditingController atsMaxFrequencyController =TextEditingController(text:item['atsMaxFrequency'] ?.toString() ??'51',);   
// ⚡ Dry Contact генератора
String selectedGeneratorMode = item['generatorMode'] as String? ??'Автоматичний';
double generatorStartSoc = double.tryParse(item['generatorStartSoc']?.toString() ?? '') ?? 20.0;
final TextEditingController generatorStartSocController = TextEditingController(text: item['generatorStartSoc']?.toString() ?? '20',);
final TextEditingController generatorStopSocController = TextEditingController(text: item['generatorStopSoc']?.toString() ?? '80',);
final TextEditingController generatorStartDelayController = TextEditingController(text: item['generatorStartDelay']?.toString() ?? '30',);
final TextEditingController generatorStopDelayController = TextEditingController(text: item['generatorStopDelay']?.toString() ?? '60',);
final TextEditingController atsSwitchDelayController =
    TextEditingController(
      text: item['atsSwitchDelay']?.toString() ?? '5',
    );

bool atsAutoReturn =
    item['atsAutoReturn'] as bool? ?? true;

// 📊 Smart Meter
final TextEditingController meterModelController = TextEditingController(text: item['meterModel']?.toString() ?? '',);
final TextEditingController modbusAddressController = TextEditingController(text: item['modbusAddress']?.toString() ?? '1',);
final TextEditingController ctRatioController = TextEditingController(text: item['ctRatio']?.toString() ?? '100/5',);
String selectedAccuracyClass = item['accuracyClass'] as String? ?? '1.0';
String selectedMeterDirection = item['meterDirection'] as String? ??'Двонаправлений';    

 // 📡 Моніторинг   
String selectedMonitoringType = item['monitoringType'] as String? ?? 'Wi-Fi';
String selectedCloudStatus = item['cloudStatus'] as String? ?? 'Активний';
String selectedMonitoringStatus = item['monitoringStatus'] as String? ?? 'Онлайн';
final TextEditingController monitoredDevicesController = TextEditingController(text: item['monitoredDevices']?.toString() ?? '1',);
final TextEditingController updateIntervalController = TextEditingController(text: item['updateInterval']?.toString() ?? '5',);

// 🏠 Home Assistant / Smart Home
String selectedProtocol = item['protocol'] as String? ?? 'Wi-Fi / Локальний IP';
String selectedIntegrationType = item['integrationType'] as String? ??'Home Assistant';
String selectedCommunicationProtocol = item['communicationProtocol'] as String? ??'MQTT';
String selectedConnectionStatus = item['connectionStatus'] as String? ?? 'Підключено';
final TextEditingController homeAssistantIpController = TextEditingController(text: item['haIp']?.toString() ?? '192.168.1.100',);
final TextEditingController connectedDevicesController = TextEditingController(text: item['connectedDevices']?.toString() ?? '10',);

// ⚡ Load Shedding
final TextEditingController criticalLoadController = TextEditingController(text: item['criticalLoad']?.toString() ?? '1.5',);
final TextEditingController importantLoadController = TextEditingController(text: item['importantLoad']?.toString() ?? '1.0',);
final TextEditingController secondaryLoadController = TextEditingController(text: item['secondaryLoad']?.toString() ?? '2.0',);
double secondaryOffSoc = double.tryParse(item['secondaryOffSoc']?.toString() ?? '') ?? 60.0;
double importantOffSoc = double.tryParse(item['importantOffSoc']?.toString() ?? '') ?? 30.0;
double emergencyOffSoc = double.tryParse(item['emergencyOffSoc']?.toString() ?? '') ?? 15.0;

// ☀️ PV Diverter
final TextEditingController smartTriggerController =
    TextEditingController(
      text: item['pvTrigger']?.toString() ?? '2000',
    );

final TextEditingController pvLoadPowerController =
    TextEditingController(
      text: item['pvLoadPower']?.toString() ?? '2000',
    );
// PV Diverter initial state
bool pvEnabled =
    item['pvEnabled'] as bool? ?? true;

String pvMode =
    item['pvMode'] as String? ??
    'Smart (За надлишком)';

bool pvAllowExport =
    item['pvAllowExport'] as bool? ?? false;

bool pvUseMeter =
    item['pvUseMeter'] as bool? ?? true;

double pvPriority =
    (item['pvPriority'] as num?)?.toDouble() ?? 50.0;

String selectedPvLoadType =
    item['pvLoadType'] as String? ?? 'Бойлер';

// 🚗 Smart EV Charger
final TextEditingController evChargerPowerController =
    TextEditingController(
      text: item['evChargerPower']?.toString() ?? '',
    );

final TextEditingController evChargerCurrentController =
    TextEditingController(
      text: item['evChargerCurrent']?.toString() ?? '',
    );

final TextEditingController evChargerEfficiencyController =
    TextEditingController(
      text: item['evChargerEfficiency']?.toString() ?? '',
    );

final TextEditingController evBatterySocThresholdController =
    TextEditingController(
      text: item['evBatterySocThreshold']?.toString() ?? '',
    );

final TextEditingController evMinSolarSurplusController =
    TextEditingController(
      text: item['evMinSolarSurplus']?.toString() ?? '',
    );
String selectedEvPhaseType =
    item['evPhaseType'] ?? '3 фази 400В';

String selectedEvChargingMode =
    item['evChargingMode'] ?? 'Балансування навантаження';

bool useDynamicLoadBalancing =
    item['useDynamicLoadBalancing'] ?? true;

bool chargeOnlyWhenBatteryFull =
    item['chargeOnlyWhenBatteryFull'] ?? false;

bool solarOnlyMode =
    item['solarOnlyMode'] ?? false;
// 🚗 Smart EV Charger
double selectedDod = item['dod'] as double? ?? 90;
double selectedMinSoc = item['minSoc'] as double? ?? 20;
double selectedReserveSoc = item['reserveSoc'] as double? ?? 10;

// Для Сервиса и обслуживания
// Active Battery Balancer

bool balancerEnabled =
    item['balancerEnabled'] as bool? ?? true;

String balancerType =
    item['balancerType'] as String? ?? 'Активний';

final TextEditingController balancerCurrentController =
    TextEditingController(
      text: item['balancerCurrent']?.toString() ?? '5',
    );

bool balancerAutoMode =
    item['balancerAutoMode'] as bool? ?? true;
// Cooling / Ventilation

bool coolingEnabled =
    item['coolingEnabled'] as bool? ?? true;

String coolingType =
    item['coolingType'] as String? ?? 'Вентилятори';

final TextEditingController coolingStartTempController =
    TextEditingController(
      text: item['coolingStartTemp']?.toString() ?? '35',
    );

final TextEditingController coolingStopTempController =
    TextEditingController(
      text: item['coolingStopTemp']?.toString() ?? '30',
    );

bool coolingAutoMode =
    item['coolingAutoMode'] as bool? ?? true;
    // Battery Heater / Thermal Box

bool batteryHeaterEnabled =
    item['batteryHeaterEnabled'] as bool? ?? true;

String batteryHeaterType =
    item['batteryHeaterType'] as String? ?? 'Термокожух';

final TextEditingController heaterStartTempController =
    TextEditingController(
      text: item['heaterStartTemp']?.toString() ?? '5',
    );

final TextEditingController heaterStopTempController =
    TextEditingController(
      text: item['heaterStopTemp']?.toString() ?? '10',
    );

final TextEditingController heaterPowerController =
    TextEditingController(
      text: item['heaterPower']?.toString() ?? '300',
    );

bool batteryHeaterAutoMode =
    item['batteryHeaterAutoMode'] as bool? ?? true;
// SOH Analyzer

bool sohEnabled =
    item['sohEnabled'] as bool? ?? true;

String sohMethod =
    item['sohMethod'] as String? ??
    'BMS Data';

final TextEditingController sohWarningController =
    TextEditingController(
      text: item['sohWarning']?.toString() ?? '80',
    );

final TextEditingController batteryCyclesController =
    TextEditingController(
      text: item['batteryCycles']?.toString() ?? '0',
    );

bool sohNotifications =
    item['sohNotifications'] as bool? ?? true;
final TextEditingController maintParamController = TextEditingController(text: item['maintParam']?.toString() ?? '25');

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            
            double calculateFinalGeneration() {
              final double qty = double.tryParse(qtyController.text) ?? 0;
              final double power = double.tryParse(powerController.text) ?? 0;
              double baseKw = (qty * power) / 1000;
              
             baseKw *=
    (SolarConstants.orientationFactors[selectedOrientation] ?? 1.0);

baseKw *=
    (SolarConstants.tiltFactors[selectedTilt] ?? 1.0);

baseKw *=
    (SolarConstants.mountFactors[selectedMountType] ?? 1.0);

baseKw *=
    (SolarConstants.shadingFactors[selectedShading] ?? 1.0);

baseKw *=
    (SolarConstants.lifespanFactors[selectedLifespan] ?? 1.0);

              if (isBifacial) {
                baseKw += baseKw * selectedAlbedoBonus;
              }

              if (selectedInverterType == 'Пряме DC підключення (Панель -> Станція XT60, ККД +10%)') {
                baseKw *= 1.10;
              }

              return baseKw;
            }
 double calculateInverterLosses() {final double own = double.tryParse(invOwnController.text) ?? 0;return (own * 24) / 1000; }
 String generatorLogicDescription() {final startSoc = generatorStartSocController.text;final stopSoc =generatorStopSocController.text;return 'Старт при $startSoc% → Стоп при $stopSoc%';}
  double calculateIntegrationLevel() {final devices = double.tryParse(connectedDevicesController.text,) ?? 0; return (devices * 2).clamp(0, 100);}         
double totalLoad() {final critical = double.tryParse(criticalLoadController.text,) ?? 0; final important = double.tryParse(importantLoadController.text, ) ?? 0; final secondary = double.tryParse( secondaryLoadController.text, ) ?? 0;return critical + important + secondary;}
double shedLoad() {final important =double.tryParse(importantLoadController.text,) ??0;final secondary = double.tryParse(secondaryLoadController.text,) ??0;return important + secondary;}
double emergencyLoad() {return double.tryParse(criticalLoadController.text,) ?? 0;}

int calculateAutomationCount() {
  final devices =
      int.tryParse(
        connectedDevicesController.text,
      ) ??
      0;

  return (devices * 2);
}

            InputDecoration dropdownDecoration(String label) {
              return InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: brandInnerBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              );
            }

            final bool isManualMode = selectedPreset == '🛠️ Свої налаштування';

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: const BoxDecoration(
                  color: brandCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
  padding: EdgeInsets.symmetric(
    horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 28,
    vertical: 24,
  ),
  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: brandBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.neon.withValues(alpha: 0.3)),
                            ),
                            child: Icon(item['icon'] as IconData? ?? Icons.electrical_services_outlined, color: AppColors.neon, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text((item['name'] ?? item['title'] ?? 'Пристрій') as String, style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w700)),
                                Text(
  isSolar
      ? 'Конфігурація сонячного поля (Solar UI)'
      : isInverter
          ? 'Розумне налаштування параметрів інвертора (Smart Config)'
          : isGenerator
              ? 'Параметри резервного паливного генератора (Fuel Engine UI)'
              : isBattery
                  ? 'Конфігурація накопичувача та ємності (Battery UI)'
                  : isWind
                      ? 'Конфігурація вітрогенератора (Wind Generator UI)'
                      : isHydro
                          ? 'Конфігурація мікро ГЕС (Micro Hydro UI)'
                          : isEvRelated
                              ? 'Параметри та ліміти двонаправленого лінку авто (EV UI)'
                              : isGrid
                                  ? 'Параметри комерційного введення мережі (Grid UI)'
                                  : isStabilizer
    ? 'Стабілізація напруги та аналіз якості електроживлення (Voltage Stabilizer UI)'
    : isVoltageRelay
        ? 'Контроль аварійних відхилень напруги та логіка відключення (Voltage Relay UI)'
        : isSurgeProtection
            ? 'Захист від імпульсних перенапруг та контроль заземлення (SPD UI)'
            : isRcd
                ? 'Диференційний захист та контроль струмів витоку (RCD UI)'
                
                                      : isSmartAutomation
                                          ? 'Інтеграція та шини автоматизації (Automation UI)'
                                          : 'Параметри обслуговування вузла (Maintenance)',
  style: const TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      /// ================== UI ДЛЯ ИНВЕРТОРА (SMART CONFIG) ==================
                      if (isInverter) ...[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedPreset,
                                dropdownColor: brandCard,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                                decoration: dropdownDecoration('Оберіть бренд та модель пристрою'),
                                items: InverterPresets.presets.map((preset) {
                                  return DropdownMenuItem<String>(
                                    value: preset['name'] as String,
                                    child: Text(preset['name'] as String),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedPreset = val!;
                                    final found = InverterPresets.presets.firstWhere((p) => p['name'] == val);
                                    if (val != '🛠️ Свої налаштування') {
                                      invPowerController.text = found['power']!;
                                      invKkdController.text = found['kkd']!;
                                      invOwnController.text = found['ownConsumption']!;
                                      invChargeController.text = found['chargeCurrent']!;
                                      invDischargeController.text = found['dischargeCurrent']!;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStaticInputField(
                                'Номінальна потужність', 
                                invPowerController, 
                                'кВт', 
                                TextInputType.number, 
                                isManualMode, 
                                (val) => setModalState(() {}),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildStaticInputField(
                                'Коефіцієнт ККД', 
                                invKkdController, 
                                '%', 
                                TextInputType.number, 
                                isManualMode, 
                                (val) => setModalState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStaticInputField(
                                'Власне споживання (очікування)', 
                                invOwnController, 
                                'Вт', 
                                TextInputType.number, 
                                isManualMode, 
                                (val) => setModalState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStaticInputField(
                                'Макс. струм заряду АКБ', 
                                invChargeController, 
                                'А', 
                                TextInputType.number, 
                                isManualMode, 
                                (val) => setModalState(() {}),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildStaticInputField(
                                'Макс. струм розряду АКБ', 
                                invDischargeController, 
                                'А', 
                                TextInputType.number, 
                                isManualMode, 
                                (val) => setModalState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStaticSwitchTile('Паралельне з\'єднання (Масштабування)', isParallel, (val) => setModalState(() => isParallel = val)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStaticSwitchTile('Продаж надлишків у мережу (Зелений тариф)', isGridExport, (val) => setModalState(() => isGridExport = val)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.neon.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neon.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.analytics_outlined, color: AppColors.neon, size: 28),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ПАСПОРТ ВТРАТ СИСТЕМИ (Доба)', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${calculateInverterLosses().toStringAsFixed(2)} кВт·г вхолосту',
                                      style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Ліміт: ${invPowerController.text} кВт',
                                style: const TextStyle(color: AppColors.neon, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ]

                      /// ================== UI ДЛЯ СОЛНЕЧНЫХ ПАНЕЛЕЙ (SOLAR UI) ==================
                      else if (isSolar) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildStaticInputField('Кількість панелей', qtyController, 'шт.', TextInputType.number, true, (val) => setModalState(() {})),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildStaticInputField('Потужність панелі', powerController, 'Вт', TextInputType.number, true, (val) => setModalState(() {})),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedOrientation,
                                dropdownColor: brandCard,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                                decoration: dropdownDecoration('Орієнтація поля'),
                                items: SolarConstants.orientationFactors.keys.map((String val) {
                                  return DropdownMenuItem<String>(value: val, child: Text(val));
                                }).toList(),
                                onChanged: (val) => setModalState(() => selectedOrientation = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedTilt,
                                dropdownColor: brandCard,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                                decoration: dropdownDecoration('Кут нахилу фотомодулів до горизонту:'),
                                items: SolarConstants.tiltFactors.keys.map((String val) {
                                  return DropdownMenuItem<String>(value: val, child: Text(val, overflow: TextOverflow.ellipsis));
                                }).toList(),
                                onChanged: (val) => setModalState(() => selectedTilt = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedMountType,
                                dropdownColor: brandCard,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                                decoration: dropdownDecoration('Тип монтажу конструкції'),
                                items: SolarConstants.mountFactors.keys.map((String val) {
                                  return DropdownMenuItem<String>(value: val, child: Text(val, overflow: TextOverflow.ellipsis));
                                }).toList(),
                                onChanged: (val) => setModalState(() => selectedMountType = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedShading,
                                dropdownColor: brandCard,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                                decoration: dropdownDecoration('Локальні фактори затінення поля'),
                                items: SolarConstants.shadingFactors.keys.map((String val) {
                                  return DropdownMenuItem<String>(value: val, child: Text(val, overflow: TextOverflow.ellipsis));
                                }).toList(),
                                onChanged: (val) => setModalState(() => selectedShading = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedLifespan,
                                dropdownColor: brandCard,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                                decoration: dropdownDecoration('Термін експлуатації / Вік деградації масиву'),
                                items: SolarConstants.lifespanFactors.keys.map((String val) {
                                  return DropdownMenuItem<String>(value: val, child: Text(val, overflow: TextOverflow.ellipsis));
                                }).toList(),
                                onChanged: (val) => setModalState(() => selectedLifespan = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedInverterType,
                                dropdownColor: brandCard,
                                isExpanded: true,
                                style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                                decoration: dropdownDecoration('Режим роботи та тип інвертора / СЕС'),
                                items: [
                                  'Гібридний (Живлення будинку + заряд АКБ)',
                                  'Мережевий (Генерація вимикається при блекауті)',
                                  'Автономний (Працює виключно на локальні прилади)',
                                  'Пряме DC підключення (Панель -> Станція XT60, ККД +10%)',
                                ].map((String val) {
                                  return DropdownMenuItem<String>(value: val, child: Text(val, overflow: TextOverflow.ellipsis));
                                }).toList(),
                                onChanged: (val) => setModalState(() => selectedInverterType = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStaticSwitchTile('Zero Export (Обмеження)', isZeroExport, (val) => setModalState(() => isZeroExport = val)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildStaticSwitchTile('Двосторонні фотомодулі (Bifacial)', isBifacial, (val) => setModalState(() => isBifacial = val)),
                            ),
                          ],
                        ),

                        if (isBifacial) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: brandInnerBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.neon.withValues(alpha: 0.15)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Двосторонні фотомодулі (Bifacial)',
                                  style: TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Вловлювання відбитого світла тильною стороною панелі.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Поверхня под конструкцією (Альбедо бонус):',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<double>(
                                  value: selectedAlbedoBonus,
                                  dropdownColor: brandCard,
                                  isExpanded: true,
                                  style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: brandBg,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 0.08,
                                      child: Text('Зелена трава / Ґрунт (Bonus +8%)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 0.22,
                                      child: Text('Сніг / Світлий дах / Галька (Bonus +22%)'),
                                    ),
                                  ],
                                  onChanged: (val) => setModalState(() => selectedAlbedoBonus = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.neon.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.neon.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppColors.neon, size: 28),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('ФІНАЛЬНА ГЕНЕРАЦІЯ (Розрахунок)', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${calculateFinalGeneration().toStringAsFixed(2)} кВт peak',
                                      style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
  '~ ${(calculateFinalGeneration() * 1150).toStringAsFixed(0)} кВт·г/рік',
  style: const TextStyle(
    color: AppColors.neon,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  ),
  overflow: TextOverflow.ellipsis,
),
                            ],
                          ),
                        ),
                      ]

/// ================== UI ДЛЯ MPPT ==================
else if (isMppt) ...[

  /// Макс параметры MPPT
  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Макс. PV напруга',
          mpptMaxVoltageController,
          'В',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: _buildStaticInputField(
          'Макс. струм',
          mpptMaxCurrentController,
          'А',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  /// Параметри панелі
  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Voc панелі',
          mpptVocController,
          'В',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: _buildStaticInputField(
          'Vmp панелі',
          mpptVmpController,
          'В',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Isc панелі',
          mpptIscController,
          'А',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: _buildStaticInputField(
          'Imp панелі',
          mpptImpController,
          'А',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  /// Конфігурація стрингів
  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Панелей послідовно',
          mpptSeriesPanelsController,
          '',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: _buildStaticInputField(
          'Паралельних стрингів',
          mpptParallelStringsController,
          '',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  /// ККД
  _buildStaticInputField(
    'ККД MPPT',
    mpptEfficiencyController,
    '%',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  /// Тип АКБ
  DropdownButtonFormField<String>(
    value: selectedMpptBatteryType,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Тип АКБ',
    ),
    items: const [
      DropdownMenuItem(
        value: 'LiFePO4',
        child: Text('LiFePO4'),
      ),
      DropdownMenuItem(
        value: 'NMC',
        child: Text('NMC'),
      ),
      DropdownMenuItem(
        value: 'AGM',
        child: Text('AGM'),
      ),
      DropdownMenuItem(
        value: 'GEL',
        child: Text('GEL'),
      ),
      DropdownMenuItem(
        value: 'Lead Acid',
        child: Text('Lead Acid'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedMpptBatteryType = v!;
      });
    },
  ),

  const SizedBox(height: 24),

  /// Паспорт MPPT
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Row(
      children: [

        const Icon(
          Icons.solar_power_outlined,
          color: AppColors.neon,
          size: 28,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    const Text(
      'ПАСПОРТ MPPT',
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    ),

    const SizedBox(height: 6),

    Text(
      'Запас напруги: '
      '${MpptCalculator.voltageMargin(
        maxVoltage: double.tryParse(
          mpptMaxVoltageController.text,
        ) ?? 0,
      ).toStringAsFixed(0)}%',
    ),

    Text(
      'Ефективність: '
      '${MpptCalculator.realEfficiency(
        efficiency: double.tryParse(
          mpptEfficiencyController.text,
        ) ?? 0,
      ).toStringAsFixed(0)}%',
    ),

    Text(
      'Ризик перевантаження: '
      '${MpptCalculator.overloadRisk(
        maxCurrent: double.tryParse(
          mpptMaxCurrentController.text,
        ) ?? 0,
        strings: double.tryParse(
          mpptParallelStringsController.text,
        ) ?? 0,
      )}',
    ),

    const SizedBox(height: 8),

    if ((double.tryParse(mpptVocController.text) ?? 0) > 0 &&
        (double.tryParse(mpptSeriesPanelsController.text) ?? 0) > 0)
      Text(
        'Voc стрингу: '
        '${MpptCalculator.stringVoc(
          voc: double.tryParse(
            mpptVocController.text,
          ) ?? 0,
          seriesPanels: double.tryParse(
            mpptSeriesPanelsController.text,
          ) ?? 0,
        ).toStringAsFixed(1)} В',
      ),

    if ((double.tryParse(mpptVmpController.text) ?? 0) > 0 &&
        (double.tryParse(mpptSeriesPanelsController.text) ?? 0) > 0)
      Text(
        'Vmp стрингу: '
        '${MpptCalculator.stringVmp(
          vmp: double.tryParse(
            mpptVmpController.text,
          ) ?? 0,
          seriesPanels: double.tryParse(
            mpptSeriesPanelsController.text,
          ) ?? 0,
        ).toStringAsFixed(1)} В',
      ),

    if ((double.tryParse(mpptImpController.text) ?? 0) > 0 &&
        (double.tryParse(mpptParallelStringsController.text) ?? 0) > 0)
      Text(
        'Струм масиву: '
        '${MpptCalculator.arrayCurrent(
          imp: double.tryParse(
            mpptImpController.text,
          ) ?? 0,
          parallelStrings: double.tryParse(
            mpptParallelStringsController.text,
          ) ?? 0,
        ).toStringAsFixed(1)} А',
      ),

    if ((double.tryParse(mpptVmpController.text) ?? 0) > 0 &&
        (double.tryParse(mpptImpController.text) ?? 0) > 0)
      Text(
        'Потужність панелі: '
        '${(
          MpptCalculator.panelPower(
            vmp: double.tryParse(
              mpptVmpController.text,
            ) ?? 0,
            imp: double.tryParse(
              mpptImpController.text,
            ) ?? 0,
          ) /
          1000
        ).toStringAsFixed(2)} кВт',
      ),

    if ((double.tryParse(mpptVmpController.text) ?? 0) > 0 &&
        (double.tryParse(mpptImpController.text) ?? 0) > 0 &&
        (double.tryParse(mpptSeriesPanelsController.text) ?? 0) > 0 &&
        (double.tryParse(mpptParallelStringsController.text) ?? 0) > 0)
      Text(
        'Потужність масиву: '
        '${(
          MpptCalculator.arrayPower(
            vmp: double.tryParse(
              mpptVmpController.text,
            ) ?? 0,
            imp: double.tryParse(
              mpptImpController.text,
            ) ?? 0,
            seriesPanels: double.tryParse(
              mpptSeriesPanelsController.text,
            ) ?? 0,
            parallelStrings: double.tryParse(
              mpptParallelStringsController.text,
            ) ?? 0,
          ) /
          1000
        ).toStringAsFixed(2)} кВт',
      ),

    Text(
      'Статус: '
      '${MpptCalculator.compatibilityStatus(
        maxVoltage: double.tryParse(
          mpptMaxVoltageController.text,
        ) ?? 0,
        maxCurrent: double.tryParse(
          mpptMaxCurrentController.text,
        ) ?? 0,
        voc: double.tryParse(
          mpptVocController.text,
        ) ?? 0,
        imp: double.tryParse(
          mpptImpController.text,
        ) ?? 0,
        seriesPanels: double.tryParse(
          mpptSeriesPanelsController.text,
        ) ?? 0,
        parallelStrings: double.tryParse(
          mpptParallelStringsController.text,
        ) ?? 0,
      )}',
    ),

    if (MpptCalculator.warningMessage(
          maxVoltage: double.tryParse(
            mpptMaxVoltageController.text,
          ) ?? 0,
          maxCurrent: double.tryParse(
            mpptMaxCurrentController.text,
          ) ?? 0,
          voc: double.tryParse(
            mpptVocController.text,
          ) ?? 0,
          imp: double.tryParse(
            mpptImpController.text,
          ) ?? 0,
          seriesPanels: double.tryParse(
            mpptSeriesPanelsController.text,
          ) ?? 0,
          parallelStrings: double.tryParse(
            mpptParallelStringsController.text,
          ) ?? 0,
        ).isNotEmpty)
      Text(
        MpptCalculator.warningMessage(
          maxVoltage: double.tryParse(
            mpptMaxVoltageController.text,
          ) ?? 0,
          maxCurrent: double.tryParse(
            mpptMaxCurrentController.text,
          ) ?? 0,
          voc: double.tryParse(
            mpptVocController.text,
          ) ?? 0,
          imp: double.tryParse(
            mpptImpController.text,
          ) ?? 0,
          seriesPanels: double.tryParse(
            mpptSeriesPanelsController.text,
          ) ?? 0,
          parallelStrings: double.tryParse(
            mpptParallelStringsController.text,
          ) ?? 0,
        ),
        style: const TextStyle(
          color: AppColors.neon,
          fontWeight: FontWeight.w600,
        ),
      ),

    const SizedBox(height: 8),

    Text(
      'Послідовно: ${mpptSeriesPanelsController.text}',
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
      ),
    ),

    Text(
      'Паралельно: ${mpptParallelStringsController.text}',
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
      ),
    ),

    Text(
      'Тип АКБ: $selectedMpptBatteryType',
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
      ),
    ),
  ],
),
        ),
      ],
    ),
  ),
]
                      /// ================== UI ДЛЯ ПАЛИВНОГО ГЕНЕРАТОРА ==================
else if (isGenerator) ...[

  _buildStaticInputField(
    'Номінальна потужність',
    genPowerController,
    'кВт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedGeneratorPhase,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Тип мережі',
    ),
    items: const [
      DropdownMenuItem(
        value: '1 Фаза (230В)',
        child: Text('1 Фаза (230В)'),
      ),
      DropdownMenuItem(
        value: '3 Фази (400В)',
        child: Text('3 Фази (400В)'),
      ),
    ],
   onChanged: (v) {
    setModalState(() {
      selectedGeneratorPhase = v!;
    });
  },
),

  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Обʼєм паливного бака',
          genTankController,
          'л',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: _buildStaticInputField(
          'Витрата палива',
          genConsumptionController,
          'л/год',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedFuelType,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Тип палива',
    ),
    items: fuelPrices.keys.map((type) {
      return DropdownMenuItem<String>(
        value: type,
        child: Text(type),
      );
    }).toList(),
    onChanged: (v) {
  setModalState(() {
    selectedFuelType = v!;

    genFuelPriceController.text =
        (fuelPrices[v] ?? 75.82)
            .toStringAsFixed(2);
  });
},
  ),

  const SizedBox(height: 16),

  

  _buildStaticSwitchTile(
    'Інтеграція з АВР',
    hasAvr,
    (v) {
      setModalState(() {
        hasAvr = v;
      });
    },
  ),

  const SizedBox(height: 12),

  _buildStaticSwitchTile(
    'ATS Ready',
    isAtsReady,
    (v) {
      setModalState(() {
        isAtsReady = v;
      });
    },
  ),

  const SizedBox(height: 12),

  

  const SizedBox(height: 12),

  _buildStaticSwitchTile(
    'Eco Mode',
    isEcoMode,
    (v) {
      setModalState(() {
        isEcoMode = v;
      });
    },
  ),

  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Шумність',
          genNoiseController,
          'дБ',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: _buildStaticInputField(
          'Ресурс двигуна',
          genResourceController,
          'м/г',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 24),
const SizedBox(height: 16),

Row(
  children: [
    Expanded(
      child: _buildStaticInputField(
        'Ціна палива',
        genFuelPriceController,
        '₴/л',
        TextInputType.number,
        true,
        (v) => setModalState(() {}),
      ),
    ),
    const SizedBox(width: 14),
    Expanded(
      child: _buildStaticInputField(
        'Годин/добу',
        genDailyHoursController,
        'год',
        TextInputType.number,
        true,
        (v) => setModalState(() {}),
      ),
    ),
  ],
),

const SizedBox(height: 16),

_buildStaticInputField(
  'Резерв палива',
  genReserveFuelController,
  'л',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),

const SizedBox(height: 24),
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'ПАСПОРТ ГЕНЕРАТОРА',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Тип мережі: $selectedGeneratorPhase',
        ),

        

        Text(
          'ATS Ready: ${isAtsReady ? "Так" : "Ні"}',
        ),

        Text(
          'AVR: ${hasAvr ? "Так" : "Ні"}',
        ),

        Text(
          'Автономність: '
          '${GeneratorCalculator.hoursFromTank(
            tankVolume:
                double.tryParse(
                  genTankController.text,
                ) ??
                0,
            consumption:
                double.tryParse(
                  genConsumptionController.text,
                ) ??
                0,
          ).toStringAsFixed(1)} год',
        ),

        Text(
          'Шумність: ${genNoiseController.text} дБ',
        ),

        Text(
          'Ресурс: ${genResourceController.text} м/г',
        ),
Text(
  'Паливо на добу: '
  '${GeneratorCalculator.fuelPerDay(
    consumption:
        double.tryParse(
          genConsumptionController.text,
        ) ?? 0,
    hoursPerDay:
        double.tryParse(
          genDailyHoursController.text,
        ) ?? 0,
  ).toStringAsFixed(1)} л',
),

Text(
  'Паливо на місяць: '
  '${GeneratorCalculator.fuelPerMonth(
    consumption:
        double.tryParse(
          genConsumptionController.text,
        ) ?? 0,
    hoursPerDay:
        double.tryParse(
          genDailyHoursController.text,
        ) ?? 0,
  ).toStringAsFixed(0)} л',
),

Text(
  'Витрати на місяць: '
  '${GeneratorCalculator.monthlyFuelCost(
    consumption:
        double.tryParse(
          genConsumptionController.text,
        ) ?? 0,
    hoursPerDay:
        double.tryParse(
          genDailyHoursController.text,
        ) ?? 0,
    fuelPrice:
        double.tryParse(
          genFuelPriceController.text,
        ) ?? 0,
  ).toStringAsFixed(0)} ₴',
),

Text(
  'Автономність з резервом: '
  '${GeneratorCalculator.autonomyWithReserve(
    tankVolume:
        double.tryParse(
          genTankController.text,
        ) ?? 0,
    reserveFuel:
        double.tryParse(
          genReserveFuelController.text,
        ) ?? 0,
    consumption:
        double.tryParse(
          genConsumptionController.text,
        ) ?? 0,
  ).toStringAsFixed(1)} год',
),
        const SizedBox(height: 8),

        Text(
          'Собівартість: '
          '${GeneratorCalculator.costPerKwh(
            generatorPower:
                double.tryParse(
                  genPowerController.text,
                ) ??
                0,
            fuelConsumption:
                double.tryParse(
                  genConsumptionController.text,
                ) ??
                0,
            fuelPrice:
                fuelPrices[selectedFuelType] ??
                50,
          ).toStringAsFixed(1)} ₴/кВт·г',
          style: const TextStyle(
            color: AppColors.neon,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  ),
]
                      /// ================== UI ДЛЯ НАКОПИЧУВАЧІВ ТА АКБ (BATTERY / BMS) ==================
else if (isBattery) ...[
  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Номінальна ємність АКБ',
          batCapacityController,
          'А·г',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: _buildStaticInputField(
          'Робоча вольтаж-лінія',
          batVoltageController,
          'В',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Кількість батарей',
    batCountController,
    'шт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedBatType,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Хімічний тип комірок батареї',
    ),
    items: const [
      DropdownMenuItem(
        value: 'LiFePO4 (LFP)',
        child: Text('LiFePO4 (LFP)'),
      ),
      DropdownMenuItem(
        value: 'Li-Ion (NMC)',
        child: Text('Li-Ion (NMC)'),
      ),
      DropdownMenuItem(
        value: 'LTO (Титанат)',
        child: Text('LTO (Титанат)'),
      ),
      DropdownMenuItem(
        value: 'Lead-Acid (Гель/AGM)',
        child: Text('Lead-Acid (Гель/AGM)'),
      ),
    ],
    onChanged: (val) {
      setModalState(() {
        selectedBatType = val!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<double>(
  value: selectedDod,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
  decoration: dropdownDecoration(
    'Глибина розряду (DoD)',
  ),
    items: const [
      DropdownMenuItem(
        value: 80.0,
        child: Text('80% (Консервативний режим)'),
      ),
      DropdownMenuItem(
        value: 90.0,
        child: Text('90% (Стандартний цикл)'),
      ),
      DropdownMenuItem(
        value: 100.0,
        child: Text('100% (Повний розряд)'),
      ),
    ],
    onChanged: (val) {
      setModalState(() {
        selectedDod = val!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<double>(
    value: selectedMinSoc,
    dropdownColor: brandCard,
    isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
    decoration: dropdownDecoration(
      'Мінімальний SOC',
    ),
    items: const [
      DropdownMenuItem(
        value: 10.0,
        child: Text('10%'),
      ),
      DropdownMenuItem(
        value: 20.0,
        child: Text('20%'),
      ),
      DropdownMenuItem(
        value: 30.0,
        child: Text('30%'),
      ),
      DropdownMenuItem(
        value: 40.0,
        child: Text('40%'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedMinSoc = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<double>(
    value: selectedReserveSoc,
    dropdownColor: brandCard,
    isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
    decoration: dropdownDecoration(
      'Резервний заряд',
    ),
    items: const [
      DropdownMenuItem(
        value: 0.0,
        child: Text('0%'),
      ),
      DropdownMenuItem(
        value: 10.0,
        child: Text('10%'),
      ),
      DropdownMenuItem(
        value: 20.0,
        child: Text('20%'),
      ),
      DropdownMenuItem(
        value: 30.0,
        child: Text('30%'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedReserveSoc = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedBms,
    dropdownColor: brandCard,
    isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
    decoration: dropdownDecoration(
      'Тип BMS',
    ),
    items: const [
      DropdownMenuItem(
        value: 'JK BMS',
        child: Text('JK BMS'),
      ),
      DropdownMenuItem(
        value: 'JBD',
        child: Text('JBD'),
      ),
      DropdownMenuItem(
        value: 'Daly',
        child: Text('Daly'),
      ),
      DropdownMenuItem(
        value: 'Seplos',
        child: Text('Seplos'),
      ),
      DropdownMenuItem(
        value: 'Pace',
        child: Text('Pace'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedBms = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedBatteryProtocol,
    dropdownColor: brandCard,
    isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
    decoration: dropdownDecoration(
      'Протокол звʼязку',
    ),
    items: const [
      DropdownMenuItem(
        value: 'CAN',
        child: Text('CAN'),
      ),
      DropdownMenuItem(
        value: 'RS485',
        child: Text('RS485'),
      ),
      DropdownMenuItem(
        value: 'Bluetooth',
        child: Text('Bluetooth'),
      ),
      DropdownMenuItem(
        value: 'WiFi',
        child: Text('WiFi'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedBatteryProtocol = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticSwitchTile(
    'Підігрів АКБ',
    hasBatteryHeating,
    (v) {
      setModalState(() {
        hasBatteryHeating = v;
      });
    },
  ),

  const SizedBox(height: 12),

  _buildStaticSwitchTile(
    'Охолодження АКБ',
    hasBatteryCooling,
    (v) {
      setModalState(() {
        hasBatteryCooling = v;
      });
    },
  ),

  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.battery_saver_rounded,
          color: AppColors.neon,
          size: 28,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'КОРИСНА ЄМНІСТЬ СИСТЕМИ',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${BatteryCalculator.calculateUsableCapacity(
                  capacity: double.tryParse(batCapacityController.text) ?? 0,
                  voltage: double.tryParse(batVoltageController.text) ?? 0,
                  count: double.tryParse(batCountController.text) ?? 1,
                  dod: selectedDod,
                  reserveSoc: selectedReserveSoc,
                  isPowerStation: false,
                ).toStringAsFixed(2)} кВт·г',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                selectedBatType,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),

              Text(
                '$selectedBms • $selectedBatteryProtocol',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '~ ${BatteryCalculator.calculateBatteryCycles(selectedBatType)} циклів',
              style: const TextStyle(
                color: AppColors.neon,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              '≈ ${BatteryCalculator.calculateBatteryYears(selectedBatType).toStringAsFixed(0)} років',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
]
                      // ================= PORTABLE ESS =================
                      else if (isPortableStation) ...[

  DropdownButtonFormField<String>(
    value: selectedPortableBrand,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Виробник',
    ),
    items: const [
      DropdownMenuItem(
        value: 'EcoFlow',
        child: Text('EcoFlow'),
      ),
      DropdownMenuItem(
        value: 'Bluetti',
        child: Text('Bluetti'),
      ),
      DropdownMenuItem(
        value: 'Jackery',
        child: Text('Jackery'),
      ),
      DropdownMenuItem(
        value: 'Anker',
        child: Text('Anker'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedPortableBrand = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedPortableBatteryType,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Тип АКБ',
    ),
    items: const [
      DropdownMenuItem(
        value: 'LiFePO4',
        child: Text('LiFePO4'),
      ),
      DropdownMenuItem(
        value: 'NMC',
        child: Text('NMC'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedPortableBatteryType = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Ємність',
    portableCapacityController,
    'кВт·год',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),
const SizedBox(height: 16),

_buildStaticInputField(
  'Кількість циклів',
  portableCyclesController,
  'циклів',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),
  const SizedBox(height: 16),

  _buildStaticInputField(
    'Потужність інвертора',
    portableInverterController,
    'Вт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  value: selectedWaveType,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
  decoration: dropdownDecoration(
    'Тип інвертора',
  ),
  items: const [
    DropdownMenuItem(
      value: 'Чиста синусоїда',
      child: Text('Чиста синусоїда'),
    ),
    DropdownMenuItem(
      value: 'Модифікована синусоїда',
      child: Text('Модифікована синусоїда'),
    ),
  ],
  onChanged: (v) {
    setModalState(() {
      selectedWaveType = v!;
    });
  },
),
  const SizedBox(height: 16),

  _buildStaticInputField(
    'PV вхід',
    portablePvController,
    'Вт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  value: selectedPvConnector,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
  decoration: dropdownDecoration(
    'PV розʼєм',
  ),
  items: const [
    DropdownMenuItem(
      value: 'MC4',
      child: Text('MC4'),
    ),
    DropdownMenuItem(
      value: 'XT60',
      child: Text('XT60'),
    ),
    DropdownMenuItem(
      value: 'XT60i',
      child: Text('XT60i'),
    ),
    DropdownMenuItem(
      value: 'Anderson',
      child: Text('Anderson'),
    ),
  ],
  onChanged: (v) {
    setModalState(() {
      selectedPvConnector = v!;
    });
  },
),
  const SizedBox(height: 16),

  _buildStaticInputField(
    'AC зарядка',
    portableAcChargeController,
    'Вт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'UPS перемикання',
    portableUpsController,
    'мс',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),
const SizedBox(height: 16),

_buildStaticSwitchTile(
  'Підходить для газового котла',
  isBoilerUps,
  (v) {
    setModalState(() {
      isBoilerUps = v;
    });
  },
),
  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'ПОРТАТИВНА ЗАРЯДНА СТАНЦІЯ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Бренд: $selectedPortableBrand',
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Тип АКБ: $selectedPortableBatteryType',
        ),
Text(
  'Циклів: ${portableCyclesController.text}',
),
Text(
  'Ресурс: '
  '${BatteryCalculator.portableLifetimeEnergy(
    capacityKwh:
        double.tryParse(
          portableCapacityController.text,
        ) ?? 0,
    cycles:
        double.tryParse(
          portableCyclesController.text,
        ) ?? 0,
  ).toStringAsFixed(0)} кВт·год',
),

Text(
  '≈ '
  '${BatteryCalculator.portableLifetimeYears(
    cycles:
        double.tryParse(
          portableCyclesController.text,
        ) ?? 0,
  ).toStringAsFixed(1)} років',
),
Text(
  'Інвертор: $selectedWaveType',
),

Text(
  'PV розʼєм: $selectedPvConnector',
),

Text(
  'Для котла: ${isBoilerUps ? "Так" : "Ні"}',
),
        const SizedBox(height: 4),

        Text(
          '500 Вт → '
          '${BatteryCalculator.calculatePortableAutonomy(
            capacityKwh: double.tryParse(
                  portableCapacityController.text,
                ) ??
                0,
            loadW: 500,
          ).toStringAsFixed(1)} год',
        ),

        Text(
          '1000 Вт → '
          '${BatteryCalculator.calculatePortableAutonomy(
            capacityKwh: double.tryParse(
                  portableCapacityController.text,
                ) ??
                0,
            loadW: 1000,
          ).toStringAsFixed(1)} год',
        ),

        Text(
          '2000 Вт → '
          '${BatteryCalculator.calculatePortableAutonomy(
            capacityKwh: double.tryParse(
                  portableCapacityController.text,
                ) ??
                0,
            loadW: 2000,
          ).toStringAsFixed(1)} год',
        ),

        const SizedBox(height: 8),

        Text(
          'Інвертор: ${portableInverterController.text} Вт',
        ),

        Text(
          'PV: ${portablePvController.text} Вт',
        ),

        Text(
          'UPS: ${portableUpsController.text} мс',
        ),
      ],
    ),
  ),
]
                      /// ================== UI ДЛЯ АЛЬТЕРНАТИВНОЇ ГЕНЕРАЦІЇ (ВІТРО ) ==================
                      else if (isWind) ...[
  Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      value: selectedWindType,
      dropdownColor: brandCard,
      isExpanded: true,
      style: const TextStyle(
        color: AppColors.textMain,
        fontSize: 14,
      ),
      decoration: dropdownDecoration('Тип турбіни'),
      items: DropdownOptions.windTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setModalState(() {
            selectedWindType = value;
          });
        }
      },
    ),
  ),

  _buildStaticInputField(
    'Середня швидкість вітру',
    windSpeedController,
    'м/с',
    TextInputType.number,
    true,
    (val) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Висота щогли',
          mastHeightController,
          'м',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: _buildStaticInputField(
          'Діаметр ротора',
          rotorDiameterController,
          'м',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Номінальна потужність турбіни',
          whPowerController,
          'кВт',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: _buildStaticInputField(
          'ККД генератора / Редуктора',
          whEfficiencyController,
          '%',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
    ],
  ), 
  const SizedBox(height: 16),

  Row(
  children: [
    

    

    Expanded(
      child: _buildStaticInputField(
        'CF',
        windCfController,
        '%',
        TextInputType.number,
        true,
        (val) => setModalState(() {}),
      ),
    ),
  ],
),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  value: selectedWindZone,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
  decoration: dropdownDecoration(
    'Вітрова зона',
  ),
  items: const [
    DropdownMenuItem(
      value: 'Низька',
      child: Text('Низька (CF≈10%)'),
    ),
    DropdownMenuItem(
      value: 'Середня',
      child: Text('Середня (CF≈20%)'),
    ),
    DropdownMenuItem(
      value: 'Добра',
      child: Text('Добра (CF≈30%)'),
    ),
    DropdownMenuItem(
      value: 'Відмінна',
      child: Text('Відмінна (CF≈40%)'),
    ),
  ],
  onChanged: (v) {
  setModalState(() {
    selectedWindZone = v!;

    switch (v) {
      case 'Низька':
        windCfController.text = '10';
        break;

      case 'Середня':
        windCfController.text = '20';
        break;

      case 'Добра':
        windCfController.text = '30';
        break;

      case 'Відмінна':
        windCfController.text = '40';
        break;
    }
  });
},
),
const SizedBox(height: 16),
_buildStaticSwitchTile(
  'MPPT контролер вітру',
  hasWindMppt,
  (v) {
    setModalState(() {
      hasWindMppt = v;
    });
  },
),
const SizedBox(height: 16),
Row(
  children: [
    Expanded(
      child: _buildStaticInputField(
        'Стартова швидкість',
        windStartSpeedController,
        'м/с',
        TextInputType.number,
        true,
        (val) => setModalState(() {}),
      ),
    ),

    const SizedBox(width: 14),

    Expanded(
      child: _buildStaticInputField(
        'Швидкість відключення',
        windCutoffSpeedController,
        'м/с',
        TextInputType.number,
        true,
        (val) => setModalState(() {}),
      ),
    ),
  ],
),

  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.air_rounded,
          color: AppColors.neon,
          size: 28,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Builder(
            builder: (context) {
              final double power =
                  double.tryParse(whPowerController.text) ?? 0;

              final double efficiency =
                  double.tryParse(whEfficiencyController.text) ?? 0;

              final double windSpeed =
                  double.tryParse(windSpeedController.text) ?? 0;

              final double mastHeight =
                  double.tryParse(mastHeightController.text) ?? 0;

              final double rotorDiameter =
                  double.tryParse(rotorDiameterController.text) ?? 0;

              final double netPower =
                  power * (efficiency / 100);
final double cf =
    (double.tryParse(windCfController.text) ?? 0) / 100;

final double averagePower =
    netPower * cf;

final double dailyGeneration =
    averagePower * 24;

final double yearlyGeneration =
    averagePower * 8760;

final double startSpeed =
    double.tryParse(
      windStartSpeedController.text,
    ) ??
    0;

final double cutoffSpeed =
    double.tryParse(
      windCutoffSpeedController.text,
    ) ??
    0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ВІТРОЕНЕРГЕТИЧНИЙ ПРОФІЛЬ',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Чиста потужність: ${netPower.toStringAsFixed(2)} кВт',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
const SizedBox(height: 8),

Text(
  'Середня потужність: ${averagePower.toStringAsFixed(2)} кВт',
  style: const TextStyle(
    color: AppColors.neon,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  ),
),

Text(
  'Генерація за добу: ${dailyGeneration.toStringAsFixed(1)} кВт·год',
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 13,
  ),
),

Text(
  'Генерація за рік: ${yearlyGeneration.toStringAsFixed(0)} кВт·год',
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 13,
  ),
),
                  const SizedBox(height: 6),

                  Text(
                    'Вітер: ${windSpeed.toStringAsFixed(1)} м/с',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
Text(
  'CF: ${(cf * 100).toStringAsFixed(0)}%',
  style: const TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),
                  Text(
                    'Щогла: ${mastHeight.toStringAsFixed(1)} м',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),

                  Text(
                    'Ротор: ${rotorDiameter.toStringAsFixed(1)} м',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),

                  Text(
                    'Тип: $selectedWindType',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  Text(
  'Старт: ${startSpeed.toStringAsFixed(1)} м/с',
  style: const TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),

Text(
  'Відключення: ${cutoffSpeed.toStringAsFixed(1)} м/с',
  style: const TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),

Text(
  'Зона: $selectedWindZone',
  style: const TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),

Text(
  'MPPT: ${hasWindMppt ? "Так" : "Ні"}',
  style: const TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),
                ],
              );
            },
          ),
        ),
      ],
    ),
  ),
]
/// ================== UI ДЛЯ АЛЬТЕРНАТИВНОЇ ГЕНЕРАЦІЇ (ГЕС) ==================
else if (isHydro) ...[
  DropdownButtonFormField<String>(
    value: selectedHydroTurbine,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Тип гідротурбіни',
    ),
    items: DropdownOptions.hydroTurbines.map((type) {
      return DropdownMenuItem<String>(
        value: type,
        child: Text(type),
      );
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        setModalState(() {
          selectedHydroTurbine = value;
        });
      }
    },
  ),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  value: selectedHydroSource,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
  decoration: dropdownDecoration(
    'Тип водойми',
  ),
  items: const [
    DropdownMenuItem(
      value: 'Річка',
      child: Text('Річка'),
    ),
    DropdownMenuItem(
      value: 'Гірський струмок',
      child: Text('Гірський струмок'),
    ),
    DropdownMenuItem(
      value: 'Канал',
      child: Text('Канал'),
    ),
    DropdownMenuItem(
      value: 'Ставок',
      child: Text('Ставок'),
    ),
    DropdownMenuItem(
      value: 'Технічний скид',
      child: Text('Технічний скид'),
    ),
  ],
  onChanged: (value) {
    if (value != null) {
      setModalState(() {
        selectedHydroSource = value;
      });
    }
  },
),
  const SizedBox(height: 16),

  _buildStaticInputField(
    'Витрата води',
    hydroFlowController,
    'л/с',
    TextInputType.number,
    true,
    null,
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Напір води',
    hydroHeadController,
    'м',
    TextInputType.number,
    true,
    null,
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'ККД турбіни',
    hydroEfficiencyController,
    '%',
    TextInputType.number,
    true,
    null,
  ),
  
const SizedBox(height: 16),

_buildStaticInputField(
  'Коеф. використання (CF)',
  hydroCfController,
  '%',
  TextInputType.number,
  true,
  (val) => setModalState(() {}),
),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  value: selectedHydroGeneratorType,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
  decoration: dropdownDecoration(
    'Тип генератора',
  ),
  items: const [
    DropdownMenuItem(
      value: 'PM Generator',
      child: Text('PM Generator'),
    ),
    DropdownMenuItem(
      value: 'Синхронний',
      child: Text('Синхронний'),
    ),
    DropdownMenuItem(
      value: 'Асинхронний',
      child: Text('Асинхронний'),
    ),
    DropdownMenuItem(
      value: 'BLDC',
      child: Text('BLDC'),
    ),
  ],
  onChanged: (v) {
    setModalState(() {
      selectedHydroGeneratorType = v!;
    });
  },
),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  value: selectedHydroOutput,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
  decoration: dropdownDecoration(
    'Підключення',
  ),
  items: const [
    DropdownMenuItem(
      value: 'Через АКБ',
      child: Text('Через АКБ'),
    ),
    DropdownMenuItem(
      value: 'Пряме живлення',
      child: Text('Пряме живлення'),
    ),
    DropdownMenuItem(
      value: 'Гібридна система',
      child: Text('Гібридна система'),
    ),
  ],
  onChanged: (v) {
    setModalState(() {
      selectedHydroOutput = v!;
    });
  },
),
const SizedBox(height: 16),
const SizedBox(height: 16),

DropdownButtonFormField<String>(
  value: selectedHydroSeason,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
  decoration: dropdownDecoration(
    'Сезонність потоку',
  ),
  items: const [
    DropdownMenuItem(
      value: 'Стабільний цілий рік',
      child: Text('Стабільний цілий рік'),
    ),
    DropdownMenuItem(
      value: 'Весняний максимум',
      child: Text('Весняний максимум'),
    ),
    DropdownMenuItem(
      value: 'Літнє падіння',
      child: Text('Літнє падіння'),
    ),
    DropdownMenuItem(
      value: 'Сильна сезонність',
      child: Text('Сильна сезонність'),
    ),
  ],
  onChanged: (v) {
    setModalState(() {
      selectedHydroSeason = v!;
    });
  },
),
const SizedBox(height: 16),
_buildStaticSwitchTile(
  'Безперервна робота 24/7',
  hydro24x7,
  (v) {
    setModalState(() {
      hydro24x7 = v;
    });
  },
),
const SizedBox(height: 16),
_buildStaticInputField(
  'Номінальна потужність',
  whPowerController,
  'кВт',
  TextInputType.number,
  true,
  (val) => setModalState(() {}),
),
const SizedBox(height: 24),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: AppColors.neon.withValues(alpha: 0.04),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.neon.withValues(alpha: 0.15),
    ),
  ),
  child: Builder(
    builder: (context) {
      final flow =
          double.tryParse(
            hydroFlowController.text,
          ) ??
          0;

      final head =
          double.tryParse(
            hydroHeadController.text,
          ) ??
          0;

      final efficiency =
          double.tryParse(
            hydroEfficiencyController.text,
          ) ??
          0;

      final hydroPower =
          9.81 *
          (flow / 1000) *
          head *
          (efficiency / 100);
final cf =
    (double.tryParse(
          hydroCfController.text,
        ) ??
        0) /
    100;

final dailyGeneration =
    hydroPower * 24 * cf;
double seasonFactor = 1.0;

switch (selectedHydroSeason) {
  case 'Весняний максимум':
    seasonFactor = 0.90;
    break;

  case 'Літнє падіння':
    seasonFactor = 0.80;
    break;

  case 'Сильна сезонність':
    seasonFactor = 0.70;
    break;

  default:
    seasonFactor = 1.0;
}
double sourceFactor = 1.0;

switch (selectedHydroSource) {
  case 'Гірський струмок':
    sourceFactor = 0.95;
    break;

  case 'Річка':
    sourceFactor = 0.90;
    break;

  case 'Канал':
    sourceFactor = 1.00;
    break;

  case 'Ставок':
    sourceFactor = 0.75;
    break;

  case 'Технічний скид':
    sourceFactor = 1.00;
    break;
}
final yearlyGeneration =
    hydroPower *
    8760 *
    cf *
    seasonFactor *
    sourceFactor;
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'ГІДРОЕНЕРГЕТИЧНИЙ ПРОФІЛЬ',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Розрахункова потужність: ${hydroPower.toStringAsFixed(2)} кВт',
            
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
const SizedBox(height: 8),

Text(
  'Генерація за добу: ${dailyGeneration.toStringAsFixed(1)} кВт·год',
  style: const TextStyle(
    color: AppColors.neon,
    fontWeight: FontWeight.w700,
  ),
),

Text(
  'Генерація за рік: ${yearlyGeneration.toStringAsFixed(0)} кВт·год',
  style: const TextStyle(
    color: AppColors.textMain,
  ),
),
          const SizedBox(height: 6),

          Text(
            'Витрата: ${flow.toStringAsFixed(1)} л/с',
            style: const TextStyle(
              color: AppColors.textMuted,
            ),
          ),

          Text(
            'Напір: ${head.toStringAsFixed(1)} м',
            style: const TextStyle(
              color: AppColors.textMuted,
            ),
          ),

          Text(
            'Тип турбіни: $selectedHydroTurbine',
            style: const TextStyle(
              color: AppColors.textMuted,
            ),
          ),
          Text(
  'Водойма: $selectedHydroSource',
  style: const TextStyle(
    color: AppColors.textMuted,
  ),
),
          Text(
  'CF: ${hydroCfController.text}%',
  style: const TextStyle(
    color: AppColors.textMuted,
  ),
),

Text(
  'Генератор: $selectedHydroGeneratorType',
  style: const TextStyle(
    color: AppColors.textMuted,
  ),
),

Text(
  'Підключення: $selectedHydroOutput',
  style: const TextStyle(
    color: AppColors.textMuted,
  ),
),

Text(
  '24/7: ${hydro24x7 ? "Так" : "Ні"}',
  style: const TextStyle(
    color: AppColors.textMuted,
  ),
),
        ],
      );
    },
  ),
),
]
                      /// ================== UI ДЛЯ ЕЛЕКТРОМОБІЛІВ ТА EV ЗАРЯДОК ==================
                      else if (isEvRelated) ...[

  DropdownButtonFormField<String>(
    value: selectedConnectorType,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Тип розʼєму',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Type 1',
        child: Text('Type 1'),
      ),
      DropdownMenuItem(
        value: 'Type 2',
        child: Text('Type 2'),
      ),
      DropdownMenuItem(
        value: 'CCS2',
        child: Text('CCS2'),
      ),
      DropdownMenuItem(
        value: 'CHAdeMO',
        child: Text('CHAdeMO'),
      ),
      DropdownMenuItem(
        value: 'GB/T',
        child: Text('GB/T'),
      ),
      DropdownMenuItem(
        value: 'Tesla NACS',
        child: Text('Tesla NACS'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedConnectorType = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  Row(
    children: [

      Expanded(
        child: _buildStaticInputField(
          'Потужність зарядки',
          evPowerController,
          'кВт',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: _buildStaticInputField(
          'Ємність АКБ авто',
          evCapacityController,
          'кВт·г',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Максимальний струм',
    evMaxCurrentController,
    'А',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedChargingMode,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Режим роботи',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Одностороння (G2V)',
        child: Text('Одностороння (G2V)'),
      ),
      DropdownMenuItem(
        value: 'Двонаправлена (V2H)',
        child: Text('Двонаправлена (V2H)'),
      ),
      DropdownMenuItem(
        value: 'Двонаправлена (V2G)',
        child: Text('Двонаправлена (V2G)'),
      ),
      DropdownMenuItem(
        value: 'V2L',
        child: Text('V2L'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedChargingMode = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedChargePriority,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Пріоритет зарядки',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Нічний тариф',
        child: Text('Нічний тариф'),
      ),
      DropdownMenuItem(
        value: 'Надлишок сонця',
        child: Text('Надлишок сонця'),
      ),
      DropdownMenuItem(
        value: 'Баланс ESS',
        child: Text('Баланс ESS'),
      ),
      DropdownMenuItem(
        value: 'Максимальна швидкість',
        child: Text('Максимальна швидкість'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedChargePriority = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  Text(
    'Резервований SOC автомобіля',
    style: const TextStyle(
      color: AppColors.textMuted,
      fontSize: 13,
    ),
  ),

  Slider(
    value: reservedVehicleSoc,
    min: 10,
    max: 80,
    divisions: 14,
    label:
        '${reservedVehicleSoc.toStringAsFixed(0)}%',
    onChanged: (v) {
      setModalState(() {
        reservedVehicleSoc = v;
      });
    },
  ),

  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Row(
      children: [

        const Icon(
          Icons.electric_car_rounded,
          color: AppColors.neon,
          size: 28,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              const Text(
                'EV ЕНЕРГОПРОФІЛЬ',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 6),

              Text(
  'Час зарядки: '
  '${EvCalculator.chargeHours(
    capacity: double.tryParse(evCapacityController.text) ?? 0,
    power: double.tryParse(evPowerController.text) ?? 0,
  ).toStringAsFixed(1)} год',
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  ),
),

Text(
  'Енергія для дому: '
  '${EvCalculator.availableHomeEnergy(
    capacity: double.tryParse(evCapacityController.text) ?? 0,
    reservedSoc: reservedVehicleSoc,
  ).toStringAsFixed(1)} кВт·г',
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
),

Text(
  'Повна зарядка: '
  '${EvCalculator.fullChargeCost(
    capacity: double.tryParse(evCapacityController.text) ?? 0,
    tariff: double.tryParse(gridNightTariffController.text) ?? 2.16,
  ).toStringAsFixed(0)} ₴',
  style: const TextStyle(
    color: AppColors.neon,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  ),
),

              const SizedBox(height: 6),

              Text(
                'Режим: $selectedChargingMode',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),

              Text(
                'Пріоритет: $selectedChargePriority',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
]

                      /// ================== UI ДЛЯ ЦЕНТРАЛЬНОЇ МЕРЕЖІ / ВВЕДЕННЯ ==================
else if (isGrid) ...[
  _buildStaticInputField(
    'Ліміт потужності за договором',
    gridLimitController,
    'кВт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedPhaseType,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration('Тип підключення'),
    items: const [
      DropdownMenuItem(
        value: '1 Фаза (230В)',
        child: Text('1 Фаза (230В)'),
      ),
      DropdownMenuItem(
        value: '3 Фази (380В)',
        child: Text('3 Фази (380В)'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedPhaseType = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Напруга мережі',
    gridVoltageController,
    'В',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedTariffZones,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Зонність обліку лічильника',
    ),
    items: [
      '1-зонний (Стандарт)',
      '2-зонний (День / Ніч)',
      '3-зонний (Піковий)',
    ].map((zone) {
      return DropdownMenuItem<String>(
        value: zone,
        child: Text(zone),
      );
    }).toList(),
    onChanged: (v) {
      setModalState(() {
        selectedTariffZones = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Денний тариф',
          gridDayTariffController,
          '₴/кВт·г',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: _buildStaticInputField(
          'Нічний тариф',
          gridNightTariffController,
          '₴/кВт·г',
          TextInputType.number,
          true,
          (v) => setModalState(() {}),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedGridQuality,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration('Якість мережі'),
    items: const [
      DropdownMenuItem(
        value: 'Стабільна мережа',
        child: Text('Стабільна мережа'),
      ),
      DropdownMenuItem(
        value: 'Часті просадки',
        child: Text('Часті просадки'),
      ),
      DropdownMenuItem(
        value: 'Перекіс фаз',
        child: Text('Перекіс фаз'),
      ),
      DropdownMenuItem(
        value: 'Критична нестабільність',
        child: Text('Критична нестабільність'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedGridQuality = v!;
      });
    },
  ),

  const SizedBox(height: 20),

  Text(
    'Середня тривалість відключень',
    style: TextStyle(
      color: AppColors.textMuted,
      fontSize: 13,
    ),
  ),

  Slider(
    value: blackoutHoursPerDay,
    min: 0,
    max: 24,
    divisions: 24,
    label:
        '${blackoutHoursPerDay.toStringAsFixed(0)} год',
    onChanged: (v) {
      setModalState(() {
        blackoutHoursPerDay = v;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Ввідний автомат',
    gridMainBreakerController,
    'А',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.bolt,
          color: AppColors.neon,
          size: 28,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ПАСПОРТ МЕРЕЖІ',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Покриття мережею: '
'${GridCalculator.gridCoverage(
  blackoutHoursPerDay: blackoutHoursPerDay,
).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Text(
                'Нічна зарядка АКБ: '
                '${GridCalculator.nightChargeCost(
  batteryKwh: 10,
  nightTariff: double.tryParse(
        gridNightTariffController.text,
      ) ??
      0,
).toStringAsFixed(0)} ₴',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                ),
              ),

              Text(
                'Економія від нічного тарифу: '
                '${GridCalculator.nightSaving(
  batteryKwh: 10,
  dayTariff: double.tryParse(
        gridDayTariffController.text,
      ) ??
      0,
  nightTariff: double.tryParse(
        gridNightTariffController.text,
      ) ??
      0,
).toStringAsFixed(0)} ₴',
                style: const TextStyle(
                  color: AppColors.neon,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
]
/// ================== UI ДЛЯ SMART METER ==================
else if (isSmartMeter) ...[

  _buildStaticInputField(
    'Модель лічильника',
    meterModelController,
    '',
    TextInputType.text,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedAccuracyClass,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration('Клас точності'),
    items: const [
      DropdownMenuItem(
        value: '0.5',
        child: Text('0.5'),
      ),
      DropdownMenuItem(
        value: '1.0',
        child: Text('1.0'),
      ),
      DropdownMenuItem(
        value: '2.0',
        child: Text('2.0'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedAccuracyClass = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedMeterDirection,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Напрямок обліку',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Імпорт',
        child: Text('Імпорт'),
      ),
      DropdownMenuItem(
        value: 'Експорт',
        child: Text('Експорт'),
      ),
      DropdownMenuItem(
        value: 'Двонаправлений',
        child: Text('Двонаправлений'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedMeterDirection = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Modbus адреса',
    modbusAddressController,
    '',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Коефіцієнт ТТ',
    ctRatioController,
    '',
    TextInputType.text,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Text(
          'ЕНЕРГОБАЛАНС',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'Миттєва потужність: '
          '${MeterCalculator.calculateInstantPower(
      voltage: 230,
      current: 16,
    ).toStringAsFixed(1)} кВт',
        ),

        Text(
          'Імпорт за добу: '
          '${MeterCalculator.calculateDailyImport(
      importedEnergy: 24.5,
    ).toStringAsFixed(1)} кВт·г',
        ),

        Text(
          'Експорт за добу: '
          '${MeterCalculator.calculateDailyExport(
      exportedEnergy: 8.7,
    ).toStringAsFixed(1)} кВт·г',
        ),

        Text(
          'Баланс: '
          '${MeterCalculator.calculateEnergyBalance(
      importedEnergy: 24.5,
      exportedEnergy: 8.7,
    ).toStringAsFixed(1)} кВт·г',
          style: const TextStyle(
            color: AppColors.neon,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  ),
]
/// ================== UI ДЛЯ СТАБІЛІЗАТОР НАПРУГИ ==================
else if (isStabilizer) ...[
  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Потужність',
          stabilizerPowerController,
          'кВА',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: DropdownButtonFormField<String>(
          value: selectedStabilizerType,
          dropdownColor: brandCard,
          isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
          decoration: dropdownDecoration('Тип'),
          items: const [
            DropdownMenuItem(
              value: 'relay',
              child: Text('Релейний'),
            ),
            DropdownMenuItem(
              value: 'electronic',
              child: Text('Електронний'),
            ),
            DropdownMenuItem(
              value: 'servo',
              child: Text('Сервопривідний'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setModalState(() {
                selectedStabilizerType = value;
              });
            }
          },
        ),
      ),
    ],
  ),

  const SizedBox(height: 14),

  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Мін. напруга',
          stabilizerMinVoltageController,
          'В',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: _buildStaticInputField(
          'Макс. напруга',
          stabilizerMaxVoltageController,
          'В',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
    ],
  ),
  const SizedBox(height: 24),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: AppColors.neon.withValues(alpha: 0.04),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.neon.withValues(alpha: 0.15),
    ),
  ),
  child: Builder(
    builder: (context) {
      final double minVoltage =
          double.tryParse(stabilizerMinVoltageController.text) ?? 0;

      final double maxVoltage =
          double.tryParse(stabilizerMaxVoltageController.text) ?? 0;

      final double range = maxVoltage - minVoltage;

      String protectionLevel;
      String protectionDescription;

      if (range >= 120) {
        protectionLevel = 'Високий';
        protectionDescription =
            'Підходить для нестабільних мереж з частими просадками та перенапругами';
      } else if (range >= 80) {
        protectionLevel = 'Стандартний';
        protectionDescription =
            'Забезпечує захист від більшості типових коливань напруги';
      } else {
        protectionLevel = 'Базовий';
        protectionDescription =
            'Рекомендується для мереж зі стабільними параметрами';
      }

      String typeName;
      String speed;
      String accuracy;
      String application;

      switch (selectedStabilizerType) {
        case 'relay':
          typeName = 'Релейний';
          speed = 'Середня';
          accuracy = 'Базова';
          application = 'Побутова техніка та загальні навантаження';
          break;

        case 'servo':
          typeName = 'Сервопривідний';
          speed = 'Низька';
          accuracy = 'Дуже висока';
          application = 'Електродвигуни та майстерні';
          break;

        default:
          typeName = 'Електронний';
          speed = 'Максимальна';
          accuracy = 'Висока';
          application = 'Чутлива електроніка та IT-обладнання';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: AppColors.neon,
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'АНАЛІТИКА NUVIT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Рівень захисту: $protectionLevel',
            style: const TextStyle(
              color: AppColors.neon,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            protectionDescription,
            style: const TextStyle(
              color: AppColors.textMain,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          const Divider(),

          const SizedBox(height: 10),

          Text(
            'Тип стабілізатора: $typeName',
            style: const TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Швидкодія: $speed',
            style: const TextStyle(
              color: AppColors.textMain,
            ),
          ),

          Text(
            'Точність: $accuracy',
            style: const TextStyle(
              color: AppColors.textMain,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Рекомендоване застосування:',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            application,
            style: const TextStyle(
              color: AppColors.textMain,
            ),
          ),
        ],
      );
    },
  ),
),
]
// ================= РЕЛЕ НАПРУГИ =================
else if (isVoltageRelay) ...[
  Row(
  children: [
    Expanded(
      child: _buildStaticInputField(
        'Мін. напруга',
        relayMinVoltageController,
        'В',
        TextInputType.number,
        true,
        (val) => setModalState(() {}),
      ),
    ),
    const SizedBox(width: 14),
    Expanded(
      child: _buildStaticInputField(
        'Макс. напруга',
        relayMaxVoltageController,
        'В',
        TextInputType.number,
        true,
        (val) => setModalState(() {}),
      ),
    ),
  ],
),

const SizedBox(height: 14),

_buildStaticInputField(
  'Затримка повторного ввімкнення',
  relayDelayController,
  'с',
  TextInputType.number,
  true,
  (val) => setModalState(() {}),
),
const SizedBox(height: 24),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: AppColors.neon.withValues(alpha: 0.04),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.neon.withValues(alpha: 0.15),
    ),
  ),
  child: Builder(
    builder: (context) {
      final double minVoltage =
          double.tryParse(relayMinVoltageController.text) ?? 180;

      final double maxVoltage =
          double.tryParse(relayMaxVoltageController.text) ?? 260;

      final double delay =
          double.tryParse(relayDelayController.text) ?? 10;

      String protectionLevel;
      String recommendation;

      if (minVoltage >= 195 && maxVoltage <= 245) {
        protectionLevel = 'Максимальний';
        recommendation =
            'Для серверів, котлів, теплових насосів та чутливої електроніки';
      } else if (minVoltage >= 185 && maxVoltage <= 255) {
        protectionLevel = 'Підвищений';
        recommendation =
            'Для сучасної побутової техніки та електроніки';
      } else {
        protectionLevel = 'Стандартний';
        recommendation =
            'Для загального побутового використання';
      }

      String restartMode;

      if (delay <= 5) {
        restartMode = 'Швидке відновлення';
      } else if (delay <= 30) {
        restartMode = 'Оптимальний режим';
      } else {
        restartMode = 'Безпечний запуск компресорної техніки';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.gpp_good_rounded,
                color: AppColors.neon,
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'АНАЛІТИКА NUVIT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Рівень захисту: $protectionLevel',
            style: const TextStyle(
              color: AppColors.neon,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Діапазон контролю: '
            '${minVoltage.toInt()}–${maxVoltage.toInt()} В',
            style: const TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Режим відновлення: $restartMode',
            style: const TextStyle(
              color: AppColors.textMain,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Рекомендовано:',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            recommendation,
            style: const TextStyle(
              color: AppColors.textMain,
              height: 1.4,
            ),
          ),
        ],
      );
    },
  ),
),
]
// ================= ПЗІП =================
else if (isSurgeProtection) ...[
  DropdownButtonFormField<String>(
  value: selectedSpdType,
  dropdownColor: brandCard,
  isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
  decoration: dropdownDecoration('Тип ПЗІП'),
  items: const [
    DropdownMenuItem(
      value: 'T1',
      child: Text('Тип 1'),
    ),
    DropdownMenuItem(
      value: 'T2',
      child: Text('Тип 2'),
    ),
    DropdownMenuItem(
      value: 'T1+T2',
      child: Text('Тип 1+2'),
    ),
  ],
  onChanged: (value) {
    if (value != null) {
      setModalState(() {
        selectedSpdType = value;
      });
    }
  },
),

const SizedBox(height: 14),

_buildStaticInputField(
  'Опір заземлення',
  groundResistanceController,
  'Ом',
  TextInputType.number,
  true,
  (val) => setModalState(() {}),
),
const SizedBox(height: 24),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: AppColors.neon.withValues(alpha: 0.04),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.neon.withValues(alpha: 0.15),
    ),
  ),
  child: Builder(
    builder: (context) {
      final double resistance =
          double.tryParse(
                groundResistanceController.text,
              ) ??
              999;

      String level;
      String recommendation;

      if (resistance <= 4) {
        level = 'Відмінний';
        recommendation =
            'Контур заземлення відповідає високим вимогам захисту.';
      } else if (resistance <= 10) {
        level = 'Добрий';
        recommendation =
            'Підходить для більшості житлових об’єктів.';
      } else {
        level = 'Потребує перевірки';
        recommendation =
            'Рекомендується вимірювання та модернізація контуру.';
      }

      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.electric_bolt_rounded,
                color: AppColors.neon,
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'АНАЛІТИКА NUVIT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Стан заземлення: $level',
            style: const TextStyle(
              color: AppColors.neon,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Тип захисту: $selectedSpdType',
            style: const TextStyle(
              color: AppColors.textMain,
            ),
          ),

          Text(
            'Опір контуру: '
            '${resistance.toStringAsFixed(1)} Ом',
            style: const TextStyle(
              color: AppColors.textMain,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            recommendation,
            style: const TextStyle(
              color: AppColors.textMain,
              height: 1.4,
            ),
          ),
        ],
      );
    },
  ),
),
]
// ================= ПЗВ =================
else if (isRcd) ...[
  _buildStaticInputField(
  'Номінальний струм',
  rcdCurrentController,
  'А',
  TextInputType.number,
  true,
  (val) => setModalState(() {}),
),
const SizedBox(height: 14),

DropdownButtonFormField<String>(
  value: selectedRcdSensitivity,
  dropdownColor: brandCard,
  isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
  decoration: dropdownDecoration(
    'Струм витоку',
  ),
  items: const [
    DropdownMenuItem(
      value: '10',
      child: Text('10 мА'),
    ),
    DropdownMenuItem(
      value: '30',
      child: Text('30 мА'),
    ),
    DropdownMenuItem(
      value: '100',
      child: Text('100 мА'),
    ),
    DropdownMenuItem(
      value: '300',
      child: Text('300 мА'),
    ),
  ],
  onChanged: (value) {
    if (value != null) {
      setModalState(() {
        selectedRcdSensitivity = value;
      });
    }
  },
),
const SizedBox(height: 14),

DropdownButtonFormField<String>(
  value: selectedRcdType,
  dropdownColor: brandCard,
  isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
  decoration: dropdownDecoration(
    'Тип ПЗВ',
  ),
  items: const [
    DropdownMenuItem(
      value: 'AC',
      child: Text('AC'),
    ),
    DropdownMenuItem(
      value: 'A',
      child: Text('A'),
    ),
    DropdownMenuItem(
      value: 'F',
      child: Text('F'),
    ),
  ],
  onChanged: (value) {
    if (value != null) {
      setModalState(() {
        selectedRcdType = value;
      });
    }
  },
),
const SizedBox(height: 24),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: AppColors.neon.withValues(alpha: 0.04),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.neon.withValues(alpha: 0.15),
    ),
  ),
  child: Builder(
    builder: (context) {
      String protectionLevel;
      String recommendation;

      switch (selectedRcdSensitivity) {
        case '10':
          protectionLevel = 'Максимальний';
          recommendation =
              'Для ванних кімнат, дитячих кімнат та розеток підвищеної безпеки.';
          break;

        case '30':
          protectionLevel = 'Стандарт житлових об’єктів';
          recommendation =
              'Оптимальний вибір для квартир та будинків.';
          break;

        case '100':
          protectionLevel = 'Протипожежний';
          recommendation =
              'Захист ліній та групових навантажень.';
          break;

        default:
          protectionLevel = 'Промисловий';
          recommendation =
              'Захист великих об’єктів та ввідних ліній.';
      }

      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_rounded,
                color: AppColors.neon,
                size: 26,
              ),
              SizedBox(width: 10),
              Text(
                'АНАЛІТИКА NUVIT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Рівень захисту: $protectionLevel',
            style: const TextStyle(
              color: AppColors.neon,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Тип ПЗВ: $selectedRcdType',
            style: const TextStyle(
              color: AppColors.textMain,
            ),
          ),

          Text(
            'Номінальний струм: '
            '${rcdCurrentController.text} А',
            style: const TextStyle(
              color: AppColors.textMain,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            recommendation,
            style: const TextStyle(
              color: AppColors.textMain,
              height: 1.4,
            ),
          ),
        ],
      );
    },
  ),
),
]
                      
/// ================== UI ДЛЯ АВР ==================
else if (isAts) ...[

  _buildStaticInputField(
    'Час перемикання',
    atsTransferTimeController,
    'мс',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedAtsPriority,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Пріоритет джерел',
    ),
    items: const [

      DropdownMenuItem(
        value:
            'Мережа → АКБ → Генератор',
        child: Text(
          'Мережа → АКБ → Генератор',
        ),
      ),

      DropdownMenuItem(
        value:
            'Мережа → Генератор → АКБ',
        child: Text(
          'Мережа → Генератор → АКБ',
        ),
      ),

      DropdownMenuItem(
        value:
            'АКБ → Мережа → Генератор',
        child: Text(
          'АКБ → Мережа → Генератор',
        ),
      ),

      DropdownMenuItem(
        value:
            'Генератор → АКБ → Мережа',
        child: Text(
          'Генератор → АКБ → Мережа',
        ),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedAtsPriority = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  Text(
    'SOC запуску генератора',
    style: TextStyle(
      color: AppColors.textMuted,
      fontSize: 13,
    ),
  ),

  Slider(
    value: generatorStartSoc,
    min: 5,
    max: 80,
    divisions: 15,
    label:
        '${generatorStartSoc.toStringAsFixed(0)}%',
    onChanged: (v) {
      setModalState(() {
        generatorStartSoc = v;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Мінімальна напруга мережі',
    atsMinGridVoltageController,
    'В',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),
  const SizedBox(height: 16),
  DropdownButtonFormField<String>(
  value: selectedBackupSource,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
  decoration: dropdownDecoration(
    'Резервне джерело',
  ),
  items: const [

    DropdownMenuItem(
      value: 'Інвертор',
      child: Text('Інвертор'),
    ),

    DropdownMenuItem(
      value: 'Генератор',
      child: Text('Генератор'),
    ),

    DropdownMenuItem(
      value: 'АКБ',
      child: Text('АКБ'),
    ),

    DropdownMenuItem(
      value: 'Сонячна генерація',
      child: Text('Сонячна генерація'),
    ),
  ],
  onChanged: (v) {
    setModalState(() {
      selectedBackupSource = v!;
    });
  },
),


const SizedBox(height: 16),
_buildStaticInputField(
  'Максимальна напруга мережі',
  atsMaxGridVoltageController,
  'В',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),
const SizedBox(height: 16),
_buildStaticInputField(
  'Мінімальна частота мережі',
  atsMinFrequencyController,
  'Гц',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),
const SizedBox(height: 16),
_buildStaticInputField(
  'Максимальна частота мережі',
  atsMaxFrequencyController,
  'Гц',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),
const SizedBox(height: 16),
_buildStaticInputField(
  'Затримка перемикання',
  atsSwitchDelayController,
  'сек',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),
const SizedBox(height: 16),
_buildStaticInputField(
  'Затримка повернення',
  atsReturnDelayController,
  'сек',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),
const SizedBox(height: 16),
DropdownButtonFormField<String>(
  value: selectedAtsMode,
  dropdownColor: brandCard,
  isExpanded: true,
  style: const TextStyle(
    color: AppColors.textMain,
    fontSize: 14,
  ),
  decoration:
      dropdownDecoration(
        'Режим роботи',
      ),
  items: const [

    DropdownMenuItem(
      value: 'Автоматичний',
      child: Text(
        'Автоматичний',
      ),
    ),

    DropdownMenuItem(
      value: 'Ручний',
      child: Text(
        'Ручний',
      ),
    ),

    DropdownMenuItem(
      value: 'Віддалений',
      child: Text(
        'Віддалений',
      ),
    ),
  ],
  onChanged: (v) {
    setModalState(() {
      selectedAtsMode = v!;
    });
  },
),
const SizedBox(height: 8),

SwitchListTile(
  value: atsAutoReturn,
  activeColor: AppColors.neon,
  title: const Text(
    'Автоповернення на мережу',
    style: TextStyle(
      color: AppColors.textMain,
    ),
  ),
  onChanged: (v) {
    setModalState(() {
      atsAutoReturn = v;
    });
  },
),
  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(
        alpha: 0.04,
      ),
      borderRadius:
          BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon
            .withValues(alpha: 0.15),
      ),
    ),
    child: Row(
      children: [

        const Icon(
          Icons.swap_horiz_rounded,
          color: AppColors.neon,
          size: 28,
        ),

        const SizedBox(width: 14),

        Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        'ПАСПОРТ АВР',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),

      const SizedBox(height: 10),

      Text(
        '⚡ Режим: $selectedAtsMode',
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        '🔄 Сценарій:',
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
        ),
      ),

      Text(
        AtsCalculator.getScenario(
          prioritySource:
              selectedAtsPriority,
        ),
        style: const TextStyle(
          color: AppColors.neon,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        '🔋 Резерв: $selectedBackupSource',
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        '⚡ Чутливість захисту: '
        '${AtsCalculator.calculateProtectionSensitivity(
          minVoltage: double.tryParse(
                atsMinGridVoltageController.text,
              ) ??
              190,
          maxVoltage: double.tryParse(
                atsMaxGridVoltageController.text,
              ) ??
              255,
        ).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        '🛡 Надійність АВР: '
        '${AtsCalculator.calculateReliability(
          autoTest: atsAutoTest,
          remoteControl: atsRemoteControl,
          phaseMonitoring:
              selectedPhaseMonitoring,
        ).toStringAsFixed(0)}%',
        style: TextStyle(
          color:
              AtsCalculator.calculateReliability(
                        autoTest: atsAutoTest,
                        remoteControl:
                            atsRemoteControl,
                        phaseMonitoring:
                            selectedPhaseMonitoring,
                      ) >=
                      90
                  ? Colors.green
                  : AtsCalculator.calculateReliability(
                            autoTest:
                                atsAutoTest,
                            remoteControl:
                                atsRemoteControl,
                            phaseMonitoring:
                                selectedPhaseMonitoring,
                          ) >=
                          75
                      ? Colors.orange
                      : Colors.red,
          fontWeight:
              FontWeight.w700,
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        '⏳ Автономність: '
        '${AtsCalculator.calculateAutonomy(
          batteryCapacityAh:
              double.tryParse(
                    batCapacityController.text,
                  ) ??
                  0,
          batteryVoltage:
              double.tryParse(
                    batVoltageController.text,
                  ) ??
                  0,
          batteryCount:
              int.tryParse(
                    batCountController.text,
                  ) ??
                  1,
          averageLoad:
              totalLoad(),
        ).toStringAsFixed(1)} год',
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        AtsCalculator.getLogicDescription(
          priority:
              selectedAtsPriority,
          backupSource:
              selectedBackupSource,
          transferTime:
              atsTransferTimeController
                  .text,
        ),
        style: const TextStyle(
          color: AppColors.neon,
          fontSize: 13,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    ],
  ),
),
      ],
    ),
  ),
]
                     /// ================== UI ДЛЯ АВТОМАТИЗАЦІЇ ТА СМАРТ КЕРУВАННЯ ==================
else if (isSmartAutomation) ...[

  DropdownButtonFormField<String>(
    value: selectedIntegrationType,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Платформа інтеграції',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Home Assistant',
        child: Text('Home Assistant'),
      ),
      DropdownMenuItem(
        value: 'Tuya',
        child: Text('Tuya'),
      ),
      DropdownMenuItem(
        value: 'Node-RED',
        child: Text('Node-RED'),
      ),
      DropdownMenuItem(
        value: 'OpenHAB',
        child: Text('OpenHAB'),
      ),
      DropdownMenuItem(
        value: 'ioBroker',
        child: Text('ioBroker'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedIntegrationType = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'IP адреса',
    homeAssistantIpController,
    '',
    TextInputType.text,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedCommunicationProtocol,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Тип інтеграції',
    ),
    items: const [
      DropdownMenuItem(
        value: 'MQTT',
        child: Text('MQTT'),
      ),
      DropdownMenuItem(
        value: 'REST API',
        child: Text('REST API'),
      ),
      DropdownMenuItem(
        value: 'Modbus TCP',
        child: Text('Modbus TCP'),
      ),
      DropdownMenuItem(
        value: 'Zigbee',
        child: Text('Zigbee'),
      ),
      DropdownMenuItem(
        value: 'Wi-Fi Local',
        child: Text('Wi-Fi Local'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedCommunicationProtocol = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Підключених пристроїв',
    connectedDevicesController,
    'шт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedConnectionStatus,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 14,
    ),
    decoration: dropdownDecoration(
      'Статус звʼязку',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Підключено',
        child: Text('Підключено'),
      ),
      DropdownMenuItem(
        value: 'Обмежений доступ',
        child: Text('Обмежений доступ'),
      ),
      DropdownMenuItem(
        value: 'Немає звʼязку',
        child: Text('Немає звʼязку'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedConnectionStatus = v!;
      });
    },
  ),

  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.hub_rounded,
          color: AppColors.neon,
          size: 28,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'ІНТЕГРАЦІЙНА ПАНЕЛЬ',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Рівень інтеграції: '
                '${calculateIntegrationLevel().toStringAsFixed(0)}%',
              ),

              const SizedBox(height: 4),

              Text(
                'Автоматизацій: '
                '${calculateAutomationCount()}',
              ),

              const SizedBox(height: 4),

              Text(
                'Статус: $selectedConnectionStatus',
                style: const TextStyle(
                  color: AppColors.neon,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
]
/// ================== MONITORING DONGLE ==================
else if (isMonitoring) ...[

  DropdownButtonFormField<String>(
    value: selectedMonitoringType,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Тип підключення',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Wi-Fi',
        child: Text('Wi-Fi'),
      ),
      DropdownMenuItem(
        value: 'LAN',
        child: Text('LAN'),
      ),
      DropdownMenuItem(
        value: '4G',
        child: Text('4G'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedMonitoringType = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedCloudStatus,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Cloud сервіс',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Активний',
        child: Text('Активний'),
      ),
      DropdownMenuItem(
        value: 'Вимкнений',
        child: Text('Вимкнений'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedCloudStatus = v!;
      });
    },
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Пристроїв у моніторингу',
    monitoredDevicesController,
    'шт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  _buildStaticInputField(
    'Інтервал оновлення',
    updateIntervalController,
    'сек',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 16),

  DropdownButtonFormField<String>(
    value: selectedMonitoringStatus,
    dropdownColor: brandCard,
    isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
    decoration: dropdownDecoration(
      'Статус',
    ),
    items: const [
      DropdownMenuItem(
        value: 'Онлайн',
        child: Text('Онлайн'),
      ),
      DropdownMenuItem(
        value: 'Обмежений',
        child: Text('Обмежений'),
      ),
      DropdownMenuItem(
        value: 'Офлайн',
        child: Text('Офлайн'),
      ),
    ],
    onChanged: (v) {
      setModalState(() {
        selectedMonitoringStatus = v!;
      });
    },
  ),

  const SizedBox(height: 24),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.15),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'МОНІТОРИНГ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Тип: $selectedMonitoringType',
        ),

        Text(
          'Cloud: $selectedCloudStatus',
        ),

        Text(
          'Статус: $selectedMonitoringStatus',
          style: const TextStyle(
            color: AppColors.neon,
            fontWeight: FontWeight.w700,
          ),
        ),

        Text(
          'Пристроїв: ${monitoredDevicesController.text}',
        ),

        Text(
          'Оновлення: ${updateIntervalController.text} сек',
        ),
      ],
    ),
  ),
]
/// ================== LOAD SHEDDING ==================
else if (isLoadShedding) ...[
  
const Text(
  'LOAD SHEDDING',
  style: TextStyle(
    color: AppColors.neon,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  ),
),

const SizedBox(height: 16),

_buildStaticInputField(
  'Критична група',
  criticalLoadController,
  'кВт',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),

const SizedBox(height: 16),

_buildStaticInputField(
  'Важлива група',
  importantLoadController,
  'кВт',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),

const SizedBox(height: 16),

_buildStaticInputField(
  'Другорядна група',
  secondaryLoadController,
  'кВт',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),

const SizedBox(height: 20),

Text(
  'SOC відключення другорядної',
  style: TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),

Slider(
  value: secondaryOffSoc,
  min: 10,
  max: 90,
  divisions: 16,
  label: '${secondaryOffSoc.toStringAsFixed(0)}%',
  onChanged: (v) {
    setModalState(() {
      secondaryOffSoc = v;
    });
  },
),

Text(
  'SOC відключення важливої',
  style: TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),

Slider(
  value: importantOffSoc,
  min: 5,
  max: 50,
  divisions: 9,
  label: '${importantOffSoc.toStringAsFixed(0)}%',
  onChanged: (v) {
    setModalState(() {
      importantOffSoc = v;
    });
  },
),

Text(
  'Аварійний режим',
  style: TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
  ),
),

Slider(
  value: emergencyOffSoc,
  min: 5,
  max: 30,
  divisions: 5,
  label: '${emergencyOffSoc.toStringAsFixed(0)}%',
  onChanged: (v) {
    setModalState(() {
      emergencyOffSoc = v;
    });
  },
),

const SizedBox(height: 16),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: brandInnerBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.neon.withValues(alpha: 0.15),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        'АНАЛІТИКА LOAD SHEDDING',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),

      const SizedBox(height: 8),

      Text(
        'Загальне навантаження: '
        '${totalLoad().toStringAsFixed(1)} кВт',
      ),

      const SizedBox(height: 4),

      Text(
        'Можна відключити: '
        '${shedLoad().toStringAsFixed(1)} кВт',
      ),

      const SizedBox(height: 4),

      Text(
        'Аварійний режим: '
        '${emergencyLoad().toStringAsFixed(1)} кВт',
      ),

      const SizedBox(height: 8),

      Text(
        '${secondaryOffSoc.toStringAsFixed(0)}% → '
        '${importantOffSoc.toStringAsFixed(0)}% → '
        '${emergencyOffSoc.toStringAsFixed(0)}%',
        style: const TextStyle(
          color: AppColors.neon,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
),
]
/// ================== DRY CONTACT ==================
else if (isDryContact) ...[

  DropdownButtonFormField<String>(
  value: selectedGeneratorMode,
  dropdownColor: brandCard,
  isExpanded: true,
style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
),
  decoration: dropdownDecoration(
    'Режим роботи',
  ),
  items: const [

    DropdownMenuItem(
      value: 'Автоматичний',
      child: Text('Автоматичний'),
    ),

    DropdownMenuItem(
      value: 'Напівавтоматичний',
      child: Text('Напівавтоматичний'),
    ),

    DropdownMenuItem(
      value: 'Ручний',
      child: Text('Ручний'),
    ),
  ],
  onChanged: (v) {
    setModalState(() {
      selectedGeneratorMode = v!;
    });
  },
),

const SizedBox(height: 16),

_buildStaticInputField(
  'SOC запуску генератора',
  generatorStartSocController,
  '%',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),

const SizedBox(height: 16),

_buildStaticInputField(
  'SOC зупинки генератора',
  generatorStopSocController,
  '%',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),

const SizedBox(height: 16),

_buildStaticInputField(
  'Затримка запуску',
  generatorStartDelayController,
  'сек',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),

const SizedBox(height: 16),

_buildStaticInputField(
  'Затримка зупинки',
  generatorStopDelayController,
  'сек',
  TextInputType.number,
  true,
  (v) => setModalState(() {}),
),

const SizedBox(height: 24),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: AppColors.neon.withValues(alpha: 0.04),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.neon.withValues(alpha: 0.15),
    ),
  ),
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [

      const Text(
        'DRY CONTACT',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),

      const SizedBox(height: 8),

      Text(
        'Режим: $selectedGeneratorMode',
        style: const TextStyle(
          color: AppColors.textMain,
          fontWeight: FontWeight.w700,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        generatorLogicDescription(),
        style: const TextStyle(
          color: AppColors.textMain,
        ),
      ),

      const SizedBox(height: 4),

      Text(
        'Затримка старту: '
        '${generatorStartDelayController.text} сек',
      ),

      Text(
        'Затримка зупинки: '
        '${generatorStopDelayController.text} сек',
      ),

      const SizedBox(height: 8),

      const Text(
        '✓ Автозапуск генератора',
        style: TextStyle(
          color: AppColors.neon,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
),
]
// ///////////////////////// PV DIVERTER /////////////////////////

else if (isPvDiverter) ...[

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Увімкнути PV Diverter',
          pvEnabled,
          (v) => setModalState(() => pvEnabled = v),
        ),
      ),
    ],
  ),

  const SizedBox(height: 12),

  DropdownButtonFormField<String>(
    value: pvMode,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 13,
    ),
    decoration: dropdownDecoration('Режим роботи'),
    items: [
      'Smart (За надлишком)',
      'Fixed Power',
      'Priority Load',
      'Priority Battery',
    ].map((String val) {
      return DropdownMenuItem<String>(
        value: val,
        child: Text(
          val,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList(),
    onChanged: (val) =>
        setModalState(() => pvMode = val!),
  ),

  const SizedBox(height: 12),

  DropdownButtonFormField<String>(
    value: selectedPvLoadType,
    dropdownColor: brandCard,
    isExpanded: true,
    style: const TextStyle(
      color: AppColors.textMain,
      fontSize: 13,
    ),
    decoration: dropdownDecoration(
      'Тип навантаження',
    ),
    items: [
      'Бойлер',
      'ТЕН',
      'Тепла підлога',
      'Басейн',
      'Кондиціонер',
      'Інше',
    ].map((String val) {
      return DropdownMenuItem<String>(
        value: val,
        child: Text(val),
      );
    }).toList(),
    onChanged: (val) =>
        setModalState(() => selectedPvLoadType = val!),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Потужність навантаження',
    pvLoadPowerController,
    'Вт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Мінімальний надлишок для запуску',
    smartTriggerController,
    'Вт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Використовувати Smart Meter',
          pvUseMeter,
          (v) => setModalState(
            () => pvUseMeter = v,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _buildStaticSwitchTile(
          'Дозволити експорт',
          pvAllowExport,
          (v) => setModalState(
            () => pvAllowExport = v,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  const Text(
    'Пріоритет дивертації',
    style: TextStyle(
      color: AppColors.textMuted,
      fontSize: 13,
    ),
  ),

  Slider(
    value: pvPriority,
    min: 0,
    max: 100,
    divisions: 20,
    label: '${pvPriority.toStringAsFixed(0)}%',
    onChanged: (v) =>
        setModalState(() => pvPriority = v),
  ),

  const SizedBox(height: 16),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.12),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'ПАСПОРТ PV DIVERTER',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Статус: ${pvEnabled ? "Увімкнено" : "Вимкнено"}',
          style: const TextStyle(
            color: AppColors.textMain,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Режим: $pvMode',
          style: const TextStyle(
            color: AppColors.textMain,
          ),
        ),

        Text(
          'Тип навантаження: $selectedPvLoadType',
          style: const TextStyle(
            color: AppColors.textMain,
          ),
        ),

        Text(
          'Потужність навантаження: '
          '${pvLoadPowerController.text.isEmpty ? "-" : pvLoadPowerController.text} Вт',
          style: const TextStyle(
            color: AppColors.textMain,
          ),
        ),

        Text(
          'Поріг запуску: '
          '${smartTriggerController.text.isEmpty ? "-" : smartTriggerController.text} Вт',
          style: const TextStyle(
            color: AppColors.textMain,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Smart Meter: ${pvUseMeter ? "Так" : "Ні"}',
          style: const TextStyle(
            color: AppColors.textMuted,
          ),
        ),

        Text(
          'Експорт у мережу: ${pvAllowExport ? "Так" : "Ні"}',
          style: const TextStyle(
            color: AppColors.textMuted,
          ),
        ),

        Text(
          'Пріоритет: ${pvPriority.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: AppColors.textMuted,
          ),
        ),
      ],
    ),
  ),
]
/// ================== UI ДЛЯ SMART EV CHARGER (EV CHARGER UI) ==================
else if (isEvCharger) ...[
  // Выбор режима зарядки и фазности
  Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<String>(
          value: selectedEvChargingMode,
          dropdownColor: brandCard,
          isExpanded: true,
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
          decoration: dropdownDecoration('Режим роботи зарядного пристрою'),
          items: [
            'Балансування навантаження',
            'Швидка зарядка (Fast Charge)',
            'Еко-режим (Eco Mode)',
          ].map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: (val) => setModalState(() => selectedEvChargingMode = val!),
        ),
      ),
    ],
  ),
  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<String>(
          value: selectedEvPhaseType,
          dropdownColor: brandCard,
          isExpanded: true,
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
          decoration: dropdownDecoration('Мережева фазність підключення'),
          items: [
            '1 фаза 230В',
            '3 фази 400В',
          ].map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: (val) => setModalState(() => selectedEvPhaseType = val!),
        ),
      ),
    ],
  ),
  const SizedBox(height: 16),

  // Ввод основных мощностных характеристик
  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Потужність чарджера',
          evChargerPowerController,
          'кВт',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: _buildStaticInputField(
          'Максимальний струм',
          evChargerCurrentController,
          'А',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
    ],
  ),
  const SizedBox(height: 16),

  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Коефіцієнт ККД станції',
          evChargerEfficiencyController,
          '%',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
    ],
  ),
  const SizedBox(height: 20),

  // Блок умных сценариев и приоритетов
  const Text(
    'РОЗУМНІ СЦЕНАРІЇ ТА АВТОМАТИЗАЦІЯ',
    style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
  ),
  const SizedBox(height: 10),

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Динамічне балансування (Dynamic Load Balancing)',
          useDynamicLoadBalancing,
          (val) => setModalState(() => useDynamicLoadBalancing = val),
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Заряджати тільки від надлишку сонця (Solar Only)',
          solarOnlyMode,
          (val) => setModalState(() => solarOnlyMode = val),
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Дозволити зарядку тільки при повній АКБ будинку',
          chargeOnlyWhenBatteryFull,
          (val) => setModalState(() => chargeOnlyWhenBatteryFull = val),
        ),
      ),
    ],
  ),
  const SizedBox(height: 16),

  // Условия порогов триггеров
  Row(
    children: [
      Expanded(
        child: _buildStaticInputField(
          'Мінімум надлишку СЕС',
          evMinSolarSurplusController,
          'Вт',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: _buildStaticInputField(
          'Поріг SOC домашньої АКБ',
          evBatterySocThresholdController,
          '%',
          TextInputType.number,
          true,
          (val) => setModalState(() {}),
        ),
      ),
    ],
  ),
  const SizedBox(height: 24),

  // Информационная панель расчетов (Live Analytics)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.neon.withValues(alpha: 0.15)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.ev_station_rounded, color: AppColors.neon, size: 26),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'ПРОГНОЗ СТАТУСУ ТА ПАРАМЕТРІВ',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: brandInnerBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neon.withValues(alpha: 0.3)),
              ),
              child: Text(
                selectedEvChargingMode,
                style: const TextStyle(color: AppColors.neon, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Сетка с выводом динамических метрик на базе введенных контроллеров
        Builder(
          builder: (context) {
            final chargerPower = double.tryParse(evChargerPowerController.text) ?? 7.4;
            final efficiency = double.tryParse(evChargerEfficiencyController.text) ?? 95.0;
            
            // Тестовый пример расчета времени полной зарядки условного авто (например, 60 кВт·г емкости)
            final double sampleCapacity = 60.0; 
            final double timeToFull = chargerPower > 0 
                ? (sampleCapacity / (chargerPower * (efficiency / 100))) 
                : 0.0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Час зарядки (60 кВт·г)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${timeToFull.toStringAsFixed(1)} год',
                      style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Балансування', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      useDynamicLoadBalancing ? 'Активне (DLB)' : 'Вимкнено',
                      style: TextStyle(
                        color: useDynamicLoadBalancing ? AppColors.neon : AppColors.textMuted, 
                        fontSize: 15, 
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        ),
      ],
    ),
  ),
]
//.............................. Active Battery Balancer
else if (isBatteryBalancer) ...[

  

  const SizedBox(height: 12),

  DropdownButtonFormField<String>(
    value: balancerType,
    dropdownColor: brandCard,
    isExpanded: true,
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
    decoration: dropdownDecoration(
      'Тип балансира',
    ),
    items: [
      'Активний',
      'Пасивний',
      'BMS Integrated',
    ].map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e),
      );
    }).toList(),
    onChanged: (v) =>
        setModalState(() => balancerType = v!),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Струм балансування',
    balancerCurrentController,
    'А',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Автоматичний режим',
          balancerAutoMode,
          (v) => setModalState(
            () => balancerAutoMode = v,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.12),
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Text(
          'ПАСПОРТ БАЛАНСИРА АКБ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Статус: ${balancerEnabled ? "Увімкнено" : "Вимкнено"}',
        ),

        Text(
          'Тип: $balancerType',
        ),

        Text(
          'Струм балансування: '
          '${balancerCurrentController.text} А',
        ),

        Text(
          'Режим: ${balancerAutoMode ? "Автоматичний" : "Ручний"}',
        ),
      ],
    ),
  ),
]
// Cooling / Ventilation
else if (isVentilation) ...[

  

  const SizedBox(height: 12),

  DropdownButtonFormField<String>(
    value: coolingType,
    dropdownColor: brandCard,
    isExpanded: true,
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
    decoration: dropdownDecoration(
      'Тип охолодження',
    ),
    items: [
      'Вентилятори',
      'Витяжна вентиляція',
      'Кондиціонування',
      'Комбінована система',
    ].map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e),
      );
    }).toList(),
    onChanged: (v) =>
        setModalState(() => coolingType = v!),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Температура запуску',
    coolingStartTempController,
    '°C',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Температура зупинки',
    coolingStopTempController,
    '°C',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Автоматичний режим',
          coolingAutoMode,
          (v) => setModalState(
            () => coolingAutoMode = v,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.12),
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Text(
          'ПАСПОРТ СИСТЕМИ ОХОЛОДЖЕННЯ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Статус: ${coolingEnabled ? "Увімкнено" : "Вимкнено"}',
        ),

        Text(
          'Тип: $coolingType',
        ),

        Text(
          'Запуск: ${coolingStartTempController.text} °C',
        ),

        Text(
          'Зупинка: ${coolingStopTempController.text} °C',
        ),

        Text(
          'Режим: ${coolingAutoMode ? "Автоматичний" : "Ручний"}',
        ),
      ],
    ),
  ),
]

// Battery Heater / Thermal Box
else if (isBatteryHeater) ...[

  

  const SizedBox(height: 12),

  DropdownButtonFormField<String>(
    value: batteryHeaterType,
    dropdownColor: brandCard,
    isExpanded: true,
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
    decoration: dropdownDecoration(
      'Тип системи',
    ),
    items: [
      'Термокожух',
      'Нагрівальний кабель',
      'Нагрівальні мати',
      'Комбінована система',
    ].map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e),
      );
    }).toList(),
    onChanged: (v) =>
        setModalState(
          () => batteryHeaterType = v!,
        ),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Температура запуску',
    heaterStartTempController,
    '°C',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Температура вимкнення',
    heaterStopTempController,
    '°C',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Потужність підігріву',
    heaterPowerController,
    'Вт',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Автоматичний режим',
          batteryHeaterAutoMode,
          (v) => setModalState(
            () => batteryHeaterAutoMode = v,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.12),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'ПАСПОРТ СИСТЕМИ ПІДІГРІВУ АКБ',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Статус: ${batteryHeaterEnabled ? "Увімкнено" : "Вимкнено"}',
        ),

        Text(
          'Тип: $batteryHeaterType',
        ),

        Text(
          'Запуск підігріву: ${heaterStartTempController.text} °C',
        ),

        Text(
          'Вимкнення підігріву: ${heaterStopTempController.text} °C',
        ),

        Text(
          'Потужність: ${heaterPowerController.text} Вт',
        ),

        Text(
          'Режим: ${batteryHeaterAutoMode ? "Автоматичний" : "Ручний"}',
        ),
      ],
    ),
  ),
]
// SOH Analyzer
else if (isBatterySohAnalyzer) ...[



  const SizedBox(height: 12),

  DropdownButtonFormField<String>(
    value: sohMethod,
    dropdownColor: brandCard,
    isExpanded: true,
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
    decoration: dropdownDecoration(
      'Джерело даних',
    ),
    items: [
      'BMS Data',
      'Manual',
      'Smart Battery',
    ].map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e),
      );
    }).toList(),
    onChanged: (v) =>
        setModalState(() => sohMethod = v!),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Попередження при SOH нижче',
    sohWarningController,
    '%',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  _buildStaticInputField(
    'Кількість циклів АКБ',
    batteryCyclesController,
    'циклів',
    TextInputType.number,
    true,
    (v) => setModalState(() {}),
  ),

  const SizedBox(height: 12),

  Row(
    children: [
      Expanded(
        child: _buildStaticSwitchTile(
          'Сповіщення',
          sohNotifications,
          (v) => setModalState(
            () => sohNotifications = v,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 16),

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neon.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.neon.withValues(alpha: 0.12),
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Text(
          'ПАСПОРТ SOH АНАЛІЗАТОРА',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Статус: ${sohEnabled ? "Увімкнено" : "Вимкнено"}',
        ),

        Text(
          'Джерело: $sohMethod',
        ),

        Text(
          'Поріг попередження: '
          '${sohWarningController.text}%',
        ),

        Text(
          'Циклів АКБ: '
          '${batteryCyclesController.text}',
        ),

        Text(
          'Сповіщення: '
          '${sohNotifications ? "Увімкнені" : "Вимкнені"}',
        ),
      ],
    ),
  ),
],
                     

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neon,
                            foregroundColor: brandBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            String customSubtitle = 'Активно • Налаштовано';
                            if (isSolar) {
                              customSubtitle = 'Генерація: ${calculateFinalGeneration().toStringAsFixed(1)} кВт';
                            } else if (isInverter) {
                              customSubtitle = '${selectedPreset.split(' ')[0]} • ${invPowerController.text} кВт (ККД ${invKkdController.text}%)';
                            } else if (isGenerator) {
                              customSubtitle = '$selectedFuelType • ${genPowerController.text} кВт • Бак ${genTankController.text}л';
                            } else if (isBattery) {
                              final double cap = double.tryParse(batCapacityController.text) ?? 0;
                              final double volt = double.tryParse(batVoltageController.text) ?? 0;
                              final double totalKwh = nameLower.contains('станція') ? cap : (cap * volt) / 1000;
                              customSubtitle = '$selectedBatType • ${totalKwh.toStringAsFixed(1)} кВт·г';
                            } else if (isWind) {
  customSubtitle =
      'Вітрогенератор • Потужність: ${whPowerController.text} кВт';
}
else if (isHydro) {
  customSubtitle =
      'Мікро ГЕС • Потужність: ${whPowerController.text} кВт';

                            } else if (isEvRelated) {
                              customSubtitle = 'EV Link • Інверсія: ${evPowerController.text} кВт';
                            }else if (isEvCharger) {

  final power =
      evChargerPowerController.text.isEmpty
          ? '-'
          : evChargerPowerController.text;

  customSubtitle =
      '$selectedEvPhaseType • $power кВт';

  if (solarOnlyMode) {
    customSubtitle =
        'PV Only • $power кВт';
  }

  if (useDynamicLoadBalancing) {
    customSubtitle =
        'DLB • $power кВт';
  }
}
                             else if (isGrid) {
                              customSubtitle = '$selectedTariffZones • Ліміт ${gridLimitController.text} кВт';
                            }
                            else if (isSmartMeter) {
  customSubtitle =
      '$selectedMeterDirection • Modbus ${modbusAddressController.text}';
}
else if (isStabilizer) {
  customSubtitle =
      'Стабілізатор • ${stabilizerPowerController.text} кВА • '
      '${stabilizerMinVoltageController.text}-${stabilizerMaxVoltageController.text} В';
}
else if (isVoltageRelay) {
  customSubtitle =
      'Реле • '
      '${relayMinVoltageController.text}-'
      '${relayMaxVoltageController.text} В';
}
else if (isSurgeProtection) {
  customSubtitle =
      'ПЗІП • $selectedSpdType • '
      '${groundResistanceController.text} Ом';
}
else if (isRcd) {
  customSubtitle =
      'ПЗВ • '
      '${selectedRcdSensitivity} мА • '
      '${rcdCurrentController.text} А';
}
                             
                            else if (isSmartAutomation) {
                              customSubtitle = 'Smart ($selectedProtocol) • Порог: ${smartTriggerController.text}';
                            } else {
                              customSubtitle = 'Оптимізація • Поріг: ${maintParamController.text}';
                            }

                            final Map<String, dynamic> resultData = {
  ...item,

  // ================= БАЗОВА ІНФОРМАЦІЯ =================
  'title': item['name'],
  'subtitle': customSubtitle,
  'icon': item['icon'],
  'qty': qtyController.text,
  'power': powerController.text,
  'selectedPreset': selectedPreset,

  // ================= СОНЯЧНІ ПАНЕЛІ =================
  'orientation': selectedOrientation,
  'tilt': selectedTilt,
  'mountType': selectedMountType,
  'shading': selectedShading,
  'lifespan': selectedLifespan,
  'isBifacial': isBifacial,
  'albedoBonus': selectedAlbedoBonus,
'solarGeneration': calculateFinalGeneration(),
'solarGenerationW': calculateFinalGeneration() * 1000,
  // ================= ІНВЕРТОР =================
  'invPower': invPowerController.text,
  'invKkd': invKkdController.text,
  'invOwn': invOwnController.text,
  'invCharge': invChargeController.text,
  'invDischarge': invDischargeController.text,
  'inverterType': selectedInverterType,
  'isParallel': isParallel,
  'isGridExport': isGridExport,
  'isZeroExport': isZeroExport,

  // ================= АКУМУЛЯТОРИ / ESS =================
  'batCapacity': batCapacityController.text,
  'batVoltage': batVoltageController.text,
  'batCount': batCountController.text,
  'batType': selectedBatType,

  'batChargeCurrent': batChargeCurrentController.text,
  'batDischargeCurrent': batDischargeCurrentController.text,

  'dod': selectedDod,
  'minSoc': selectedMinSoc,
  'reserveSoc': selectedReserveSoc,

  'hasBatteryHeating': hasBatteryHeating,
  'hasBatteryCooling': hasBatteryCooling,

  'bmsType': selectedBms,
  'batteryProtocol': selectedBatteryProtocol,

  // ================= MPPT =================
  'mpptMaxVoltage': mpptMaxVoltageController.text,
  'mpptMaxCurrent': mpptMaxCurrentController.text,
  'mpptStrings': mpptStringsController.text,

  'mpptVoc': mpptVocController.text,
  'mpptVmp': mpptVmpController.text,
  'mpptIsc': mpptIscController.text,
  'mpptImp': mpptImpController.text,

  'mpptSeriesPanels': mpptSeriesPanelsController.text,
  'mpptParallelStrings': mpptParallelStringsController.text,

  'mpptBatteryType': selectedMpptBatteryType,
  'mpptEfficiency': mpptEfficiencyController.text,

  // ================= ВІТРОГЕНЕРАТОР =================
  'windType': selectedWindType,
  'windSpeed': windSpeedController.text,
  'mastHeight': mastHeightController.text,
  'rotorDiameter': rotorDiameterController.text,

  'whPower': whPowerController.text,
  'whEfficiency': whEfficiencyController.text,

  'windCf': windCfController.text,
  'windStartSpeed': windStartSpeedController.text,
  'windCutoffSpeed': windCutoffSpeedController.text,

  'windZone': selectedWindZone,
  'hasWindMppt': hasWindMppt,

  // ================= МІКРО ГЕС =================
  'hydroFlow': hydroFlowController.text,
  'hydroHead': hydroHeadController.text,
  'hydroEfficiency': hydroEfficiencyController.text,
  'hydroTurbine': selectedHydroTurbine,
'hydroCf': hydroCfController.text,

'hydroGeneratorType':
    selectedHydroGeneratorType,

'hydroOutput':
    selectedHydroOutput,

'hydro24x7':
    hydro24x7,
    'hydroSource': selectedHydroSource,
  // ================= ПАЛИВНИЙ ГЕНЕРАТОР =================
  'genPower': genPowerController.text,
  'genTank': genTankController.text,
  'genConsumption': genConsumptionController.text,

  'fuelType': selectedFuelType,
  'generatorPhase': selectedGeneratorPhase,

  'hasAvr': hasAvr,
  'isEcoMode': isEcoMode,
  'isAtsReady': isAtsReady,

  'genNoise': genNoiseController.text,
  'genResource': genResourceController.text,

  'genFuelPrice': genFuelPriceController.text,
  'genDailyHours': genDailyHoursController.text,
  'genReserveFuel': genReserveFuelController.text,

  // ================= PORTABLE ESS =================
  'portableBrand': selectedPortableBrand,
  'portableBatteryType': selectedPortableBatteryType,

  'portableCapacity': portableCapacityController.text,
  'portableInverter': portableInverterController.text,
  'portablePv': portablePvController.text,
  'portableAcCharge': portableAcChargeController.text,
  'portableUps': portableUpsController.text,

  'portableCycles': portableCyclesController.text,
  'waveType': selectedWaveType,
  'pvConnector': selectedPvConnector,
  'isBoilerUps': isBoilerUps,

  // ================= EV CHARGER =================
  'evPower': evPowerController.text,
  'evCapacity': evCapacityController.text,
  'evMaxCurrent': evMaxCurrentController.text,

  'connectorType': selectedConnectorType,
  'chargingMode': selectedChargingMode,
  'chargePriority': selectedChargePriority,

  'reservedVehicleSoc': reservedVehicleSoc,

  // ================= ATS =================
'atsTransferTime': atsTransferTimeController.text,
'atsMinGridVoltage': atsMinGridVoltageController.text,
'atsMaxGridVoltage': atsMaxGridVoltageController.text,
'atsReturnDelay': atsReturnDelayController.text,

'atsPriority': selectedAtsPriority,
'backupSource': selectedBackupSource,
'atsMode': selectedAtsMode,
'phaseMonitoring': selectedPhaseMonitoring,

'atsRemoteControl': atsRemoteControl,
'atsAutoTest': atsAutoTest,
'atsSwitchDelay':
    atsSwitchDelayController.text,

'atsAutoReturn':
    atsAutoReturn,

'atsMinFrequency':
    atsMinFrequencyController.text,

'atsMaxFrequency':
    atsMaxFrequencyController.text,

// ================= DRY CONTACT =================
'generatorMode': selectedGeneratorMode,

'generatorStartSoc':
    generatorStartSocController.text,

'generatorStopSoc':
    generatorStopSocController.text,

'generatorStartDelay': generatorStartDelayController.text,
'generatorStopDelay': generatorStopDelayController.text,

  // ================= SMART LOAD =================
  'criticalLoad': criticalLoadController.text,
  'importantLoad': importantLoadController.text,
  'secondaryLoad': secondaryLoadController.text,

  'secondaryOffSoc': secondaryOffSoc,
  'importantOffSoc': importantOffSoc,
  'emergencyOffSoc': emergencyOffSoc,

  // ================= ЛІЧИЛЬНИК =================
  'gridLimit': gridLimitController.text,
  'tariffZones': selectedTariffZones,

  'meterModel': meterModelController.text,
  'accuracyClass': selectedAccuracyClass,
  'meterDirection': selectedMeterDirection,

  'modbusAddress': modbusAddressController.text,
  'ctRatio': ctRatioController.text,

  // ================= МОНІТОРИНГ =================
  'monitoringType': selectedMonitoringType,
  'cloudStatus': selectedCloudStatus,
  'monitoringStatus': selectedMonitoringStatus,

  'monitoredDevices': monitoredDevicesController.text,
  'updateInterval': updateIntervalController.text,

  // ================= HOME ASSISTANT =================
  'haIp': homeAssistantIpController.text,
  'integrationType': selectedIntegrationType,
  'communicationProtocol': selectedCommunicationProtocol,
  'connectedDevices': connectedDevicesController.text,
  'connectionStatus': selectedConnectionStatus,
  // ================= EV CHARGER =================

'evChargerPower':
    evChargerPowerController.text,

'evChargerCurrent':
    evChargerCurrentController.text,

'evChargerEfficiency':
    evChargerEfficiencyController.text,

'evPhaseType':
    selectedEvPhaseType,

'evChargingMode':
    selectedEvChargingMode,

'useDynamicLoadBalancing':
    useDynamicLoadBalancing,

'chargeOnlyWhenBatteryFull':
    chargeOnlyWhenBatteryFull,

'solarOnlyMode':
    solarOnlyMode,

'evBatterySocThreshold':
    evBatterySocThresholdController.text,

'evMinSolarSurplus':
    evMinSolarSurplusController.text,
// ================= СТАБІЛІЗАТОР =================
'stabilizerPower': stabilizerPowerController.text,
'stabilizerType': selectedStabilizerType,
'stabilizerMinVoltage': stabilizerMinVoltageController.text,
'stabilizerMaxVoltage': stabilizerMaxVoltageController.text,
'stabilizerBypass': stabilizerBypass,
// ================= РЕЛЕ НАПРУГИ =================
'relayMinVoltage': relayMinVoltageController.text,
'relayMaxVoltage': relayMaxVoltageController.text,
'relayDelay': relayDelayController.text,
// ================= ПЗІП =================
'spdType': selectedSpdType,
'groundResistance': groundResistanceController.text,
// ================= ПЗВ =================
'rcdCurrent': rcdCurrentController.text,
'rcdSensitivity': selectedRcdSensitivity,
'rcdType': selectedRcdType,
  // ================= ОБСЛУГОВУВАННЯ =================
  'maintParam': maintParamController.text,
  /// PV Diverter
'pvEnabled': pvEnabled,
'pvMode': pvMode,

'pvTrigger':
    double.tryParse(
      smartTriggerController.text,
    ) ?? 0,

'pvAllowExport': pvAllowExport,

'pvUseMeter': pvUseMeter,

'pvPriority': pvPriority,

'pvLoadType': selectedPvLoadType,

'pvLoadPower':
    double.tryParse(
      pvLoadPowerController.text,
    ) ?? 0,
// Active Battery Balancer
'balancerEnabled': balancerEnabled,

'balancerType': balancerType,

'balancerCurrent':
    double.tryParse(
      balancerCurrentController.text,
    ) ?? 0,

'balancerAutoMode': balancerAutoMode,
// Cooling / Ventilation
'coolingEnabled': coolingEnabled,

'coolingType': coolingType,

'coolingStartTemp':
    double.tryParse(
      coolingStartTempController.text,
    ) ?? 35,

'coolingStopTemp':
    double.tryParse(
      coolingStopTempController.text,
    ) ?? 30,

'coolingAutoMode': coolingAutoMode,
// Battery Heater / Thermal Box
'batteryHeaterEnabled': batteryHeaterEnabled,

'batteryHeaterType': batteryHeaterType,

'heaterStartTemp':
    double.tryParse(
      heaterStartTempController.text,
    ) ?? 5,

'heaterStopTemp':
    double.tryParse(
      heaterStopTempController.text,
    ) ?? 10,

'heaterPower':
    double.tryParse(
      heaterPowerController.text,
    ) ?? 300,

'batteryHeaterAutoMode':
    batteryHeaterAutoMode,
    // SOH Analyzer
    'sohEnabled': sohEnabled,

'sohMethod': sohMethod,

'sohWarning':
    double.tryParse(
      sohWarningController.text,
    ) ?? 80,

'batteryCycles':
    int.tryParse(
      batteryCyclesController.text,
    ) ?? 0,

'sohNotifications':
    sohNotifications,
};



                            if (isEditing) {
                              Navigator.pop(context, resultData);
                            } else {
                              Navigator.pop(context);
                              Navigator.pop(context, {
                                ...resultData,
                                'useAccentColor': true,
                              }); 
                            }
                          },
                          child: Text(isEditing ? 'Зберегти зміни' : 'Підключити пристрій', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildStaticInputField(
    String label, 
    TextEditingController controller, 
    String? suffix, 
    TextInputType type, 
    bool isEnabled, 
    Function(String)? onChanged,
  ) {
    return TextField(
      controller: controller,
      keyboardType: type,
      onChanged: onChanged,
      enabled: isEnabled,
      style: TextStyle(
        color: isEnabled ? AppColors.textMain : AppColors.textMuted, 
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: isEnabled ? AppColors.neon : AppColors.textMuted, 
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: brandInnerBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.neon, width: 1)),
      ),
    );
  }

  static Widget _buildStaticSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: brandInnerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.neon,
            onChanged: onChanged,
          ),
        ],
      ),
    );
    
  }

  @override
  Widget build(BuildContext context) {
    final devices = _getAvailableDevices();
    final currentCategory = categoryTitles[categoryIndex];
    return Scaffold(
      backgroundColor: brandBg,
      appBar: AppBar(
        backgroundColor: brandBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentCategory,
          style: const TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Builder( // Оборачиваем в Builder, чтобы получить контекст для MediaQuery
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        return Container(
          constraints: const BoxConstraints(maxWidth: 800),
          margin: EdgeInsets.all(isMobile ? 16 : 32),
          padding: EdgeInsets.all(isMobile ? 16 : 32),
            decoration: BoxDecoration(
              color: brandCard,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.neon.withValues(alpha: 0.08)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 15))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Доступне обладнання для інтеграції', style: TextStyle(color: AppColors.textMain, fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  propertyType == 0
                      ? 'Відображаються лише пристрої, які безпечно та технічно можливо встановити в умовах квартири.'
                      : 'Відображається повний спектр промислового та побутового обладнання для приватного будинку.',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 32),
                Flexible(
                  child: devices.isEmpty
                      ? const Center(child: Text('Немає доступних пристроїв', style: TextStyle(color: AppColors.textMuted)))
                      : ListView.separated(
                          itemCount: devices.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = devices[index];
                            final String deviceName = item['name'] as String? ?? '';
                            
                            final bool isAlreadyConnected = connectedDeviceNames.contains(deviceName);

                            return InkWell(
                              onTap: isAlreadyConnected
                                  ? () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Пристрій "$deviceName" вже підключено до вашої системи ESS!'),
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                      );
                                    }
                                  : () => openDeviceSetupBottomSheet(context, item),
                              borderRadius: BorderRadius.circular(18),
                              child: Opacity(
                                opacity: isAlreadyConnected ? 0.45 : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: brandInnerBg,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isAlreadyConnected 
                                          ? Colors.orangeAccent.withValues(alpha: 0.3) 
                                          : AppColors.textMuted.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          color: const Color(0xFF020D2D),
                                          border: Border.all(
                                            color: isAlreadyConnected 
                                                ? Colors.orangeAccent.withValues(alpha: 0.4) 
                                                : AppColors.neon.withValues(alpha: 0.25), 
                                            width: 1,
                                          ),
                                        ),
                                        child: NeonEquipmentIcon(
                                          icon:  item['icon'] as IconData,  
                                          neonColor: isAlreadyConnected ? Colors.orangeAccent : AppColors.neon,
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              deviceName, 
                                              style: TextStyle(
                                                color: isAlreadyConnected ? AppColors.textMuted : AppColors.textMain, 
                                                fontWeight: FontWeight.w700, 
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
  item['desc'] as String,
  maxLines: 2, // Ограничиваем двумя строками
  overflow: TextOverflow.ellipsis, // Добавляем троеточие в конце
  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
),
                                          ],
                                        ),
                                      ),
                                      isAlreadyConnected
                                          ? const Text(
                                              'Вже додано',
                                              style: TextStyle(
                                                color: Colors.orangeAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            )
                                          : const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neon, size: 16),
                                    ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ); 
            }, 
          ), 
        ),
      ),
    );
  }
}

class NeonEquipmentIcon extends StatelessWidget {
  final IconData icon;
  final Color neonColor;

  const NeonEquipmentIcon({super.key, required this.icon, required this.neonColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            inherit: false,
            color: neonColor.withValues(alpha: 0.6),
            fontSize: 24,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            shadows: [
              Shadow(blurRadius: 10.0, color: neonColor),
              Shadow(blurRadius: 18.0, color: neonColor.withValues(alpha: 0.4)),
            ],
          ),
        ),
        Icon(icon, color: neonColor, size: 24),
      ],
    );
  }
}