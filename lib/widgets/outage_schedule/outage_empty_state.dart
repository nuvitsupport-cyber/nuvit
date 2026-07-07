import 'package:flutter/material.dart';

import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import '../../utils/outage/outage_icons.dart';

class OutageEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const OutageEmptyState({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: OutageConstants.sectionSpacing * 2,
        horizontal: OutageConstants.cardPadding,
      ),
      decoration: BoxDecoration(
        color: OutageColors.card,
        borderRadius: BorderRadius.circular(OutageConstants.cardRadius),
        border: Border.all(
          color: OutageColors.border,
          width: OutageConstants.borderWidth,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          // Иконка отсутствия данных со слабым свечением
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OutageColors.textSecondary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              OutageIcons.unknown, // В твоем файле это Icons.help_outline_rounded
              color: OutageColors.textSecondary,
              size: OutageConstants.largeIcon * 1.2,
            ),
          ),
          
          const SizedBox(height: OutageConstants.itemSpacing),
          
          // Главный текст сообщения
          const Text(
            'Графік відключень відсутній',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: OutageColors.textPrimary,
              fontSize: OutageConstants.subtitleSize,
              fontWeight: OutageConstants.titleWeight,
            ),
          ),
          
          const SizedBox(height: OutageConstants.smallSpacing),
          
          // Подзаголовок с пояснением
          const Text(
            'Не вдалося завантажити актуальні дані або постачальник послуг не опублікував графік на сьогодні.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: OutageColors.textSecondary,
              fontSize: OutageConstants.bodySize,
              height: 1.4,
            ),
          ),
          
          // Показываем кнопку обновления только если передан коллбэк
          if (onRefresh != null) ...[
            const SizedBox(height: OutageConstants.sectionSpacing),
            ElevatedButton.icon(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: OutageColors.innerCard,
                foregroundColor: OutageColors.accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: OutageConstants.cardPadding,
                  vertical: OutageConstants.innerPadding * 0.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OutageConstants.chipRadius),
                  side: const BorderSide(
                    color: OutageColors.border,
                    width: OutageConstants.borderWidth,
                  ),
                ),
              ),
              icon: const Icon(
                OutageIcons.refresh, 
                size: OutageConstants.normalIcon,
              ),
              label: const Text(
                'Оновити дані',
                style: TextStyle(
                  fontWeight: OutageConstants.titleWeight,
                  fontSize: OutageConstants.bodySize,
                ),
              ),
            ),
          ],
          
        ],
      ),
    );
  }
}