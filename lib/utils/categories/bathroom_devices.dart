import 'package:flutter/material.dart';
import '../device_in.dart';

class BathroomDevices {
  const BathroomDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Догляд за волоссям
    // =========================

    DeviceInfo(
      name: 'Фен',
      category: 'Ванна кімната',
      icon: Icons.air_outlined,
      typicalPower: 1500,
      maxPower: 2200,
      peakPower: 2200,
      defaultHoursPerDay: 0.2,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Плойка',
      category: 'Ванна кімната',
      icon: Icons.waves_outlined,
      typicalPower: 60,
      maxPower: 120,
      peakPower: 120,
      defaultHoursPerDay: 0.2,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Випрямляч волосся',
      category: 'Ванна кімната',
      icon: Icons.horizontal_rule_outlined,
      typicalPower: 70,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 0.2,
      priority: DevicePriority.low,
    ),

    // =========================
    // Гоління
    // =========================

    DeviceInfo(
      name: 'Електробритва',
      category: 'Ванна кімната',
      icon: Icons.face_outlined,
      typicalPower: 10,
      maxPower: 20,
      peakPower: 20,
      standbyPower: 1,
      defaultHoursPerDay: 0.1,
    ),

    DeviceInfo(
      name: 'Тример',
      category: 'Ванна кімната',
      icon: Icons.content_cut_outlined,
      typicalPower: 10,
      maxPower: 20,
      peakPower: 20,
      standbyPower: 1,
      defaultHoursPerDay: 0.1,
    ),

    // =========================
    // Догляд за зубами
    // =========================

    DeviceInfo(
      name: 'Електрична зубна щітка',
      category: 'Ванна кімната',
      icon: Icons.cleaning_services_outlined,
      typicalPower: 3,
      maxPower: 5,
      peakPower: 5,
      standbyPower: 1,
      defaultHoursPerDay: 0.1,
    ),

    DeviceInfo(
      name: 'Іригатор',
      category: 'Ванна кімната',
      icon: Icons.water_drop_outlined,
      typicalPower: 20,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 0.1,
    ),

    // =========================
    // Здоров'я
    // =========================

    DeviceInfo(
      name: "Електронні ваги",
      category: 'Ванна кімната',
      icon: Icons.monitor_weight_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      standbyPower: 1,
      defaultHoursPerDay: 0.05,
    ),

    DeviceInfo(
      name: 'Тонометр',
      category: 'Ванна кімната',
      icon: Icons.favorite_outline,
      typicalPower: 5,
      maxPower: 10,
      peakPower: 10,
      defaultHoursPerDay: 0.05,
    ),

    DeviceInfo(
      name: 'Небулайзер',
      category: 'Ванна кімната',
      icon: Icons.air,
      typicalPower: 70,
      maxPower: 120,
      peakPower: 120,
      defaultHoursPerDay: 0.3,
      priority: DevicePriority.normal,
      supportsBackup: true,
    ),

    // =========================
    // Комфорт
    // =========================

    DeviceInfo(
      name: 'Дзеркало з підсвіткою',
      category: 'Ванна кімната',
      icon: Icons.light_mode_outlined,
      typicalPower: 20,
      maxPower: 40,
      peakPower: 40,
      defaultHoursPerDay: 2,
    ),

    DeviceInfo(
      name: 'Підігрів дзеркала',
      category: 'Ванна кімната',
      icon: Icons.auto_awesome_outlined,
      typicalPower: 30,
      maxPower: 60,
      peakPower: 60,
      defaultHoursPerDay: 1,
      generatesHeat: true,
    ),

    DeviceInfo(
      name: 'Витяжний вентилятор',
      category: 'Ванна кімната',
      icon: Icons.mode_fan_off_outlined,
      typicalPower: 20,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 2,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Електричний рушникосушник',
      category: 'Ванна кімната',
      icon: Icons.dry_outlined,
      typicalPower: 150,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 6,
      generatesHeat: true,
      shiftable: true,
      supportsScheduling: true,
    ),

    // =========================
    // Smart пристрої
    // =========================

    DeviceInfo(
      name: 'Smart дзеркало',
      category: 'Ванна кімната',
      icon: Icons.smart_display_outlined,
      typicalPower: 50,
      maxPower: 100,
      peakPower: 100,
      standbyPower: 3,
      defaultHoursPerDay: 3,
      smartDevice: true,
      wifiSupported: true,
      homeAssistantSupported: true,
    ),
  ];
}