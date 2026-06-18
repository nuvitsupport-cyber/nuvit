import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EnergyConfigService {
  /// Проверяет, какие элементы энергосистемы физически настроены у пользователя
  static Future<Map<String, bool>> getSystemStructure() async {
    final prefs = await SharedPreferences.getInstance();
    final tabDevicesString = prefs.getString('tabDevices');
    
    bool hasSolar = false;
    bool hasBattery = false;
    bool hasInverter = false;

    if (tabDevicesString != null) {
      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(tabDevicesString));
        // Нас интересует вкладка 0: Джерела живлення та генерація
        final generationDevices = decoded['0'] as List? ?? [];
        
        for (var device in generationDevices) {
          final title = (device['title'] as String? ?? '').toLowerCase();
          if (title.contains('панел') || title.contains('соняч') || title.contains('solar')) {
            hasSolar = true;
          }
          if (title.contains('акум') || title.contains('акб') || title.contains('battery') || title.contains('батарея')) {
            hasBattery = true;
          }
          if (title.contains('інвертор') || title.contains('inverter')) {
            hasInverter = true;
          }
        }
      } catch (e) {
        print('Ошибка парсинга оборудования: $e');
      }
    }

    return {
      'hasSolar': hasSolar,
      'hasBattery': hasBattery,
      'hasInverter': hasInverter,
      'isHouse': (prefs.getInt('selectedProperty') ?? 0) == 1,
    };
  }
}