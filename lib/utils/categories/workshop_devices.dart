import 'package:flutter/material.dart';
import '../device_in.dart';

class WorkshopDevices {
  const WorkshopDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Компресори
    // =========================

    DeviceInfo(
      name: 'Повітряний компресор',
      category: 'Гараж та майстерня',
      icon: Icons.air_outlined,
      typicalPower: 1500,
      maxPower: 3000,
      peakPower: 5000,
      hasMotor: true,
      startupMultiplier: 3,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Зварювання
    // =========================

    DeviceInfo(
      name: 'Зварювальний інвертор',
      category: 'Гараж та майстерня',
      icon: Icons.construction_outlined,
      typicalPower: 3500,
      maxPower: 7000,
      peakPower: 7000,
      defaultHoursPerDay: 0.5,
      priority: DevicePriority.low,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Плазморіз',
      category: 'Гараж та майстерня',
      icon: Icons.bolt_outlined,
      typicalPower: 4000,
      maxPower: 8000,
      peakPower: 8000,
      defaultHoursPerDay: 0.5,
      priority: DevicePriority.low,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Верстати
    // =========================

    DeviceInfo(
      name: 'Токарний верстат',
      category: 'Гараж та майстерня',
      icon: Icons.precision_manufacturing_outlined,
      typicalPower: 1500,
      maxPower: 4000,
      peakPower: 5000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 2,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Фрезерний верстат',
      category: 'Гараж та майстерня',
      icon: Icons.settings_outlined,
      typicalPower: 1500,
      maxPower: 4000,
      peakPower: 5000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 2,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Свердлильний верстат',
      category: 'Гараж та майстерня',
      icon: Icons.hardware_outlined,
      typicalPower: 800,
      maxPower: 2000,
      peakPower: 3000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 1,
    ),

    // =========================
    // Електроінструмент
    // =========================

    DeviceInfo(
      name: 'Болгарка',
      category: 'Гараж та майстерня',
      icon: Icons.handyman_outlined,
      typicalPower: 1000,
      maxPower: 2200,
      peakPower: 3500,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 0.5,
    ),

    DeviceInfo(
      name: 'Перфоратор',
      category: 'Гараж та майстерня',
      icon: Icons.carpenter_outlined,
      typicalPower: 1000,
      maxPower: 1800,
      peakPower: 3000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 0.5,
    ),

    DeviceInfo(
      name: 'Електродриль',
      category: 'Гараж та майстерня',
      icon: Icons.build_outlined,
      typicalPower: 600,
      maxPower: 1200,
      peakPower: 2000,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 0.5,
    ),

    DeviceInfo(
      name: 'Шуруповерт (зарядка)',
      category: 'Гараж та майстерня',
      icon: Icons.battery_charging_full_outlined,
      typicalPower: 80,
      maxPower: 200,
      peakPower: 200,
      defaultHoursPerDay: 2,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Обробка дерева
    // =========================

    DeviceInfo(
      name: 'Циркулярна пилка',
      category: 'Гараж та майстерня',
      icon: Icons.content_cut_outlined,
      typicalPower: 1800,
      maxPower: 3500,
      peakPower: 5000,
      hasMotor: true,
      startupMultiplier: 2.5,
      defaultHoursPerDay: 1,
    ),

    DeviceInfo(
      name: 'Лобзик',
      category: 'Гараж та майстерня',
      icon: Icons.architecture_outlined,
      typicalPower: 500,
      maxPower: 1000,
      peakPower: 1500,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 0.5,
    ),

    DeviceInfo(
      name: 'Стрічкова шліфмашина',
      category: 'Гараж та майстерня',
      icon: Icons.blur_linear_outlined,
      typicalPower: 800,
      maxPower: 1500,
      peakPower: 2500,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 0.5,
    ),

    // =========================
    // Майстерня
    // =========================

    DeviceInfo(
      name: 'Витяжка майстерні',
      category: 'Гараж та майстерня',
      icon: Icons.mode_fan_off_outlined,
      typicalPower: 500,
      maxPower: 1200,
      peakPower: 1800,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 2,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Освітлення майстерні',
      category: 'Гараж та майстерня',
      icon: Icons.lightbulb_outline,
      typicalPower: 100,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 4,
    ),

    DeviceInfo(
      name: '3D-принтер',
      category: 'Гараж та майстерня',
      icon: Icons.print_outlined,
      typicalPower: 150,
      maxPower: 400,
      peakPower: 500,
      defaultHoursPerDay: 6,
      generatesHeat: true,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      smartDevice: true,
      wifiSupported: true,
      aiImportance: 80,
    ),
  ];
}