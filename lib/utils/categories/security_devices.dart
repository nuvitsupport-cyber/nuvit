import 'package:flutter/material.dart';
import '../device_in.dart';

class SecurityDevices {
  const SecurityDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Відеоспостереження
    // =========================

    DeviceInfo(
      name: 'IP камера',
      category: 'Безпека',
      icon: Icons.videocam_outlined,
      typicalPower: 8,
      maxPower: 15,
      peakPower: 15,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
      aiImportance: 95,
    ),

    DeviceInfo(
      name: 'PTZ камера',
      category: 'Безпека',
      icon: Icons.camera_outdoor_outlined,
      typicalPower: 20,
      maxPower: 40,
      peakPower: 50,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Відеореєстратор (NVR)',
      category: 'Безпека',
      icon: Icons.storage_outlined,
      typicalPower: 30,
      maxPower: 80,
      peakPower: 80,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      aiImportance: 90,
    ),

    // =========================
    // Сигналізація
    // =========================

    DeviceInfo(
      name: 'Централь сигналізації',
      category: 'Безпека',
      icon: Icons.security_outlined,
      typicalPower: 10,
      maxPower: 30,
      peakPower: 30,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
      smartDevice: true,
      aiImportance: 100,
    ),

    DeviceInfo(
      name: 'Сирена',
      category: 'Безпека',
      icon: Icons.notifications_active_outlined,
      typicalPower: 10,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 0.1,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    // =========================
    // Датчики
    // =========================

    DeviceInfo(
      name: 'Датчик руху',
      category: 'Безпека',
      icon: Icons.motion_photos_on_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
    ),

    DeviceInfo(
      name: 'Датчик відкриття дверей',
      category: 'Безпека',
      icon: Icons.door_front_door_outlined,
      typicalPower: 1,
      maxPower: 3,
      peakPower: 3,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'Датчик диму',
      category: 'Безпека',
      icon: Icons.smoke_free_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Датчик газу',
      category: 'Безпека',
      icon: Icons.gas_meter_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Датчик затоплення',
      category: 'Безпека',
      icon: Icons.water_damage_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      supportsBackup: true,
    ),

    // =========================
    // Контроль доступу
    // =========================

    DeviceInfo(
      name: 'Домофон',
      category: 'Безпека',
      icon: Icons.dialpad_outlined,
      typicalPower: 10,
      maxPower: 25,
      peakPower: 25,
      defaultHoursPerDay: 24,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Відеодомофон',
      category: 'Безпека',
      icon: Icons.video_call_outlined,
      typicalPower: 20,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 24,
      supportsBackup: true,
      smartDevice: true,
      wifiSupported: true,
    ),

    DeviceInfo(
      name: 'Електрозамок',
      category: 'Безпека',
      icon: Icons.lock_outline,
      typicalPower: 10,
      maxPower: 30,
      peakPower: 30,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Система контролю доступу',
      category: 'Безпека',
      icon: Icons.badge_outlined,
      typicalPower: 15,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 24,
      priority: DevicePriority.high,
      supportsBackup: true,
    ),

    // =========================
    // Освітлення безпеки
    // =========================

    DeviceInfo(
      name: 'Прожектор з датчиком руху',
      category: 'Безпека',
      icon: Icons.lightbulb_outline,
      typicalPower: 30,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 3,
      smartDevice: true,
    ),

    DeviceInfo(
      name: 'Аварійне освітлення',
      category: 'Безпека',
      icon: Icons.emergency_outlined,
      typicalPower: 10,
      maxPower: 30,
      peakPower: 30,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      critical: true,
      supportsBackup: true,
    ),
  ];
}