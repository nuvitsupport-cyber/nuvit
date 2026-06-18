import 'package:flutter/material.dart';
import '../device_in.dart';

class LaundryDevices {
  const LaundryDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Прання
    // =========================

    DeviceInfo(
      name: 'Пральна машина',
      category: 'Прання та догляд',
      icon: Icons.local_laundry_service_outlined,
      typicalPower: 800,
      maxPower: 2200,
      peakPower: 2200,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 1,
      cyclicOperation: true,
      cycleDuration: 120,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 85,
    ),

    DeviceInfo(
      name: 'Сушильна машина',
      category: 'Прання та догляд',
      icon: Icons.dry_outlined,
      typicalPower: 2000,
      maxPower: 2500,
      peakPower: 2500,
      defaultHoursPerDay: 1,
      cyclicOperation: true,
      cycleDuration: 90,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 80,
    ),

    DeviceInfo(
      name: 'Прально-сушильна машина',
      category: 'Прання та догляд',
      icon: Icons.local_laundry_service,
      typicalPower: 1800,
      maxPower: 2500,
      peakPower: 2500,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 1,
      cyclicOperation: true,
      cycleDuration: 180,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 85,
    ),

    // =========================
    // Прасування
    // =========================

    DeviceInfo(
      name: 'Праска',
      category: 'Прання та догляд',
      icon: Icons.iron_outlined,
      typicalPower: 1800,
      maxPower: 2400,
      peakPower: 2400,
      defaultHoursPerDay: 0.5,
      priority: DevicePriority.low,
      shiftable: true,
      supportsScheduling: true,
    ),

    DeviceInfo(
      name: 'Парогенератор',
      category: 'Прання та догляд',
      icon: Icons.water_drop_outlined,
      typicalPower: 2200,
      maxPower: 3000,
      peakPower: 3000,
      defaultHoursPerDay: 0.5,
      priority: DevicePriority.low,
      shiftable: true,
      supportsScheduling: true,
    ),

    DeviceInfo(
      name: 'Відпарювач',
      category: 'Прання та догляд',
      icon: Icons.cloud_outlined,
      typicalPower: 1500,
      maxPower: 1800,
      peakPower: 1800,
      defaultHoursPerDay: 0.3,
      priority: DevicePriority.low,
    ),

    // =========================
    // Догляд за одягом
    // =========================

    DeviceInfo(
      name: 'Електросушарка для взуття',
      category: 'Прання та догляд',
      icon: Icons.hiking_outlined,
      typicalPower: 20,
      maxPower: 30,
      peakPower: 30,
      defaultHoursPerDay: 4,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Електросушарка для білизни',
      category: 'Прання та догляд',
      icon: Icons.dry_cleaning_outlined,
      typicalPower: 250,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
    ),

    DeviceInfo(
      name: 'Швейна машина',
      category: 'Прання та догляд',
      icon: Icons.content_cut_outlined,
      typicalPower: 80,
      maxPower: 120,
      peakPower: 150,
      hasMotor: true,
      startupMultiplier: 1.3,
      defaultHoursPerDay: 1,
    ),

    DeviceInfo(
      name: 'Машинка для видалення катишків',
      category: 'Прання та догляд',
      icon: Icons.cleaning_services_outlined,
      typicalPower: 5,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 0.2,
      priority: DevicePriority.low,
    ),
  ];
}