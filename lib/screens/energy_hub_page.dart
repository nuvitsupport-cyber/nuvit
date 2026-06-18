// lib/screens/energy_hub_page.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // Импортируем ваши цвета, как в devices_page.dart

class EnergyHubPage extends StatelessWidget {
  const EnergyHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= ЗАГОЛОВОК =================
        const Text(
          'Енергохаб',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 38,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Моніторинг та оптимізація розподілу енергії',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
          ),
        ),

        // Твой будущий контент страницы Энергохаба пойдет ниже:
      ],
    );
  }
}