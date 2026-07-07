import 'package:flutter/material.dart';

import '../../models/outage/outage_period.dart';
import '../../models/outage/outage_state.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import '../../utils/outage/outage_formatter.dart';
import '../../utils/outage/outage_icons.dart';

class OutagePeriodTile extends StatelessWidget {
  final OutagePeriod period;

  const OutagePeriodTile({
    super.key,
    required this.period,
  });

  /// Локальный хелпер для получения текстового названия статуса
  String _getStateLabel(OutageState state) {
    switch (state) {
      case OutageState.powerOn:
        return 'Є світло';
      case OutageState.possibleOutage:
        return 'Можливе відключення';
      case OutageState.outage:
        return 'Відключення';
      case OutageState.unknown:
        return 'Невідомо';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем цвета и иконки на основе состояния сети
    final stateColor = OutageColors.state(period.state);
    final stateText = _getStateLabel(period.state);

    return Container(
      padding: const EdgeInsets.all(OutageConstants.innerPadding),
      decoration: BoxDecoration(
        color: OutageColors.innerCard,
        borderRadius: BorderRadius.circular(OutageConstants.innerRadius),
        border: Border.all(
          // Если период идет прямо сейчас, слегка подсвечиваем рамку цветом статуса
          color: period.isCurrent
              ? stateColor.withOpacity(0.5)
              : OutageColors.border,
          width: OutageConstants.borderWidth,
        ),
      ),
      child: Row(
        children: [
          
          // 1. Иконка состояния в цветном кружке
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: stateColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              OutageIcons.state(period.state),
              color: stateColor,
              size: OutageConstants.normalIcon,
            ),
          ),
          
          const SizedBox(width: OutageConstants.itemSpacing),

          // 2. Время и статус
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Время (напр. 18:00 - 20:00)
                Text(
                  OutageFormatter.period(period),
                  style: const TextStyle(
                    color: OutageColors.textPrimary,
                    fontWeight: OutageConstants.subtitleWeight,
                    fontSize: OutageConstants.subtitleSize,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Статус и описание
                Row(
                  children: [
                    Text(
                      stateText,
                      style: TextStyle(
                        color: OutageColors.stateText(period.state),
                        fontSize: OutageConstants.captionSize,
                        fontWeight: OutageConstants.bodyWeight,
                      ),
                    ),
                    
                    // Если есть дополнительное описание (напр. "Планові роботи")
                    if (period.description != null) ...[
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '• ${period.description}',
                          style: const TextStyle(
                            color: OutageColors.textSecondary,
                            fontSize: OutageConstants.captionSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 3. Плашка вероятности (показываем только для возможных отключений)
          if (period.isPossible && period.probability > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: stateColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(OutageConstants.chipRadius),
              ),
              child: Text(
                OutageFormatter.percent(period.probability),
                style: TextStyle(
                  color: stateColor,
                  fontSize: OutageConstants.captionSize,
                  fontWeight: OutageConstants.bodyWeight,
                ),
              ),
            ),
            
        ],
      ),
    );
  }
}