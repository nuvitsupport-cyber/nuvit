import 'package:flutter/material.dart';
import '../device_in.dart';

class ChargersDevices {
  const ChargersDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Смартфони
    // =========================

    DeviceInfo(
      name: 'Зарядка смартфона',
      category: 'Зарядні пристрої',
      icon: Icons.smartphone_outlined,
      typicalPower: 15,
      maxPower: 45,
      peakPower: 45,
      standbyPower: 0.5,
      defaultHoursPerDay: 3,
      priority: DevicePriority.normal,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Бездротова зарядка',
      category: 'Зарядні пристрої',
      icon: Icons.wifi_tethering_outlined,
      typicalPower: 10,
      maxPower: 20,
      peakPower: 20,
      standbyPower: 1,
      defaultHoursPerDay: 4,
    ),

    // =========================
    // Комп'ютери
    // =========================

    DeviceInfo(
      name: 'Зарядка ноутбука',
      category: 'Зарядні пристрої',
      icon: Icons.laptop_chromebook_outlined,
      typicalPower: 65,
      maxPower: 150,
      peakPower: 150,
      standbyPower: 1,
      defaultHoursPerDay: 6,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'USB-C Dock',
      category: 'Зарядні пристрої',
      icon: Icons.usb_outlined,
      typicalPower: 20,
      maxPower: 60,
      peakPower: 60,
      defaultHoursPerDay: 8,
    ),

    // =========================
    // Планшети
    // =========================

    DeviceInfo(
      name: 'Зарядка планшета',
      category: 'Зарядні пристрої',
      icon: Icons.tablet_android_outlined,
      typicalPower: 20,
      maxPower: 45,
      peakPower: 45,
      standbyPower: 1,
      defaultHoursPerDay: 3,
    ),

    // =========================
    // Power Bank
    // =========================

    DeviceInfo(
      name: 'Power Bank',
      category: 'Зарядні пристрої',
      icon: Icons.battery_charging_full_outlined,
      typicalPower: 18,
      maxPower: 65,
      peakPower: 65,
      standbyPower: 0.5,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Фото та відео
    // =========================

    DeviceInfo(
      name: 'Зарядка фотоапарата',
      category: 'Зарядні пристрої',
      icon: Icons.camera_alt_outlined,
      typicalPower: 15,
      maxPower: 30,
      peakPower: 30,
      defaultHoursPerDay: 2,
    ),

    DeviceInfo(
      name: 'Зарядка дрона',
      category: 'Зарядні пристрої',
      icon: Icons.flight_outlined,
      typicalPower: 50,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 2,
      shiftable: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Wearables
    // =========================

    DeviceInfo(
      name: 'Зарядка смарт-годинника',
      category: 'Зарядні пристрої',
      icon: Icons.watch_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      standbyPower: 0.5,
      defaultHoursPerDay: 2,
    ),

    DeviceInfo(
      name: 'Зарядка навушників',
      category: 'Зарядні пристрої',
      icon: Icons.headphones_outlined,
      typicalPower: 3,
      maxPower: 10,
      peakPower: 10,
      standbyPower: 0.5,
      defaultHoursPerDay: 2,
    ),

    // =========================
    // Інструмент
    // =========================

    DeviceInfo(
      name: 'Зарядка акумуляторного інструменту',
      category: 'Зарядні пристрої',
      icon: Icons.handyman_outlined,
      typicalPower: 100,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 1,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Побутова техніка
    // =========================

    DeviceInfo(
      name: 'Зарядка електрощітки',
      category: 'Зарядні пристрої',
      icon: Icons.cleaning_services_outlined,
      typicalPower: 2,
      maxPower: 5,
      peakPower: 5,
      standbyPower: 0.5,
      defaultHoursPerDay: 1,
    ),

    DeviceInfo(
      name: 'Універсальна USB станція',
      category: 'Зарядні пристрої',
      icon: Icons.hub_outlined,
      typicalPower: 30,
      maxPower: 120,
      peakPower: 120,
      standbyPower: 2,
      defaultHoursPerDay: 12,
      supportsBackup: true,
    ),
  ];
}