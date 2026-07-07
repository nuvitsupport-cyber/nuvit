import 'package:flutter/material.dart';

import '../../models/outage/outage_insight.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import '../../utils/outage/outage_icons.dart';

class OutageAiCard extends StatelessWidget {
  final List<OutageInsight> insights;

  const OutageAiCard({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    // Если инсайтов нет, скрываем карточку, чтобы не занимать место
    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(OutageConstants.cardPadding),
      decoration: BoxDecoration(
        color: OutageColors.aiCardBackground,
        borderRadius: BorderRadius.circular(OutageConstants.cardRadius),
        border: Border.all(
          color: OutageColors.aiCardBorder,
          width: OutageConstants.borderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // 1. Иконка AI-ассистента
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: OutageColors.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              OutageIcons.ai, // В outage_icons.dart это Icons.auto_awesome_rounded
              color: OutageColors.accent,
              size: OutageConstants.largeIcon,
            ),
          ),
          
          const SizedBox(width: OutageConstants.itemSpacing),

          // 2. Блок с заголовком и списком рекомендаций
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // Заголовок
                const Text(
                  'AI Аналіз',
                  style: TextStyle(
                    color: OutageColors.accent,
                    fontSize: OutageConstants.subtitleSize,
                    fontWeight: OutageConstants.titleWeight,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Список инсайтов (берем максимум из констант, чтобы не раздувать UI)
                ...insights.take(OutageConstants.maxInsights).map((insight) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // Маркер списка (буллит)
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: OutageColors.textSecondary,
                            fontSize: OutageConstants.bodySize,
                            fontWeight: OutageConstants.titleWeight, // Делаем точку чуть жирнее
                          ),
                        ),
                        
                        // Текст инсайта (используем поле message)
                        Expanded(
                          child: Text(
                            insight.message, 
                            style: const TextStyle(
                              color: OutageColors.textSecondary,
                              fontSize: OutageConstants.bodySize,
                              height: 1.3, // Улучшаем читабельность многострочного текста
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}