// lib/screens/energy_hub_page.dart

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/models/autonomy_result.dart';
import '../widgets/energy_hub/autonomy_calculator/autonomy_calculator_widget.dart';
import '../widgets/energy_hub/weather_insights_section.dart';
class EnergyHubPage extends StatelessWidget {
  const EnergyHubPage({super.key});

  static const Color brandBg = Color(0xFF020D2D);       
  static const Color brandCard = Color(0xFF0A153A);     
  static const Color brandInnerBg = Color(0xFF051033);  

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: brandBg,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 1. Главный заголовок страницы Энергохаб
                Text(
                  'Енергохаб',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: isDesktop ? 38 : 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Моніторинг та оптимізація енергосистеми',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),

                SizedBox(height: isDesktop ? 32 : 24),

                /// 2. Карточка калькулятора автономности
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  decoration: BoxDecoration(
                    color: brandCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Калькулятор автономності',
                        style: TextStyle(
                          color: AppColors.textMain, 
                          fontSize: isDesktop ? 22 : 18, 
                          fontWeight: FontWeight.w600, 
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Плануйте своє споживання і дізнайтесь, на скільки енергії вистачить',
                        style: TextStyle(
                          color: AppColors.textMuted, 
                          fontSize: isDesktop ? 14 : 12,
                          height: 1.4, 
                        ),
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      AutonomyCalculatorWidget(
                        result: AutonomyResult.demo(),
                      ),
                    ],
                  ),
                ),

                // Отступ между калькулятором и виджетом погоды
                SizedBox(height: isDesktop ? 32 : 24),

                /// 3. ВИДЖЕТ ПОГОДНЫХ ИНСАЙТОВ
                const WeatherInsightsSection(city: 'Kyiv'), 
              ],
            ),
          ),
        );
      },
    );
  }
}