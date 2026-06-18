// lib/screens/home_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import '../layouts/desktop_layout.dart';
import '../layouts/mobile_layout.dart';
import '../models/device_model.dart';
import '../services/weather_service.dart'; 
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

import '../utils/calculations/autonomy_calculator.dart';
import '../utils/calculations/battery_calculator.dart';
import '../utils/calculations/readiness_estimator.dart';

import '../widgets/battery_input_field.dart';
import '../widgets/device_list_card.dart';
import '../widgets/autonomy_result_card.dart';
import '../widgets/battery_health_card.dart';
import '../widgets/blackout_readiness_card.dart';
import '../widgets/weather_insights_card.dart';
import 'devices_page.dart';
import 'load_management_page.dart';
import 'energy_hub_page.dart';
import '../main.dart' show notificationsPlugin;

// Временные заглушки для остальных вкладок, чтобы не было ошибок компиляции
class HistoryPage extends StatelessWidget { const HistoryPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Історія подій та відключень', style: TextStyle(color: Colors.white, fontSize: 20))); }
class ReportsPage extends StatelessWidget { const ReportsPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Аналітика та Звіти генерації СЕС', style: TextStyle(color: Colors.white, fontSize: 20))); }
class SettingsPage extends StatelessWidget { const SettingsPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text('Налаштування профілю користувача', style: TextStyle(color: Colors.white, fontSize: 20))); }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Переменная для контроля вкладок сайдбара

  // Метод, который переключает тела экранов в зависимости от выбранного пункта меню
  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return MainDashboardContent(
          onDevicesPageRequested: () {
            setState(() {
              _selectedIndex = 2; // Переключаемся на вкладку инфраструктуры внутри сайдбара
            });
          },
        );
      case 1:
        return const EnergyHubPage();
      case 2:
        return const InfrastructureHistoryPreviewPage(); // 🔥 Напрямую подключаем твою страницу инфраструктуры
      case 3:
        return const ReportsPage();
      case 4:
        return const SettingsPage();
      default:
        return MainDashboardContent(
          onDevicesPageRequested: () => setState(() => _selectedIndex = 2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Если ширина экрана меньше 900 (как и в твоем MainDashboardContent),
          // то используем мобильную оболочку из концепта
          if (constraints.maxWidth < 900) {
            return MobileLayout(
              selectedIndex: _selectedIndex,
              onIndexChanged: (int newIndex) {
                setState(() {
                  _selectedIndex = newIndex;
                });
              },
              child: _getSelectedPage(_selectedIndex),
            );
          }

          // Для больших экранов оставляем твой оригинальный DesktopLayout
          return DesktopLayout(
            selectedIndex: _selectedIndex,
            onIndexChanged: (int newIndex) async {
              setState(() {
                _selectedIndex = newIndex;
              });
            },
            child: _getSelectedPage(_selectedIndex),
          );
        },
      ),
    );
  }
}

// =========================================================================
// ОСНОВНОЙ ВИДЖЕТ ТВОЕЙ ГЛАВНОЙ ПАНЕЛИ МОНИТОРИНГУ NUVIT
// =========================================================================
class MainDashboardContent extends StatefulWidget {
  final VoidCallback onDevicesPageRequested;

  const MainDashboardContent({
    super.key,
    required this.onDevicesPageRequested,
  });

  @override
  State<MainDashboardContent> createState() => _MainDashboardContentState();
}

class _MainDashboardContentState extends State<MainDashboardContent> {
  final WeatherService _weatherService = WeatherService();

  String selectedMode = 'Економ';
  String housingType = 'Квартира'; 

  final Map<String, String> modeHints = {
    'Економ': 'Вмикаються лише життєво важливі системи для забезпечення базового виживання.',
    'Робота': 'Оптимально для віддаленої роботи: зв\'язок, комп\'ютери та критична побутова техніка.',
    'Комфорт': 'Максимально можливий уровень автономності з урахуванням великих споживачів.',
    'Свої налаштування': 'Повне ручне керування. Налаштуйте кожен прилад індивідуально за допомогою чекбоксів.',
  };

  final TextEditingController batteryController = TextEditingController(text: '1000');
  
  List<DeviceModel> activeDevices = [];
  
  String weatherAdvice = '';
  bool isLoadingWeather = true;
  String batteryType = 'LiFePO4';
  double batteryHealth = 100.0;
  double cycleCount = 120.0; 
  double dailyDepthOfDischarge = 50.0;
  int currentSoC = 100;

  String essArchitecture = 'stationary';
  String? selectedStationPresetName;

  Map<String, bool> energySystems = {
    'inverter': true,
    'solar_pv': false,
    'generator': false,
    'wind_turbine': false,
    'portable_ess': false,
    'two_zone_meter': false,
    'ats_system': false,
    'smart_meter': false,
    'stabilizer': false,
    'smart_home': false,
    'mppt_charge': false,
    'active_balancer': false,
    'wifi_dongle': false,
    'spd_protection': false,
    'cooling_system': false,
  };

  @override
  void initState() {
    super.initState();
    _applyProfilePreset(selectedMode);
    _updateCalculatedHealth(); 
    _initWeatherAndNotifications(); 
    loadProfileFromStorage();
  }

  @override
  void dispose() {
    batteryController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentStateToStorage() async {
    await StorageService.saveProfile(
      homeType: housingType,
      batteryType: batteryType,
      devices: activeDevices,
      energySystems: energySystems,
      batteryCapacity: batteryCapacity,
    );
  }

  void _showProfileDetailsModal(String modeName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bool isHouse = housingType == 'Будинок';
        final Map<String, int> targetDeviceMap = isHouse ? AppConstants.houseDevices : AppConstants.apartmentDevices;
        final Map<String, Map<String, bool>> targetProfiles = isHouse ? AppConstants.houseProfiles : AppConstants.apartmentProfiles;
        final Map<String, bool> presetMap = targetProfiles[modeName] ?? {};

        int totalWatts = 0;
        List<Widget> deviceRows = [];

        targetDeviceMap.forEach((name, watts) {
          if (presetMap[name] == true) {
            totalWatts += watts;
            deviceRows.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(name, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                    ),
                    Text('$watts Вт', style: const TextStyle(fontSize: 14, color: AppColors.neon, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }
        });

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Режим: $modeName ($housingType)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.neon),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                Text(
                  modeHints[modeName] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                if (modeName != 'Свої налаштування') ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white24),
                  ),
                  const Text(
                    'СПИСОК АКТИВНИХ ПРИЛАДІВ:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(children: deviceRows),
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Загальна потужність пресету:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$totalWatts Вт', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.neon)),
                    ],
                  ),
                ],
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neon,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      _changeMode(modeName);
                      Navigator.pop(context);
                    },
                    child: const Text('ЗАСТОСУВАТИ ЦЕЙ РЕЖИМ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyProfilePreset(String profileName) {
    if (profileName == 'Свої налаштування') return;

    final bool isHouse = housingType == 'Будинок';
    final Map<String, int> targetDeviceMap = isHouse ? AppConstants.houseDevices : AppConstants.apartmentDevices;
    final Map<String, Map<String, bool>> targetProfiles = isHouse ? AppConstants.houseProfiles : AppConstants.apartmentProfiles;
    
    final Map<String, bool> presetMap = targetProfiles[profileName] ?? {};
    activeDevices.clear();
    
    targetDeviceMap.forEach((name, watts) {
      String category = 'Загальнопобутові';
      int priority = 2;

      if (watts >= 1100 || 
          name.contains('Бойлер') || 
          name.contains('плита') || 
          name.contains('Кавомашина') ||
          name.contains('Клімат-система') ||
          name.contains('Пральна machine') ||
          name.contains('Мікрохвильова піч') ||
          name.contains('Електрочайник')) {
        category = 'Важка техніка';
        priority = 3;
      } else if (name.contains('Роутер') || 
                 name.contains('Освітлення') || 
                 name.contains('Зарядка') || 
                 name.contains('котел') || 
                 name.contains('безпеки') ||
                 name.contains('Мережевий вузол') ||
                 name.contains('відеонагляду')) {
        category = 'Критичне навантаження';
        priority = 1;
      }

      activeDevices.add(DeviceModel(
        name: name,
        watts: watts,
        enabled: presetMap[name] ?? false,
        category: category,
        priority: priority,
      ));
    });
  }

  Future<void> loadProfileFromStorage() async {
    final profile = await StorageService.loadProfile();
    if (!mounted) return;
    setState(() {
      if (profile['homeType'] != null) {
        housingType = profile['homeType'] as String;
      }

      if (profile['energySystems'] != null) {
        energySystems = Map<String, bool>.from(profile['energySystems'] as Map);
        if (energySystems['portable_ess'] == true) {
          essArchitecture = 'portable';
        } else {
          essArchitecture = 'stationary';
        }
      }

      if (profile['devices'] != null) {
        activeDevices = List<DeviceModel>.from(profile['devices'] as List);
        selectedMode = 'Свої налаштування';
      } else {
        _applyProfilePreset(selectedMode);
      }

      if (profile['batteryType'] != null) batteryType = profile['batteryType'] as String;

      if (profile['batteryCapacity'] != null) {
        batteryController.text = profile['batteryCapacity'].toString();
      }
    });
    _updateCalculatedHealth();
    updateEnergyWidget();
  }

  void _updateCalculatedHealth() {
    setState(() {
      batteryHealth = BatteryCalculator.calculateBatteryHealth(
        batteryType: batteryType,
        cycleCount: cycleCount,
      );
    });
  }

  Future<void> _initWeatherAndNotifications() async {
    if (kIsWeb) {
      await analyzeWeather();
      return;
    }
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await analyzeWeather();
  }

  int get batteryCapacity {
    final val = int.tryParse(batteryController.text) ?? 0;
    return val > 100000 ? 100000 : val;
  }

  int get activeLoad {
    return AutonomyCalculator.calculateActiveLoad(activeDevices);
  }

  bool get isStandby {
    final bool isSystemOn = essArchitecture == 'portable' || (energySystems['inverter'] ?? false);
    return batteryCapacity > 0 && activeLoad == 0 && !isSystemOn;
  }
  
  bool get isEmptyBattery => batteryCapacity <= 0;

  double get autonomyHours {
    final bool isMainInverterOn = essArchitecture == 'stationary' 
        ? (energySystems['inverter'] ?? false)
        : true; 

    return AutonomyCalculator.calculateAutonomyHours(
      batteryCapacity: batteryCapacity,
      batteryHealth: batteryHealth,
      currentSoC: currentSoC,
      currentDoD: dailyDepthOfDischarge.round(),
      activeLoad: activeLoad,
      isInverterOn: isMainInverterOn,
    );
  }

  Future<void> updateEnergyWidget() async {
    if (kIsWeb) return;
    final String autonomyStr = AutonomyCalculator.formatAutonomy(
      hours: autonomyHours,
      isEmptyBattery: isEmptyBattery,
      isStandby: isStandby,
      currentSoC: currentSoC,
      currentDoD: dailyDepthOfDischarge.round(),
    );

    await HomeWidget.saveWidgetData<String>('battery', '$batteryCapacity Wh');
    await HomeWidget.saveWidgetData<String>('autonomy', autonomyStr);
    await HomeWidget.saveWidgetData<String>('weather', weatherAdvice);

    await HomeWidget.updateWidget(name: 'NuvitWidgetProvider', iOSName: 'NuvitWidget');
  }

  void _changeMode(String newMode) {
    setState(() {
      selectedMode = newMode;
      if (newMode != 'Свої налаштування') {
        _applyProfilePreset(newMode);
      }
    });
    _saveCurrentStateToStorage();
    updateEnergyWidget(); 
  }

  void _toggleDevice(String key, bool value) {
    setState(() {
      final index = activeDevices.indexWhere((device) => device.name == key);
      if (index != -1) {
        activeDevices[index] = activeDevices[index].copyWith(enabled: value);
      }
    });
    _saveCurrentStateToStorage();
    updateEnergyWidget(); 
  }

  Future<void> analyzeWeather() async {
    try {
      if (!mounted) return;
      setState(() => isLoadingWeather = true);
      
      final data = await _weatherService.getWeather('Kyiv');
      final forecastList = data['list'];
      if (forecastList == null || forecastList.length < 9) throw Exception('Недостатньо даних');

      final tomorrow = forecastList[8];
      final clouds = tomorrow['clouds']?['all'] ?? 0;
      final temp = (tomorrow['main']?['temp'] ?? 20.0).toDouble();
      final windSpeed = (tomorrow['wind']?['speed'] ?? 0.0).toDouble();
      final weatherCondition = tomorrow['weather']?[0]?['main'] ?? 'Clear';
      int generationLoss = clouds > 80 ? ((weatherCondition == 'Rain' || weatherCondition == 'Snow') ? 85 : 70) : (clouds > 50 ? 40 : 10);
      List<String> insights = [];
      bool triggerUrgentAlert = false;

      if (generationLoss >= 70) {
        insights.add('📉 Generation PV впаде на $generationLoss% через щільну хмарність та опади ($weatherCondition).');
        triggerUrgentAlert = true;
      } else if (generationLoss >= 40) {
        insights.add('⛅ Помірна хмарність: очікується незначне падіння сонячної генерації на $generationLoss%.');
      } else {
        insights.add('☀️ Чудова погода для сонячних систем. Generation maximal.');
      }

      if (temp < 0) {
        insights.add('❄️ Температура $temp°C. Ефективність хімічних процесів у літієвих АКБ (LFP) може знизитись на 10-15%.');
      } else if (temp > 32) {
        insights.add('🔥 Спека $temp°C збільшить споживання кліматичної техніки. Контролюйте охолодження інвертора.');
      }

      if (windSpeed > 15) {
        insights.add('💨 Штормовий вітер ($windSpeed м/с)! Високий ризик аварійних обривів ЛЕП. Рекомендуємо зарядити АКБ до 100%.');
        triggerUrgentAlert = true;
      }

      if (dailyDepthOfDischarge > 80 && batteryType == 'LiFePO4') {
        insights.add('⚠️ AI Protection: Ви регулярно розряджаєте АКБ глибше ніж на 80% ($dailyDepthOfDischarge%).');
      }

      String finalAdvice = insights.join('\n\n');
      finalAdvice += triggerUrgentAlert 
          ? '\n\n⚡ Рекомендація NUVIT: Переведіть систему в режим пріоритету заряда (Grid Priority) вночі.'
          : '\n\n🔋 Рекомендація NUVIT: Працюйте в штатному режимі циклювання (Self-Consumption).';

      if (!mounted) return;
      setState(() {
        weatherAdvice = finalAdvice;
        isLoadingWeather = false;
      });
      updateEnergyWidget(); 
      if (triggerUrgentAlert) sendNotification('Погіршення метеоумов! Перевірте статус вашої ESS системи.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        weatherAdvice = 'Не вдалося отримати метеодані.';
        isLoadingWeather = false;
      });
      updateEnergyWidget();
    }
  }

  Future<void> sendNotification(String message) async {
    if (kIsWeb) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'nuvit_channel', 'NUVIT Alerts', channelDescription: 'Weather forecast alerts',
      importance: Importance.max, priority: Priority.high,
    );
    await notificationsPlugin.show(0, 'NUVIT Smart Forecast', message, const NotificationDetails(android: androidDetails));
  }

  @override
  Widget build(BuildContext context) {
    final int readinessScore = ReadinessEstimator.calculateReadinessScore(
      batteryHealth: batteryHealth, 
      autonomyHours: autonomyHours, 
      activeLoad: activeLoad, 
      weatherAdvice: weatherAdvice,
    );
    final double expectedYears = BatteryCalculator.calculateRemainingYears(
      batteryType: batteryType, 
      cycleCount: cycleCount, 
      dailyDepthOfDischarge: dailyDepthOfDischarge,
    );
    String readinessStatus = readinessScore < 50 ? 'CRITICAL' : (readinessScore < 80 ? 'MODERATE' : 'SAFE');
    Color readinessColor = readinessScore < 50 ? AppConstants.colorCritical : (readinessScore < 80 ? AppConstants.colorModerate : AppConstants.colorSafe);
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Позволяет DesktopLayout управлять фоном
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'NUVIT SMART PLANNER',
          style: TextStyle(color: AppColors.neon, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.neon, size: 28),
            tooltip: 'Налаштування інфраструктури',
            onPressed: widget.onDevicesPageRequested, // Вызываем триггер смены вкладки
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildLeftFormColumn())),
                        const SizedBox(width: 30),
                        Expanded(flex: 5, child: Column(children: _buildRightAnalyticsColumn(readinessScore, readinessStatus, readinessColor, expectedYears))),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildLeftFormColumn(),
                        const SizedBox(height: 35),
                        ..._buildRightAnalyticsColumn(readinessScore, readinessStatus, readinessColor, expectedYears),
                      ],
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildLeftFormColumn() {
    final Map<String, bool> deviceToggleMap = { for (var d in activeDevices) d.name: d.enabled };
    final Map<String, int> deviceWattsMap = { for (var d in activeDevices) d.name: d.watts };
    
    return [
      Text('Тип житла: $housingType', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
      const SizedBox(height: 25),
      
      BatteryInputField(
        controller: batteryController,
        onChanged: (_) {
          setState(() {
            selectedStationPresetName = null;
          });
          updateEnergyWidget();
        },
        onEditingComplete: () {
          _saveCurrentStateToStorage();
          updateEnergyWidget();
        },
      ),
      const SizedBox(height: 20),

      Card(
        color: AppColors.card,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ПОТОЧНИЙ ЗАРЯД БАТАРЕЇ (SoC)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.1),
                  ),
                  Text(
                    '$currentSoC%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.neon),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.neon,
                  inactiveTrackColor: Colors.white10,
                  thumbColor: AppColors.neon,
                  overlayColor: AppColors.neon.withValues(alpha: 0.2),
                  valueIndicatorColor: AppColors.card,
                ),
                child: Slider(
                  value: currentSoC.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '$currentSoC%',
                  onChanged: (double newValue) {
                    setState(() {
                      currentSoC = newValue.round();
                    });
                  },
                  onChangeEnd: (double val) {
                    updateEnergyWidget();
                  },
                ),
              ),
              Builder(builder: (context) {
                final int minAllowed = 100 - dailyDepthOfDischarge.round();
                if (currentSoC <= minAllowed) {
                  return const Text(
                    '⚠️ Увага: Заряд нижче або дорівнює встановленому ліміту безпеки DoD!',
                    style: TextStyle(color: AppConstants.colorCritical, fontSize: 11, fontWeight: FontWeight.bold),
                  );
                }
                return Text(
                  'Доступно для використання: ${currentSoC - minAllowed}% ємності (до порогу розряду $minAllowed%).',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                );
              }),
            ],
          ),
        ),
      ),

      const SizedBox(height: 20),
      _buildBatteryConfigRow(),
      
      const SizedBox(height: 35),
      
      Card(
        color: AppColors.card,
        child: ListTile(
          leading: const Icon(Icons.bolt, color: AppColors.neon, size: 28),
          title: const Text(
            'РЕЖИМ ЕНЕРГОСПОЖИВАННЯ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60, letterSpacing: 1.1),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Поточний пресет: $selectedMode',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.neon),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoadManagementPage(
                  selectedMode: selectedMode,
                  housingType: housingType,
                  modeHints: modeHints,
                  onModeChanged: (newMode) => _changeMode(newMode),
                  onShowDetailsModal: (mode) => _showProfileDetailsModal(mode),
                ),
              ),
            );
          },
        ),
      ),
      
      if (selectedMode == 'Свої налаштування') ...[
        const SizedBox(height: 20),
        DeviceListCard(
          activeDevices: deviceToggleMap,
          deviceWatts: deviceWattsMap,
          onDeviceToggle: _toggleDevice,
          onClearAllDevices: () {
            setState(() {
              for (int i = 0; i < activeDevices.length; i++) {
                activeDevices[i] = activeDevices[i].copyWith(enabled: false);
              }
            });
            _saveCurrentStateToStorage();
            updateEnergyWidget();
          },
          onCustomDeviceAdded: (String name, int watts) {
            setState(() {
              String category = 'Загальнопобутові';
              int priority = 2;

              if (watts >= 1100 || name.toLowerCase().contains('котел') || name.toLowerCase().contains('плита')) {
                category = 'Важка техніка';
                priority = 3;
              } else if (name.toLowerCase().contains('роутер') || name.toLowerCase().contains('освітлення') || name.toLowerCase().contains('насос')) {
                category = 'Критичне навантаження';
                priority = 1;
              }

              activeDevices.add(DeviceModel(
                name: name,
                watts: watts,
                enabled: true, 
                category: category,
                priority: priority,
              ));
            });

            _saveCurrentStateToStorage(); 
            updateEnergyWidget(); 
          },
        ),
      ],
    ];
  }

  List<Widget> _buildRightAnalyticsColumn(int score, String status, Color color, double expectedYears) {
    return [
      AutonomyResultCard(
        statusText: AutonomyCalculator.formatAutonomy(
          hours: autonomyHours, 
          isEmptyBattery: isEmptyBattery, 
          isStandby: isStandby,
          currentSoC: currentSoC,
          currentDoD: dailyDepthOfDischarge.round(),
        ),
        activeLoad: activeLoad, isEmptyBattery: isEmptyBattery, isStandby: isStandby,
      ),
      const SizedBox(height: 30),
      BatteryHealthCard(
        batteryType: batteryType, health: batteryHealth, currentCycles: cycleCount,
        maxCycles: AppConstants.batteryMaxCycles[batteryType] ?? 500,
        dailyDoD: dailyDepthOfDischarge.round(), expectedYears: expectedYears,
        onAddCycle: () => setState(() { cycleCount += (dailyDepthOfDischarge / 100.0); _updateCalculatedHealth(); updateEnergyWidget(); }),
        onResetCycles: () => setState(() { cycleCount = 0; _updateCalculatedHealth(); updateEnergyWidget(); }),
      ),
      const SizedBox(height: 30),
      BlackoutReadinessCard(score: score, status: status, color: color),
      const SizedBox(height: 30),
      WeatherInsightsCard(isLoading: isLoadingWeather, adviceText: weatherAdvice),
    ];
  }

  Widget _buildBatteryConfigRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Тип акумулятора:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: batteryType,
                    isExpanded: true,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: Colors.white),
                    items: AppConstants.batteryTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) => setState(() { 
                      batteryType = value!; 
                      selectedStationPresetName = null;
                      _updateCalculatedHealth(); 
                      _saveCurrentStateToStorage();
                      updateEnergyWidget(); 
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Поріг розряду (DoD): ${dailyDepthOfDischarge.round()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              Slider(
                value: dailyDepthOfDischarge, min: 10, max: 100,
                activeColor: AppColors.neon,
                inactiveColor: Colors.white10,
                onChanged: (val) => setState(() => dailyDepthOfDischarge = val),
                onChangeEnd: (_) {
                  _saveCurrentStateToStorage();
                  updateEnergyWidget();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}