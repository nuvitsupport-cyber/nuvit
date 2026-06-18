
import 'package:flutter/material.dart';
import '../device_in.dart';

class KitchenDevices {
  const KitchenDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Охолодження
    // =========================

    DeviceInfo(
      name: 'Холодильник',
      category: 'Кухня',
      icon: Icons.kitchen_outlined,
      typicalPower: 150,
      maxPower: 300,
      peakPower: 600,
      standbyPower: 5,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 95,
    ),

    DeviceInfo(
      name: 'Морозильна камера',
      category: 'Кухня',
      icon: Icons.kitchen,
      typicalPower: 180,
      maxPower: 350,
      peakPower: 700,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 90,
    ),

    // =========================
    // Приготування напоїв
    // =========================

    DeviceInfo(
      name: 'Електрочайник',
      category: 'Кухня',
      icon: Icons.coffee_outlined,
      typicalPower: 2000,
      maxPower: 2000,
      peakPower: 2000,
      defaultHoursPerDay: 0.2,
      priority: DevicePriority.low,
      shiftable: true,
      supportsScheduling: true,
    ),

    DeviceInfo(
      name: 'Кавоварка',
      category: 'Кухня',
      icon: Icons.local_cafe_outlined,
      typicalPower: 1000,
      maxPower: 1200,
      peakPower: 1200,
      defaultHoursPerDay: 0.3,
    ),

    DeviceInfo(
      name: 'Кавомашина',
      category: 'Кухня',
      icon: Icons.coffee,
      typicalPower: 1500,
      maxPower: 1600,
      peakPower: 1600,
      defaultHoursPerDay: 0.5,
    ),

    // =========================
    // Основне приготування їжі
    // =========================

    DeviceInfo(
      name: 'Мікрохвильова піч',
      category: 'Кухня',
      icon: Icons.microwave_outlined,
      typicalPower: 1200,
      maxPower: 1400,
      peakPower: 1400,
      defaultHoursPerDay: 0.3,
    ),

    DeviceInfo(
      name: 'Мультиварка',
      category: 'Кухня',
      icon: Icons.rice_bowl_outlined,
      typicalPower: 800,
      maxPower: 1000,
      peakPower: 1000,
      defaultHoursPerDay: 1,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    DeviceInfo(
      name: 'Пароварка',
      category: 'Кухня',
      icon: Icons.soup_kitchen_outlined,
      typicalPower: 900,
      maxPower: 1000,
      peakPower: 1000,
      defaultHoursPerDay: 1,
      supportsPVExcess: true,
    ),

    DeviceInfo(
      name: 'Рисоварка',
      category: 'Кухня',
      icon: Icons.rice_bowl,
      typicalPower: 700,
      maxPower: 800,
      peakPower: 800,
      defaultHoursPerDay: 1,
      supportsPVExcess: true,
    ),

    // =========================
    // Техніка
    // =========================

    DeviceInfo(
      name: 'Блендер',
      category: 'Кухня',
      icon: Icons.blender_outlined,
      typicalPower: 700,
      maxPower: 1000,
      peakPower: 1200,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 0.1,
    ),

    DeviceInfo(
      name: 'Міксер',
      category: 'Кухня',
      icon: Icons.cyclone_outlined,
      typicalPower: 300,
      maxPower: 500,
      peakPower: 600,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 0.1,
    ),

    DeviceInfo(
      name: "М'ясорубка",
      category: 'Кухня',
      icon: Icons.settings_outlined,
      typicalPower: 1500,
      maxPower: 1800,
      peakPower: 2200,
      hasMotor: true,
      startupMultiplier: 1.7,
      defaultHoursPerDay: 0.1,
    ),

    DeviceInfo(
      name: 'Кухонний комбайн',
      category: 'Кухня',
      icon: Icons.blender,
      typicalPower: 1000,
      maxPower: 1200,
      peakPower: 1500,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 0.2,
    ),

    // =========================
    // Великі навантаження
    // =========================

    DeviceInfo(
      name: 'Посудомийна машина',
      category: 'Кухня',
      icon: Icons.water_drop_outlined,
      typicalPower: 1800,
      maxPower: 2200,
      peakPower: 2200,
      defaultHoursPerDay: 2,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 85,
    ),

    DeviceInfo(
      name: 'Духова шафа',
      category: 'Кухня',
      icon: Icons.local_fire_department_outlined,
      typicalPower: 2500,
      maxPower: 3000,
      peakPower: 3000,
      defaultHoursPerDay: 1,
      shiftable: true,
      supportsScheduling: true,
    ),

    DeviceInfo(
      name: 'Індукційна плита',
      category: 'Кухня',
      icon: Icons.electric_bolt_outlined,
      typicalPower: 3500,
      maxPower: 7000,
      peakPower: 7000,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Електроплита',
      category: 'Кухня',
      icon: Icons.soup_kitchen,
      typicalPower: 3000,
      maxPower: 6000,
      peakPower: 6000,
      defaultHoursPerDay: 1,
    ),

    // =========================
    // Додаткові пристрої
    // =========================

    DeviceInfo(
      name: 'Тостер',
      category: 'Кухня',
      icon: Icons.breakfast_dining_outlined,
      typicalPower: 900,
      maxPower: 1200,
      peakPower: 1200,
      defaultHoursPerDay: 0.1,
    ),

    DeviceInfo(
      name: 'Аерогриль',
      category: 'Кухня',
      icon: Icons.air,
      typicalPower: 1500,
      maxPower: 1800,
      peakPower: 1800,
      defaultHoursPerDay: 0.5,
      supportsPVExcess: true,
    ),

    DeviceInfo(
      name: 'Витяжка',
      category: 'Кухня',
      icon: Icons.air_outlined,
      typicalPower: 120,
      maxPower: 200,
      peakPower: 250,
      defaultHoursPerDay: 1,
    ),
  ];
}
