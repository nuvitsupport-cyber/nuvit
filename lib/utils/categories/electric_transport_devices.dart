import 'package:flutter/material.dart';
import '../device_in.dart';

class ElectricTransportDevices {
  const ElectricTransportDevices._();

  static const List<DeviceInfo> items = [

    // =========================
    // EV Charger AC
    // =========================

    DeviceInfo(
      name: 'EV Charger 3.7 кВт',
      category: 'Електротранспорт',
      icon: Icons.ev_station_outlined,
      typicalPower: 3700,
      maxPower: 3700,
      peakPower: 3700,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 95,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'EV Charger 7.4 кВт',
      category: 'Електротранспорт',
      icon: Icons.ev_station_outlined,
      typicalPower: 7400,
      maxPower: 7400,
      peakPower: 7400,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 100,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'EV Charger 11 кВт',
      category: 'Електротранспорт',
      icon: Icons.ev_station,
      typicalPower: 11000,
      maxPower: 11000,
      peakPower: 11000,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 100,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'EV Charger 22 кВт',
      category: 'Електротранспорт',
      icon: Icons.ev_station,
      typicalPower: 22000,
      maxPower: 22000,
      peakPower: 22000,
      defaultHoursPerDay: 3,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      allowAutoStart: true,
      aiImportance: 100,
      priority: DevicePriority.low,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    // =========================
    // Електросамокати
    // =========================

    DeviceInfo(
      name: 'Зарядка електросамоката',
      category: 'Електротранспорт',
      icon: Icons.electric_scooter_outlined,
      typicalPower: 150,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    DeviceInfo(
      name: 'Зарядка потужного електросамоката',
      category: 'Електротранспорт',
      icon: Icons.electric_scooter,
      typicalPower: 300,
      maxPower: 600,
      peakPower: 600,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Електровелосипеди
    // =========================

    DeviceInfo(
      name: 'Зарядка електровелосипеда',
      category: 'Електротранспорт',
      icon: Icons.electric_bike_outlined,
      typicalPower: 200,
      maxPower: 500,
      peakPower: 500,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Моноколеса
    // =========================

    DeviceInfo(
      name: 'Зарядка моноколеса',
      category: 'Електротранспорт',
      icon: Icons.trip_origin,
      typicalPower: 200,
      maxPower: 500,
      peakPower: 500,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Електромотоцикли
    // =========================

    DeviceInfo(
      name: 'Зарядка електромотоцикла',
      category: 'Електротранспорт',
      icon: Icons.two_wheeler_outlined,
      typicalPower: 1000,
      maxPower: 3000,
      peakPower: 3000,
      defaultHoursPerDay: 3,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
    ),

    // =========================
    // Гольфкари та квадроцикли
    // =========================

    DeviceInfo(
      name: 'Зарядка гольфкара',
      category: 'Електротранспорт',
      icon: Icons.directions_car_outlined,
      typicalPower: 2000,
      maxPower: 4000,
      peakPower: 4000,
      defaultHoursPerDay: 5,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    DeviceInfo(
      name: 'Зарядка електроквадроцикла',
      category: 'Електротранспорт',
      icon: Icons.offline_bolt_outlined,
      typicalPower: 1500,
      maxPower: 3500,
      peakPower: 3500,
      defaultHoursPerDay: 4,
      shiftable: true,
      supportsScheduling: true,
      supportsPVExcess: true,
      supportedProperties: [
        PropertyType.house,
      ],
    ),

    // =========================
    // Інше
    // =========================

    DeviceInfo(
      name: 'Зарядка інвалідного електровізка',
      category: 'Електротранспорт',
      icon: Icons.accessible_forward_outlined,
      typicalPower: 100,
      maxPower: 300,
      peakPower: 300,
      defaultHoursPerDay: 6,
      supportsBackup: true,
      shiftable: true,
      supportsScheduling: true,
    ),
  ];
}