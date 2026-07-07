import 'package:flutter/material.dart';

import '../../models/outage/outage_source.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import '../../utils/outage/outage_icons.dart';

class OutageSourceBadge extends StatelessWidget {
  final OutageSource source;

  const OutageSourceBadge({
    super.key,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    // Используем безопасный для темной темы зеленый цвет (Emerald) 
    // или адаптируем под общую дизайн-систему проекта
    const sourceColor = Color(0xFF10B981); 

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: sourceColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(OutageConstants.chipRadius),
        border: Border.all(
          color: sourceColor.withOpacity(0.25),
          width: OutageConstants.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          // Иконка источника данных (из утилит проекта)
          const Icon(
            OutageIcons.source,
            color: sourceColor,
            size: 13,
          ),
          
          const SizedBox(width: 6),
          
          // Название источника (например, ДТЕК, Укренерго)
          Text(
            source.name,
            style: const TextStyle(
              color: sourceColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
          
        ],
      ),
    );
  }
}