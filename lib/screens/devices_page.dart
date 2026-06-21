// lib/screens/devices_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import 'connect_equipment/connect_equipment_page.dart';
import '../utils/global_devices_catalog.dart';
import '../utils/device_categories_info.dart';
import '../utils/device_cats_info.dart';
import '../utils/device_in.dart';
import '../utils/device_categories.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



class InfrastructureHistoryPreviewPage extends StatefulWidget {
  const InfrastructureHistoryPreviewPage({super.key});

  @override
  State<InfrastructureHistoryPreviewPage> createState() =>
      _InfrastructureHistoryPreviewPageState();
      
}
class DeviceConfig {
  int amount;
  double hoursPerDay;
  String energyMode;

  DeviceConfig({
    required this.amount,
    required this.hoursPerDay,
    this.energyMode = 'balanced',
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'hoursPerDay': hoursPerDay,
      'energyMode': energyMode,
    };
  }

  factory DeviceConfig.fromJson(
    Map<String, dynamic> json,
  ) {
    return DeviceConfig(
      amount: json['amount'],
      hoursPerDay:
          (json['hoursPerDay'] as num).toDouble(),
      energyMode: json['energyMode'] ?? 'balanced',
    );
  }
}
class _InfrastructureHistoryPreviewPageState
    extends State<InfrastructureHistoryPreviewPage> {
  int selectedProperty = 0;
  int selectedTab = 0;
  bool _isDataLoaded = false;

List<DeviceInfo> selectedDevices = [];
Map<String, bool> expandedCategories = {};
Map<String, DeviceConfig> deviceCustomConfigs = {};
Set<String> deletedDeviceNames = {}; 
Map<String, double> customDevicePowers = {};
List<DeviceInfo> customDevices = [];
Map<String, String> customDeviceCategories = {};
final Map<String, TextEditingController> _powerControllers = {};
final Set<String> _hoveredActivateButtons = {};
final Set<String> _hoveredPowerButtons = {};
final Set<String> _hoveredDeleteButtons = {};
final Map<String, TextEditingController> _hoursControllers = {};

int resetCounter = 0;

static const Color brandBg = Color(0xFF020D2D);       
  static const Color brandCard = Color(0xFF0A153A);     
  static const Color brandInnerBg = Color(0xFF051033);  

  final tabs = [
    'Джерела живлення та генерація',
    'Захист та стабілізація мережі',
    'Автоматизація та смарт керування',
    'Оптимізація та обслуговування',
  ];

  late Map<int, List<Map<String, dynamic>>> tabDevices;

  @override
  void initState() {
    super.initState();
    _resetToDefaults();
    for (final category in DeviceCategories.all) {
  expandedCategories[category] = false;
}
    tabDevices = {
      0: [], 
      1: [], 
      2: [], 
      3: [], 
    };
    selectedDevices = GlobalDevicesCatalog.allDevices.take(3).toList();
    _loadData();
  }

  @override
void dispose() {
  // Автосохранение срабатывает ТОЛЬКО если данные были ранее успешно загружены.
  // Это предотвращает затирание вашего сейва пустыми дефолтами при быстром выходе.
  if (_isDataLoaded) {
    _saveData(showSnackBar: false);
  }

  // Очистка ресурсов
  _powerControllers.forEach((_, c) => c.dispose());
  _hoursControllers.forEach((_, c) => c.dispose());
  super.dispose();
}

Future<void> _saveData({
  bool showSnackBar = true,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('selectedProperty', selectedProperty);
    await prefs.setInt('selectedTab', selectedTab);
    await prefs.setString('expandedCategories', jsonEncode(expandedCategories));
    await prefs.setString('deletedDeviceNames', jsonEncode(deletedDeviceNames.toList()));
    await prefs.setString('customDevicePowers', jsonEncode(customDevicePowers));
    await prefs.setString('customDeviceCategories', jsonEncode(customDeviceCategories));
    
    await prefs.setString(
      'deviceCustomConfigs',
      jsonEncode(
        deviceCustomConfigs.map((key, value) => MapEntry(key, value.toJson())),
      ),
    );

    await prefs.setString(
      'customDevices',
      jsonEncode(customDevices.map((e) => e.toJson()).toList()),
    );
    
    await prefs.setString(
      'tabDevices',
      jsonEncode(_serializeTabDevices()),
    );

    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Налаштування збережено'),
          backgroundColor: AppColors.neon,
        ),
      );
    }
  } catch (e) {
    debugPrint("Ошибка при сохранении данных истории: $e");
  }
}
Map<String, List<Map<String, dynamic>>> _serializeTabDevices() {
  // Меняем тип ключа с int на String
  final result = <String, List<Map<String, dynamic>>>{};

  tabDevices.forEach((tab, devices) {
    // Приводим int-ключ вкладки к строке: "0", "1", "2" и т.д.
    result[tab.toString()] = devices.map((device) {
      final copy = Map<String, dynamic>.from(device);

      if (copy['icon'] is IconData) {
        copy['iconCodePoint'] =
            (copy['icon'] as IconData).codePoint;

        copy.remove('icon');
      }

      return copy;
    }).toList();
  });

  return result;
}
Map<int, List<Map<String, dynamic>>> _deserializeTabDevices(
  String jsonString,
) {
  final decoded = Map<String, dynamic>.from(jsonDecode(jsonString));
  final result = <int, List<Map<String, dynamic>>>{};

  decoded.forEach((tabKey, devices) {
    // Явно указываем тип генерируемого картой списка через .map<Map<String, dynamic>>
    result[int.parse(tabKey)] = (devices as List).map<Map<String, dynamic>>((device) {
      final copy = Map<String, dynamic>.from(device as Map);

      if (copy.containsKey('iconCodePoint')) {
        copy['icon'] = IconData(
          copy['iconCodePoint'],
          fontFamily: 'MaterialIcons',
        );
        copy.remove('iconCodePoint');
      }

      return copy;
    }).toList();
  });

  return result;
}
Future<void> _loadData() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final localProperty = prefs.getInt('selectedProperty') ?? 0;
    final localTab = prefs.getInt('selectedTab') ?? 0;

    Map<String, bool> localExpanded = {};
    final expandedString = prefs.getString('expandedCategories');
    if (expandedString != null) {
      localExpanded = Map<String, bool>.from(jsonDecode(expandedString));
    } else {
      localExpanded = Map<String, bool>.from(expandedCategories);
    }

    Set<String> localDeleted = {};
    final deletedString = prefs.getString('deletedDeviceNames');
    if (deletedString != null) {
      localDeleted = Set<String>.from(jsonDecode(deletedString));
    }

    Map<String, double> localPowers = {};
    final powersString = prefs.getString('customDevicePowers');
    if (powersString != null) {
      localPowers = Map<String, double>.from(
        (jsonDecode(powersString)).map((k, v) => MapEntry(k, (v as num).toDouble())),
      );
    }

    Map<String, String> localCategories = {};
    final categoriesString = prefs.getString('customDeviceCategories');
    if (categoriesString != null) {
      localCategories = Map<String, String>.from(jsonDecode(categoriesString));
    }

    Map<String, DeviceConfig> localConfigs = {};
    final configString = prefs.getString('deviceCustomConfigs');
    if (configString != null) {
      final decoded = jsonDecode(configString) as Map<String, dynamic>;
      localConfigs = decoded.map<String, DeviceConfig>(
        (key, value) => MapEntry(key, DeviceConfig.fromJson(Map<String, dynamic>.from(value))),
      );
    } else {
      localConfigs = Map<String, DeviceConfig>.from(deviceCustomConfigs);
    }

    List<DeviceInfo> localCustomDevices = [];
    final customDevicesString = prefs.getString('customDevices');
    if (customDevicesString != null) {
      final decoded = jsonDecode(customDevicesString) as List;
      localCustomDevices = decoded.map((e) => DeviceInfo.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    Map<int, List<Map<String, dynamic>>> localTabDevices = {0: [], 1: [], 2: [], 3: []};
    final tabDevicesString = prefs.getString('tabDevices');
    if (tabDevicesString != null) {
      localTabDevices = _deserializeTabDevices(tabDevicesString);
    }

    if (mounted) {
      setState(() {
        selectedProperty = localProperty;
        selectedTab = localTab;
        expandedCategories = localExpanded;
        deletedDeviceNames = localDeleted;
        customDevicePowers = localPowers;
        customDeviceCategories = localCategories;
        deviceCustomConfigs = localConfigs;
        customDevices = localCustomDevices;
        tabDevices = localTabDevices;
        _isDataLoaded = true; // Данные успешно применились!

        for (var c in _powerControllers.values) {
          c.dispose();
        }
        for (var c in _hoursControllers.values) {
          c.dispose();
        }
        _powerControllers.clear();
        _hoursControllers.clear();
      });
    }
  } catch (e) {
    debugPrint("Ошибка при загрузке данных истории: $e");
  }
}

void _resetToDefaults() {
  resetCounter++;
  deviceCustomConfigs.clear();
  deletedDeviceNames.clear();
  customDevicePowers.clear(); 
  
  for (var c in _powerControllers.values) {
    c.dispose();
  }
  for (var c in _hoursControllers.values) {
    c.dispose();
  }
  _powerControllers.clear();
  _hoursControllers.clear();

  for (final category in DeviceCategories.all) {
    expandedCategories[category] = false; 
    final devices = GlobalDevicesCatalog.byCategory(category);
    for (final d in devices) {
      deviceCustomConfigs[d.name] = DeviceConfig(
        amount: 0,
        hoursPerDay: d.defaultHoursPerDay,
        energyMode: 'balanced', 
      );
    }
  }
}
 

  /// Динамічно перевіряє, чи додано сонячні панелі до конфігурації
  bool get _hasSolarPanels {
    for (var devices in tabDevices.values) {
      for (var device in devices) {
        final title = (device['title'] as String? ?? '').toLowerCase();
        if (title.contains('панел') || title.contains('соняч') || title.contains('solar')) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = selectedProperty == 0 
        ? DeviceCategories.apartmentCategories 
        : DeviceCategories.houseCategories;

    
int totalDevicesCount = 0;

// Подсчёт количества активных устройств
for (final category in currentCategories) {

  final allDevices = [

    ...GlobalDevicesCatalog.byCategoryAndProperty(
      category,
      selectedProperty,
    ),

    ...customDevices.where(
      (d) => d.category == category,
    ),

  ];

  for (final d in allDevices) {

    // пропускаем удалённые приборы
    if (deletedDeviceNames.contains(d.name)) continue;

    final config = deviceCustomConfigs[d.name] ??
        DeviceConfig(
          amount: d.defaultQuantity,
          hoursPerDay: d.defaultHoursPerDay,
        );

    if (config.amount > 0) {
      totalDevicesCount += config.amount;
    }
  }
}
final screenWidth = MediaQuery.of(context).size.width;

final isMobile = screenWidth < 700;
final isTablet = screenWidth >= 700 && screenWidth < 1100;
final isDesktop = screenWidth >= 1100;
  final paddingValue = isMobile ? 16.0 : 24.0;

return Scaffold(
      backgroundColor: brandBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              /// ВИБІР ТИПУ НЕРУХОМОСТІ
              _buildMainCard(
                padding: paddingValue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Вибір типу нерухомості',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Оберіть тип вашої нерухомості для оптимальної конфігурації системи',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
if (isMobile)
  Column(
    children: [
      _buildPropertyCard(
        title: 'Квартира',
        subtitle: 'Багатоквартирний будинок',
        icon: Icons.apartment_outlined,
        isSelected: selectedProperty == 0,
        onTap: () => setState(() => selectedProperty = 0),
      ),
      const SizedBox(height: 16),
      _buildPropertyCard(
        title: 'Приватний будинок',
        subtitle: 'Приватний будинок або котедж',
        icon: Icons.home_outlined,
        isSelected: selectedProperty == 1,
        onTap: () => setState(() => selectedProperty = 1),
      ),
    ],
  )
else
                    Row(
                      children: [
                        Expanded(
                          child: _buildPropertyCard(
                            title: 'Квартира',
                            subtitle: 'Багатоквартирний будинок',
                            icon: Icons.apartment_outlined,
                            isSelected: selectedProperty == 0,
                            onTap: () {
                              setState(() {
                                selectedProperty = 0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildPropertyCard(
                            title: 'Приватний будинок',
                            subtitle: 'Приватний будинок або котедж',
                            icon: Icons.home_outlined,
                            isSelected: selectedProperty == 1,
                            onTap: () {
                              setState(() {
                                selectedProperty = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// МОЄ ОБЛАДНАННЯ
              _buildMainCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Моє обладнання (ESS)',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Підключіть та налаштуйте ваше обладнання ESS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    
                    /// TAB BAR
                    isMobile
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: brandInnerBg,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: List.generate(
                                  tabs.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedTab = index;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20), // Фіксований відступ тексту для скролу
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: selectedTab == index
                                            ? AppColors.neon.withValues(alpha: 0.12)
                                            : Colors.transparent,
                                        border: selectedTab == index
                                            ? Border.all(
                                                color: AppColors.neon.withValues(alpha: 0.3),
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          tabs[index],
                                          style: TextStyle(
                                            color: selectedTab == index ? AppColors.neon : AppColors.textMuted,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: brandInnerBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: List.generate(
                                tabs.length,
                                (index) => Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedTab = index;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: selectedTab == index
                                            ? AppColors.neon.withValues(alpha: 0.12)
                                            : Colors.transparent,
                                        border: selectedTab == index
                                            ? Border.all(
                                                color: AppColors.neon.withValues(alpha: 0.3),
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          tabs[index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: selectedTab == index
                                                ? AppColors.neon
                                                : AppColors.textMuted,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 24),

                    /// ДИНАМІЧНИЙ КОНТЕНТ
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 950;
                        
                        final currentTabDevices = tabDevices[selectedTab] ?? [];
                        List<Widget> currentEquipment = [];

                        if (currentTabDevices.isEmpty) {
                          currentEquipment = [
                            _buildEmptyEquipmentState(),
                          ];
                        } else {
                          for (int i = 0; i < currentTabDevices.length; i++) {
                            final device = currentTabDevices[i];
                            currentEquipment.add(
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildEquipmentTile(
                                  index: i,
                                  device: device, 
                                  icon: device['icon'] as IconData? ?? Icons.electrical_services_outlined,
        title: device['title']?.toString() ?? device['name']?.toString() ?? 'Обладнання',
        subtitle: device['subtitle']?.toString() ?? '',
        useAccentColor: device['useAccentColor'] == true,
        isMobile: isMobile,
                                ),
                              ),
                            );
                          }
                        }

                        if (isDesktop) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildAddEquipmentCard(currentTab: selectedTab),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 7,
                                child: Column(children: currentEquipment),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _buildAddEquipmentCard(currentTab: selectedTab),
                            const SizedBox(height: 20),
                            ...currentEquipment,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ГЛОБАЛЬНИЙ СПИСОК ПРИЛАДІВ
_buildMainCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      
      if (isMobile) ...[
        // ==========================================
        // 📱 ВЕРСТКА ДЛЯ ТЕЛЕФОНУ (Як зараз — Адаптивна з переносами)
        // ==========================================
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Блок заголовка на весь екран смартфона
            SizedBox(
              width: double.infinity, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Глобальний список приладів',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 22, // Зменшений шрифт для мобільного
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Керування побутовими приладами для розрахунку автономності',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Кнопка з короткою назвою для телефону
            _buildGhostButton(
              icon: Icons.refresh_rounded,
              title: 'Скинути', 
              onTap: () {
    setState(() {
      _resetToDefaults();
    });
  },
),
            
            _buildPrimaryButton(
              icon: Icons.add,
              title: 'Додати прилад',
              onTap: () => _showAddDeviceDialog(context),
            ),
            
            // Лічильник із фіксованим розміром (щоб не розтягувався у Wrap)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: brandBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(.05)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  const Icon(Icons.devices_outlined, color: AppColors.neon, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$totalDevicesCount',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ] else ...[
        // ==========================================
        // 💻 ВЕРСТКА ДЛЯ МОНІТОРА (Як було раніше — Строга лінійна структура)
        // ==========================================
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Глобальний список приладів',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 24, // Повнорозмірний заголовок
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Керування побутовими приладами для розрахунку автономності',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            _buildGhostButton(
              icon: Icons.refresh_rounded,
              title: 'Скинути до замовчування', // Повна назва кнопки
              onTap: () {
    setState(() {
      _resetToDefaults();
    });
  },
),
            
            const SizedBox(width: 14), // Старі чіткі відступи монітора
            
            _buildPrimaryButton(
              icon: Icons.add,
              title: 'Додати прилад',
              onTap: () => _showAddDeviceDialog(context),
            ),
            
            const SizedBox(width: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: brandBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.devices_outlined, color: AppColors.neon, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$totalDevicesCount',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],

      const SizedBox(height: 24),

      // Шапка таблиці відображається ТІЛЬКИ на ПК/Моніторах
      if (!isMobile) ...[
        _buildTableHeader(),
        const SizedBox(height: 12),
      ],

      /// Динамічний рендеринг категорій і приборів
      ...currentCategories.map((category) {
        final allDevices = [
          ...GlobalDevicesCatalog.byCategoryAndProperty(category, selectedProperty),
          ...customDevices.where((d) => d.category == category),
        ];
                      // Исключаем из верстки те приборы, чьи имена есть в deletedDeviceNames
                      final devices = allDevices.where((d) => !deletedDeviceNames.contains(d.name)).toList();
                      devices.sort((a, b) {
                        final amtA = deviceCustomConfigs[a.name]?.amount ?? a.defaultQuantity;
                        final amtB = deviceCustomConfigs[b.name]?.amount ?? b.defaultQuantity;
                        
                        if (amtA > 0 && amtB == 0) return -1; // Активный поднимается выше
                        if (amtA == 0 && amtB > 0) return 1;  // Неактивный опускается ниже
                        return 0;
                      });
                      if (devices.isEmpty) return const SizedBox.shrink();

                      final isExpanded = expandedCategories[category] ?? false;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => expandedCategories[category] = !isExpanded),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              child: Row(
                                children: [
                                  Icon(isExpanded ? Icons.expand_more : Icons.chevron_right, color: AppColors.neon, size: 20),
                                  const SizedBox(width: 8),
                                  Text(category, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Spacer(),
                                  Text('${devices.length} прил.', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded)
                            ...devices.map((device) {
                              final config = deviceCustomConfigs[device.name] ??= DeviceConfig(
                                amount: device.defaultQuantity,
                                hoursPerDay: device.defaultHoursPerDay,
                              );
                              return Column(
                                children: [
                                  isMobile
    ? _buildDeviceMobileCard(
        device: device,
        config: config,
      )
    : _buildDeviceRow(
        device: device,
        config: config,
      ),
                                  Divider(color: AppColors.textMuted.withOpacity(0.08), height: 1),
                                ],
                              );
                            }),
                        ],
                      );
                    }),
                    const SizedBox(height: 30),

Divider(),

const SizedBox(height: 20),

Text(
  'Збереження налаштувань',
  style: TextStyle(
    fontSize: isMobile ? 16 : 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

Text(
  'Зберігає всі зміни на сторінці, включаючи обладнання, налаштування пристроїв та користувацькі дані.',
  textAlign: isMobile ? TextAlign.start : TextAlign.center,
  style: TextStyle(
    color: AppColors.textMuted,
    fontSize: isMobile ? 13 : 14,
  ),
),
const SizedBox(height: 20),
Center(
  child: SizedBox(
    width: isMobile ? double.infinity : 220,
    height: 56,
    child: ElevatedButton(
      onPressed: _saveData,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neon,
        foregroundColor: brandBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: const Text(
        'Зберегти',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ),
),
                    

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
  final isMobile = MediaQuery.of(context).size.width < 900;
  
  return Column( // Прибрали const звідси
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Налаштування інфраструктури',
        style: TextStyle(
          color: AppColors.textMain,
          fontSize: isMobile ? 24 : 38, // Тепер це працює без помилок!
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8), // Додали const сюди
      const Text( // Додали const сюди, бо цей текст статичний
        'Налаштуйте вашу енергосистему та обладнання',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 16,
        ),
      ),
    ],
  );
  }

  Widget _buildMainCard({required Widget child, double padding = 24.0}) {
  return Container(
    padding: EdgeInsets.all(padding),
      width: double.infinity,
      
      decoration: BoxDecoration(
        color: brandCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.neon.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPropertyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.neon
                : AppColors.textMuted.withValues(alpha: 0.12),
            width: 1.5,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.neon.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                )
              : null,
          color: brandInnerBg,
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF020D2D),
                border: Border.all(color: AppColors.neon.withValues(alpha: 0.2), width: 1),
              ),
              child: NeonEquipmentIcon(icon: icon, neonColor: AppColors.neon),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.neon,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEquipmentCard({required int currentTab}) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return InkWell(
      onTap: () async {
        // Собираем плоский список названий абсолютно всех уже подключенных устройств
        final List<String> connectedDeviceNames = [];
        for (var devices in tabDevices.values) {
          for (var device in devices) {
            if (device['title'] != null) {
              connectedDeviceNames.add(device['title'] as String);
            }
          }
        }
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectEquipmentPage(
              categoryIndex: currentTab,
              propertyType: selectedProperty,
              hasSolarPanels: _hasSolarPanels,
              connectedDeviceNames: connectedDeviceNames, // Передаем список для блокировки
            ),
          ),
        );
        if (result != null && result is Map<String, dynamic>) {
          // Гарантируем наличие ключа 'title' для обратной совместимости с тайлом
          final title = result['title'] ?? result['name'] ?? '';
          result['title'] = title;
          bool isDuplicate = false;
          for (var devices in tabDevices.values) {
            if (devices.any((d) => (d['title'] ?? d['name']) == title)) {
              isDuplicate = true;
              break;
            }
          }
          if (isDuplicate) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Пристрій "$title" вже додано до конфігурації!'),
                  backgroundColor: Colors.orangeAccent,
                ),
              );
            }
          } else {
            setState(() {
              tabDevices[currentTab]!.add(result);
            });
          }
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: isMobile ? 140 : 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.neon.withValues(alpha: 0.15),
          ),
          color: brandInnerBg,
        ),
        child: Center( // <-- КЛЮЧОВЕ: Прибрали const звідси, бо всередині є динамічний isMobile
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.neon,
                size: isMobile ? 36 : 54, // Тепер це працює легально!
              ),
              SizedBox(height: isMobile ? 10 : 18),
              Text(
                'Підключити обладнання',
                style: TextStyle(
                  color: AppColors.neon,
                  fontSize: isMobile ? 16 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(height: 8), // Поставили const сюди
                const Text( // Поставили const сюди
                  'Натисніть для додавання пристрою',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEquipmentState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 24),
      decoration: BoxDecoration(
        color: brandInnerBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_clear_outlined,
            color: AppColors.textMuted.withValues(alpha: 0.35),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Нічого не підключено',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'У цій категорії конфігурації ще немає активних пристроїв інфраструктури ESS.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 🌟 ТАЙЛ ОБЛАДНАННЯ З ІНТЕГРОВАНОЮ ШЕСТЕРНЕЮ
  Widget _buildEquipmentTile({
    required int index,
    required Map<String, dynamic> device, 
    required IconData icon,
    required String title,
    required String subtitle,
    required bool useAccentColor,
    required bool isMobile,
  }) {
    final baseColor = useAccentColor ? AppColors.neon : AppColors.textMain;
    // ================= 📱 МОБІЛЬНА ВЕРСІЯ =================
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: brandInnerBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Використовуємо гарну неонову іконку навіть на мобільному (але трохи меншу 44x44)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF020D2D),
                    border: Border.all(
                      color: baseColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: NeonEquipmentIcon(
                    icon: icon,
                    neonColor: baseColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: const TextStyle(
                          color: AppColors.textMain, 
                          fontWeight: FontWeight.w700, 
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle.isNotEmpty) 
                        Text(
                          subtitle, 
                          style: const TextStyle(
                            color: AppColors.textMuted, 
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Colors.white10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Підключено', 
                  style: TextStyle(
                    color: AppColors.neon, 
                    fontWeight: FontWeight.w600, 
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    /// ⚙️ РОБОЧА КНОПКА НАЛАШТУВАНЬ ДЛЯ МОБІЛКИ
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted, size: 20),
                      onPressed: () async {
                        final updatedConfig = await ConnectEquipmentPage.openDeviceSetupBottomSheet(
                          context,
                          device,
                          isEditing: true,
                        );

                        if (updatedConfig != null && mounted) {
                          setState(() {
                            final idx = tabDevices[selectedTab]!.indexOf(device);
                            if (idx != -1) {
                              tabDevices[selectedTab]![idx] = updatedConfig;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    /// 🗑️ РОБОЧА КНОПКА ВИДАЛЕННЯ ДЛЯ МОБІЛКИ
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        setState(() {
                          tabDevices[selectedTab]!.removeAt(index);
                        });
                      },
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      );
    }

    // ================= 💻 ДЕСКТОПНА ВЕРСІЯ (МОНІТОР) =================
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brandInnerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textMuted.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF020D2D),
              border: Border.all(
                color: baseColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: NeonEquipmentIcon(
              icon: icon,
              neonColor: baseColor,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Підключено',
            style: TextStyle(
              color: AppColors.neon,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          
          /// ⚙️ ОНОВЛЕНА КНОПКА НАЛАШТУВАНЬ (ШЕСТЕРНЯ)
          IconButton(
  icon: const Icon(
    Icons.settings_outlined,
    color: AppColors.textMuted,
    size: 22,
  ),
  onPressed: () async {
    // 1. Напрямую открываем BottomSheet настроек для этого конкретного устройства
    final updatedConfig = await ConnectEquipmentPage.openDeviceSetupBottomSheet(
      context,
      device, // Передаем данные именно ЭТОГО устройства
      isEditing: true, // Включаем режим редактирования
    );

    // 2. Если пользователь отредактировал параметры и нажал "Зберегти зміни"
    if (updatedConfig != null && mounted) {
      setState(() {
        // Находим, под каким индексом это устройство лежит в текущей вкладке (tabDevices)
        final index = tabDevices[selectedTab]!.indexOf(device);
        if (index != -1) {
          // Обновляем данные устройства новыми значениями из конфигуратора
          tabDevices[selectedTab]![index] = updatedConfig;
        }
      });
    }
  },
),
          
          const SizedBox(width: 10),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                tabDevices[selectedTab]!.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  /// ОБНОВЛЕННАЯ КНОПКА СБРОСА (ПРИНИМАЕТ onTap)
  Widget _buildGhostButton({
    required IconData icon, 
    required String title,
    VoidCallback? onTap, // <-- Добавили параметр клика
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15)),
          color: brandInnerBg,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textMain, size: 18),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  /// ОБНОВЛЕННАЯ ОСНОВНАЯ КНОПКА ДОБАВЛЕНИЯ (ПРИНИМАЕТ onTap)
  Widget _buildPrimaryButton({
    required IconData icon, 
    required String title,
    VoidCallback? onTap, // <-- Добавили параметр клика
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.neon.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.neon.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neon, size: 18),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(color: AppColors.neon, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

Widget _buildTableHeader() {
  return Padding(
    // Добавляем отступ 12 слева и справа, чтобы колонки шапки встали ровно над колонками строк
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: const Row(
      children: [
        // Название прибора оставляем прижатым к левому краю
        Expanded(
          flex: 3, 
          child: Text('Прилад', style: TextStyle(
            color: Color(0xFF7E8AA8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .8,)),
        ),
        
        // Мощность — центрируем, так как инпут под ней центрирован
        Expanded(
          flex: 2, 
          child: Center(
            child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bolt_rounded,
          size: 14,
          color: AppColors.textMuted,
        ),
        SizedBox(width: 6),
        Text(
          'Потужність',
          style: TextStyle(
            color: Color(0xFF7E8AA8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .8,
          ),
        ),
      ],
    ),
  ),
),
        
        // Количество — центрируем, как и кнопки счетчика
        Expanded(
          flex: 2, 
          child: Center(
            child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
  Icons.grid_view_rounded,
  size: 14,
  color: AppColors.textMuted,
),
        SizedBox(width: 6),
        Text(
          'Кількість',
          style: TextStyle(
            color: Color(0xFF7E8AA8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .8,
          ),
        ),
      ],
    ),
  ),
),
        
        // Время использования — центрируем под инпут часов
        Expanded(
          flex: 3, 
          child: Center(
            child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
  Icons.schedule_rounded,
  size: 14,
  color: AppColors.textMuted,
),
        SizedBox(width: 6),
        Text(
          'Час використання',
          style: TextStyle(
            color: Color(0xFF7E8AA8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .8,
          ),
        ),
      ],
    ),
  ),
),
        
        // Режим — центрируем под выпадающий список
        Expanded(
          flex: 2, 
          child: Center(
            child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
  Icons.tune_rounded,
  size: 14,
  color: AppColors.textMuted,
),
        SizedBox(width: 6),
        Text(
          'Режим',
          style: TextStyle(
            color: Color(0xFF7E8AA8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .8,
          ),
        ),
      ],
    ),
  ),
),
        
        // Действие — прижимаем к правому краю, как и кнопки управления
        Expanded(
          flex: 2, 
          child: Align(
  alignment: Alignment.centerRight,
            child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
  Icons.settings_outlined,
  size: 14,
  color: AppColors.textMuted,
),
        SizedBox(width: 6),
        Text(
          'Дія',
          style: TextStyle(
            color: Color(0xFF7E8AA8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .8,
          ),
        ),
      ],
    ),
  ),
),
      ],
    ),
  );
}

 /// ИНТЕРАКТИВНАЯ СТРОКА ТАБЛИЦЫ ПРИБОРОВ
  Widget _buildDeviceRow({
    required DeviceInfo device,
    required DeviceConfig config,
  }) {
    final modeColor = _getModeColor(config.energyMode);
    // Вместо Padding используем AnimatedContainer для плавного включения подсветки
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 8),
padding: const EdgeInsets.symmetric(
  vertical: 16,
  horizontal: 12,
),
      decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(18),

  color: config.amount > 0
    ? const Color(0xFF0E1D3E)
    : const Color(0xFF081224).withOpacity(.35),

  border: Border.all(
  color: config.amount > 0
      ? modeColor.withOpacity(.18)
      : Colors.white.withOpacity(.03),
  width: 1.2,
),

  boxShadow: config.amount > 0
    ? [

        BoxShadow(
          color: modeColor.withOpacity(.12),
          blurRadius: 34,
          spreadRadius: 1,
        ),

        BoxShadow(
          color: modeColor.withOpacity(.05),
          blurRadius: 60,
          spreadRadius: 4,
        ),

      ]
    : [],
),
      child: Row(
        children: [
          // 1. Иконка и название
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
  width: 44,
  height: 44,
  decoration: BoxDecoration(
    color: config.amount > 0
    ? const Color(0xFF0D1A36)
    : const Color(0xFF081224),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
  color: config.amount > 0
      ? modeColor.withOpacity(.18)
      : Colors.white.withOpacity(.03),
  width: 1.2,
),
boxShadow: config.amount > 0
    ? [
        BoxShadow(
          color: modeColor.withOpacity(.12),
          blurRadius: 18,
          spreadRadius: 1,
        ),
      ]
    : [],
  ),
  child: Icon(
  device.icon,
  size: 20,
  color: config.amount > 0
      ? modeColor
      : AppColors.textMuted.withOpacity(.7),
),
),

const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    device.name,
                    style: TextStyle(
                      color: config.amount > 0 ? AppColors.textMain : AppColors.textMuted,
                      fontSize: 15,
                       // Зачеркиваем, если выключен
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
    if (config.amount == 0) ...[
  Expanded(
    flex: 9,
    child: Center(
      child: _buildActivateButton(
        device,
        config,
      ),
    ),
  ),

  Expanded(
  flex: 2,
  child: Align(
    alignment: Alignment.centerRight,
    child: _buildActionButton(
      hoverKey: '${device.name}_delete',
      hoverSet: _hoveredDeleteButtons,
      icon: Icons.delete_outline_rounded,
      color: AppColors.textMuted,
      onTap: () => setState(() {
        deletedDeviceNames.add(device.name);
      }),
    ),
  ),
),
]


else ...[

  /// МОЩНОСТЬ
  Expanded(
    flex: 2,
    child: Center(
      child: SizedBox(
        width: 110,
        height: 48,
        child: TextField(
          controller: _powerControllers.putIfAbsent(
            device.name,
            () => TextEditingController(
              text: (customDevicePowers[device.name] ?? device.typicalPower)
                  .toStringAsFixed(0),
            ),
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 18,
  fontWeight: FontWeight.w700,
  letterSpacing: .3,
          ),
          decoration: InputDecoration(
  isDense: true,

  contentPadding: const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  ),

  filled: true,
  fillColor: brandCard,

  suffixText: 'W',

  suffixStyle: TextStyle(
    color: AppColors.neon.withOpacity(.7),
    fontSize: 13,
    fontWeight: FontWeight.w600,
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),

    borderSide: BorderSide(
      color: Colors.white.withOpacity(.05),
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),

    borderSide: BorderSide(
      color: AppColors.neon.withOpacity(.8),
      width: 1.4,
    ),
  ),
),
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null) {
              setState(() {
                customDevicePowers[device.name] = parsed;
              });
            }
          },
        ),
      ),
    ),
  ),

  /// КОЛИЧЕСТВО
  Expanded(
  flex: 2,
  child: Center(
    child: Container(
      width: 140,
      height: 46,

      decoration: BoxDecoration(
        color: brandCard,

        borderRadius: BorderRadius.circular(30),

        border: Border.all(
          color: AppColors.neon.withOpacity(.12),
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withOpacity(.05),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),

      child: Row(
        children: [

          /// -
          Expanded(
            child: Center(
              child: _buildMiniBtn(
                icon: Icons.remove,
                onTap: config.amount > 0
                    ? () => setState(() => config.amount--)
                    : null,
              ),
            ),
          ),

          /// число
          Container(
            width: 40,
            alignment: Alignment.center,

            child: Text(
              '${config.amount}',
              style: TextStyle(
                color: AppColors.neon,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          /// +
          Expanded(
            child: Center(
              child: _buildMiniBtn(
                icon: Icons.add,
                onTap: () => setState(() => config.amount++),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
    

        

  /// ЧАСЫ
  Expanded(
    flex: 3,
    child: Center(
      child: SizedBox(
        width: 110,
        height: 48,
        child: TextFormField(
          controller: _hoursControllers.putIfAbsent(
  device.name,
  () => TextEditingController(
    text: config.hoursPerDay.toString(),
  ),
),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 17,
  fontWeight: FontWeight.w700,
  letterSpacing: .3,
),
          decoration: InputDecoration(
            filled: true,
            fillColor: brandCard,
            suffixText: 'год',

suffixStyle: TextStyle(
  color: AppColors.neon.withOpacity(.7),
  fontSize: 13,
  fontWeight: FontWeight.w600,
),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
  color: Colors.white.withOpacity(.06),
),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
  color: AppColors.neon.withOpacity(.8),
  width: 1.3,
),
            ),
          ),
          onChanged: (value) {
  final parsed =
      double.tryParse(value.replaceAll(',', '.'));

  if (parsed != null) {
    final corrected = parsed.clamp(0.0, 24.0);

    setState(() {
      config.hoursPerDay = corrected;
    });

    if (parsed != corrected) {
      _hoursControllers[device.name]!.text =
          corrected.toString();

      _hoursControllers[device.name]!.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: _hoursControllers[device.name]!.text.length,
        ),
      );
    }
  }
},

  onEditingComplete: () {
    final corrected =
        config.hoursPerDay.clamp(0.0, 24.0);

    _hoursControllers[device.name]!.text =
        corrected.toString();

    setState(() {
      config.hoursPerDay = corrected;
    });
  },
),
      ),
    ),
  ),

  /// РЕЖИМ
  Expanded(
    flex: 2,
    child: Center(
      child: Container(
        height: 48,
padding: const EdgeInsets.symmetric(horizontal: 14),
decoration: BoxDecoration(
  color: brandCard,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: Colors.white.withOpacity(.06),
  ),
),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: config.energyMode,
            dropdownColor: brandCard,
            icon: Icon(
  Icons.keyboard_arrow_down_rounded,
  size: 20,
  color: AppColors.neon.withOpacity(.85),
),
           style: const TextStyle(
  color: AppColors.textMain,
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: .2,
),
            items: [
  DropdownMenuItem(
    value: 'basic',
    child: Row(
      children: [
        Icon(
          Icons.battery_2_bar_rounded,
          size: 18,
          color: Colors.green,
        ),
        SizedBox(width: 8),
        Text('Базовий'),
      ],
    ),
  ),

  DropdownMenuItem(
    value: 'balanced',
    child: Row(
      children: [
        Icon(
          Icons.battery_5_bar_rounded,
          size: 18,
          color: Colors.lightBlue,
        ),
        SizedBox(width: 8),
        Text('Збалансований'),
      ],
    ),
  ),

  DropdownMenuItem(
    value: 'comfort',
    child: Row(
      children: [
        Icon(
          Icons.battery_full_rounded,
          size: 18,
          color: Colors.orange,
        ),
        SizedBox(width: 8),
        Text('Комфорт'),
      ],
    ),
  ),

  DropdownMenuItem(
    value: 'custom',
    child: Row(
      children: [
        Icon(
          Icons.tune_rounded,
          size: 18,
          color: AppColors.neon,
        ),
        SizedBox(width: 8),
        Text('Власний'),
      ],
    ),
  ),
],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  config.energyMode = value;
                });
              }
            },
          ),
        ),
      ),
    ),
  ),

  /// КНОПКИ
  Expanded(
    flex: 2,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
  hoverKey: '${device.name}_power',
  hoverSet: _hoveredPowerButtons,
  icon: Icons.power_settings_new_rounded,
  color: Colors.redAccent,
  onTap: () => setState(() {
    config.amount = 0;
  }),
),

const SizedBox(width: 10),

_buildActionButton(
  hoverKey: '${device.name}_delete',
  hoverSet: _hoveredDeleteButtons,
  icon: Icons.delete_outline_rounded,
  color: AppColors.textMuted,
  onTap: () => setState(() {
    deletedDeviceNames.add(device.name);
  }),
),
   ],
    ),
  ),

] // конец else

        ], // конец children
      ),
    );
  }

Widget _buildActivateButton(
  DeviceInfo device,
  DeviceConfig config,
) {
  final isHovered =
      _hoveredActivateButtons.contains(device.name);

  return MouseRegion(
    cursor: SystemMouseCursors.click,

    onEnter: (_) {
      setState(() {
        _hoveredActivateButtons.add(device.name);
      });
    },

    onExit: (_) {
      setState(() {
        _hoveredActivateButtons.remove(device.name);
      });
    },

    child: GestureDetector(
      onTap: () => setState(() {
        config.amount =
            device.defaultQuantity > 0
                ? device.defaultQuantity
                : 1;
      }),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: brandCard,

          borderRadius: BorderRadius.circular(30),

          border: Border.all(
            color: isHovered
                ? AppColors.neon.withOpacity(.55)
                : AppColors.neon.withOpacity(.18),
            width: 1.2,
          ),

          boxShadow: [
            BoxShadow(
              color: AppColors.neon.withOpacity(
                isHovered ? .22 : .07,
              ),
              blurRadius: isHovered ? 28 : 16,
              spreadRadius: isHovered ? 2 : 0,
            ),
          ],
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isHovered ? 1.12 : 1,
              child: Icon(
                Icons.power_settings_new_rounded,
                color: AppColors.neon,
                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            const Text(
              'Активувати',
              style: TextStyle(
                color: AppColors.neon,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: .3,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
          
          
  

  /// Маленькая кнопка для счетчиков плюса и минуса
 Widget _buildMiniBtn({
  required IconData icon,
  VoidCallback? onTap,
}) {
  final enabled = onTap != null;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(100),

    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),

      width: 34,
      height: 34,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: brandCard,

        border: Border.all(
          color: enabled
              ? AppColors.neon.withOpacity(.12)
              : Colors.white.withOpacity(.04),
        ),

        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.neon.withOpacity(.06),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),

      child: Icon(
        icon,
        size: 16,
        color: enabled
            ? AppColors.textMain
            : AppColors.textMuted.withOpacity(.3),
      ),
    ),
  );
}
Widget _buildActionButton({
  required String hoverKey,
  required Set<String> hoverSet,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  final isHovered = hoverSet.contains(hoverKey);

  return MouseRegion(
    cursor: SystemMouseCursors.click,

    onEnter: (_) => setState(() {
      hoverSet.add(hoverKey);
    }),

    onExit: (_) => setState(() {
      hoverSet.remove(hoverKey);
    }),

    child: GestureDetector(
      onTap: onTap,

      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isHovered ? 1.05 : 1,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: brandCard,

            shape: BoxShape.circle,

            border: Border.all(
              color: color.withOpacity(
                isHovered ? .45 : .15,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: color.withOpacity(
                  isHovered ? .25 : .08,
                ),
                blurRadius: isHovered ? 28 : 16,
                spreadRadius: isHovered ? 2 : 0,
              ),
            ],
          ),

          child: Icon(
            icon,
            size: isHovered ? 19 : 18,
            color: color,
          ),
        ),
      ),
    ),
  );
}
Color _getModeColor(String mode) {
  switch (mode) {
    case 'basic':
      return const Color(0xFFFF4D4F);

    case 'balanced':
      return const Color(0xFF4DB7FF);

    case 'comfort':
      return const Color(0xFFFFB84D);

    case 'custom':
      return AppColors.neon;

    default:
      return AppColors.neon;
  }
}
InputDecoration _dialogFieldDecoration({
  required String hint,
  required IconData icon,
  Color iconColor = AppColors.textMuted,
  String? suffix,

}) {
  return InputDecoration(
    hintText: hint,

    hintStyle: TextStyle(
      color: AppColors.textMuted.withOpacity(.7),
      fontSize: 15,
    ),

    prefixIcon: Icon(
      icon,
      color: iconColor,
      size: 20,
    ),
suffixText: suffix,

suffixStyle: const TextStyle(
  color: AppColors.neon,
  fontSize: 14,
  fontWeight: FontWeight.w600,
),
    filled: true,
    fillColor: brandCard,

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(.06),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: AppColors.neon,
        width: 1.2,
      ),
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );
}
  /// Диалоговое окно добавления кастомного прибора
  void _showAddDeviceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final powerController = TextEditingController();
    final hoursController = TextEditingController(text: '2.0');
    String selectedCategory = 'Освітлення';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A153A), // brandCard
          title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [

    Row(
      children: [
        Icon(
          Icons.add_circle_outline_rounded,
          color: AppColors.neon,
          size: 24,
        ),

        SizedBox(width: 10),

        Text(
          'Власний пристрій',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),

    SizedBox(height: 8),

    Text(
      'Створіть новий електроприлад для Nuvit',
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
    ),
  ],
),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textMain),
                decoration: _dialogFieldDecoration(
  hint: 'Назва приладу',
  icon: Icons.devices_rounded,
),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: powerController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textMain),
                decoration: _dialogFieldDecoration(
  hint: 'Потужність',
  icon: Icons.bolt_rounded,
  iconColor: Colors.amber,
  suffix: 'W',
),
              ),
              const SizedBox(height: 14),

DropdownButtonFormField<String>(
  value: selectedCategory,

  dropdownColor: brandCard,

  style: const TextStyle(
    color: AppColors.textMain,
  ),

  decoration: _dialogFieldDecoration(
    hint: 'Категорія',
    icon: Icons.category_outlined,
  ),

  items: const [

    DropdownMenuItem(
      value: 'Освітлення',
      child: Text('Освітлення'),
    ),

    DropdownMenuItem(
      value: 'Кухня',
      child: Text('Кухня'),
    ),

    DropdownMenuItem(
      value: 'Клімат',
      child: Text('Клімат'),
    ),

    DropdownMenuItem(
      value: 'Прання',
      child: Text('Прання'),
    ),

    DropdownMenuItem(
      value: 'Мультимедіа',
      child: Text('Мультимедіа'),
    ),

    DropdownMenuItem(
  value: "Комп'ютери",
  child: Text("Комп'ютери"),
),

    DropdownMenuItem(
      value: 'Інше',
      child: Text('Інше'),
    ),
  ],

  onChanged: (value) {
    if (value != null) {
      selectedCategory = value;
    }
  },
),
const SizedBox(height: 14),
              TextField(
                controller: hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textMain),
                decoration: _dialogFieldDecoration(
  hint: 'Годин на добу',
  icon: Icons.schedule_rounded,
  iconColor: AppColors.neon,
  suffix: 'год',
),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Скасувати', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
  final name = nameController.text.trim();
  final power = double.tryParse(powerController.text) ?? 0.0;
  final hours = double.tryParse(hoursController.text) ?? 1.0;

  if (name.isNotEmpty && power > 0) {
    setState(() {

  customDevices.add(
    DeviceInfo(
      name: name,
      category: selectedCategory,

      icon: Icons.devices_other_rounded,

      typicalPower: power,
      maxPower: power,
      peakPower: power,

      defaultQuantity: 1,
      defaultHoursPerDay: hours,
    ),
  );

  deviceCustomConfigs[name] = DeviceConfig(
    amount: 1,
    hoursPerDay: hours,
  );

  customDeviceCategories[name] = selectedCategory;

});
                  Navigator.pop(context);
                }
              },
              child: const Text('Додати'),
            ),
          ],
        );
      },
    );
  }
   
Widget _buildDeviceMobileCard({
    required DeviceInfo device,
    required DeviceConfig config,
  }) {
    final modeColor = _getModeColor(config.energyMode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.amount > 0
            ? const Color(0xFF0E1D3E)
            : const Color(0xFF081224).withOpacity(.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.amount > 0
              ? modeColor.withOpacity(.18)
              : Colors.white.withOpacity(.03),
          width: 1.2,
        ),
        boxShadow: config.amount > 0
            ? [
                BoxShadow(
                  color: modeColor.withOpacity(.12),
                  blurRadius: 30,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: modeColor.withOpacity(.05),
                  blurRadius: 60,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 1. Иконка и название
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: config.amount > 0
                      ? const Color(0xFF0D1A36)
                      : const Color(0xFF081224),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: config.amount > 0
                        ? modeColor.withOpacity(.18)
                        : Colors.white.withOpacity(.03),
                    width: 1.2,
                  ),
                  boxShadow: config.amount > 0
                      ? [
                          BoxShadow(
                            color: modeColor.withOpacity(.12),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  device.icon,
                  size: 20,
                  color: config.amount > 0
                      ? modeColor
                      : AppColors.textMuted.withOpacity(.7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  device.name,
                  style: TextStyle(
                    color: config.amount > 0
                        ? AppColors.textMain
                        : AppColors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (config.amount == 0) ...[
            const SizedBox(height: 18),
            /// Состояние ВЫКЛЮЧЕНО (Активация и удаление)
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: _buildActivateButton(
                      device,
                      config,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  hoverKey: '${device.name}_delete',
                  hoverSet: _hoveredDeleteButtons,
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.textMuted,
                  onTap: () => setState(() {
                    deletedDeviceNames.add(device.name);
                  }),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 18),

            /// МОЩНОСТЬ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 18,
                      color: AppColors.neon,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Потужність',
                      style: TextStyle(
                        color: AppColors.textMuted.withOpacity(.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 110,
                  height: 48,
                  child: TextField(
                    controller: _powerControllers.putIfAbsent(
                      device.name,
                      () => TextEditingController(
                        text: (customDevicePowers[device.name] ?? device.typicalPower)
                            .toStringAsFixed(0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .3,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: brandCard,
                      suffixText: 'W',
                      suffixStyle: TextStyle(
                        color: AppColors.neon.withOpacity(.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.neon.withOpacity(.8),
                          width: 1.4,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        setState(() {
                          customDevicePowers[device.name] = parsed;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            /// КОЛИЧЕСТВО
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Кількість',
                  style: TextStyle(
                    color: AppColors.textMuted.withOpacity(.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: 140,
                  height: 46,
                  decoration: BoxDecoration(
                    color: brandCard,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.neon.withOpacity(.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neon.withOpacity(.05),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: _buildMiniBtn(
                            icon: Icons.remove,
                            onTap: config.amount > 0
                                ? () => setState(() => config.amount--)
                                : null,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '${config.amount}',
                          style: const TextStyle(
                            color: AppColors.neon,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: _buildMiniBtn(
                            icon: Icons.add,
                            onTap: () => setState(() => config.amount++),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            /// ГОДИННИК
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Годин на добу',
                  style: TextStyle(
                    color: AppColors.textMuted.withOpacity(.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 48,
                  child: TextFormField(
                    controller: _hoursControllers.putIfAbsent(
                      device.name,
                      () => TextEditingController(
                        text: config.hoursPerDay.toString(),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .3,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: brandCard,
                      suffixText: 'год',
                      suffixStyle: TextStyle(
                        color: AppColors.neon.withOpacity(.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(.06),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.neon.withOpacity(.8),
                          width: 1.3,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed =
                          double.tryParse(value.replaceAll(',', '.'));
                      if (parsed != null) {
                        final corrected = parsed.clamp(0.0, 24.0);
                        setState(() {
                          config.hoursPerDay = corrected;
                        });
                        if (parsed != corrected) {
                          _hoursControllers[device.name]!.text =
                              corrected.toString();
                          _hoursControllers[device.name]!.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                              offset: _hoursControllers[device.name]!.text.length,
                            ),
                          );
                        }
                      }
                    },
                    onEditingComplete: () {
                      final corrected =
                          config.hoursPerDay.clamp(0.0, 24.0);
                      _hoursControllers[device.name]!.text =
                          corrected.toString();
                      setState(() {
                        config.hoursPerDay = corrected;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            /// РЕЖИМ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Режим',
                  style: TextStyle(
                    color: AppColors.textMuted.withOpacity(.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: brandCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(.06),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: config.energyMode,
                      dropdownColor: brandCard,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.neon.withOpacity(.85),
                      ),
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .2,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'basic',
                          child: Row(
                            children: [
                              Icon(Icons.battery_2_bar_rounded, size: 18, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Базовий'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'balanced',
                          child: Row(
                            children: [
                              Icon(Icons.battery_5_bar_rounded, size: 18, color: Colors.lightBlue),
                              SizedBox(width: 8),
                              Text('Збалансований'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'comfort',
                          child: Row(
                            children: [
                              Icon(Icons.battery_full_rounded, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Комфорт'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'custom',
                          child: Row(
                            children: [
                              Icon(Icons.tune_rounded, size: 18, color: AppColors.neon),
                              SizedBox(width: 8),
                              Text('Власний'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            config.energyMode = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            /// КНОПКИ (Вимкнути / Видалити)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  hoverKey: '${device.name}_power',
                  hoverSet: _hoveredPowerButtons,
                  icon: Icons.power_settings_new_rounded,
                  color: Colors.redAccent,
                  onTap: () => setState(() {
                    config.amount = 0;
                  }),
                ),
                const SizedBox(width: 10),
                _buildActionButton(
                  hoverKey: '${device.name}_delete',
                  hoverSet: _hoveredDeleteButtons,
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.textMuted,
                  onTap: () => setState(() {
                    deletedDeviceNames.add(device.name);
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
}