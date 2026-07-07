import 'package:flutter/material.dart';

import '../../models/outage/outage_period.dart';
import '../../models/outage/outage_state.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';

class OutageTimeline extends StatelessWidget {
  final List<OutagePeriod> periods;

  const OutageTimeline({
    super.key,
    required this.periods,
  });

  /// Сопоставляет конкретный час суток (от 0 до 23) с состоянием сети
  OutageState _getStateForHour(int hour) {
    if (periods.isEmpty) return OutageState.unknown;

    for (final period in periods) {
      // Проверяем, попадает ли переданный час в диапазон периода
      final startHour = period.start.hour;
      var endHour = period.end.hour;
      
      // Если период заканчивается в 00:00 следующего дня, считаем это как 24
      if (endHour == 0 && period.end.day != period.start.day) {
        endHour = 24;
      }

      if (hour >= startHour && hour < endHour) {
        return period.state;
      }
    }
    
    // Если данных на этот час нет, возвращаем неизвестное состояние
    return OutageState.unknown; 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // 1. Метки времени
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimeLabel('00'),
            _TimeLabel('06'),
            _TimeLabel('12'),
            _TimeLabel('18'),
            _TimeLabel('24'),
          ],
        ),
        
        const SizedBox(height: OutageConstants.smallSpacing),

        // 2. Блоки таймлайна (24 часа)
        Row(
          children: List.generate(OutageConstants.hoursInDay, (index) {
            final state = _getStateForHour(index);
            final color = OutageColors.state(state);
            
            return Expanded(
              child: Container(
                height: OutageConstants.timelineHeight,
                margin: EdgeInsets.only(
                  // Отступ справа для всех блоков, кроме последнего
                  right: index < OutageConstants.hoursInDay - 1 
                      ? OutageConstants.timelineSpacing 
                      : 0,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                    OutageConstants.timelineRadius,
                  ),
                  // Легкое свечение, как на дизайне, чтобы блоки смотрелись объемнее
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: OutageConstants.itemSpacing),

        // 3. Легенда состояний
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendItem(
              color: OutageColors.powerOn,
              label: 'Є світло',
            ),
            _LegendItem(
              color: OutageColors.possibleOutage,
              label: 'Можливо',
            ),
            _LegendItem(
              color: OutageColors.outage,
              label: 'Відключення',
            ),
          ],
        ),
      ],
    );
  }
}

/// Вспомогательный виджет для текста времени ("00", "06" и т.д.)
class _TimeLabel extends StatelessWidget {
  final String text;

  const _TimeLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: OutageColors.textSecondary,
        fontSize: OutageConstants.captionSize,
        fontWeight: OutageConstants.bodyWeight,
      ),
    );
  }
}

/// Вспомогательный виджет для кружочков легенды
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: OutageColors.textSecondary,
            fontSize: OutageConstants.captionSize,
            fontWeight: OutageConstants.bodyWeight,
          ),
        ),
      ],
    );
  }
}