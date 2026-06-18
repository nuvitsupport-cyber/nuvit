// lib/widgets/device_list_card.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class DeviceListCard extends StatefulWidget {
  final Map<String, bool> activeDevices;
  final Map<String, int> deviceWatts;
  final Function(String, bool) onDeviceToggle;
  final Function(String, int) onCustomDeviceAdded; 
  final VoidCallback? onClearAllDevices; // Новий колбек для швидкого скидання всіх чекбоксів

  const DeviceListCard({
    super.key,
    required this.activeDevices,
    required this.deviceWatts,
    required this.onDeviceToggle,
    required this.onCustomDeviceAdded,
    this.onClearAllDevices,
  });

  @override
  State<DeviceListCard> createState() => _DeviceListCardState();
}

class _DeviceListCardState extends State<DeviceListCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wattsController = TextEditingController();
  String _searchQuery = ''; // Для фільтрації пошуку

  final Map<String, bool> _isCategoryExpanded = {
    'Критичне навантаження': false,
    'Загальнопобутові': false,
    'Важка техніка': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _wattsController.dispose();
    super.dispose();
  }

  void _submitNewDevice() {
    final String name = _nameController.text.trim();
    final int? watts = int.tryParse(_wattsController.text.trim());

    if (name.isEmpty || watts == null || watts <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Введіть коректну назву та потужність приладу!'),
          backgroundColor: AppConstants.colorCritical,
        ),
      );
      return;
    }

    widget.onCustomDeviceAdded(name, watts);

    _nameController.clear();
    _wattsController.clear();
    FocusScope.of(context).unfocus();
  }

  String _getCategoryForDevice(String name, int watts) {
    if (name.contains('Роутер') || name.contains('Освітлення') || name.contains('Заряд') || name.contains('насоси')) {
      return 'Критичне навантаження';
    } else if (watts >= 1200 || name.contains('котел') || name.contains('плита')) {
      return 'Важка техніка';
    }
    return 'Загальнопобутові';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Групуємо прилади за категоріями з урахуванням пошукового фільтру
    Map<String, List<String>> categorizedDevices = {
      'Критичне навантаження': [],
      'Загальнопобутові': [],
      'Важка техніка': [],
    };

    // Також порахуємо сумарні Вати для кожної категорії окремо (Тільки для увімкнених!)
    Map<String, int> categoryActiveWatts = {
      'Критичне навантаження': 0,
      'Загальнопобутові': 0,
      'Важка техніка': 0,
    };

    for (var deviceName in widget.activeDevices.keys) {
      final watts = widget.deviceWatts[deviceName] ?? 0;
      final isEnabled = widget.activeDevices[deviceName] ?? false;
      final category = _getCategoryForDevice(deviceName, watts);

      if (isEnabled) {
        categoryActiveWatts[category] = (categoryActiveWatts[category] ?? 0) + watts;
      }

      // Фільтрація через пошук
      if (_searchQuery.isEmpty || deviceName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        if (categorizedDevices.containsKey(category)) {
          categorizedDevices[category]!.add(deviceName);
        } else {
          categorizedDevices['Загальнопобутові']!.add(deviceName);
        }
      }
    }

    Map<String, IconData> categoryIcons = {
      'Критичне навантаження': Icons.gpp_good,
      'Загальнопобутові': Icons.bolt,
      'Важка техніка': Icons.gavel,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 ФІШКА 1: Панель швидких дій верхнього рівня + Пошук
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'СПИСОК ВАРІАНТІВ НАВАНТАЖЕННЯ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.1),
                ),
                if (widget.onClearAllDevices != null)
                  TextButton.icon(
                    onPressed: widget.onClearAllDevices,
                    icon: const Icon(Icons.power_settings_new, size: 16, color: Colors.redAccent),
                    label: const Text('Вимкнути все', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            
            // 🔥 ФІШКА 2: Компактне поле пошуку пристроїв
            TextField(
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Швидкий пошук приладу за назвою...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                fillColor: Colors.white.withValues(alpha: 0.03),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 15),

            // 2. Рендеринг категорій
            ...categorizedDevices.entries.map((categoryEntry) {
              final categoryName = categoryEntry.key;
              final deviceList = categoryEntry.value;

              if (deviceList.isEmpty && _searchQuery.isNotEmpty) return const SizedBox.shrink();
              if (deviceList.isEmpty) return const SizedBox.shrink();

              int activeCount = deviceList.where((name) => widget.activeDevices[name] == true).length;
              bool hasActiveDevices = activeCount > 0;
              bool isExpanded = _isCategoryExpanded[categoryName] ?? false;
              int activeWatts = categoryActiveWatts[categoryName] ?? 0;

              Color headerColor = hasActiveDevices ? AppColors.neon : Colors.white60;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isCategoryExpanded[categoryName] = !isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(categoryIcons[categoryName], color: headerColor, size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    categoryName.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 13, 
                                      color: headerColor,
                                      shadows: hasActiveDevices ? [
                                        Shadow(color: AppColors.neon.withValues(alpha: 0.5), blurRadius: 8)
                                      ] : null,
                                    ),
                                  ),
                                ),
                                // 🔥 ФІШКА 3: Показ сумарних активних Ватів поруч із назвою категорії
                                if (hasActiveDevices)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '($activeWatts Вт)',
                                      style: TextStyle(color: AppColors.neon.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: hasActiveDevices ? AppColors.neon.withValues(alpha: 0.15) : Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                  border: hasActiveDevices ? Border.all(color: AppColors.neon.withValues(alpha: 0.3), width: 1) : null,
                                ),
                                child: Text(
                                  '$activeCount / ${deviceList.length}',
                                  style: TextStyle(
                                    fontSize: 11, 
                                    color: hasActiveDevices ? AppColors.neon : Colors.grey, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: headerColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  
                  if (isExpanded) ...[
                    ...deviceList.map((deviceName) {
                      final watts = widget.deviceWatts[deviceName] ?? 0;
                      final isEnabled = widget.activeDevices[deviceName] ?? false;

                      return CheckboxListTile(
                        activeColor: AppColors.neon,
                        checkColor: Colors.black,
                        title: Text(
                          deviceName, 
                          style: TextStyle(
                            fontSize: 14,
                            color: isEnabled ? Colors.white : Colors.white70,
                          ),
                        ),
                        subtitle: Text('$watts W', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        value: isEnabled,
                        onChanged: (bool? val) {
                          widget.onDeviceToggle(deviceName, val ?? false);
                        },
                      );
                    }),
                  ],
                  const SizedBox(height: 10),
                ],
              );
            }),

            const Divider(color: Colors.white24, height: 20),

            // 3. БЛОК: Інший прилад (якого немає в списку)
            Row(
              children: [
                const Icon(Icons.add_box_outlined, color: AppColors.neon, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Інший прилад (якого немає в списку)',
                  style: TextStyle(
                    color: AppColors.neon,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Назва (напр. Акваріум)',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _wattsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Потужність',
                      suffixText: 'Вт',
                      suffixStyle: TextStyle(color: AppColors.neon),
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.neon, size: 32),
                  onPressed: _submitNewDevice,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}