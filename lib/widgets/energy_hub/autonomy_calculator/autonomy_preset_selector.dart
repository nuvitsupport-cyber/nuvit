// lib/widgets/energy_hub/autonomy_calculator/widgets/autonomy_preset_selector.dart

import 'package:flutter/material.dart';
import 'package:nuvit/utils/app_colors.dart';

class AutonomyPresetSelector extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onChanged;

  const AutonomyPresetSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  // Брендовая палитра для соблюдения многослойности UI
  static const Color brandBg = Color(0xFF020D2D);       
  static const Color brandCard = Color(0xFF0A153A);     
  static const Color brandInnerBg = Color(0xFF051033);  

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    // Лаконичные описания под каждым пресетом
    final presets = [
      (
        id: 'basic',
        title: 'Базовий',
        description: 'Тільки найнеобхідніші пристрої',
        icon: Icons.energy_savings_leaf,
        color: Color(0x22FF4554),
      ),
      (
        id: 'balanced',
        title: 'Збалансований',
        description: 'Оптимальне щоденне навантаження',
        icon: Icons.balance_rounded,
        color: Color(0xFF0052FF),
      ),
      (
        id: 'comfort',
        title: 'Комфорт',
        description: 'Максимальне використання техніки',
        icon: Icons.offline_bolt,
        color: Color(0xFFFF7A00),
      ),
      (
        id: 'custom',
        title: 'Власний',
        description: 'Ручне налаштування списку',
        icon: Icons.tune_rounded,
        color: AppColors.neon,
      ),
    ];

    Widget presetsContent;

    if (isMobile) {
      // Мобильная версия: Горизонтальный скролл (карусель)
      presetsContent = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        // Убрали clipBehavior: Clip.none, теперь карточки не будут вылезать за края контейнера!
        child: Padding(
          // Добавили вертикальный отступ, чтобы свечение активной карточки не обрезалось
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: presets.asMap().entries.map((entry) {
              final index = entry.key;
              final preset = entry.value;
              final isLast = index == presets.length - 1;

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 12),
                child: SizedBox(
                  width: 250, // Фиксированная ширина
                  child: _buildPresetCard(
                    preset.id,
                    preset.title,
                    preset.description,
                    preset.icon,
                    preset.color,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    } else if (isTablet) {
      presetsContent = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: presets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
        ),
        itemBuilder: (context, index) {
          final preset = presets[index];
          return _buildPresetCard(
            preset.id,
            preset.title,
            preset.description,
            preset.icon,
            preset.color,
          );
        },
      );
    } else {
      presetsContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: presets.map((preset) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: _buildPresetCard(
                preset.id,
                preset.title,
                preset.description,
                preset.icon,
                preset.color,
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Общее описание-инструкция блока пресетов
        Text(
          'Виберіть пресет автономності',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Оберіть готовий шаблон або налаштуйте список пристроїв вручну',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        
        const SizedBox(height: 12), 
        
        /// Сетка или список карточек пресетов
        presetsContent,
      ],
    );
  }

  Widget _buildPresetCard(
    String id,
    String title,
    String description,
    IconData icon,
    Color accentColor,
  ) {
    final isSelected = selectedMode == id;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(.12)
              : brandCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? accentColor
                : Colors.white.withOpacity(.03),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(.15),
                    blurRadius: 14,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Иконка пресета
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            /// Текстовый блок пресета
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textMain
                          : AppColors.textMain.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}