import 'package:flutter/material.dart';
import '../device_in.dart';

class HealthDevices {
  const HealthDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Моніторинг здоров'я
    // =========================

    DeviceInfo(
      name: 'Тонометр',
      category: "Здоров'я та спорт",
      icon: Icons.favorite_outline,
      typicalPower: 5,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 0.1,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Пульсоксиметр',
      category: "Здоров'я та спорт",
      icon: Icons.monitor_heart_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 0.1,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Глюкометр',
      category: "Здоров'я та спорт",
      icon: Icons.bloodtype_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 0.1,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Електронні ваги',
      category: "Здоров'я та спорт",
      icon: Icons.monitor_weight_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 0.05,
    ),

    // =========================
    // Медичне обладнання
    // =========================

    DeviceInfo(
      name: 'Небулайзер',
      category: "Здоров'я та спорт",
      icon: Icons.air_outlined,
      typicalPower: 70,
      maxPower: 120,
      peakPower: 120,
      defaultHoursPerDay: 0.5,
      priority: DevicePriority.high,
      supportsBackup: true,
      aiImportance: 90,
    ),

    DeviceInfo(
      name: 'CPAP апарат',
      category: "Здоров'я та спорт",
      icon: Icons.air,
      typicalPower: 40,
      maxPower: 90,
      peakPower: 90,
      defaultHoursPerDay: 8,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 100,
    ),

    DeviceInfo(
      name: 'Кисневий концентратор',
      category: "Здоров'я та спорт",
      icon: Icons.health_and_safety_outlined,
      typicalPower: 350,
      maxPower: 700,
      peakPower: 700,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 100,
    ),

    // =========================
    // Фітнес
    // =========================

    DeviceInfo(
      name: 'Бігова доріжка',
      category: "Здоров'я та спорт",
      icon: Icons.directions_run_outlined,
      typicalPower: 1200,
      maxPower: 2500,
      peakPower: 3500,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
      shiftable: true,
    ),

    DeviceInfo(
      name: 'Велотренажер',
      category: "Здоров'я та спорт",
      icon: Icons.pedal_bike_outlined,
      typicalPower: 50,
      maxPower: 200,
      peakPower: 200,
      defaultHoursPerDay: 1,
    ),

    DeviceInfo(
      name: 'Еліптичний тренажер',
      category: "Здоров'я та спорт",
      icon: Icons.fitness_center_outlined,
      typicalPower: 50,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 1,
    ),

    DeviceInfo(
      name: 'Гребний тренажер',
      category: "Здоров'я та спорт",
      icon: Icons.rowing_outlined,
      typicalPower: 50,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 1,
    ),

    // =========================
    // Масаж
    // =========================

    DeviceInfo(
      name: 'Масажне крісло',
      category: "Здоров'я та спорт",
      icon: Icons.chair_outlined,
      typicalPower: 120,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Масажер для ніг',
      category: "Здоров'я та спорт",
      icon: Icons.accessibility_new_outlined,
      typicalPower: 40,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 0.5,
    ),

    // =========================
    // Recovery
    // =========================

    DeviceInfo(
      name: 'Інфрачервона сауна',
      category: "Здоров'я та спорт",
      icon: Icons.whatshot_outlined,
      typicalPower: 2000,
      maxPower: 3500,
      peakPower: 3500,
      defaultHoursPerDay: 1,
      generatesHeat: true,
      priority: DevicePriority.low,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Електрична грілка',
      category: "Здоров'я та спорт",
      icon: Icons.local_fire_department_outlined,
      typicalPower: 60,
      maxPower: 120,
      peakPower: 120,
      defaultHoursPerDay: 2,
      generatesHeat: true,
    ),

    // =========================
    // Wearables
    // =========================

    DeviceInfo(
      name: 'Зарядка смарт-годинника',
      category: "Здоров'я та спорт",
      icon: Icons.watch_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      standbyPower: 0.5,
      defaultHoursPerDay: 2,
    ),
  ];
}