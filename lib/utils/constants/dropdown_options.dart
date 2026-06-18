
class DropdownOptions {
  const DropdownOptions._();

  // ================= АКБ =================

  static const batteryTypes = [
    'LiFePO4 (LFP)',
    'Li-Ion (NMC)',
    'LTO (Титанат)',
    'Lead-Acid (Гель/AGM)',
  ];
static const windTypes = [
  'Горизонтальна вісь (HAWT)',
  'Вертикальна вісь (VAWT)',
  'Мікротурбіна',
];
  static const mpptBatteryTypes = [
    'LiFePO4',
    'NMC',
    'AGM',
    'GEL',
    'Lead Acid',
  ];

  static const bmsTypes = [
    'JK BMS',
    'JBD',
    'Daly',
    'Seplos',
    'Pace',
  ];

  static const batteryProtocols = [
    'CAN',
    'RS485',
    'Bluetooth',
    'WiFi',
  ];

  // ================= EV =================

  static const connectorTypes = [
    'Type 1',
    'Type 2',
    'CCS2',
    'CHAdeMO',
    'GB/T',
    'Tesla NACS',
  ];

  static const chargingModes = [
    'Одностороння (G2V)',
    'Двонаправлена (V2H)',
    'Двонаправлена (V2G)',
    'V2L',
  ];

  static const chargingPriorities = [
    'Нічний тариф',
    'Надлишок сонця',
    'Баланс ESS',
    'Максимальна швидкість',
  ];

  // ================= ATS =================

  static const atsPriorities = [
    'Мережа → АКБ → Генератор',
    'Мережа → Генератор → АКБ',
    'АКБ → Мережа → Генератор',
  ];

  // ================= МЕРЕЖА =================

  static const phaseTypes = [
    '1 Фаза (230В)',
    '3 Фази (400В)',
  ];

  static const gridQualities = [
    'Стабільна мережа',
    'Часті просадки',
    'Часті аварії',
  ];

  static const tariffZones = [
    '1-зонний',
    '2-зонний (День / Ніч)',
    '3-зонний',
  ];

  // ================= ЛІЧИЛЬНИК =================

  static const meterDirections = [
    'Однонаправлений',
    'Двонаправлений',
  ];

  static const accuracyClasses = [
    '0.5',
    '1.0',
    '2.0',
  ];

  // ================= ГЕНЕРАТОР =================

  static const fuelTypes = [
    'Бензин',
    'Дизель',
    'Газ (LPG)',
  ];

  // ================= SMART =================

  static const integrationTypes = [
    'Home Assistant',
    'Tuya',
    'Shelly',
    'Node-RED',
  ];

  static const communicationProtocols = [
    'MQTT',
    'Modbus TCP',
    'Modbus RTU',
    'HTTP API',
  ];
static const List<String> hydroTurbines = [
  'Pelton',
  'Turgo',
  'Crossflow',
  'Francis',
  'Kaplan',
];
  static const connectionStatuses = [
    'Підключено',
    'Не підключено',
    'Помилка звʼязку',
  ];
  static const integrationPlatforms = [
  'Home Assistant',
  'Tuya',
  'Node-RED',
  'OpenHAB',
  'ioBroker',
];
static const integrationProtocols = [
  'MQTT',
  'REST API',
  'Modbus TCP',
  'Zigbee',
  'Wi-Fi Local',
];

}