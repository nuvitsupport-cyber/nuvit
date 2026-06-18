import 'package:flutter/material.dart';
import '../device_in.dart';

class EntertainmentDevices {
  const EntertainmentDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Телебачення
    // =========================

    DeviceInfo(
      name: 'Телевізор LED',
      category: 'Мультимедіа',
      icon: Icons.tv_outlined,
      typicalPower: 100,
      maxPower: 180,
      peakPower: 180,
      standbyPower: 1,
      defaultHoursPerDay: 5,
      priority: DevicePriority.normal,
      supportsBackup: true,
      aiImportance: 70,
    ),

    DeviceInfo(
      name: 'OLED телевізор',
      category: 'Мультимедіа',
      icon: Icons.tv,
      typicalPower: 150,
      maxPower: 300,
      peakPower: 300,
      standbyPower: 1,
      defaultHoursPerDay: 5,
      priority: DevicePriority.normal,
    ),

    // =========================
    // Аудіо
    // =========================

    DeviceInfo(
      name: 'Саундбар',
      category: 'Мультимедіа',
      icon: Icons.speaker_outlined,
      typicalPower: 40,
      maxPower: 120,
      peakPower: 120,
      standbyPower: 1,
      defaultHoursPerDay: 4,
    ),

    DeviceInfo(
      name: 'Домашній кінотеатр',
      category: 'Мультимедіа',
      icon: Icons.surround_sound_outlined,
      typicalPower: 200,
      maxPower: 500,
      peakPower: 500,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'AV ресивер',
      category: 'Мультимедіа',
      icon: Icons.graphic_eq_outlined,
      typicalPower: 80,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'Активна акустика',
      category: 'Мультимедіа',
      icon: Icons.speaker_group_outlined,
      typicalPower: 60,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 4,
    ),

    DeviceInfo(
      name: 'Smart колонка',
      category: 'Мультимедіа',
      icon: Icons.smart_toy_outlined,
      typicalPower: 8,
      maxPower: 15,
      peakPower: 15,
      standbyPower: 2,
      defaultHoursPerDay: 24,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
    ),

    // =========================
    // Відео
    // =========================

    DeviceInfo(
      name: 'Проектор',
      category: 'Мультимедіа',
      icon: Icons.video_settings_outlined,
      typicalPower: 250,
      maxPower: 400,
      peakPower: 400,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'Медіаплеєр',
      category: 'Мультимедіа',
      icon: Icons.play_circle_outline,
      typicalPower: 10,
      maxPower: 20,
      peakPower: 20,
      standbyPower: 1,
      defaultHoursPerDay: 5,
    ),

    // =========================
    // Ігри
    // =========================

    DeviceInfo(
      name: 'PlayStation',
      category: 'Мультимедіа',
      icon: Icons.sports_esports_outlined,
      typicalPower: 180,
      maxPower: 250,
      peakPower: 250,
      standbyPower: 2,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'Xbox',
      category: 'Мультимедіа',
      icon: Icons.sports_esports,
      typicalPower: 180,
      maxPower: 250,
      peakPower: 250,
      standbyPower: 2,
      defaultHoursPerDay: 3,
    ),

    DeviceInfo(
      name: 'Nintendo Switch Dock',
      category: 'Мультимедіа',
      icon: Icons.gamepad_outlined,
      typicalPower: 18,
      maxPower: 40,
      peakPower: 40,
      standbyPower: 1,
      defaultHoursPerDay: 2,
    ),

    // =========================
    // VR
    // =========================

    DeviceInfo(
      name: 'VR система',
      category: 'Мультимедіа',
      icon: Icons.view_in_ar_outlined,
      typicalPower: 50,
      maxPower: 120,
      peakPower: 120,
      defaultHoursPerDay: 2,
    ),

    // =========================
    // Стрімінг
    // =========================

    DeviceInfo(
      name: 'TV Box',
      category: 'Мультимедіа',
      icon: Icons.live_tv_outlined,
      typicalPower: 10,
      maxPower: 20,
      peakPower: 20,
      standbyPower: 1,
      defaultHoursPerDay: 6,
    ),

    DeviceInfo(
      name: 'Chromecast',
      category: 'Мультимедіа',
      icon: Icons.cast_outlined,
      typicalPower: 5,
      maxPower: 10,
      peakPower: 10,
      standbyPower: 1,
      defaultHoursPerDay: 24,
    ),
  ];
}