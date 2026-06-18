import 'package:flutter/material.dart';

import 'device_categories.dart';
import 'device_categories_info.dart';

class DeviceCategoriesInfo {
  const DeviceCategoriesInfo._();

  static const List<DeviceCategoryInfo> all = [

    DeviceCategoryInfo(
      id: DeviceCategories.lighting,
      name: 'Освітлення',
      icon: Icons.lightbulb_outline,
      color: Colors.amber,
      order: 1,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.kitchen,
      name: 'Кухня',
      icon: Icons.kitchen_outlined,
      color: Colors.orange,
      order: 2,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.laundry,
      name: 'Прання та догляд',
      icon: Icons.local_laundry_service_outlined,
      color: Colors.blue,
      order: 3,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.climate,
      name: 'Клімат',
      icon: Icons.ac_unit_outlined,
      color: Colors.cyan,
      order: 4,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.hotWater,
      name: 'Гаряча вода',
      icon: Icons.water_drop_outlined,
      color: Colors.redAccent,
      order: 5,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.entertainment,
      name: 'Розваги',
      icon: Icons.tv_outlined,
      color: Colors.purple,
      order: 6,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.computers,
      name: "Комп'ютери",
      icon: Icons.computer_outlined,
      color: Colors.indigo,
      order: 7,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.bathroom,
      name: 'Ванна кімната',
      icon: Icons.bathtub_outlined,
      color: Colors.teal,
      order: 8,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.cleaning,
      name: 'Прибирання',
      icon: Icons.cleaning_services_outlined,
      color: Colors.green,
      order: 9,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.chargers,
      name: 'Зарядні пристрої',
      icon: Icons.battery_charging_full_outlined,
      color: Colors.lightGreen,
      order: 10,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.electricTransport,
      name: 'Електротранспорт',
      icon: Icons.electric_car_outlined,
      color: Colors.blueAccent,
      order: 11,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.pumps,
      name: 'Насоси',
      icon: Icons.water_outlined,
      color: Colors.blue,
      order: 12,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.security,
      name: 'Безпека',
      icon: Icons.security_outlined,
      color: Colors.red,
      order: 13,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.smartHome,
      name: 'Smart Home',
      icon: Icons.home_outlined,
      color: Colors.deepPurple,
      order: 14,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.health,
      name: "Здоров'я та спорт",
      icon: Icons.favorite_outline,
      color: Colors.pink,
      order: 15,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.aquarium,
      name: 'Акваріум',
      icon: Icons.water,
      color: Colors.lightBlue,
      order: 16,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.workshop,
      name: 'Гараж та майстерня',
      icon: Icons.handyman_outlined,
      color: Colors.brown,
      order: 17,
      supportsApartment: false,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.garden,
      name: 'Сад та двір',
      icon: Icons.yard_outlined,
      color: Colors.green,
      order: 18,
      supportsApartment: false,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.office,
      name: 'Офіс',
      icon: Icons.work_outline,
      color: Colors.blueGrey,
      order: 19,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.server,
      name: 'Серверне обладнання',
      icon: Icons.dns_outlined,
      color: Colors.deepOrange,
      order: 20,
    ),

    DeviceCategoryInfo(
      id: DeviceCategories.other,
      name: 'Інше',
      icon: Icons.devices_other_outlined,
      color: Colors.grey,
      order: 21,
    ),
  ];
}