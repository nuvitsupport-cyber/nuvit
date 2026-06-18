import 'categories/lighting_devices.dart';
import 'categories/kitchen_devices.dart';
import 'categories/laundry_devices.dart';
import 'categories/climate_devices.dart';
import 'categories/hot_water_devices.dart';
import 'categories/entertainment_devices.dart';
import 'categories/computers_devices.dart';
import 'categories/bathroom_devices.dart';
import 'categories/cleaning_devices.dart';
import 'categories/chargers_devices.dart';
import 'categories/electric_transport_devices.dart';
import 'categories/pumps_devices.dart';
import 'categories/security_devices.dart';
import 'categories/smart_home_devices.dart';
import 'categories/health_devices.dart';
import 'categories/aquarium_devices.dart';
import 'categories/workshop_devices.dart';
import 'categories/garden_devices.dart';
import 'categories/office_devices.dart';
import 'categories/server_devices.dart';

import 'device_in.dart';

class GlobalDevicesCatalog {
  const GlobalDevicesCatalog._();

  static List<DeviceInfo> get allDevices => [
        // Освітлення
        ...LightingDevices.items,

        // Кухня
        ...KitchenDevices.items,

        // Прання та догляд
        ...LaundryDevices.items,

        // Клімат
        ...ClimateDevices.items,

        // Гаряча вода
        ...HotWaterDevices.items,

        // Розваги
        ...EntertainmentDevices.items,

        // Комп'ютери
        ...ComputersDevices.items,

        // Ванна кімната
        ...BathroomDevices.items,

        // Прибирання
        ...CleaningDevices.items,

        // Зарядні пристрої
        ...ChargersDevices.items,

        // Електротранспорт
        ...ElectricTransportDevices.items,

        // Насоси
        ...PumpsDevices.items,

        // Безпека
        ...SecurityDevices.items,

        // Smart Home
        ...SmartHomeDevices.items,

        // Здоров'я та спорт
        ...HealthDevices.items,

        // Акваріум
        ...AquariumDevices.items,

        // Гараж та майстерня
        ...WorkshopDevices.items,

        // Сад та двір
        ...GardenDevices.items,

        // Офіс
        ...OfficeDevices.items,

        // Серверне обладнання
        ...ServerDevices.items,
      ];

  static List<DeviceInfo> byCategory(String category) {
    return allDevices
        .where((d) => d.category == category)
        .toList();
  }

  static List<DeviceInfo> forProperty(int propertyType) {
    return allDevices.where((device) {
      if (device.supportedProperties.isEmpty) {
        return true;
      }

      // Сравниваем индекс enum с переданным int
      return device.supportedProperties.any((p) => p.index == propertyType);
    }).toList();
  }
static List<DeviceInfo> byCategoryAndProperty(
  String category,
  int propertyType,
) {
  return allDevices.where((device) {

    if (device.category != category) {
      return false;
    }

    if (device.supportedProperties.isEmpty) {
      return true;
    }

    // Сравниваем индекс enum с переданным int
    return device.supportedProperties.any((p) => p.index == propertyType);

  }).toList();
}
  static List<DeviceInfo> criticalLoads() {
    return allDevices
        .where(
          (d) =>
              d.critical ||
              d.priority == DevicePriority.critical,
        )
        .toList();
  }

  static List<DeviceInfo> backupLoads() {
    return allDevices
        .where((d) => d.supportsBackup)
        .toList();
  }

  static List<DeviceInfo> pvExcessLoads() {
    return allDevices
        .where((d) => d.supportsPVExcess)
        .toList();
  }

  static List<DeviceInfo> smartDevices() {
    return allDevices
        .where((d) => d.smartDevice)
        .toList();
  }

  static List<DeviceInfo> homeAssistantDevices() {
    return allDevices
        .where((d) => d.homeAssistantSupported)
        .toList();
  }

  static List<DeviceInfo> shiftableLoads() {
    return allDevices
        .where((d) => d.shiftable)
        .toList();
  }

  static List<DeviceInfo> motors() {
    return allDevices
        .where((d) => d.hasMotor)
        .toList();
  }

  static List<DeviceInfo> heatingLoads() {
    return allDevices
        .where((d) => d.generatesHeat)
        .toList();
  }
}