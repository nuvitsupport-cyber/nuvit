import 'package:flutter/material.dart';
import '../device_in.dart';

class ComputersDevices {
  const ComputersDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Комп'ютери
    // =========================

    DeviceInfo(
      name: "Настільний ПК",
      category: 'Комп’ютери',
      icon: Icons.computer_outlined,
      typicalPower: 250,
      maxPower: 600,
      peakPower: 700,
      standbyPower: 5,
      defaultHoursPerDay: 8,
      priority: DevicePriority.normal,
      supportsBackup: true,
      aiImportance: 90,
    ),

    DeviceInfo(
      name: "Ігровий ПК",
      category: 'Комп’ютери',
      icon: Icons.desktop_windows_outlined,
      typicalPower: 500,
      maxPower: 1000,
      peakPower: 1200,
      standbyPower: 10,
      defaultHoursPerDay: 4,
    ),

    DeviceInfo(
      name: 'Ноутбук',
      category: 'Комп’ютери',
      icon: Icons.laptop_outlined,
      typicalPower: 60,
      maxPower: 120,
      peakPower: 120,
      standbyPower: 2,
      defaultHoursPerDay: 8,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Міні ПК',
      category: 'Комп’ютери',
      icon: Icons.memory_outlined,
      typicalPower: 20,
      maxPower: 65,
      peakPower: 65,
      standbyPower: 1,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    // =========================
    // Монітори
    // =========================

    DeviceInfo(
      name: 'Монітор 24"',
      category: 'Комп’ютери',
      icon: Icons.monitor_outlined,
      typicalPower: 30,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 8,
    ),

    DeviceInfo(
      name: 'Монітор 32"',
      category: 'Комп’ютери',
      icon: Icons.monitor,
      typicalPower: 45,
      maxPower: 80,
      peakPower: 80,
      defaultHoursPerDay: 8,
    ),

    // =========================
    // Мережа
    // =========================

    DeviceInfo(
      name: 'Wi-Fi роутер',
      category: 'Комп’ютери',
      icon: Icons.router_outlined,
      typicalPower: 10,
      maxPower: 20,
      peakPower: 20,
      standbyPower: 8,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 95,
    ),

    DeviceInfo(
      name: 'Mesh вузол',
      category: 'Комп’ютери',
      icon: Icons.wifi_tethering_outlined,
      typicalPower: 8,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Комутатор',
      category: 'Комп’ютери',
      icon: Icons.hub_outlined,
      typicalPower: 20,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 24,
    ),

    DeviceInfo(
      name: 'PoE комутатор',
      category: 'Комп’ютери',
      icon: Icons.settings_ethernet_outlined,
      typicalPower: 50,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 24,
    ),

    // =========================
    // Зберігання
    // =========================

    DeviceInfo(
      name: 'NAS сервер',
      category: 'Комп’ютери',
      icon: Icons.storage_outlined,
      typicalPower: 40,
      maxPower: 100,
      peakPower: 120,
      standbyPower: 15,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      aiImportance: 85,
    ),

    DeviceInfo(
      name: 'Зовнішній HDD',
      category: 'Комп’ютери',
      icon: Icons.save_outlined,
      typicalPower: 8,
      maxPower: 15,
      peakPower: 20,
      defaultHoursPerDay: 4,
    ),

    // =========================
    // Друк
    // =========================

    DeviceInfo(
      name: 'Принтер',
      category: 'Комп’ютери',
      icon: Icons.print_outlined,
      typicalPower: 30,
      maxPower: 500,
      peakPower: 500,
      standbyPower: 3,
      defaultHoursPerDay: 1,
    ),

    DeviceInfo(
      name: 'МФУ',
      category: 'Комп’ютери',
      icon: Icons.print,
      typicalPower: 40,
      maxPower: 700,
      peakPower: 700,
      standbyPower: 5,
      defaultHoursPerDay: 1,
    ),

    DeviceInfo(
      name: '3D-принтер',
      category: 'Комп’ютери',
      icon: Icons.precision_manufacturing_outlined,
      typicalPower: 150,
      maxPower: 350,
      peakPower: 350,
      defaultHoursPerDay: 5,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Резервне живлення
    // =========================

    DeviceInfo(
      name: 'UPS',
      category: 'Комп’ютери',
      icon: Icons.battery_charging_full_outlined,
      typicalPower: 20,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
    ),

    // =========================
    // Smart Home
    // =========================

    DeviceInfo(
      name: 'Raspberry Pi',
      category: 'Комп’ютери',
      icon: Icons.memory,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
      homeAssistantSupported: true,
      aiImportance: 95,
    ),

    DeviceInfo(
      name: 'Home Assistant Server',
      category: 'Комп’ютери',
      icon: Icons.home_outlined,
      typicalPower: 15,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
      homeAssistantSupported: true,
      aiImportance: 100,
    ),

    // =========================
    // Периферія
    // =========================

    DeviceInfo(
      name: 'Сканер',
      category: 'Комп’ютери',
      icon: Icons.document_scanner_outlined,
      typicalPower: 20,
      maxPower: 80,
      peakPower: 80,
      defaultHoursPerDay: 1,
    ),

    DeviceInfo(
      name: 'Док-станція',
      category: 'Комп’ютери',
      icon: Icons.usb_outlined,
      typicalPower: 10,
      maxPower: 30,
      peakPower: 30,
      defaultHoursPerDay: 8,
    ),
  ];
}