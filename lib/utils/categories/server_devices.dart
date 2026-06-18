import 'package:flutter/material.dart';
import '../device_in.dart';

class ServerDevices {
  const ServerDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Сервери
    // =========================

    DeviceInfo(
      name: 'Домашній сервер',
      category: 'Серверне обладнання',
      icon: Icons.dns_outlined,
      typicalPower: 80,
      maxPower: 250,
      peakPower: 300,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 100,
    ),

    DeviceInfo(
      name: 'Mini PC',
      category: 'Серверне обладнання',
      icon: Icons.memory_outlined,
      typicalPower: 15,
      maxPower: 65,
      peakPower: 80,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
      aiImportance: 95,
    ),

    DeviceInfo(
      name: 'Rack Server',
      category: 'Серверне обладнання',
      icon: Icons.storage_outlined,
      typicalPower: 250,
      maxPower: 700,
      peakPower: 800,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
    ),

    // =========================
    // NAS
    // =========================

    DeviceInfo(
      name: 'NAS',
      category: 'Серверне обладнання',
      icon: Icons.save_outlined,
      typicalPower: 20,
      maxPower: 80,
      peakPower: 100,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
      aiImportance: 95,
    ),

    DeviceInfo(
      name: 'JBOD сховище',
      category: 'Серверне обладнання',
      icon: Icons.sd_storage_outlined,
      typicalPower: 40,
      maxPower: 150,
      peakPower: 180,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    // =========================
    // Home Assistant
    // =========================

    DeviceInfo(
      name: 'Home Assistant Green',
      category: 'Серверне обладнання',
      icon: Icons.home_outlined,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      smartDevice: true,
      homeAssistantSupported: true,
      aiImportance: 100,
    ),

    DeviceInfo(
      name: 'Raspberry Pi',
      category: 'Серверне обладнання',
      icon: Icons.developer_board_outlined,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
      smartDevice: true,
      homeAssistantSupported: true,
    ),

    // =========================
    // Мережеве обладнання
    // =========================

    DeviceInfo(
      name: 'PoE комутатор',
      category: 'Серверне обладнання',
      icon: Icons.settings_ethernet_outlined,
      typicalPower: 20,
      maxPower: 120,
      peakPower: 120,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: '10G комутатор',
      category: 'Серверне обладнання',
      icon: Icons.hub_outlined,
      typicalPower: 30,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Маршрутизатор',
      category: 'Серверне обладнання',
      icon: Icons.router_outlined,
      typicalPower: 10,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 100,
    ),

    // =========================
    // Відеоспостереження
    // =========================

    DeviceInfo(
      name: 'NVR',
      category: 'Серверне обладнання',
      icon: Icons.video_library_outlined,
      typicalPower: 25,
      maxPower: 80,
      peakPower: 100,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Blue Iris Server',
      category: 'Серверне обладнання',
      icon: Icons.videocam_outlined,
      typicalPower: 80,
      maxPower: 250,
      peakPower: 300,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    // =========================
    // UPS
    // =========================

    DeviceInfo(
      name: 'UPS',
      category: 'Серверне обладнання',
      icon: Icons.battery_charging_full_outlined,
      typicalPower: 20,
      maxPower: 100,
      peakPower: 100,
      standbyPower: 15,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 100,
    ),

    DeviceInfo(
      name: 'PDU',
      category: 'Серверне обладнання',
      icon: Icons.power_outlined,
      typicalPower: 5,
      maxPower: 20,
      peakPower: 20,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    // =========================
    // Охолодження
    // =========================

    DeviceInfo(
      name: 'Вентиляція серверної шафи',
      category: 'Серверне обладнання',
      icon: Icons.mode_fan_off_outlined,
      typicalPower: 15,
      maxPower: 60,
      peakPower: 60,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Кондиціонер серверної',
      category: 'Серверне обладнання',
      icon: Icons.ac_unit_outlined,
      typicalPower: 1000,
      maxPower: 3000,
      peakPower: 4000,
      defaultHoursPerDay: 24,
      generatesHeat: false,
      priority: DevicePriority.high,
      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Smart Rack
    // =========================

    DeviceInfo(
      name: 'Smart PDU',
      category: 'Серверне обладнання',
      icon: Icons.electrical_services_outlined,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
      supportsBackup: true,
    ),
  ];
}