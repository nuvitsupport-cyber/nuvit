import 'package:flutter/material.dart';

import '../../models/outage/outage_forecast.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import '../../utils/outage/outage_formatter.dart';
import '../../utils/outage/outage_icons.dart';

class OutageStatsGrid extends StatelessWidget {
  final OutageForecast forecast;

  const OutageStatsGrid({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final stats = forecast.statistics;
    final nextEvent = forecast.nextEvent;

    // Форматируем время следующего отключения (если оно есть)
    final String nextTimeStr = nextEvent != null
        ? OutageFormatter.time(nextEvent.start)
        : '--:--';

    return Row(
      children: [
        
        Expanded(
          child: _StatCard(
            icon: OutageIcons.powerOn,
            iconColor: OutageColors.powerOn,
            title: 'Світло',
            value: OutageFormatter.hours(stats.powerHours),
            subtitle: 'Прогноз',
          ),
        ),
        
        const SizedBox(width: OutageConstants.smallSpacing),
        
        Expanded(
          child: _StatCard(
            // Используем иконку отключения (вилка/розетка)
            icon: Icons.power_off_rounded, 
            iconColor: OutageColors.outage,
            title: 'Без світла',
            value: OutageFormatter.hours(stats.outageHours),
            subtitle: 'Прогноз',
          ),
        ),
        
        const SizedBox(width: OutageConstants.smallSpacing),
        
        Expanded(
          child: _StatCard(
            icon: OutageIcons.timeline, // Иконка часов
            iconColor: OutageColors.possibleOutage,
            title: 'Наступне',
            value: nextTimeStr,
            subtitle: 'Сьогодні',
          ),
        ),
        
        const SizedBox(width: OutageConstants.smallSpacing),
        
        const Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_rounded,
            iconColor: Colors.blueAccent, // Цвет под иконку календаря
            title: 'Черга',
            value: '2.1', // TODO: Заменить на реальные данные из профиля/настроек
            subtitle: 'Ваша черга',
          ),
        ),
        
      ],
    );
  }
}

/// Приватный вспомогательный виджет для отрисовки одной карточки статистики
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 4.0, // Минимальный отступ, так как карточки узкие
      ),
      decoration: BoxDecoration(
        color: OutageColors.innerCard,
        borderRadius: BorderRadius.circular(OutageConstants.innerRadius),
        border: Border.all(
          color: OutageColors.border,
          width: OutageConstants.borderWidth,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Icon(
            icon,
            color: iconColor,
            size: OutageConstants.normalIcon,
          ),
          
          const SizedBox(height: 6),
          
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: OutageColors.textSecondary,
              fontSize: 11, // Делаем шрифт чуть меньше, чтобы влезло в экран
              fontWeight: OutageConstants.bodyWeight,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: OutageColors.textPrimary,
              fontSize: 15,
              fontWeight: OutageConstants.titleWeight,
            ),
          ),
          
          const SizedBox(height: 2),
          
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: OutageColors.textSecondary,
              fontSize: 9,
            ),
          ),
          
        ],
      ),
    );
  }
}