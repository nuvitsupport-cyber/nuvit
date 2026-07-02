// lib/screens/energy_hub_page.dart

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/models/autonomy_result.dart';
import '../models/energy_flow/energy_flow_state.dart'; // ВАЖЛИВО: Доданий імпорт
import '../widgets/energy_hub/autonomy_calculator/autonomy_calculator_widget.dart';
import '../widgets/energy_hub/weather_insights_section.dart';
import '../widgets/energy_hub/energy_flow_widget.dart';

class EnergyHubPage extends StatefulWidget {
  const EnergyHubPage({super.key});

  static const Color brandBg = Color(0xFF020D2D);       
  static const Color brandCard = Color(0xFF0A153A);     
  static const Color brandInnerBg = Color(0xFF051033);  

  @override
  State<EnergyHubPage> createState() => _EnergyHubPageState();
}

class _EnergyHubPageState extends State<EnergyHubPage> {
  double _cloudiness = 0.0;
  double _rainMm = 0.0;
  double _ambientTemp = 25.0;

  // 🔥 Стан для віджета потоків (починаємо з пустого)
  EnergyFlowState _flowState = EnergyFlowState.empty();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: EnergyHubPage.brandBg,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                
                // 🔥 Передаємо стан у віджет
                EnergyFlowWidget(state: _flowState),
                
                SizedBox(height: isDesktop ? 32 : 24),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  decoration: BoxDecoration(
                    color: EnergyHubPage.brandCard,
                    borderRadius: BorderRadius.circular(12),
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
                        cloudiness: _cloudiness,
                        rainMm: _rainMm,
                        ambientTemp: _ambientTemp,
                        // 🔥 Отримуємо результати математики і оновлюємо сторінку
                        onStateCalculated: (newState) {
                          setState(() {
                            _flowState = newState;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isDesktop ? 32 : 24),

                WeatherInsightsSection(
                  city: 'Kyiv',
                  onWeatherUpdated: (cloudiness, rainMm, tempC) {
                    setState(() {
                      _cloudiness = cloudiness;
                      _rainMm = rainMm;
                      _ambientTemp = tempC;
                    });
                  },
                ), 
              ],
            ),
          ),
        );
      },
    );
  }
}