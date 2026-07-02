import 'package:flutter/material.dart';
import 'package:nuvit/utils/app_colors.dart';

class ConsumptionItem {
  final String name;
  final double energyKwh;
  final IconData icon;
  final String deviceMode; // Додано для синхронізації кольорів із пресетами

  const ConsumptionItem({
    required this.name,
    required this.energyKwh,
    required this.icon,
    this.deviceMode = 'custom',
  });
}

class ConsumptionBreakdownCard extends StatelessWidget {
  final List<ConsumptionItem> items;

  const ConsumptionBreakdownCard({
    super.key,
    required this.items,
  });

  // Уніфікована палітра кольорів відповідно до інших віджетів
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    // Фільтруємо пристрої із нульовим споживанням
    final activeItems = items.where((item) => item.energyKwh > 0).toList();

    final totalConsumption = activeItems.fold<double>(
      0,
      (sum, item) => sum + item.energyKwh,
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF051033), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(.03),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header (Завжди залишається на місці)
          Row(
            children: [
              const Icon(
                Icons.pie_chart_rounded,
                color: AppColors.neon,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Структура споживання',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Якщо пристроїв немає — показуємо заглушку, інакше — контент
          activeItems.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    /// Total Info Block
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A153A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(.02),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Colors.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Загальне споживання активних пристроїв',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            '${totalConsumption.toStringAsFixed(1)} кВт·год',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Devices List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeItems.length,
                      itemBuilder: (context, index) {
                        final item = activeItems[index];
                        final percent = totalConsumption == 0 
                            ? 0.0 
                            : item.energyKwh / totalConsumption;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildRow(item, percent),
                        );
                      },
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  /// 🌟 Нова кастомна заглушка (Естетичний Empty State)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Прозора іконка з легким світінням
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.power_off_rounded, 
                color: AppColors.textMuted.withOpacity(0.4), 
                size: 42,
              ),
            ),
            const SizedBox(height: 16),
            
            // Головний текст
            const Text(
              'Немає активних споживачів',
              style: TextStyle(
                color: Colors.white70, 
                fontSize: 14, 
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            
            // Підказка для користувача
            Text(
              'Увімкніть прилади за допомогою тумблерів живлення у блоці пресетів вище, щоб розрахувати структуру витрат енергії.',
              style: TextStyle(
                color: AppColors.textMuted.withOpacity(0.5), 
                fontSize: 12,
                height: 1.35,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(ConsumptionItem item, double percent) {
    final accentColor = _getPresetColor(item.deviceMode);

    return Column(
      children: [
        Row(
          children: [
            /// Іконка пристрою з відповідним фоном пресета
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                color: accentColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            /// Назва та абсолютне значення
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.energyKwh.toStringAsFixed(2)} кВт·год',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),

            /// Відсоткова частка
            Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        /// Оновлений Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(.04),
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
      ],
    );
  }

  
}