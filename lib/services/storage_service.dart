import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/device_model.dart';

class StorageService {
  static const String _keyDevices = 'householdDevices';
  static const String _keyEnergySystems = 'energySystems';
  static const String _keyBatteryType = 'batteryType';
  static const String _keyHomeType = 'homeType';
  static const String _keyBatteryCapacity = 'batteryCapacity'; // 1. Добавили ключ

  // Сохранение всего глобального профиля пользователя
  static Future<void> saveProfile({
    required List<DeviceModel> devices,
    required Map<String, bool> energySystems,
    required String batteryType,
    required String homeType,
    required int batteryCapacity, // 2. Добавили параметр
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final List<Map<String, dynamic>> devicesJson = devices.map((d) => d.toJson()).toList();
    await prefs.setString(_keyDevices, jsonEncode(devicesJson));
    await prefs.setString(_keyEnergySystems, jsonEncode(energySystems));
    await prefs.setString(_keyBatteryType, batteryType);
    await prefs.setString(_keyHomeType, homeType);
    await prefs.setInt(_keyBatteryCapacity, batteryCapacity); // 3. Сохранили значение
  }

  // Загрузка глобального профиля
  static Future<Map<String, dynamic>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? devicesRaw = prefs.getString(_keyDevices);
    final String? energyRaw = prefs.getString(_keyEnergySystems);
    final String? batteryType = prefs.getString(_keyBatteryType);
    final String? homeType = prefs.getString(_keyHomeType);
    final int? batteryCapacity = prefs.getInt(_keyBatteryCapacity); // 4. Загрузили значение

    List<DeviceModel>? devices;
    if (devicesRaw != null) {
      final List<dynamic> decoded = jsonDecode(devicesRaw);
      devices = decoded.map((item) => DeviceModel.fromJson(item as Map<String, dynamic>)).toList();
    }

    Map<String, bool>? energySystems;
    if (energyRaw != null) {
      energySystems = Map<String, bool>.from(jsonDecode(energyRaw));
    }

    return {
      'devices': devices,
      'energySystems': energySystems,
      'batteryType': batteryType,
      'homeType': homeType,
      'batteryCapacity': batteryCapacity, // 5. Вернули в мапе
    };
  }
}