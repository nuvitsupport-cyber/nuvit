// lib/screens/load_management_page.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class LoadManagementPage extends StatelessWidget {
  final String selectedMode;
  final String housingType;
  final Map<String, String> modeHints;
  final Function(String) onModeChanged;
  final Function(String) onShowDetailsModal;

  const LoadManagementPage({
    super.key,
    required this.selectedMode,
    required this.housingType,
    required this.modeHints,
    required this.onModeChanged,
    required this.onShowDetailsModal,
  });

  // Генерація рядка для зеленої підказки (Tooltip)
  String _getProfileDevicesString(String modeName) {
    if (modeName == 'Свої налаштування') return 'Повністю ручний вибір споживачів.';
    
    final bool isHouse = housingType == 'Будинок';
    final Map<String, int> targetDeviceMap = isHouse ? AppConstants.houseDevices : AppConstants.apartmentDevices;
    final Map<String, Map<String, bool>> targetProfiles = isHouse ? AppConstants.houseProfiles : AppConstants.apartmentProfiles;
    
    final Map<String, bool> presetMap = targetProfiles[modeName] ?? {};
    List<String> enabledNames = [];

    targetDeviceMap.forEach((name, watts) {
      if (presetMap[name] == true) {
        enabledNames.add('• $name ($watts Вт)');
      }
    });

    return enabledNames.isEmpty 
        ? 'Немає активних приладів' 
        : 'Включені прилади:\n${enabledNames.join('\n')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'КЕРУВАННЯ НАВАНТАЖЕННЯМ',
          style: TextStyle(color: AppColors.neon, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Оберіть пресет енергоспоживання:',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: modeHints.keys.map((mode) {
                    final bool isSelected = selectedMode == mode;
                    final String hintText = modeHints[mode] ?? '';
                    
                    return ListTile(
                      leading: Radio<String>(
                        activeColor: AppColors.neon,
                        value: mode,
                        groupValue: selectedMode,
                        onChanged: (val) {
                          if (val != null) {
                            onModeChanged(val);
                            Navigator.pop(context); // Повертаємось на головну після вибору
                          }
                        },
                      ),
                      title: Text(
                        mode,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.neon : Colors.white,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          hintText,
                          style: TextStyle(
                            fontSize: 12, 
                            color: isSelected ? Colors.white70 : Colors.grey[500],
                          ),
                        ),
                      ),
                      trailing: Tooltip(
                        decoration: BoxDecoration(
                          color: const Color(0xFF39D200), // Твій зелений колір
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        message: _getProfileDevicesString(mode), 
                        triggerMode: TooltipTriggerMode.tap, 
                        child: GestureDetector(
                          onLongPress: () {
                            onShowDetailsModal(mode); // Твій BottomSheet по довгому тапу
                          },
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.neon,
                            size: 24,
                          ),
                        ),
                      ),
                      onTap: () {
                        onModeChanged(mode);
                        Navigator.pop(context); // Повертаємось на головну після вибору
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '💡 Підказка: Короткий тап по іконці інформації покаже швидкий список приладів у зеленому вікні, а довгий тап відкриє повну панель розрахунку потужності.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}