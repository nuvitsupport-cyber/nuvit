import 'package:flutter/material.dart';
import '../device_in.dart';

class CleaningDevices {
  const CleaningDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Пилососи
    // =========================

    DeviceInfo(
      name: 'Пилосос',
      category: 'Прибирання',
      icon: Icons.cleaning_services_outlined,
      typicalPower: 1000,
      maxPower: 1800,
      peakPower: 2200,
      hasMotor: true,
      startupMultiplier: 1.8,
      defaultHoursPerDay: 0.5,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Вертикальний пилосос',
      category: 'Прибирання',
      icon: Icons.cleaning_services,
      typicalPower: 400,
      maxPower: 800,
      peakPower: 1000,
      hasMotor: true,
      startupMultiplier: 1.5,
      defaultHoursPerDay: 0.5,
    ),

    DeviceInfo(
      name: 'Миючий пилосос',
      category: 'Прибирання',
      icon: Icons.water_drop_outlined,
      typicalPower: 1400,
      maxPower: 2000,
      peakPower: 2500,
      hasMotor: true,
      startupMultiplier: 1.8,
      defaultHoursPerDay: 0.5,
    ),

    DeviceInfo(
      name: 'Робот-пилосос',
      category: 'Прибирання',
      icon: Icons.smart_toy_outlined,
      typicalPower: 40,
      maxPower: 80,
      peakPower: 100,
      standbyPower: 2,
      defaultHoursPerDay: 2,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      shiftable: true,
      allowAutoStart: true,
      aiImportance: 85,
    ),

    DeviceInfo(
      name: 'Робот-мийник підлоги',
      category: 'Прибирання',
      icon: Icons.auto_fix_high_outlined,
      typicalPower: 50,
      maxPower: 100,
      peakPower: 100,
      standbyPower: 2,
      defaultHoursPerDay: 2,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      shiftable: true,
    ),

    // =========================
    // Пароочищення
    // =========================

    DeviceInfo(
      name: 'Пароочисник',
      category: 'Прибирання',
      icon: Icons.cloud_outlined,
      typicalPower: 1500,
      maxPower: 2000,
      peakPower: 2000,
      defaultHoursPerDay: 0.3,
      generatesHeat: true,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Паровий швабра',
      category: 'Прибирання',
      icon: Icons.water,
      typicalPower: 1200,
      maxPower: 1500,
      peakPower: 1500,
      defaultHoursPerDay: 0.3,
      generatesHeat: true,
    ),

    // =========================
    // Миття вікон
    // =========================

    DeviceInfo(
      name: 'Робот-мийник вікон',
      category: 'Прибирання',
      icon: Icons.window_outlined,
      typicalPower: 80,
      maxPower: 120,
      peakPower: 150,
      defaultHoursPerDay: 1,
      smartDevice: true,
      wifiSupported: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Високий тиск
    // =========================

    DeviceInfo(
      name: 'Мийка високого тиску',
      category: 'Прибирання',
      icon: Icons.local_car_wash_outlined,
      typicalPower: 1800,
      maxPower: 2500,
      peakPower: 3000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,

      supportedProperties: [
        PropertyType.house,
      ],
    ),

    // =========================
    // Осушення
    // =========================

    DeviceInfo(
      name: 'Електросушарка для взуття',
      category: 'Прибирання',
      icon: Icons.hiking_outlined,
      typicalPower: 20,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'Сушильна шафа',
      category: 'Прибирання',
      icon: Icons.checkroom_outlined,
      typicalPower: 1000,
      maxPower: 1500,
      peakPower: 1500,
      defaultHoursPerDay: 2,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Smart пристрої
    // =========================

    DeviceInfo(
      name: 'UV стерилізатор',
      category: 'Прибирання',
      icon: Icons.auto_awesome_outlined,
      typicalPower: 15,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Озонатор',
      category: 'Прибирання',
      icon: Icons.blur_on_outlined,
      typicalPower: 80,
      maxPower: 120,
      peakPower: 120,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
    ),
  ];
}