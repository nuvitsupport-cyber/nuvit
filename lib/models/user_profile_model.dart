import 'device_model.dart';

class UserProfileModel {
  final List<DeviceModel> devices;
  final Map<String, bool> energySystems;
  final String batteryType;
  final String homeType;
  final String selectedMode; // Добавлено
  final int additionalLoad;  // Добавлено
  final DateTime lastUpdated;

  UserProfileModel({
    required this.devices,
    required this.energySystems,
    required this.batteryType,
    required this.homeType,
    required this.selectedMode,
    required this.additionalLoad,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'devices': devices.map((d) => d.toJson()).toList(),
    'energySystems': energySystems,
    'batteryType': batteryType,
    'homeType': homeType,
    'selectedMode': selectedMode,
    'additionalLoad': additionalLoad,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => UserProfileModel(
    devices: (json['devices'] as List<dynamic>).map((i) => DeviceModel.fromJson(i)).toList(),
    energySystems: Map<String, bool>.from(json['energySystems']),
    batteryType: json['batteryType'] ?? 'LiFePO4',
    homeType: json['homeType'] ?? 'Квартира',
    selectedMode: json['selectedMode'] ?? 'Економ',
    additionalLoad: json['additionalLoad'] ?? 0,
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
}