import 'package:flutter/material.dart';
import '../device_in.dart';

class PumpsDevices {
  const PumpsDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Водопостачання
    // =========================

    DeviceInfo(
      name: 'Насос свердловини',
      category: 'Насоси',
      icon: Icons.water_outlined,
      typicalPower: 1000,
      maxPower: 2200,
      peakPower: 4000,
      hasMotor: true,
      startupMultiplier: 2.5,
      defaultHoursPerDay: 2,
      priority: DevicePriority.high,
      supportsBackup: true,
      aiImportance: 95,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Насос підвищення тиску',
      category: 'Насоси',
      icon: Icons.speed_outlined,
      typicalPower: 300,
      maxPower: 800,
      peakPower: 1500,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 3,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Насосна станція',
      category: 'Насоси',
      icon: Icons.settings_input_component_outlined,
      typicalPower: 1200,
      maxPower: 2500,
      peakPower: 4500,
      hasMotor: true,
      startupMultiplier: 3,
      defaultHoursPerDay: 2,
      priority: DevicePriority.high,
      supportsBackup: true,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    // =========================
    // Опалення
    // =========================

    DeviceInfo(
      name: 'Циркуляційний насос',
      category: 'Насоси',
      icon: Icons.sync_outlined,
      typicalPower: 60,
      maxPower: 120,
      peakPower: 180,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
      aiImportance: 90,
    ),

    DeviceInfo(
      name: 'Насос теплої підлоги',
      category: 'Насоси',
      icon: Icons.grid_4x4_outlined,
      typicalPower: 50,
      maxPower: 100,
      peakPower: 150,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Насос рециркуляції ГВП',
      category: 'Насоси',
      icon: Icons.repeat_outlined,
      typicalPower: 50,
      maxPower: 100,
      peakPower: 150,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    // =========================
    // Дренаж
    // =========================

    DeviceInfo(
      name: 'Дренажний насос',
      category: 'Насоси',
      icon: Icons.water_damage_outlined,
      typicalPower: 800,
      maxPower: 1500,
      peakPower: 3000,
      hasMotor: true,
      startupMultiplier: 2.5,
      defaultHoursPerDay: 1,
      priority: DevicePriority.high,
      supportsBackup: true,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Каналізаційна станція',
      category: 'Насоси',
      icon: Icons.plumbing_outlined,
      typicalPower: 1000,
      maxPower: 2000,
      peakPower: 4000,
      hasMotor: true,
      startupMultiplier: 3,
      defaultHoursPerDay: 1,
      priority: DevicePriority.high,
      supportsBackup: true,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    // =========================
    // Полив
    // =========================

    DeviceInfo(
      name: 'Насос поливу',
      category: 'Насоси',
      icon: Icons.grass_outlined,
      typicalPower: 800,
      maxPower: 1500,
      peakPower: 3000,
      hasMotor: true,
      startupMultiplier: 2.5,
      defaultHoursPerDay: 2,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Автоматичний полив',
      category: 'Насоси',
      icon: Icons.spa_outlined,
      typicalPower: 500,
      maxPower: 1200,
      peakPower: 2500,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 1,
      shiftable: true,
      supportsScheduling: true,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    // =========================
    // Басейн
    // =========================

    DeviceInfo(
      name: 'Басейновий насос',
      category: 'Насоси',
      icon: Icons.pool_outlined,
      typicalPower: 1000,
      maxPower: 2000,
      peakPower: 3500,
      hasMotor: true,
      startupMultiplier: 2.5,
      defaultHoursPerDay: 8,
      shiftable: true,
      supportsPVExcess: true,
      supportsScheduling: true,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Насос фонтану',
      category: 'Насоси',
      icon: Icons.waterfall_chart_outlined,
      typicalPower: 100,
      maxPower: 300,
      peakPower: 500,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 8,
      priority: DevicePriority.low,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    // =========================
    // Акваріум
    // =========================

    DeviceInfo(
      name: 'Акваріумний компресор',
      category: 'Насоси',
      icon: Icons.bubble_chart_outlined,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      priority: DevicePriority.normal,
      supportsBackup: true,
    ),
  ];
}