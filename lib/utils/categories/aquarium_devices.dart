import 'package:flutter/material.dart';
import '../device_in.dart';

class AquariumDevices {
  const AquariumDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Фільтрація
    // =========================

    DeviceInfo(
      name: 'Внутрішній фільтр',
      category: 'Акваріум',
      icon: Icons.water_outlined,
      typicalPower: 10,
      maxPower: 30,
      peakPower: 30,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Зовнішній фільтр',
      category: 'Акваріум',
      icon: Icons.filter_alt_outlined,
      typicalPower: 20,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Самп',
      category: 'Акваріум',
      icon: Icons.sync_outlined,
      typicalPower: 40,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Аерація
    // =========================

    DeviceInfo(
      name: 'Компресор акваріума',
      category: 'Акваріум',
      icon: Icons.bubble_chart_outlined,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Повітряний насос',
      category: 'Акваріум',
      icon: Icons.air_outlined,
      typicalPower: 10,
      maxPower: 20,
      peakPower: 20,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    // =========================
    // Нагрів
    // =========================

    DeviceInfo(
      name: 'Нагрівач акваріума',
      category: 'Акваріум',
      icon: Icons.whatshot_outlined,
      typicalPower: 50,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 12,
      generatesHeat: true,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Контролер температури',
      category: 'Акваріум',
      icon: Icons.thermostat_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
      smartDevice: true,
    ),

    // =========================
    // Освітлення
    // =========================

    DeviceInfo(
      name: 'LED освітлення акваріума',
      category: 'Акваріум',
      icon: Icons.lightbulb_outline,
      typicalPower: 20,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 10,
      shiftable: true,
      supportsScheduling: true,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'RGB освітлення акваріума',
      category: 'Акваріум',
      icon: Icons.color_lens_outlined,
      typicalPower: 30,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 10,
      shiftable: true,
      supportsScheduling: true,
      smartDevice: true,
    ),

    // =========================
    // CO₂
    // =========================

    DeviceInfo(
      name: 'Система CO₂',
      category: 'Акваріум',
      icon: Icons.science_outlined,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 8,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'Електромагнітний клапан CO₂',
      category: 'Акваріум',
      icon: Icons.settings_input_component_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 8,
      smartDevice: true,
      supportsScheduling: true,
    ),

    // =========================
    // Морський акваріум
    // =========================

    DeviceInfo(
      name: 'Скімер',
      category: 'Акваріум',
      icon: Icons.waves_outlined,
      typicalPower: 20,
      maxPower: 60,
      peakPower: 60,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Помпа течії',
      category: 'Акваріум',
      icon: Icons.rotate_right_outlined,
      typicalPower: 10,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    // =========================
    // Автоматизація
    // =========================

    DeviceInfo(
      name: 'Автогодівниця',
      category: 'Акваріум',
      icon: Icons.schedule_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      smartDevice: true,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Контролер акваріума',
      category: 'Акваріум',
      icon: Icons.memory_outlined,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      smartDevice: true,
      supportsBackup: true,
      homeAssistantSupported: true,
      aiImportance: 90,
    ),
  ];
}