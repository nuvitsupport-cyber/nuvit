import 'package:flutter/material.dart';
import '../device_in.dart';

class ClimateDevices {
  const ClimateDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // Кондиціонування
    // =========================

    DeviceInfo(
      name: 'Кондиціонер',
      category: 'Клімат',
      icon: Icons.ac_unit_outlined,
      typicalPower: 1200,
      minPower: 300,
      maxPower: 1500,
      peakPower: 2500,
      variablePower: true,
      defaultHoursPerDay: 6,
      generatesCooling: true,
      aiImportance: 90,
    ),

    DeviceInfo(
      name: 'Мобільний кондиціонер',
      category: 'Клімат',
      icon: Icons.mode_fan_off_outlined,
      typicalPower: 1300,
      maxPower: 1800,
      peakPower: 2500,
      defaultHoursPerDay: 5,
      generatesCooling: true,
    ),

    DeviceInfo(
      name: 'Вентилятор',
      category: 'Клімат',
      icon: Icons.mode_fan_off,
      typicalPower: 50,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 8,
    ),

    // =========================
    // Опалення
    // =========================

    DeviceInfo(
      name: 'Конвектор',
      category: 'Клімат',
      icon: Icons.device_thermostat_outlined,
      typicalPower: 1500,
      maxPower: 2000,
      peakPower: 2000,
      defaultHoursPerDay: 6,
      generatesHeat: true,
    ),

    DeviceInfo(
      name: 'Масляний радіатор',
      category: 'Клімат',
      icon: Icons.whatshot_outlined,
      typicalPower: 1500,
      maxPower: 2000,
      peakPower: 2000,
      defaultHoursPerDay: 6,
      generatesHeat: true,
    ),

    DeviceInfo(
      name: 'Тепловентилятор',
      category: 'Клімат',
      icon: Icons.air_outlined,
      typicalPower: 2000,
      maxPower: 2500,
      peakPower: 2500,
      defaultHoursPerDay: 4,
      generatesHeat: true,
    ),

    DeviceInfo(
      name: 'Інфрачервоний обігрівач',
      category: 'Клімат',
      icon: Icons.wb_incandescent_outlined,
      typicalPower: 1200,
      maxPower: 1800,
      peakPower: 1800,
      defaultHoursPerDay: 5,
      generatesHeat: true,
    ),

    DeviceInfo(
      name: 'Теплова гармата',
      category: 'Клімат',
      icon: Icons.local_fire_department_outlined,
      typicalPower: 3000,
      maxPower: 5000,
      peakPower: 5000,
      defaultHoursPerDay: 2,
      generatesHeat: true,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Тепла підлога',
      category: 'Клімат',
      icon: Icons.grid_4x4_outlined,
      typicalPower: 1000,
      maxPower: 3000,
      peakPower: 3000,
      variablePower: true,
      defaultHoursPerDay: 8,
      generatesHeat: true,
    ),

    DeviceInfo(
      name: 'Електрокотел',
      category: 'Клімат',
      icon: Icons.fireplace_outlined,
      typicalPower: 6000,
      maxPower: 9000,
      peakPower: 9000,
      defaultHoursPerDay: 8,
      generatesHeat: true,
      priority: DevicePriority.low,
    ),

    DeviceInfo(
      name: 'Тепловий насос',
      category: 'Клімат',
      icon: Icons.heat_pump_outlined,
      typicalPower: 2500,
      minPower: 800,
      maxPower: 4000,
      peakPower: 5000,
      variablePower: true,
      defaultHoursPerDay: 10,
      generatesHeat: true,
      generatesCooling: true,
      aiImportance: 95,

      supportedProperties: const [
        PropertyType.house,
      ],
    ),

    // =========================
    // Вентиляція
    // =========================

    DeviceInfo(
      name: 'Бризер',
      category: 'Клімат',
      icon: Icons.air,
      typicalPower: 50,
      maxPower: 100,
      peakPower: 100,
      defaultHoursPerDay: 12,
    ),

    DeviceInfo(
      name: 'Рекуператор',
      category: 'Клімат',
      icon: Icons.sync_alt_outlined,
      typicalPower: 80,
      maxPower: 150,
      peakPower: 150,
      defaultHoursPerDay: 24,
      priority: DevicePriority.critical,
      supportsBackup: true,
    ),

    DeviceInfo(
      name: 'Вентиляційна установка',
      category: 'Клімат',
      icon: Icons.wind_power_outlined,
      typicalPower: 300,
      maxPower: 500,
      peakPower: 500,
      defaultHoursPerDay: 24,
    ),

    // =========================
    // Вологість та якість повітря
    // =========================

    DeviceInfo(
      name: 'Зволожувач повітря',
      category: 'Клімат',
      icon: Icons.water_drop_outlined,
      typicalPower: 30,
      maxPower: 50,
      peakPower: 50,
      defaultHoursPerDay: 8,
    ),

    DeviceInfo(
      name: 'Осушувач повітря',
      category: 'Клімат',
      icon: Icons.water_damage_outlined,
      typicalPower: 300,
      maxPower: 600,
      peakPower: 600,
      defaultHoursPerDay: 6,
    ),

    DeviceInfo(
      name: 'Очищувач повітря',
      category: 'Клімат',
      icon:  Icons.air_outlined,
      typicalPower: 40,
      maxPower: 80,
      peakPower: 80,
      defaultHoursPerDay: 12,
    ),

    DeviceInfo(
      name: 'Іонізатор',
      category: 'Клімат',
      icon: Icons.bubble_chart_outlined,
      typicalPower: 15,
      maxPower: 20,
      peakPower: 20,
      defaultHoursPerDay: 8,
    ),

    DeviceInfo(
      name: 'Озонатор',
      category: 'Клімат',
      icon: Icons.blur_on_outlined,
      typicalPower: 80,
      maxPower: 120,
      peakPower: 120,
      defaultHoursPerDay: 1,
      priority: DevicePriority.low,
    ),

    // =========================
    // Декоративні
    // =========================

    DeviceInfo(
      name: 'Електрокамін',
      category: 'Клімат',
      icon: Icons.fireplace,
      typicalPower: 1500,
      maxPower: 2000,
      peakPower: 2000,
      defaultHoursPerDay: 4,
      generatesHeat: true,
    ),
  ];
}