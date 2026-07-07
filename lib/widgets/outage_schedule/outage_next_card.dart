import 'package:flutter/material.dart';

import '../../models/outage/next_outage_event.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import '../../utils/outage/outage_formatter.dart';
import '../../utils/outage/outage_icons.dart';

class OutageNextCard extends StatelessWidget {
  final NextOutageEvent? event;

  const OutageNextCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Сценарий: Отключений не предвидится (event == null)
    if (event == null) {
      return Container(
        padding: const EdgeInsets.all(OutageConstants.innerPadding),
        decoration: BoxDecoration(
          color: OutageColors.powerOn.withOpacity(0.05),
          borderRadius: BorderRadius.circular(OutageConstants.innerRadius),
          border: Border.all(
            color: OutageColors.powerOn.withOpacity(0.2),
            width: OutageConstants.borderWidth,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                OutageIcons.powerOn,
                color: OutageColors.powerOn,
                size: OutageConstants.largeIcon,
              ),
              SizedBox(height: 8),
              Text(
                'Відключень\nне передбачається',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: OutageColors.powerOn,
                  fontSize: OutageConstants.bodySize,
                  fontWeight: OutageConstants.subtitleWeight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Сценарий: Событие есть. 
    // Проверяем, идет ли отключение прямо сейчас, чтобы изменить логику текста
    final bool isActive = event!.isActive;
    final DateTime targetTime = isActive ? event!.end : event!.start;
    
    // Если title пустой, подставляем дефолтный текст
    final String defaultLabel = isActive ? 'Світло з\'явиться о' : 'Наступне відключення';
    final String displayLabel = event!.title.isNotEmpty ? event!.title : defaultLabel;

    return Container(
      padding: const EdgeInsets.all(OutageConstants.innerPadding),
      decoration: BoxDecoration(
        color: OutageColors.innerCard,
        borderRadius: BorderRadius.circular(OutageConstants.innerRadius),
        border: Border.all(
          color: OutageColors.border,
          width: OutageConstants.borderWidth,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Верхняя строка: Заголовок и Время
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  displayLabel,
                  style: const TextStyle(
                    color: OutageColors.textSecondary,
                    fontSize: OutageConstants.bodySize,
                    fontWeight: OutageConstants.bodyWeight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                OutageFormatter.time(targetTime),
                style: const TextStyle(
                  color: OutageColors.textPrimary,
                  fontSize: OutageConstants.titleSize,
                  fontWeight: OutageConstants.titleWeight,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: OutageConstants.itemSpacing),
          
          // Нижняя строка: Продолжительность
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Тривалість',
                style: TextStyle(
                  color: OutageColors.textSecondary,
                  fontSize: OutageConstants.bodySize,
                  fontWeight: OutageConstants.bodyWeight,
                ),
              ),
              Text(
                '~ ${OutageFormatter.duration(event!.duration)}',
                style: const TextStyle(
                  color: OutageColors.textPrimary,
                  fontSize: OutageConstants.subtitleSize,
                  fontWeight: OutageConstants.subtitleWeight,
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}