// lib/widgets/energy_hub/autonomy_calculator/autonomy_preset_view_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:nuvit/utils/app_colors.dart';
import 'package:nuvit/utils/global_devices_catalog.dart';
import 'autonomy_preset_selector.dart';

class AutonomyPresetDevicesWidget extends StatefulWidget {
  // Колбэк передает выбранный пресет и список устройств в главный виджет для расчетов
  final Function(String preset, List<Map<String, dynamic>> filteredDevices)? onPresetChanged;

  const AutonomyPresetDevicesWidget({
    super.key, 
    this.onPresetChanged,
  });

  @override
  State<AutonomyPresetDevicesWidget> createState() => _AutonomyPresetDevicesWidgetState();
}

class _AutonomyPresetDevicesWidgetState extends State<AutonomyPresetDevicesWidget> {
  String _currentPreset = 'balanced'; 
  bool _isLoading = true;

  Map<String, dynamic> _deviceConfigs = {};
  Map<String, double> _customPowers = {};
  Set<String> _deletedDevices = {};
  List<dynamic> _customDevices = [];

  // Список пристроїв, які активовані саме у "Власному" пресеті
  Set<String> _customActiveDevices = {};

  // Список для відображення в UI
  List<Map<String, dynamic>> _displayDevices = [];

  @override
  void initState() {
    super.initState();
    _loadStoredDevices();
  }

  Future<void> _loadStoredDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        final configString = prefs.getString('deviceCustomConfigs');
        if (configString != null) {
          _deviceConfigs = jsonDecode(configString);
        }

        final powersString = prefs.getString('customDevicePowers');
        if (powersString != null) {
          _customPowers = Map<String, double>.from(
            (jsonDecode(powersString)).map((k, v) => MapEntry(k, (v as num).toDouble())),
          );
        }

        final deletedString = prefs.getString('deletedDeviceNames');
        if (deletedString != null) {
          _deletedDevices = Set<String>.from(jsonDecode(deletedString));
        }

        final customDevicesString = prefs.getString('customDevices');
        if (customDevicesString != null) {
          _customDevices = jsonDecode(customDevicesString);
        }

        final customActiveString = prefs.getStringList('customActiveDevices');
        if (customActiveString != null) {
          _customActiveDevices = customActiveString.toSet();
        }

        _isLoading = false;
      });

      _filterDevicesByPreset();
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Метод для перемикання стану пристрою у власному пресеті
  Future<void> _toggleCustomDevice(String name, bool isActive) async {
    setState(() {
      if (isActive) {
        _customActiveDevices.add(name);
      } else {
        _customActiveDevices.remove(name);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('customActiveDevices', _customActiveDevices.toList());

    _filterDevicesByPreset();
  }

  bool _checkPresetMatch(String deviceMode, String selectedPreset) {
    if (selectedPreset == 'custom') return true; // У кастомному показуємо всі налаштовані
    
    switch (selectedPreset) {
      case 'basic':
        return deviceMode == 'basic';
      case 'balanced':
        return deviceMode == 'basic' || deviceMode == 'balanced';
      case 'comfort':
        return deviceMode == 'basic' || deviceMode == 'balanced' || deviceMode == 'comfort';
      default:
        return false;
    }
  }

  // Допоміжний метод для правильного сортування пристроїв
  int _getPresetSortOrder(String mode) {
    switch (mode) {
      case 'basic': return 0;
      case 'balanced': return 1;
      case 'comfort': return 2;
      case 'custom': return 3;
      default: return 4;
    }
  }

  void _filterDevicesByPreset() {
    Map<String, Map<String, dynamic>> allAvailableDevices = {};

    for (var d in GlobalDevicesCatalog.allDevices) {
      allAvailableDevices[d.name] = {
        'typicalPower': d.typicalPower,
        'icon': d.icon ?? Icons.devices_other_rounded,
      };
    }

    for (var custom in _customDevices) {
      final name = custom['name'];
      allAvailableDevices[name] = {
        'typicalPower': (custom['typicalPower'] as num).toDouble(),
        'icon': Icons.add_to_photos_rounded,
      };
    }

    List<Map<String, dynamic>> displayList = [];
    List<Map<String, dynamic>> activeListForCalculation = [];

    _deviceConfigs.forEach((name, config) {
      if (_deletedDevices.contains(name)) return;

      final deviceBaseInfo = allAvailableDevices[name];
      if (deviceBaseInfo == null) return; 

      final int amount = config['amount'] ?? 0;
      final double hours = (config['hoursPerDay'] as num?)?.toDouble() ?? 0.0;
      final String deviceMode = config['energyMode'] ?? 'balanced';

      // Беремо лише ті пристрої, які користувач додав (amount > 0)
      if (amount > 0 && _checkPresetMatch(deviceMode, _currentPreset)) {
        final double finalPower = _customPowers[name] ?? deviceBaseInfo['typicalPower'];

        final deviceData = {
          'name': name,
          'amount': amount,
          'hoursPerDay': hours,
          'power': finalPower,
          'deviceMode': deviceMode,
          'icon': deviceBaseInfo['icon'],
        };

        displayList.add(deviceData);

        // Якщо це кастомний пресет, у розрахунок йдуть ТІЛЬКИ ті, що включені тумблером
        if (_currentPreset == 'custom') {
          if (_customActiveDevices.contains(name)) {
            activeListForCalculation.add(deviceData);
          }
        } else {
          // Для інших пресетів у розрахунок йде все, що відображається
          activeListForCalculation.add(deviceData);
        }
      }
    });

    // Якщо це "Власний" пресет, сортуємо їх по категоріям (базовий -> збалансований...)
    if (_currentPreset == 'custom') {
      displayList.sort((a, b) {
        final orderA = _getPresetSortOrder(a['deviceMode']);
        final orderB = _getPresetSortOrder(b['deviceMode']);
        return orderA.compareTo(orderB);
      });
    }

    setState(() {
      _displayDevices = displayList;
    });

    if (widget.onPresetChanged != null) {
      // У головний віджет передаємо лише АКТИВНІ пристрої для математики
      widget.onPresetChanged!(_currentPreset, activeListForCalculation);
    }
  }

  void _onPresetChanged(String newPreset) {
    setState(() {
      _currentPreset = newPreset;
    });
    _filterDevicesByPreset();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    // Рахуємо скільки активно саме зараз для заголовка
    int activeCount = _currentPreset == 'custom' 
        ? _displayDevices.where((d) => _customActiveDevices.contains(d['name'])).length 
        : _displayDevices.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF051033),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(.03), 
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AutonomyPresetSelector(
            selectedMode: _currentPreset,
            onChanged: _onPresetChanged,
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Пристрої у цьому пресеті ($activeCount)',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 12),

          _displayDevices.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _displayDevices.length,
                  itemBuilder: (context, index) {
                    final device = _displayDevices[index];
                    return _buildDeviceListTile(device);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDeviceListTile(Map<String, dynamic> device) {
    final presetColor = _getPresetColor(device['deviceMode']);
    final isCustomMode = _currentPreset == 'custom';
    
    // Перевіряємо чи активний пристрій. Якщо режим НЕ кастомний — він активний завжди.
    final isActive = isCustomMode ? _customActiveDevices.contains(device['name']) : true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Якщо неактивний, робимо плашку темнішою, щоб вона "зливалась" із фоном
        color: isActive ? const Color(0xFF0A153A) : const Color(0xFF051033), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? presetColor.withOpacity(0.25) : Colors.white.withOpacity(0.02),
          width: 1.2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: presetColor.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : [],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? presetColor.withOpacity(0.12) : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              device['icon'] is IconData ? device['icon'] : Icons.devices_other_rounded, 
              color: isActive ? presetColor : AppColors.textMuted.withOpacity(0.5), 
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textMuted.withOpacity(0.7), 
                    fontSize: 14, 
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto', // Або ваш кастомний шрифт
                  ),
                  child: Text(device['name']),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    color: isActive ? AppColors.textMuted : AppColors.textMuted.withOpacity(0.4), 
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                  child: Text('Кіл-ть: ${device['amount']} шт. | Час: ${device['hoursPerDay']} год/день'),
                ),
              ],
            ),
          ),
          
          // Блок з потужністю та КНОПКОЮ ЖИВЛЕННЯ (якщо Власний пресет)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: isActive ? Colors.amber : AppColors.textMuted.withOpacity(0.4), 
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
                child: Text('${device['power'].toInt()} Вт'),
              ),
              if (isCustomMode) ...[
                const SizedBox(height: 10), // Збільшений відступ
                InkWell(
                  onTap: () => _toggleCustomDevice(device['name'], !isActive),
                  borderRadius: BorderRadius.circular(100),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A153A), // Темний фон
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? presetColor : AppColors.textMuted.withOpacity(0.1), // Тонка кольорова рамка (як в image_1.png)
                        width: 1.0,
                      ),
                      boxShadow: isActive ? [
                          BoxShadow(
                            color: presetColor.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ] : [],
                    ),
                    child: Icon(
                      Icons.power_settings_new_rounded, // Іконка живлення
                      color: isActive ? presetColor : AppColors.textMuted.withOpacity(0.3),
                      size: 20,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.power_off, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              'Немає активних пристроїв для цього пресета.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Налаштуйте список пристроїв на сторінці "Налаштування інфраструктури".',
              style: TextStyle(color: AppColors.textMuted.withOpacity(0.6), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPresetColor(String mode) {
    switch (mode) {
      case 'basic': 
        return const Color(0xFFFF4554);
      case 'balanced': 
        return const Color(0xFF0052FF);
      case 'comfort': 
        return const Color(0xFFFF7A00);
      case 'custom': 
        return AppColors.neon;
      default: 
        return Colors.blueAccent;
    }
  }
}