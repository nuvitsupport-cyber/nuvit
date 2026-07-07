import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math; // Підключаємо математику для тригонометричної інтерполяції

import '../../../services/weather_service.dart';
import '../../utils/autonomy/ess_models.dart';
import '../../utils/autonomy/ess_system_loader.dart';

import '../../models/generation_forecast.dart';
import 'package:nuvit/services/hybrid_forecast_engine.dart';
import 'package:nuvit/services/ai/ai_recommendation_engine.dart'; 
import '../../widgets/generation_breakdown_card.dart';

const Color kAppBackground = Color(0xFF020D2D);
const Color kCardBackground = Color(0xFF0C1940); 
const Color kInnerBackground = Color(0xFF051033); 
const Color kNeonGreen = Color(0xFF39FF14);
const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFF8E99B0);

class WeatherInsightsSection extends StatefulWidget {
  final String city;
  final Function(double cloudiness, double rainMm, double tempC)? onWeatherUpdated;
  
  const WeatherInsightsSection({
    super.key, 
    this.city = 'Kyiv', 
    this.onWeatherUpdated,
  });

  @override
  State<WeatherInsightsSection> createState() => _WeatherInsightsSectionState();
}

class _WeatherInsightsSectionState extends State<WeatherInsightsSection> {
  final WeatherService _weatherService = WeatherService();
  
  bool _isLoading = true;
  AiRecommendation? _currentRecommendation; 
  
  double _cityLatitude = 49.0;
  EssSystemSettings? _systemSettings;
  double _totalSolarPeakKw = 0.0;
  
  List<Map<String, dynamic>> _forecastDays = [];
  SystemForecastSummary? _todaySummary; 
  
  double _currentCloudiness = 0;
  double _currentRainMm = 0;
  double _currentSnowMm = 0; 
  double _currentTemp = 20;
  double _currentWindSpeed = 0;
  
  List<FlSpot> _todayChartSpots = [];
  int _currentRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadSystemAndWeatherData();
  }

  @override
  void didUpdateWidget(covariant WeatherInsightsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city) {
      _loadSystemAndWeatherData();
    }
  }

  Future<void> _loadSystemAndWeatherData() async {
    final int requestId = ++_currentRequestId; 
    setState(() => _isLoading = true);

    try {
      final settings = await EssSystemLoader.load();
      if (requestId != _currentRequestId || !mounted) return;

      if (settings == null) {
        setState(() {
          _systemSettings = null;
          _totalSolarPeakKw = 0.0;
          _forecastDays = [];
          _todaySummary = null;
          _todayChartSpots = [];
          _currentCloudiness = 0.0;
          _currentRainMm = 0.0;
          _currentSnowMm = 0.0;
          
          _currentRecommendation = const AiRecommendation(
            title: 'Налаштування відсутні',
            message: 'Налаштування системи не знайдено. Будь ласка, додайте систему.',
            severity: AiRecommendationSeverity.warning,
            icon: Icons.warning_amber_rounded,
          );
          
          _isLoading = false; 
        });
        return;
      }

      final double totalSolarPeakKw = EssSystemLoader.totalSolarKw(settings);
      final weatherData = await _weatherService.getWeather(widget.city);
      
      if (requestId != _currentRequestId || !mounted) return;

      setState(() {
        _systemSettings = settings;
        _totalSolarPeakKw = totalSolarPeakKw;

        if (weatherData['city'] != null && weatherData['city']['coord'] != null) {
          _cityLatitude = (weatherData['city']['coord']['lat'] as num?)?.toDouble() ?? 49.0;
        }
        
        final list = weatherData['list'] as List?;
        if (list != null && list.isNotEmpty) {
          _parseWeatherData(list); 
          widget.onWeatherUpdated?.call(
            _currentCloudiness,
            _currentRainMm,
            _currentTemp,
          );
        } else {
          _forecastDays = [];
          _todayChartSpots = [];
          _todaySummary = null;
          
          _currentRecommendation = AiRecommendation(
            title: 'Помилка погоди',
            message: 'Не вдалося отримати актуальні дані про погоду для міста ${widget.city}.',
            severity: AiRecommendationSeverity.critical,
            icon: Icons.error_outline,
          );
        }
        
        _isLoading = false; 
      });

    } catch (e) {
      if (requestId != _currentRequestId || !mounted) return;
      
      setState(() {
        _forecastDays = [];
        _todayChartSpots = [];
        _todaySummary = null;
        _currentCloudiness = 0.0;
        _currentRainMm = 0.0;
        _currentSnowMm = 0.0;
        _currentTemp = 0.0; 
        
        _currentRecommendation = const AiRecommendation(
          title: 'Помилка з\'єднання',
          message: 'Помилка при завантаженні даних. Перевірте з’єднання.',
          severity: AiRecommendationSeverity.critical,
          icon: Icons.wifi_off,
        );
        
        _isLoading = false;
      });
    }
  }

  // --- ТРИГОНОМЕТРИЧНА ІНТЕРПОЛЯЦІЯ ---
  List<WeatherHourForecast> _getHourlyInterpolatedWeather(List<dynamic> allForecasts, DateTime targetDay) {
    final List<WeatherHourForecast> hourlyForecasts = [];
    
    final List<Map<String, dynamic>> sorted = allForecasts
        .map((f) => f as Map<String, dynamic>)
        .toList()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['dt_txt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b['dt_txt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });

    for (int hour = 0; hour < 24; hour++) {
      final targetTime = DateTime(targetDay.year, targetDay.month, targetDay.day, hour);
      
      Map<String, dynamic>? before;
      Map<String, dynamic>? after;
      
      for (var f in sorted) {
        final fTime = DateTime.tryParse(f['dt_txt']?.toString() ?? '');
        if (fTime == null) continue;

        if (fTime.isBefore(targetTime) || fTime.isAtSameMomentAs(targetTime)) {
          before = f;
        }
        if (fTime.isAfter(targetTime) || fTime.isAtSameMomentAs(targetTime)) {
          after = f;
          break; 
        }
      }
      
      before ??= after ?? (sorted.isNotEmpty ? sorted.first : {});
      after ??= before;
      
      final DateTime t1 = DateTime.tryParse(before['dt_txt']?.toString() ?? '') ?? targetTime;
      final DateTime t2 = DateTime.tryParse(after['dt_txt']?.toString() ?? '') ?? targetTime;
      
      double weight = 0.0;
      final int totalMinutes = t2.difference(t1).inMinutes;
      if (totalMinutes > 0) {
        weight = targetTime.difference(t1).inMinutes / totalMinutes;
      }
      
      // S-подібна крива (ease-in-out) для плавної зміни показників
      final double sineWeight = (1.0 - math.cos(weight * math.pi)) / 2.0;
      
      final double cloud1 = (before['clouds']?['all'] as num? ?? 0.0).toDouble();
      final double cloud2 = (after['clouds']?['all'] as num? ?? 0.0).toDouble();
      
      final double temp1 = (before['main']?['temp'] as num? ?? 0.0).toDouble();
      final double temp2 = (after['main']?['temp'] as num? ?? 0.0).toDouble();
      
      final double wind1 = (before['wind']?['speed'] as num? ?? 0.0).toDouble();
      final double wind2 = (after['wind']?['speed'] as num? ?? 0.0).toDouble();
      
      final double rain1 = (before['rain']?['3h'] as num? ?? 0.0).toDouble();
      final double rain2 = (after['rain']?['3h'] as num? ?? 0.0).toDouble();

      final double snow1 = (before['snow']?['3h'] as num? ?? 0.0).toDouble();
      final double snow2 = (after['snow']?['3h'] as num? ?? 0.0).toDouble();
      
      hourlyForecasts.add(WeatherHourForecast(
        dateTime: targetTime,
        cloudCover: cloud1 + sineWeight * (cloud2 - cloud1),
        windSpeed: wind1 + sineWeight * (wind2 - wind1),
        accumulatedRain: rain1 + sineWeight * (rain2 - rain1),
        accumulatedSnow: snow1 + sineWeight * (snow2 - snow1), 
        temperatureC: temp1 + sineWeight * (temp2 - temp1),
      ));
    }
    return hourlyForecasts;
  }

  void _calculateHybridForecast(List rawList, DateTime targetDay) {
    if (_systemSettings == null) return;

    final engine = HybridForecastEngine(latitude: _cityLatitude);
    final List<WeatherHourForecast> weatherData = _getHourlyInterpolatedWeather(rawList, targetDay);

    _todaySummary = engine.calculate(
      settings: _systemSettings!,
      weatherData: weatherData,
    );

    List<FlSpot> spots = [];
    for (var point in _todaySummary!.hourlyPoints) {
      spots.add(FlSpot(
        point.time.hour.toDouble(), 
        double.parse(point.totalKw.toStringAsFixed(2))
      ));
    }
    _todayChartSpots = spots;
  }

  // --- БЕЗПЕЧНИЙ ПАРСИНГ JSON ---
  void _parseWeatherData(List rawList) {
    if (rawList.isEmpty) return;

    final Map<String, List<dynamic>> groupedByDay = {};
    for (var item in rawList) {
      final dtTxt = item['dt_txt']?.toString();
      if (dtTxt == null) continue;
      final date = dtTxt.split(' ')[0];
      groupedByDay.putIfAbsent(date, () => []).add(item);
    }

    final dates = groupedByDay.keys.toList()..sort();
    if (dates.isEmpty) {
      _forecastDays = [];
      _todaySummary = null;
      _todayChartSpots = [];
      
      _currentRecommendation = AiRecommendation(
        title: 'Помилка даних',
        message: 'Не вдалося розібрати погодні дані для міста ${widget.city}.',
        severity: AiRecommendationSeverity.critical,
        icon: Icons.error_outline,
      );
      return;
    }

    final firstForecast = rawList.first as Map<String, dynamic>? ?? {};
    
    // Замість жорстких індексів використовуємо `?` і `?? 0.0`
    _currentCloudiness = (firstForecast['clouds']?['all'] as num? ?? 0.0).toDouble();
    _currentTemp = (firstForecast['main']?['temp'] as num? ?? 0.0).toDouble();
    _currentRainMm = (firstForecast['rain']?['3h'] as num? ?? 0.0).toDouble();
    _currentSnowMm = (firstForecast['snow']?['3h'] as num? ?? 0.0).toDouble();
    _currentWindSpeed = (firstForecast['wind']?['speed'] as num? ?? 0.0).toDouble();

    final todayForecasts = groupedByDay[dates[0]]!;
    final DateTime todayDate = DateTime.tryParse(todayForecasts[0]['dt_txt']?.toString() ?? '') ?? DateTime.now();
    
    _calculateHybridForecast(rawList, todayDate);
    
    final aiEngine = AiRecommendationEngine(latitude: _cityLatitude);
    _currentRecommendation = aiEngine.generate(
      settings: _systemSettings,
      todaySummary: _todaySummary,
      cloudiness: _currentCloudiness,
      rainMm: _currentRainMm,
      snowMm: _currentSnowMm,
      windSpeed: _currentWindSpeed,
      tempC: _currentTemp,
      todayDate: todayDate,
    );

    List<Map<String, dynamic>> computedDays = [];
    for (int i = 1; i < dates.length && computedDays.length < 3; i++) {
      final dateStr = dates[i];
      final dayForecasts = groupedByDay[dateStr]!;

      double maxTemp = -999;
      double minTemp = 999;
      double totalClouds = 0;
      double totalRain = 0;
      double totalWind = 0;
      String mainCondition = 'clear';
      String description = '';

      for (var f in dayForecasts) {
        final temp = (f['main']?['temp'] as num? ?? 0.0).toDouble();
        if (temp > maxTemp) maxTemp = temp;
        if (temp < minTemp) minTemp = temp;
        
        totalClouds += (f['clouds']?['all'] as num? ?? 0.0).toDouble();
        totalWind += (f['wind']?['speed'] as num? ?? 0.0).toDouble();
        totalRain += (f['rain']?['3h'] as num? ?? 0.0).toDouble();
        
        final dtStr = f['dt_txt']?.toString() ?? '';
        if (dtStr.contains('12:00') || dtStr.contains('15:00')) {
          final weatherArr = f['weather'] as List<dynamic>?;
          if (weatherArr != null && weatherArr.isNotEmpty) {
            mainCondition = weatherArr[0]?['main']?.toString().toLowerCase() ?? 'clear';
            description = weatherArr[0]?['description']?.toString() ?? '';
          }
        }
      }
      
      if (description.isEmpty && dayForecasts.isNotEmpty) {
        final weatherArr = dayForecasts[0]['weather'] as List<dynamic>?;
        if (weatherArr != null && weatherArr.isNotEmpty) {
          mainCondition = weatherArr[0]?['main']?.toString().toLowerCase() ?? 'clear';
          description = weatherArr[0]?['description']?.toString() ?? '';
        }
      }

      double dayExpectedGenerationKwh = 0.0;
      double daytimeClouds = 0.0;
      int daylightIntervals = 0;

      if (_systemSettings != null) {
        final engine = HybridForecastEngine(latitude: _cityLatitude);
        final DateTime targetDayTime = DateTime.tryParse(dayForecasts[0]['dt_txt']?.toString() ?? '') ?? DateTime.now();
        
        final List<WeatherHourForecast> futureWeather = _getHourlyInterpolatedWeather(rawList, targetDayTime);

        for (var point in futureWeather) {
          if (point.dateTime.hour >= 6 && point.dateTime.hour <= 18) {
            daytimeClouds += point.cloudCover;
            daylightIntervals++;
          }
        }

        final summary = engine.calculate(settings: _systemSettings!, weatherData: futureWeather);
        // Замінено на безпечний доступ, у разі відсутності поля буде 0.0
        dayExpectedGenerationKwh = summary.totalSolarKwh + summary.totalWindKwh + summary.totalHydroKwh;
      }

      double avgCloudiness = daylightIntervals > 0 
          ? daytimeClouds / daylightIntervals 
          : (dayForecasts.isNotEmpty ? totalClouds / dayForecasts.length : 0.0);

      computedDays.add({
        'dateLabel': i == 1 ? 'Завтра' : (i == 2 ? 'Післязавтра' : 'Через 3 дні'),
        'tempRange': '${maxTemp == -999 ? 0 : maxTemp.round()}° / ${minTemp == 999 ? 0 : minTemp.round()}°',
        'condition': mainCondition,
        'description': description,
        'generationKw': dayExpectedGenerationKwh.toStringAsFixed(1),
        'cloudiness': avgCloudiness,
        'wind': dayForecasts.isNotEmpty ? totalWind / dayForecasts.length : 0.0,
      });
    }

    _forecastDays = computedDays;
  }

  IconData _getWeatherIcon(String condition) {
    if (condition.contains('clear') || condition.contains('sun')) return Icons.wb_sunny;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('rain')) return Icons.water_drop;
    if (condition.contains('snow')) return Icons.ac_unit;
    return Icons.wb_cloudy_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;
        final isTablet = constraints.maxWidth >= 850 && constraints.maxWidth < 1100;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kNeonGreen.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator(color: kNeonGreen)),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isMobile),
                    const SizedBox(height: 20),
                    if (isMobile)
                      _buildMobileLayout()
                    else if (isTablet)
                      _buildTabletLayout()
                    else
                      _buildDesktopLayout(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _buildExpectedGenerationCard()),
            const SizedBox(width: 14),
            Expanded(flex: 6, child: _buildThreeDayForecastCard()),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _buildHourlyChartCard()),
            const SizedBox(width: 14),
            Expanded(flex: 3, child: _buildFactorsCard()),
            const SizedBox(width: 14),
            Expanded(flex: 3, child: _buildRecommendationsCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildExpectedGenerationCard()),
            const SizedBox(width: 14),
            Expanded(child: _buildThreeDayForecastCard()),
          ],
        ),
        const SizedBox(height: 14),
        _buildHourlyChartCard(),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFactorsCard()),
            const SizedBox(width: 14),
            Expanded(child: _buildRecommendationsCard()),
          ]
        )
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildExpectedGenerationCard(),
        const SizedBox(height: 14),
        _buildThreeDayForecastCard(),
        const SizedBox(height: 14),
        _buildHourlyChartCard(),
        const SizedBox(height: 14),
        _buildFactorsCard(),
        const SizedBox(height: 14),
        _buildRecommendationsCard(),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    final headerText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMobile 
              ? 'Прогноз для м. ${widget.city}' 
              : 'Прогноз генерації для м. ${widget.city}',
          style: const TextStyle(
            color: kTextPrimary, 
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2, 
        ),
        const SizedBox(height: 4),
        const Text(
          'Оцінка виробітку системи ESS',
          style: TextStyle(color: kTextSecondary, fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );

    if (isMobile) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2), 
            child: Icon(Icons.wb_sunny_outlined, color: kNeonGreen, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(child: headerText),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: kNeonGreen, size: 26),
              const SizedBox(width: 10),
              Expanded(child: headerText),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: kNeonGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: kNeonGreen.withOpacity(0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.analytics_outlined, color: kNeonGreen, size: 12),
              SizedBox(width: 4),
              Text(
                'АКТУАЛЬНИЙ ПРОГНОЗ', 
                style: TextStyle(
                  color: kNeonGreen, 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildExpectedGenerationCard() {
    if (_todaySummary == null) {
      return const _InnerCard(
        child: SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator(color: kNeonGreen)),
        ),
      );
    }

    return GenerationBreakdownCard(
      solarKwh: _todaySummary!.totalSolarKwh,
      windKwh: _todaySummary!.totalWindKwh,
      hydroKwh: _todaySummary!.totalHydroKwh,
    );
  }

  Widget _buildThreeDayForecastCard() {
    if (_forecastDays.isEmpty) {
      return const _InnerCard(child: Center(child: Text('Немає даних', style: TextStyle(color: kTextSecondary))));
    }

    List<Widget> children = [];
    for (int i = 0; i < _forecastDays.length; i++) {
      final day = _forecastDays[i];
      final double cloudiness = day['cloudiness'];
      final double wind = day['wind'] ?? 0.0;
      
      String statusText;
      Color statusColor;

      if (cloudiness <= 30) {
        statusText = 'Високий потенціал';
        statusColor = kNeonGreen;
      } else if (cloudiness <= 65) {
        statusText = 'Помірна хмарність';
        statusColor = Colors.orangeAccent; 
      } else {
        statusText = 'Низька інсоляція';
        statusColor = Colors.redAccent;
      }

      children.add(
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day['dateLabel'], 
                style: TextStyle(
                  color: day['dateLabel'] == 'Завтра' ? kNeonGreen : kTextSecondary, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Icon(_getWeatherIcon(day['condition']), color: kTextPrimary, size: 20),
              const SizedBox(height: 4),
              Text(day['tempRange'], style: const TextStyle(color: kTextPrimary, fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                '${day['generationKw']} кВт·год', 
                style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                statusText, 
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                'Хмарність: ${cloudiness.round()}%', 
                style: const TextStyle(color: kTextSecondary, fontSize: 10),
              ),
              Text(
                'Вітер: ${wind.toStringAsFixed(1)} м/с', 
                style: const TextStyle(color: kTextSecondary, fontSize: 10),
              ),
            ],
          ),
        ),
      );
      
      if (i < _forecastDays.length - 1) {
        children.add(Container(width: 1, height: 70, color: Colors.white10));
      }
    }

    return _InnerCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: children));
  }

  Widget _buildHourlyChartCard() {
    if (_systemSettings == null || (_systemSettings!.solarArrays.isEmpty && _systemSettings!.windGenerators.isEmpty && _systemSettings!.hydroStations.isEmpty)) {
      return const _InnerCard(
        child: SizedBox(
          height: 140,
          child: Center(
            child: Text('[Будь ласка, додайте систему генерації]', style: TextStyle(color: kTextSecondary)),
          ),
        ),
      );
    }

    double todayMaxExpected = 0.0;
    if (_todayChartSpots.isNotEmpty) {
      todayMaxExpected = _todayChartSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    }
    
    double maxY = todayMaxExpected > 0 ? todayMaxExpected * 1.2 : 5.0;

    final double currentHour = DateTime.now().hour.toDouble();

    return _InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Прогноз загальної потужності', style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              Text('Пік: ${todayMaxExpected.toStringAsFixed(1)} кВт', style: const TextStyle(color: kNeonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: LineChart(
              LineChartData(
                extraLinesData: ExtraLinesData(
                  verticalLines: [
                    VerticalLine(
                      x: currentHour,
                      color: Colors.orangeAccent.withOpacity(0.8),
                      strokeWidth: 1.5,
                      dashArray: [4, 4], 
                      label: VerticalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        labelResolver: (line) => 'Зараз',
                      ),
                    ),
                  ],
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 3, 
                      getTitlesWidget: (value, meta) {
                        final int hour = value.toInt();
                        if (hour >= 0 && hour <= 23 && hour % 3 == 0) {
                          return Text(
                            '${hour.toString().padLeft(2, '0')}:00', 
                            style: const TextStyle(color: kTextSecondary, fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,   
                maxX: 23,  
                minY: 0,
                maxY: maxY, 
                lineBarsData: [
                  LineChartBarData(
                    spots: _todayChartSpots.isEmpty 
                        ? [const FlSpot(0, 0), const FlSpot(12, 0), const FlSpot(23, 0)] 
                        : _todayChartSpots,
                    isCurved: true, 
                    color: kNeonGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false), 
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          kNeonGreen.withOpacity(0.25),
                          kNeonGreen.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsCard() {
    return _InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Фактори впливу', style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildFactorRow(Icons.cloud_outlined, 'Хмарність', '${_currentCloudiness.round()}%', _currentCloudiness > 50 ? Colors.orangeAccent : kNeonGreen),
          const SizedBox(height: 8),
          _buildFactorRow(Icons.water_drop_outlined, 'Дощ', '${_currentRainMm.toStringAsFixed(1)} мм', _currentRainMm > 0 ? Colors.blueAccent : kNeonGreen),
          const SizedBox(height: 8),
          _buildFactorRow(Icons.ac_unit, 'Сніг', '${_currentSnowMm.toStringAsFixed(1)} мм', _currentSnowMm > 0 ? Colors.lightBlueAccent : kNeonGreen),
          const SizedBox(height: 8),
          _buildFactorRow(Icons.air, 'Швид. вітру', '${_currentWindSpeed.toStringAsFixed(1)} м/с', _currentWindSpeed > 3.0 ? kNeonGreen : kTextSecondary),
          const SizedBox(height: 8),
          _buildFactorRow(Icons.thermostat_outlined, 'Температура', '${_currentTemp.round()}°C', kTextPrimary),
        ],
      ),
    );
  }

  Widget _buildFactorRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: kTextSecondary, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
          ],
        ),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    final rec = _currentRecommendation;
    if (rec == null) return const _InnerCard(child: Text('Завантаження аналітики...'));

    final color = rec.getColor(kNeonGreen);

    return _InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(rec.icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rec.title, 
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (rec.idealGenerationKwh > 0) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildMetricRow('Ідеальний потенціал', '${rec.idealGenerationKwh.toStringAsFixed(1)} кВт·год'),
                  const Divider(color: Colors.white10, height: 10),
                  _buildMetricRow('Очікувана генерація', '${rec.expectedGenerationKwh.toStringAsFixed(1)} кВт·год', valueColor: kNeonGreen),
                  const Divider(color: Colors.white10, height: 10),
                  _buildMetricRow('Втрати через погоду', '-${rec.lossesKwh.toStringAsFixed(1)} кВт·год', valueColor: Colors.redAccent),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          if (rec.lossReasons.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Причини втрат: ${rec.lossReasons.join(", ")}.',
                style: const TextStyle(color: kTextSecondary, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
          ],

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              border: Border.all(color: color.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rec.message,
              style: const TextStyle(color: kTextPrimary, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {Color valueColor = kTextPrimary}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InnerCard extends StatelessWidget {
  final Widget child;
  const _InnerCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kInnerBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: child,
    );
  }
}