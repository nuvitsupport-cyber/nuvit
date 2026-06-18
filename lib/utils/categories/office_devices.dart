import 'package:flutter/material.dart';
import '../device_in.dart';

class OfficeDevices {
  const OfficeDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Комп'ютери
    // =========================

    DeviceInfo(
      name: 'Робочий ПК',
      category: 'Офіс',
      icon: Icons.desktop_windows_outlined,
      typicalPower: 250,
      maxPower: 800,
      peakPower: 1000,
      defaultHoursPerDay: 8,
      priority: DevicePriority.high,
      supportsBackup: true,
      aiImportance: 90,
    ),

    DeviceInfo(
      name: 'Ігровий ПК',
      category: 'Офіс',
      icon: Icons.computer_outlined,
      typicalPower: 400,
      maxPower: 1000,
      peakPower: 1200,
      defaultHoursPerDay: 4,
      priority: DevicePriority.normal,
    ),

    DeviceInfo(
      name: 'Ноутбук',
      category: 'Офіс',
      icon: Icons.laptop_outlined,
      typicalPower: 65,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 8,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Монітор',
      category: 'Офіс',
      icon: Icons.monitor_outlined,
      typicalPower: 30,
      maxPower: 80,
      peakPower: 80,
      defaultHoursPerDay: 8,
      supportsBackup: true,
    ),

    // =========================
    // Мережеве обладнання
    // =========================

    DeviceInfo(
      name: 'Wi-Fi роутер',
      category: 'Офіс',
      icon: Icons.router_outlined,
      typicalPower: 10,
      maxPower: 25,
      peakPower: 25,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 100,
    ),

    DeviceInfo(
      name: 'Mesh система',
      category: 'Офіс',
      icon: Icons.wifi_outlined,
      typicalPower: 15,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Комутатор (Switch)',
      category: 'Офіс',
      icon: Icons.settings_ethernet_outlined,
      typicalPower: 15,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    // =========================
    // Друк
    // =========================

    DeviceInfo(
      name: 'Лазерний принтер',
      category: 'Офіс',
      icon: Icons.print_outlined,
      typicalPower: 500,
      maxPower: 1500,
      peakPower: 1800,
      defaultHoursPerDay: 0.5,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Струменевий принтер',
      category: 'Офіс',
      icon: Icons.print,
      typicalPower: 30,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 0.5,
    ),

    DeviceInfo(
      name: 'Сканер',
      category: 'Офіс',
      icon: Icons.document_scanner_outlined,
      typicalPower: 15,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 0.2,
    ),

    DeviceInfo(
      name: 'БФП (МФУ)',
      category: 'Офіс',
      icon: Icons.copy_outlined,
      typicalPower: 400,
      maxPower: 1200,
      peakPower: 1500,
      defaultHoursPerDay: 0.5,
    ),

    // =========================
    // Освітлення
    // =========================

    DeviceInfo(
      name: 'Настільна лампа',
      category: 'Офіс',
      icon: Icons.lightbulb_outline,
      typicalPower: 10,
      maxPower: 25,
      peakPower: 25,
      defaultHoursPerDay: 6,
    ),

    DeviceInfo(
      name: 'LED панель',
      category: 'Офіс',
      icon: Icons.light_mode_outlined,
      typicalPower: 40,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 8,
    ),

    // =========================
    // Аксесуари
    // =========================

    DeviceInfo(
      name: 'Док-станція',
      category: 'Офіс',
      icon: Icons.usb_outlined,
      typicalPower: 20,
      maxPower: 60,
      peakPower: 60,
      defaultHoursPerDay: 8,
    ),

    DeviceInfo(
      name: 'Шредер',
      category: 'Офіс',
      icon: Icons.delete_outline,
      typicalPower: 150,
      maxPower: 400,
      peakPower: 600,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 0.2,
    ),

    DeviceInfo(
      name: 'Ламінатор',
      category: 'Офіс',
      icon: Icons.article_outlined,
      typicalPower: 300,
      maxPower: 800,
      peakPower: 800,
      generatesHeat: true,
      defaultHoursPerDay: 0.2,
    ),

    // =========================
    // Відеоконференції
    // =========================

    DeviceInfo(
      name: 'Вебкамера',
      category: 'Офіс',
      icon: Icons.videocam_outlined,
      typicalPower: 5,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 6,
    ),

    DeviceInfo(
      name: 'Система відеоконференцій',
      category: 'Офіс',
      icon: Icons.video_call_outlined,
      typicalPower: 50,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 4,
      priority: DevicePriority.high,
    ),

    // =========================
    // UPS
    // =========================

    DeviceInfo(
      name: 'UPS',
      category: 'Офіс',
      icon: Icons.battery_charging_full_outlined,
      typicalPower: 20,
      maxPower: 80,
      peakPower: 80,
      standbyPower: 10,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 95,
    ),
  ];
}