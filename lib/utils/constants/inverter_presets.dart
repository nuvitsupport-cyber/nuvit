class InverterPresets {
  const InverterPresets._();

  static const List<Map<String, dynamic>> presets = [
    {
      'name': 'Deye (Серія SUN-SG)',
      'power': '5.0',
      'kkd': '97.6',
      'ownConsumption': '50',
      'chargeCurrent': '120',
      'dischargeCurrent': '120',
    },
    {
      'name': 'Victron Energy (MultiPlus-II)',
      'power': '3.0',
      'kkd': '95.0',
      'ownConsumption': '18',
      'chargeCurrent': '70',
      'dischargeCurrent': '70',
    },
    {
      'name': 'Huawei (Серія SUN2000)',
      'power': '5.0',
      'kkd': '98.4',
      'ownConsumption': '30',
      'chargeCurrent': '100',
      'dischargeCurrent': '100',
    },
    {
      'name': 'Growatt (Серія SPH)',
      'power': '5.0',
      'kkd': '97.5',
      'ownConsumption': '40',
      'chargeCurrent': '95',
      'dischargeCurrent': '95',
    },
    {
      'name': 'Axioma Energy (Серія ISMPPT)',
      'power': '5.6',
      'kkd': '93.0',
      'ownConsumption': '60',
      'chargeCurrent': '100',
      'dischargeCurrent': '100',
    },
    {
      'name': 'Must (Серія PH1800)',
      'power': '5.2',
      'kkd': '93.0',
      'ownConsumption': '55',
      'chargeCurrent': '80',
      'dischargeCurrent': '80',
    },
    {
      'name': '🛠️ Свої налаштування',
      'power': '',
      'kkd': '',
      'ownConsumption': '',
      'chargeCurrent': '',
      'dischargeCurrent': '',
    },
  ];
}