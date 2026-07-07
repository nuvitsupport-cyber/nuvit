import 'package:flutter/material.dart';

import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';

class OutageLoading extends StatelessWidget {
  const OutageLoading({super.key});

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
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          // Центрированный фирменный лоадер
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(OutageColors.accent),
              backgroundColor: OutageColors.innerCard,
            ),
          ),
          
          const SizedBox(height: OutageConstants.itemSpacing),
          
          // Главный текст состояния
          Text(
            'Оновлення даних...',
            style: TextStyle(
              color: OutageColors.textPrimary,
              fontSize: OutageConstants.subtitleSize,
              fontWeight: OutageConstants.titleWeight,
            ),
          ),
          
          const SizedBox(height: OutageConstants.smallSpacing),
          
          // Дополнительное пояснение для пользователя
          Text(
            'Будь ласка, зачекайте, завантажуємо актуальний графік відключень.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: OutageColors.textSecondary,
              fontSize: OutageConstants.bodySize,
              height: 1.4,
            ),
          ),
          
        ],
      ),
    );
  }
}