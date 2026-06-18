import 'package:flutter/material.dart';
import '../device_in.dart';

class LightingDevices {
  const LightingDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Основне освітлення
    // =========================

    DeviceInfo(
      name: 'LED лампа',
      category: 'Освітлення',
      icon: Icons.lightbulb_outline,
      typicalPower: 10,
      maxPower: 10,
      peakPower: 10,
      defaultQuantity: 8,
      defaultHoursPerDay: 5,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 90,
    ),

    DeviceInfo(
      name: 'Люстра',
      category: 'Освітлення',
      icon: Icons.light_outlined,
      typicalPower: 60,
      maxPower: 60,
      peakPower: 60,
      defaultQuantity: 1,
      defaultHoursPerDay: 4,
      priority: DevicePriority.normal,
    ),

    DeviceInfo(
      name: 'Настільна лампа',
      category: 'Освітлення',
      icon: Icons.light_mode_outlined,
      typicalPower: 12,
      maxPower: 12,
      peakPower: 12,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'Торшер',
      category: 'Освітлення',
      icon: Icons.light,
      typicalPower: 20,
      maxPower: 20,
      peakPower: 20,
      defaultHoursPerDay: 4,
    ),

    DeviceInfo(
      name: 'Нічник',
      category: 'Освітлення',
      icon: Icons.nightlight_round,
      typicalPower: 2,
      maxPower: 2,
      peakPower: 2,
      defaultHoursPerDay: 8,
      priority: DevicePriority.low,
    ),

    // =========================
    // LED
    // =========================

    DeviceInfo(
      name: 'LED стрічка',
      category: 'Освітлення',
      icon: Icons.linear_scale,
      typicalPower: 24,
      maxPower: 24,
      peakPower: 24,
      defaultHoursPerDay: 5,
    ),

    DeviceInfo(
      name: 'RGB LED стрічка',
      category: 'Освітлення',
      icon: Icons.gradient,
      typicalPower: 30,
      maxPower: 30,
      peakPower: 30,
      defaultHoursPerDay: 4,
    ),

    DeviceInfo(
      name: 'Підсвічування кухні',
      category: 'Освітлення',
      icon: Icons.countertops_outlined,
      typicalPower: 15,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'Підсвічування сходів',
      category: 'Освітлення',
      icon: Icons.stairs_outlined,
      typicalPower: 20,
      maxPower: 20,
      peakPower: 20,
      defaultHoursPerDay: 2,
    ),

    // =========================
    // Декоративне
    // =========================

    DeviceInfo(
      name: 'Гірлянда',
      category: 'Освітлення',
      icon: Icons.celebration_outlined,
      typicalPower: 10,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 6,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Декоративне RGB освітлення',
      category: 'Освітлення',
      icon: Icons.palette_outlined,
      typicalPower: 40,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 4,
      priority: DevicePriority.low,
    ),

    // =========================
    // Зовнішнє освітлення
    // =========================

    DeviceInfo(
      name: 'Вуличне освітлення',
      category: 'Освітлення',
      icon: Icons.wb_sunny_outlined,
      typicalPower: 50,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 8,
      supportsScheduling: true,
    ),

    DeviceInfo(
      name: 'Прожектор',
      category: 'Освітлення',
      icon: Icons.highlight_outlined,
      typicalPower: 100,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'Освітлення двору',
      category: 'Освітлення',
      icon: Icons.yard_outlined,
      typicalPower: 80,
      maxPower: 80,
      peakPower: 80,
      defaultHoursPerDay: 8,
      supportsScheduling: true,
    ),

    // =========================
    // Резервне освітлення
    // =========================

    DeviceInfo(
      name: 'Аварійне освітлення',
      category: 'Освітлення',
      icon: Icons.emergency_outlined,
      typicalPower: 15,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 2,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 95,
    ),

    // =========================
    // Smart Lighting
    // =========================

    DeviceInfo(
      name: 'Розумна лампа',
      category: 'Освітлення',
      icon: Icons.lightbulb,
      typicalPower: 12,
      maxPower: 12,
      peakPower: 12,
      defaultHoursPerDay: 5,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
    ),

    DeviceInfo(
      name: 'Розумний світильник',
      category: 'Освітлення',
      icon: Icons.tungsten_outlined,
      typicalPower: 25,
      maxPower: 25,
      peakPower: 25,
      defaultHoursPerDay: 5,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
    ),
  ];
}