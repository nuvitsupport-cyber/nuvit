import 'package:flutter/material.dart';
import '../device_in.dart';

class GardenDevices {
  const GardenDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Косіння трави
    // =========================

    DeviceInfo(
      name: 'Електрична газонокосарка',
      category: 'Сад та двір',
      icon: Icons.grass_outlined,
      typicalPower: 1400,
      maxPower: 2500,
      peakPower: 3500,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Робот-газонокосарка',
      category: 'Сад та двір',
      icon: Icons.smart_toy_outlined,
      typicalPower: 50,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 4,
      smartDevice: true,
      wifiSupported: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 85,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Електричний тример',
      category: 'Сад та двір',
      icon: Icons.content_cut_outlined,
      typicalPower: 700,
      maxPower: 1500,
      peakPower: 2500,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 0.5,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Полив
    // =========================

    DeviceInfo(
      name: 'Контролер поливу',
      category: 'Сад та двір',
      icon: Icons.water_drop_outlined,
      typicalPower: 5,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 24,
      smartDevice: true,
      supportsBackup: true,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Крапельний полив',
      category: 'Сад та двір',
      icon: Icons.opacity_outlined,
      typicalPower: 50,
      maxPower: 200,
      peakPower: 200,
      defaultHoursPerDay: 2,
      supportsScheduling: true,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Освітлення
    // =========================

    DeviceInfo(
      name: 'Садове LED освітлення',
      category: 'Сад та двір',
      icon: Icons.lightbulb_outline,
      typicalPower: 50,
      maxPower: 200,
      peakPower: 200,
      defaultHoursPerDay: 6,
      smartDevice: true,
      supportsScheduling: true,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Прожектор двору',
      category: 'Сад та двір',
      icon: Icons.highlight_outlined,
      typicalPower: 30,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 6,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Вода та басейн
    // =========================

    DeviceInfo(
      name: 'Фільтр басейну',
      category: 'Сад та двір',
      icon: Icons.pool_outlined,
      typicalPower: 800,
      maxPower: 2000,
      peakPower: 3000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 8,
      shiftable: true,
      supportsPVExcess: true,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Підігрів басейну',
      category: 'Сад та двір',
      icon: Icons.whatshot_outlined,
      typicalPower: 2000,
      maxPower: 5000,
      peakPower: 5000,
      generatesHeat: true,
      defaultHoursPerDay: 6,
      shiftable: true,
      supportsPVExcess: true,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Фонтан',
      category: 'Сад та двір',
      icon: Icons.waterfall_chart_outlined,
      typicalPower: 100,
      maxPower: 300,
      peakPower: 500,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 8,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Комфорт
    // =========================

    DeviceInfo(
      name: 'Електричний гриль',
      category: 'Сад та двір',
      icon: Icons.outdoor_grill_outlined,
      typicalPower: 1800,
      maxPower: 3000,
      peakPower: 3000,
      generatesHeat: true,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Інфрачервоний обігрівач тераси',
      category: 'Сад та двір',
      icon: Icons.local_fire_department_outlined,
      typicalPower: 1500,
      maxPower: 3000,
      peakPower: 3000,
      generatesHeat: true,
      defaultHoursPerDay: 3,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Smart
    // =========================

    DeviceInfo(
      name: 'Метеостанція',
      category: 'Сад та двір',
      icon: Icons.cloud_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 24,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
      supportsBackup: true,
      aiImportance: 70,
    ),

    DeviceInfo(
      name: 'Smart годівниця для тварин',
      category: 'Сад та двір',
      icon: Icons.pets_outlined,
      typicalPower: 5,
      maxPower: 20,
      peakPower: 20,
      defaultHoursPerDay: 24,
      smartDevice: true,
      supportsBackup: true,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Електричний відлякувач комах',
      category: 'Сад та двір',
      icon: Icons.bug_report_outlined,
      typicalPower: 10,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 8,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),
  ];
}