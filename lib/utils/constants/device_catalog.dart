import 'package:flutter/material.dart';
import '../models/device_info.dart';

class DeviceCatalog {
  const DeviceCatalog._();

  // =========================
  // Источники питания
  // =========================

  static List<DeviceInfo> powerSources({
    required int propertyType,
  }) {
    final devices = [
      DeviceInfo(
        name: 'Гібридний/Автономний інвертор',
        description:
            'Центральний енергетичний вузол системи для керування живленням, зарядом АКБ та розподілом енергії між джерелами',
        icon: Icons.electrical_services_outlined,
      ),

      DeviceInfo(
        name: propertyType == 0
            ? 'Балконні сонячні панелі'
            : 'Сонячні панелі (PV масив)',
        description: propertyType == 0
            ? 'Генерація електроенергії за допомогою компактних сонячних модулів для квартири або балкону'
            : 'Основне джерело відновлюваної енергії для живлення будинку та заряджання акумуляторів',
        icon: Icons.solar_power_outlined,
      ),

      const DeviceInfo(
        name: 'Паливний генератор (Бензин/Дизель/Газ)',
        description:
            'Резервне джерело живлення для підтримки роботи системи під час аварійних або тривалих відключень',
        icon: Icons.ev_station_outlined,
        allowedInApartment: false,
      ),

      const DeviceInfo(
        name: 'Вітрогенератор (Мікро-ВЕС)',
        description:
            'Додаткове джерело генерації електроенергії від енергії вітру для автономних та гібридних систем',
        icon: Icons.air_outlined,
        allowedInApartment: false,
      ),

      const DeviceInfo(
        name: 'Портативна зарядна станція',
        description:
            'Мобільний накопичувач енергії для резервного живлення побутових приладів та критичних навантажень',
        icon: Icons.battery_charging_full_outlined,
      ),

      DeviceInfo(
        name: propertyType == 0
            ? 'Електромобіль як резерв (V2L)'
            : 'Електромобіль до будинку (V2H)',
        description: propertyType == 0
            ? 'Використання акумулятора електромобіля як резервного джерела живлення через функцію Vehicle-to-Load'
            : 'Інтеграція акумулятора електромобіля в енергосистему будинку через двонаправлену зарядну інфраструктуру',
        icon: Icons.electric_car_outlined,
      ),

      const DeviceInfo(
        name: 'Акумуляторна батарея (АКБ / BMS)',
        description:
            'Накопичення надлишкової енергії та забезпечення автономної роботи системи під час відсутності мережі',
        icon: Icons.developer_board_outlined,
      ),

      const DeviceInfo(
        name: 'Центральна електромережа',
        description:
            'Основне джерело електропостачання з контролем параметрів мережі та тарифного обліку',
        icon: Icons.cable_outlined,
      ),

      const DeviceInfo(
        name: 'Мікро-гідроелектростанція (Мікро-ГЕС)',
        description:
            'Безперервне відновлюване джерело генерації електроенергії на основі енергії водного потоку',
        icon: Icons.water_drop_outlined,
        allowedInApartment: false,
      ),
    ];

    if (propertyType == 0) {
      return devices
          .where((device) => device.allowedInApartment)
          .toList();
    }

    return devices;
  }

  // =========================
  // Защита сети
  // =========================

  static List<DeviceInfo> protectionDevices({
    required bool hasSolarPanels,
  }) {
    return [
      const DeviceInfo(
        name: 'Стабілізатор напруги',
        description:
            'Підтримання стабільної напруги для захисту побутової техніки та електроніки від перепадів мережі',
        icon: Icons.tune_outlined,
      ),

      if (hasSolarPanels)
        const DeviceInfo(
          name: 'Контролер заряду сонця (MPPT)',
          description:
              'Оптимізація генерації сонячних панелей та ефективне заряджання акумуляторних батарей',
          icon: Icons.solar_power_outlined,
        ),

      const DeviceInfo(
        name: 'Система ПЗІП + Заземлення',
        description:
            'Захист обладнання від блискавки, імпульсних перенапруг та аварій електромережі',
        icon: Icons.electric_bolt_outlined,
      ),

      const DeviceInfo(
        name: 'Реле напруги (Zubr / Barrier)',
        description:
            'Автоматичне відключення живлення при небезпечних просадках або перенапрузі мережі',
        icon: Icons.gpp_maybe_outlined,
      ),

      const DeviceInfo(
        name: 'Диференційний автомат / ПЗВ',
        description:
            'Захист людей та електромережі від струмів витоку і пошкодження ізоляції',
        icon: Icons.shield_outlined,
      ),
    ];
  }

  // =========================
  // Автоматизация
  // =========================

  static List<DeviceInfo> automationDevices({
    required bool hasSolarPanels,
  }) {
    return [
      const DeviceInfo(
        name: 'АВР (Автоматичне введення резерву)',
        description:
            'Автоматичне перемикання між мережею, інвертором та генератором',
        icon: Icons.sync_outlined,
      ),

      const DeviceInfo(
        name: 'Розумний лічильник (Smart Meter / Chint)',
        description:
            'Контроль генерації, споживання, імпорту та експорту електроенергії',
        icon: Icons.electric_meter_outlined,
      ),

      const DeviceInfo(
        name: 'Розумний будинок (Home Assistant/Tuya)',
        description:
            'Автоматизація та централізоване керування енергосистемою',
        icon: Icons.home_outlined,
      ),

      const DeviceInfo(
        name: 'Модуль моніторингу (Wi-Fi/4G Dongle)',
        description:
            'Віддалений моніторинг інвертора та передача телеметрії',
        icon: Icons.router_outlined,
      ),

      const DeviceInfo(
        name: 'Розумне реле скидання навантаження (Load Shedding)',
        description:
            'Автоматичне відключення некритичних навантажень для економії АКБ',
        icon: Icons.toggle_on_outlined,
      ),

      if (hasSolarPanels)
        const DeviceInfo(
          name: 'Контролер надлишків сонця (PV Diverter)',
          description:
              'Перенаправлення надлишкової сонячної енергії на корисне навантаження',
          icon: Icons.heat_pump_outlined,
        ),

      const DeviceInfo(
        name: 'Сухий контакт генератора (Dry Contact)',
        description:
            'Автоматичний запуск та зупинка генератора за умовами системи',
        icon: Icons.settings_input_component_outlined,
      ),

      const DeviceInfo(
        name: 'Смарт-контролер зарядки ЕМ (EV Charger)',
        description:
            'Розумна зарядка електромобіля з динамічним балансуванням потужності',
        icon: Icons.charging_station_outlined,
      ),
    ];
  }

  // =========================
  // Оптимизация и сервис
  // =========================

  static List<DeviceInfo> maintenanceDevices() {
    return const [
     
      DeviceInfo(
        name: 'Активний балансир АКБ',
        description:
            'Вирівнювання заряду між комірками батареї',
        icon: Icons.scale_outlined,
      ),

      DeviceInfo(
        name: 'Система охолодження та вентиляції',
        description:
            'Автоматичне керування вентиляторами',
        icon: Icons.air_outlined,
      ),

      DeviceInfo(
        name: 'Термокожух з підігрівом АКБ',
        description:
            'Підтримка безпечної температури батарей',
        icon: Icons.wb_sunny_outlined,
      ),

      

      DeviceInfo(
        name: 'Аналізатор деградації батарей (SOH)',
        description:
            'Моніторинг залишкової ємності та циклів',
        icon: Icons.analytics_outlined,
      ),

      
    ];
  }
}