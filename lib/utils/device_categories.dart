class DeviceCategories {
  const DeviceCategories._();

  // =========================
  // Основні категорії
  // =========================

  static const String lighting = 'Освітлення';
  static const String kitchen = 'Кухня';
  static const String laundry = 'Прання та догляд';
  static const String climate = 'Клімат';
  static const String hotWater = 'Гаряча вода';
  static const String entertainment = 'Розваги';
  static const String computers = "Комп'ютери";
  static const String bathroom = 'Ванна кімната';
  static const String cleaning = 'Прибирання';
  static const String chargers = 'Зарядні пристрої';
  static const String electricTransport = 'Електротранспорт';
  static const String pumps = 'Насоси';
  static const String security = 'Безпека';
  static const String smartHome = 'Smart Home';
  static const String health = "Здоров'я та спорт";
  static const String aquarium = 'Акваріум';
  static const String workshop = 'Гараж та майстерня';
  static const String garden = 'Сад та двір';
  static const String office = 'Офіс';
  static const String server = 'Серверне обладнання';
  static const String other = 'Інше';

  // =========================
  // Список усіх категорій
  // =========================

  static const List<String> all = [
    lighting,
    kitchen,
    laundry,
    climate,
    hotWater,
    entertainment,
    computers,
    bathroom,
    cleaning,
    chargers,
    electricTransport,
    pumps,
    security,
    smartHome,
    health,
    aquarium,
    workshop,
    garden,
    office,
    server,
    other,
  ];

  // =========================
  // Категорії для квартири
  // =========================

  static const List<String> apartmentCategories = [
    lighting,
    kitchen,
    laundry,
    climate,
    hotWater,
    entertainment,
    computers,
    bathroom,
    cleaning,
    chargers,
    security,
    smartHome,
    health,
    aquarium,
    office,
    server,
    other,
  ];

  // =========================
  // Категорії для будинку
  // =========================

  static const List<String> houseCategories = [
    ...all,
  ];

  // =========================
  // Smart Home
  // =========================

  static const List<String> smartCategories = [
    smartHome,
    security,
    server,
  ];

  // =========================
  // Критичні навантаження
  // =========================

  static const List<String> criticalCategories = [
    security,
    pumps,
    health,
    server,
    smartHome,
  ];

  // =========================
  // PV Excess
  // =========================

  static const List<String> pvCategories = [
    chargers,
    electricTransport,
    workshop,
    garden,
    cleaning,
  ];

  // =========================
  // Резервне живлення
  // =========================

  static const List<String> backupCategories = [
    security,
    smartHome,
    health,
    pumps,
    office,
    server,
    aquarium,
  ];
}