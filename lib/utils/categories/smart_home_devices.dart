import 'package:flutter/material.dart';
import '../device_in.dart';

class SmartHomeDevices {
  const SmartHomeDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Хаби та контролери
    // =========================

    DeviceInfo(
      name: 'Home Assistant Server',
      category: 'Smart Home',
      icon: Icons.home_outlined,
      typicalPower: 15,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      supportsBackup: true,
      smartDevice: true,
      homeAssistantSupported: true,
      aiImportance: 100,
    ),

    DeviceInfo(
      name: 'Zigbee Hub',
      category: 'Smart Home',
      icon: Icons.hub_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
      homeAssistantSupported: true,
    ),

    DeviceInfo(
      name: 'Matter Hub',
      category: 'Smart Home',
      icon: Icons.device_hub_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'Aqara Hub',
      category: 'Smart Home',
      icon: Icons.router_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
    ),

    // =========================
    // Smart Meter
    // =========================

    DeviceInfo(
      name: 'Smart Meter',
      category: 'Smart Home',
      icon: Icons.electric_meter_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      supportsBackup: true,
      smartDevice: true,
      aiImportance: 100,
    ),

    // =========================
    // Реле та вимикачі
    // =========================

    DeviceInfo(
      name: 'Shelly Relay',
      category: 'Smart Home',
      icon: Icons.toggle_on_outlined,
      typicalPower: 1,
      maxPower: 3,
      peakPower: 3,
      defaultHoursPerDay: 24,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
    ),

    DeviceInfo(
      name: 'Sonoff Relay',
      category: 'Smart Home',
      icon: Icons.power_outlined,
      typicalPower: 1,
      maxPower: 3,
      peakPower: 3,
      defaultHoursPerDay: 24,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
    ),

    DeviceInfo(
      name: 'Smart вимикач',
      category: 'Smart Home',
      icon: Icons.toggle_on_outlined,
      typicalPower: 1,
      maxPower: 3,
      peakPower: 3,
      defaultHoursPerDay: 24,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'Smart розетка',
      category: 'Smart Home',
      icon: Icons.power,
      typicalPower: 1,
      maxPower: 3,
      peakPower: 3,
      defaultHoursPerDay: 24,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
    ),

    // =========================
    // Клімат
    // =========================

    DeviceInfo(
      name: 'Smart термостат',
      category: 'Smart Home',
      icon: Icons.thermostat_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      smartDevice: true,
      homeAssistantSupported: true,
    ),

    DeviceInfo(
      name: 'Smart клапан',
      category: 'Smart Home',
      icon: Icons.water_drop_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'Smart привід радіатора',
      category: 'Smart Home',
      icon: Icons.device_thermostat_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      smartDevice: true,
      homeAssistantSupported: true,
    ),

    // =========================
    // Освітлення
    // =========================

    DeviceInfo(
      name: 'Smart лампа',
      category: 'Smart Home',
      icon: Icons.lightbulb_outline,
      typicalPower: 10,
      maxPower: 20,
      peakPower: 20,
      defaultHoursPerDay: 5,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'Smart LED стрічка',
      category: 'Smart Home',
      icon: Icons.linear_scale_outlined,
      typicalPower: 30,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 6,
      smartDevice: true,
    ),

    // =========================
    // Штори та жалюзі
    // =========================

    DeviceInfo(
      name: 'Smart штори',
      category: 'Smart Home',
      icon: Icons.blinds_outlined,
      typicalPower: 20,
      maxPower: 60,
      peakPower: 100,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 1,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'Smart жалюзі',
      category: 'Smart Home',
      icon: Icons.window_outlined,
      typicalPower: 20,
      maxPower: 60,
      peakPower: 100,
      hasMotor: true,
      startupMultiplier: 2,
      defaultHoursPerDay: 1,
      smartDevice: true,
    ),

    // =========================
    // DIY та IoT
    // =========================

    DeviceInfo(
      name: 'ESP32',
      category: 'Smart Home',
      icon: Icons.memory_outlined,
      typicalPower: 1,
      maxPower: 3,
      peakPower: 3,
      defaultHoursPerDay: 24,
      smartDevice: true,
      homeAssistantSupported: true,
    ),

    DeviceInfo(
      name: 'ESP8266',
      category: 'Smart Home',
      icon: Icons.memory,
      typicalPower: 1,
      maxPower: 3,
      peakPower: 3,
      defaultHoursPerDay: 24,
      smartDevice: true,
      homeAssistantSupported: true,
    ),

    DeviceInfo(
      name: 'Raspberry Pi',
      category: 'Smart Home',
      icon: Icons.developer_board_outlined,
      typicalPower: 5,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
      homeAssistantSupported: true,
      aiImportance: 95,
    ),
  ];
}