import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_colors.dart';
import '../utils/models/autonomy_result.dart';
import '../widgets/energy_hub/autonomy_calculator/autonomy_calculator_widget.dart';
import '../widgets/energy_hub/weather_insights_section.dart';
import '../widgets/outage_schedule/outage_schedule_widget.dart';

// Импорт модели данных графика отключений (проверьте относительный путь в вашем проекте)
import '../models/outage/outage_forecast.dart';
// import '../models/outage/outage_settings.dart'; // Раскомментируйте при подключении провайдера
// import '../providers/outage/mock_outage_provider.dart'; // Раскомментируйте для тестов

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
  
  String _selectedCity = 'Київ'; // Город по умолчанию
  bool _isLoadingCity = true;

  // Переменные состояния для модуля графика отключений
  OutageForecast? _outageForecast;
  bool _isOutageLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCity();
    _loadOutageData(); // Запуск загрузки графика при инициализации страницы
  }

  // Загружаем город из глобальных настроек инфраструктуры
  Future<void> _loadCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCity = prefs.getString('selectedCity');
      
      if (mounted) {
        setState(() {
          if (savedCity != null && savedCity.trim().isNotEmpty) {
            _selectedCity = savedCity;
          }
          _isLoadingCity = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCity = false;
        });
      }
    }
  }

  // Метод для загрузки/обновления данных графика отключений
  Future<void> _loadOutageData() async {
    if (!mounted) return;

    setState(() {
      _isOutageLoading = true;
    });

    try {
      // TODO: Подключите ваш MockOutageProvider или реальный API-сервис ДТЕК
      // const provider = MockOutageProvider();
      // final forecast = await provider.loadForecast(const OutageSettings());
      // setState(() {
      //   _outageForecast = forecast;
      // });
    } catch (e) {
      // Здесь можно обработать потенциальные ошибки сети
    } finally {
      if (mounted) {
        setState(() {
          _isOutageLoading = false;
        });
      }
    }
  }

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
                        onStateCalculated: (newState) {
                          // Логика обновления потоков энергии временно отключена
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isDesktop ? 32 : 24),

                // Интеграция реального виджета графика отключений вместо заглушки
                OutageScheduleWidget(
                  forecast: _outageForecast,
                  isLoading: _isOutageLoading,
                  onRefresh: _loadOutageData,
                ),

                SizedBox(height: isDesktop ? 32 : 24), 

                // Ждем загрузки города перед рендерингом виджета погоды
                _isLoadingCity
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(color: AppColors.neon),
                        ),
                      )
                    : WeatherInsightsSection(
                        city: _selectedCity, // Передаем загруженный город
                        onWeatherUpdated: (cloudiness, rainMm, tempC) {
                          // Делаем проверку mounted чтобы избежать утечек памяти 
                          if (mounted) {
                            setState(() {
                              _cloudiness = cloudiness;
                              _rainMm = rainMm;
                              _ambientTemp = tempC;
                            });
                          }
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