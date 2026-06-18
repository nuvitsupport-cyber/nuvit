import 'package:flutter/material.dart';
import '../device_in.dart';

class HotWaterDevices {
  const HotWaterDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Бойлери
    // =========================

    DeviceInfo(
      name: 'Бойлер',
      category: 'Гаряча вода',
      icon: Icons.hot_tub_outlined,
      typicalPower: 2000,
      maxPower: 2000,
      peakPower: 2000,
      defaultHoursPerDay: 3,
      generatesHotWater: true,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 95,
    ),

    DeviceInfo(
      name: 'Проточний водонагрівач',
      category: 'Гаряча вода',
      icon: Icons.water_drop_outlined,
      typicalPower: 6000,
      maxPower: 9000,
      peakPower: 9000,
      defaultHoursPerDay: 1,
      generatesHotWater: true,
      priority: DevicePriority.low,
      aiImportance: 75,
    ),

    DeviceInfo(
      name: 'Накопичувальний водонагрівач',
      category: 'Гаряча вода',
      icon: Icons.water_drop,
      typicalPower: 1500,
      maxPower: 2000,
      peakPower: 2000,
      defaultHoursPerDay: 3,
      generatesHotWater: true,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Насоси ГВП
    // =========================

    DeviceInfo(
      name: 'Насос рециркуляції ГВП',
      category: 'Гаряча вода',
      icon: Icons.sync_outlined,
      typicalPower: 50,
      maxPower: 100,
      peakPower: 150,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 24,
      priority: DevicePriority.normal,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Циркуляційний насос бойлера',
      category: 'Гаряча вода',
      icon: Icons.rotate_right_outlined,
      typicalPower: 60,
      maxPower: 120,
      peakPower: 180,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 24,
      priority: DevicePriority.normal,
      supportsBackup: true,
    ),

    // =========================
    // Ванна кімната
    // =========================

    DeviceInfo(
      name: 'Електричний рушникосушник',
      category: 'Гаряча вода',
      icon: Icons.dry_outlined,
      typicalPower: 150,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 6,
      generatesHeat: true,
    ),

    DeviceInfo(
      name: 'Гідромасажна ванна',
      category: 'Гаряча вода',
      icon: Icons.bathtub_outlined,
      typicalPower: 1500,
      maxPower: 2500,
      peakPower: 3000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 0.5,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Джакузі',
      category: 'Гаряча вода',
      icon: Icons.hot_tub,
      typicalPower: 2000,
      maxPower: 3500,
      peakPower: 4000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,

      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // SPA та басейн
    // =========================

    DeviceInfo(
      name: 'Підігрів басейну',
      category: 'Гаряча вода',
      icon: Icons.pool_outlined,
      typicalPower: 3000,
      maxPower: 6000,
      peakPower: 6000,
      defaultHoursPerDay: 6,
      generatesHotWater: true,
      priority: DevicePriority.low,
      supportsPVExcess: true,

      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'SPA система',
      category: 'Гаряча вода',
      icon: Icons.spa_outlined,
      typicalPower: 2500,
      maxPower: 5000,
      peakPower: 5000,
      defaultHoursPerDay: 2,
      priority: DevicePriority.low,

      supportedProperties: const [
        PropertyType.house,
      ],
    ),
  ];
}