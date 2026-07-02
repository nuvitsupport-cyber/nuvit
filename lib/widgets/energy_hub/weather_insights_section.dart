import 'package:flutter/material.dart';
import '../../../services/weather_service.dart';
import '../../utils/autonomy/ess_models.dart';
import '../../utils/autonomy/ess_system_loader.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

// Футуристичная палитра Nuvit
const Color kAppBackground = Color(0xFF020D2D);
const Color kCardBackground = Color(0xFF0C1940); // Основной цвет контейнера погоды
const Color kInnerBackground = Color(0xFF051033); // Темная подложка для внутренних блоков
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
  String _adviceText = '';
  double _cityLatitude = 49.0;
  EssSystemSettings? _systemSettings;
  double _totalSolarPeakKw = 0.0;
  
  List<Map<String, dynamic>> _forecastDays = [];
  String _todayGenerationKw = '0.0'; // Генерация на сегодняшний день
  double _currentCloudiness = 0;
  double _currentRainMm = 0;
  double _currentTemp = 20;
  
  late String _selectedCity;
List<FlSpot> _todayChartSpots = [];
int _currentRequestId = 0;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.city; 
    _loadSystemAndWeatherData();
  }
@override
  void didUpdateWidget(covariant WeatherInsightsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Проверяем, действительно ли изменился город, чтобы избежать лишних запросов к API
    if (oldWidget.city != widget.city) {
      _selectedCity = widget.city;
      _loadSystemAndWeatherData();
    }
  }
  Future<void> _loadSystemAndWeatherData() async {
    final int requestId = ++_currentRequestId; // Фиксируем ID этого запроса
    setState(() => _isLoading = true);

    try {
      // ---------------------------------------------------------
      // НОВИЙ КОД: Отримуємо збережене місто з SharedPreferences
      // ---------------------------------------------------------
      final prefs = await SharedPreferences.getInstance();
      final savedCity = prefs.getString('selectedCity');
      
      if (savedCity != null && savedCity.trim().isNotEmpty) {
        _selectedCity = savedCity.trim();
      }
      // ---------------------------------------------------------

      // 1. Загружаем настройки СЕС
      final settings = await EssSystemLoader.load();
      // Если за время ожидания прилетел новый запрос или виджет закрыли — выходим
      if (requestId != _currentRequestId || !mounted) return;

      // ИСПРАВЛЕНО: Явно очищаем всё старое состояние, если настройки СЕС не найдены
      if (settings == null) {
        setState(() {
          _systemSettings = null;
          _totalSolarPeakKw = 0.0;
          _forecastDays = [];
          _todayGenerationKw = '0.0';
          _todayChartSpots = [];
          _currentCloudiness = 0.0;
          _currentRainMm = 0.0;
          
          _adviceText = 'Налаштування СЕС не знайдено. Будь ласка, додайте систему.';
          _isLoading = false; // Выключаем лоадер
        });
        return;
      }

      final double totalSolarPeakKw = EssSystemLoader.totalSolarKw(settings);

      // 2. Загружаем погоду
      final weatherData = await _weatherService.getWeather(_selectedCity);
      // Снова проверяем актуальность перед изменением состояния
      if (requestId != _currentRequestId || !mounted) return;

      // 3. Если все проверки пройдены, безопасно обновляем State
      setState(() {
        _systemSettings = settings;
        _totalSolarPeakKw = totalSolarPeakKw;

        if (weatherData['city'] != null && weatherData['city']['coord'] != null) {
          _cityLatitude = (weatherData['city']['coord']['lat'] as num).toDouble();
        }
        
        final list = weatherData['list'] as List?;
        if (list != null && list.isNotEmpty) {
          _parseWeatherData(list); 
          widget.onWeatherUpdated?.call(
            _currentCloudiness,
            _currentRainMm,
            _currentTemp,);
        } else {
          // Если погода не загрузилась, тоже можно частично сбросить погодные данные
          _forecastDays = [];
          _todayChartSpots = [];
          _todayGenerationKw = '0.0';
          _adviceText = 'Не вдалося отримати актуальні дані про погоду для міста $_selectedCity.';
        }
        
        _isLoading = false; // Отключаем загрузку
      });

    } catch (e) {
      // Обработка ошибок сетевых запросов с защитой токена и полной очисткой состояния
      if (requestId != _currentRequestId || !mounted) return;
      
      setState(() {
        // 1. Очищаем графики и прогнозы
        _forecastDays = [];
        _todayChartSpots = [];
        _todayGenerationKw = '0.0';
        
        // 2. Очищаем факторы влияния (чтобы не отображались старые данные)
        _currentCloudiness = 0.0;
        _currentRainMm = 0.0;
        _currentTemp = 0.0; 
        
        // 3. Выводим текст ошибки и снимаем лоадер
        _adviceText = 'Помилка при завантаженні даних. Перевірте з’єднання.';
        _isLoading = false;
      });
    }
  }

void _generateChartSpots(List todayForecasts) {
    List<FlSpot> spots = [];
    
    // Определяем текущий месяц из первого доступного прогноза
    DateTime date = todayForecasts.isNotEmpty 
        ? DateTime.parse(todayForecasts.first['dt_txt'].toString()) 
        : DateTime.now();
    int month = date.month;

    // Динамическая модель светового дня (приблизительно для широт Украины)
    double sunriseHour;
    double sunsetHour;
    double seasonalPeak; // Коэффициент максимальной высоты солнца (0.0 - 1.0)

    if (month == 12 || month == 1 || month == 2) { 
      sunriseHour = 7.5; sunsetHour = 16.0; seasonalPeak = 0.45; // Зима (короткий день, солнце низко)
    } else if (month == 3 || month == 4 || month == 5) { 
      sunriseHour = 6.0; sunsetHour = 19.5; seasonalPeak = 0.8;  // Весна
    } else if (month == 6 || month == 7 || month == 8) { 
      sunriseHour = 5.0; sunsetHour = 21.0; seasonalPeak = 1.0;  // Лето (длинный день, солнце в зените)
    } else { 
      sunriseHour = 6.5; sunsetHour = 18.0; seasonalPeak = 0.65; // Осень
    }

    // Точки для графика (соответствуют вашей оси X в UI)
    List<int> chartHours = [6, 9, 12, 15, 18, 21];

    for (int hour in chartHours) {
      // Ищем прогноз OpenWeather, который ближе всего к текущему часу
      Map<String, dynamic> closestForecast = {};
      int minDifference = 24; // Задаем заведомо большое начальное значение

      for (var f in todayForecasts) {
        DateTime dt = DateTime.parse(f['dt_txt'].toString());
        int difference = (dt.hour - hour).abs();
        
        // Если нашли прогноз, который ближе по времени, обновляем данные
        if (difference < minDifference) {
          minDifference = difference;
          closestForecast = f as Map<String, dynamic>;
        }
      }

      // Используем данные из найденного ближайшего прогноза
      double hourCloudiness = _currentCloudiness; 
      double hourRain = _currentRainMm;
      double hourTemp = _currentTemp;
      if (closestForecast.isNotEmpty && closestForecast['clouds'] != null) {
        hourCloudiness = (closestForecast['clouds']['all'] as num).toDouble();
      }
      if (closestForecast['rain'] != null && closestForecast['rain']['3h'] != null) {
          hourRain = (closestForecast['rain']['3h'] as num).toDouble();
        } else {
          hourRain = 0.0;
        }
        if (closestForecast['main'] != null) {
          hourTemp = (closestForecast['main']['temp'] as num).toDouble();
        }
        
      

      // 1. Расчет "идеальной" инсоляции в этот час по форме купола
      double baseFactor = 0.0;
      if (hour >= sunriseHour && hour <= sunsetHour) {
        // Синусоидальная модель от восхода до заката
        double progress = (hour - sunriseHour) / (sunsetHour - sunriseHour);
        baseFactor = math.sin(progress * math.pi); 
      }

      // Применяем сезонное снижение пика
      baseFactor *= seasonalPeak;

      // 2. Нелинейное влияние облачности из API
      double cloudFactor = _getCloudFactor(hourCloudiness);
      double rainFactor = _getRainFactor(hourRain);
double tempFactor = _getTemperatureFactor(hourTemp, baseFactor * cloudFactor);
      // 3. Итоговая мощность
      double generationAtHour = _totalSolarPeakKw * baseFactor * cloudFactor * rainFactor * tempFactor;
      
      // Защита от отрицательных значений
      generationAtHour = generationAtHour.clamp(0.0, _totalSolarPeakKw);
      
      spots.add(FlSpot(hour.toDouble(), double.parse(generationAtHour.toStringAsFixed(2))));
    }
    
    _todayChartSpots = spots;
  }
  void _parseWeatherData(List rawList) {
    final Map<String, List<dynamic>> groupedByDay = {};
    for (var item in rawList) {
      final dtTxt = item['dt_txt'].toString();
      final date = dtTxt.split(' ')[0];
      groupedByDay.putIfAbsent(date, () => []).add(item);
    }

    final dates = groupedByDay.keys.toList()..sort();
    if (dates.isEmpty) {
      _forecastDays = [];
      _todayGenerationKw = '0.0';
      _todayChartSpots = [];
      _currentCloudiness = 0.0;
      _currentRainMm = 0.0;
      _adviceText = 'Не вдалося розібрати погодні дані для міста $_selectedCity.';
      return;
    }

    // 1. Текущие погодные срезы
    final firstForecast = rawList[0];
    _currentCloudiness = (firstForecast['clouds']['all'] as num).toDouble();
    _currentTemp = (firstForecast['main']['temp'] as num).toDouble();
    _currentRainMm = 0.0;
    if (firstForecast['rain'] != null && firstForecast['rain']['3h'] != null) {
      _currentRainMm = (firstForecast['rain']['3h'] as num).toDouble();
    }

    // 2. Расчет генерации на СЕГОДНЯ
    final todayForecasts = groupedByDay[dates[0]]!;
    _generateChartSpots(todayForecasts);
    double todayTotalClouds = 0;
    double todayTotalRain = 0;
    double todayTotalTemp = 0;
    for (var f in todayForecasts) {
      todayTotalClouds += (f['clouds']['all'] as num).toDouble();
      todayTotalTemp += (f['main']['temp'] as num).toDouble(); 
      if (f['rain'] != null && f['rain']['3h'] != null) {
        todayTotalRain += (f['rain']['3h'] as num).toDouble();
      }
    }
    double todayAvgCloudiness = todayForecasts.isNotEmpty ? (todayTotalClouds / todayForecasts.length) : _currentCloudiness;
    double todayAvgRain = todayForecasts.isNotEmpty ? (todayTotalRain / todayForecasts.length) : _currentRainMm;
    double todayAvgTemp = todayForecasts.isNotEmpty ? (todayTotalTemp / todayForecasts.length) : _currentTemp; 
    DateTime todayDate = DateTime.parse(todayForecasts[0]['dt_txt'].toString());
    double todayExpectedGenerationWh = _calculateDailyGeneration(todayAvgCloudiness, todayAvgRain, todayAvgTemp, todayDate);
    _todayGenerationKw = (todayExpectedGenerationWh / 1000).toStringAsFixed(1);

    // 3. Прогноз на следующие 3 дня
    List<Map<String, dynamic>> computedDays = [];
    for (int i = 1; i < dates.length && computedDays.length < 3; i++) {
      final dateStr = dates[i];
      final dayForecasts = groupedByDay[dateStr]!;

      double maxTemp = -999;
      double minTemp = 999;
      double totalClouds = 0;
      double totalRain = 0;
      double totalTemp = 0; 
      String mainCondition = 'clear';
      String description = '';

      for (var f in dayForecasts) {
        final temp = (f['main']['temp'] as num).toDouble();
        if (temp > maxTemp) maxTemp = temp;
        if (temp < minTemp) minTemp = temp;
        totalTemp += temp;
        totalClouds += (f['clouds']['all'] as num).toDouble();
        if (f['rain'] != null && f['rain']['3h'] != null) {
          totalRain += (f['rain']['3h'] as num).toDouble();
        }
        if (f['dt_txt'].toString().contains('12:00') || f['dt_txt'].toString().contains('15:00')) {
          mainCondition = f['weather'][0]['main'].toString().toLowerCase();
          description = f['weather'][0]['description'].toString();
        }
      }
      
      if (description.isEmpty && dayForecasts.isNotEmpty) {
        mainCondition = dayForecasts[0]['weather'][0]['main'].toString().toLowerCase();
        description = dayForecasts[0]['weather'][0]['description'].toString();
      }

      double avgCloudiness = totalClouds / dayForecasts.length;
      double avgRain = totalRain / dayForecasts.length; 
      double avgTemp = totalTemp / dayForecasts.length;
      DateTime dayDate = DateTime.parse(dayForecasts[0]['dt_txt'].toString());
double expectedGenerationWh = _calculateDailyGeneration(avgCloudiness, avgRain, avgTemp, dayDate);
      computedDays.add({
        'dateLabel': i == 1 ? 'Завтра' : (i == 2 ? 'Післязавтра' : 'Через 3 дні'),
        'tempRange': '${maxTemp.round()}° / ${minTemp.round()}°',
        'condition': mainCondition,
        'description': description,
        'generationKw': (expectedGenerationWh / 1000).toStringAsFixed(1),
        'cloudiness': avgCloudiness,
      });
    }

    _forecastDays = computedDays;

    // 4. Формирование умных советов на основе Performance Ratio
    if (_forecastDays.isNotEmpty) {
      final double todayGenKwh = double.tryParse(_todayGenerationKw) ?? 0.0;

      if (_totalSolarPeakKw == 0) {
        _adviceText = 'У вашому профілі Nuvit не виявлено активних сонячних панелей. Додайте СЕС для розрахунку прогнозу.';
      } else {
        // Вычисляем максимально возможную генерацию для ТЕКУЩЕГО дня при ИДЕАЛЬНОЙ погоде
        // (0% облаков, 0мм осадков, базовая температура STC 25°C)
        double idealGenerationWh = _calculateDailyGeneration(0.0, 0.0, 25.0, todayDate);
        double idealGenerationKwh = idealGenerationWh / 1000.0;

        // Рассчитываем соотношение реального прогноза к идеальному потенциалу дня
        double performanceRatio = idealGenerationKwh > 0 ? (todayGenKwh / idealGenerationKwh) : 0.0;
        int efficiencyPercent = (performanceRatio * 100).round();

        if (performanceRatio >= 0.85) {
          // Отличный день (>85% от идеала)
          _adviceText = 'Сьогодні очікується чудова сонячна погода (ефективність дня ~$efficiencyPercent%). Очікуємо ~$_todayGenerationKw кВт·год. Рекомендуємо максимальне навантаження вдень!';
        } else if (performanceRatio >= 0.60) {
          // Хороший / умеренный день (60% - 85%)
          _adviceText = 'Сьогодні очікується помірна інсоляція. Прогнозований виробіток: $_todayGenerationKw кВт·год (~$efficiencyPercent% від потенціалу системи). Базові прилади працюватимуть оптимально.';
        } else if (performanceRatio >= 0.35) {
          // Сниженная генерация (35% - 60%)
          _adviceText = 'Сьогодні хмарність або опади знижують ефективность СЕС до ~$efficiencyPercent%. Прогноз: $_todayGenerationKw кВт·год. Переведіть енергоємні прилади на години пікової генерації або нічний буфер.';
        } else {
          // Слабая генерация (<35%)
          _adviceText = 'Вкрай слабка генерація через негоду: всього $_todayGenerationKw кВт·год (~$efficiencyPercent% від норми). Рекомендується мінімізувати споживання та розраховувати на мережу або АКБ.';
        }
      }
    }
  }

double _getEffectiveSunHours(double lat, DateTime date) {
    // 1. Точный расчет дня года с учетом календарных нюансов и високосности
    final startOfYear = DateTime(date.year, 1, 1);
    final int dayOfYear = date.difference(startOfYear).inDays + 1;

    // 2. Склонение солнца (в радианах)
    double declinationDeg = 23.45 * math.sin((360.0 / 365.0) * (dayOfYear - 81.0) * math.pi / 180.0);
    double declinationRad = declinationDeg * math.pi / 180.0;
    double latRad = lat * math.pi / 180.0;

    // 3. Расчет часового угла захода солнца (omega)
    double tanLat = math.tan(latRad);
    double tanDecl = math.tan(declinationRad);
    double cosOmega = -tanLat * tanDecl;
    cosOmega = cosOmega.clamp(-1.0, 1.0); 
    double omega = math.acos(cosOmega);

    // 4. Длина светового дня в часах
    double daylightHours = (2.0 * omega * 180.0 / math.pi) / 15.0;

    // 5. Максимальная высота солнца (в зените)
    double maxElevationDeg = 90.0 - (lat - declinationDeg).abs();
    double maxElevationRad = maxElevationDeg * math.pi / 180.0;

    // 6. Расчет PSH (Peak Sun Hours)
    double psh = daylightHours * math.sin(maxElevationRad) * 0.45;

    return psh.clamp(0.5, 8.0); 
  }
  double _calculateDailyGeneration(double cloudiness, double rainMm, double tempC, DateTime date) {
    if (_systemSettings == null || _totalSolarPeakKw == 0) return 0.0;
    double totalWh = 0.0;
    
    // --> НОВОЕ: Динамические часы вместо const 4.5
    double effectiveSunHours = _getEffectiveSunHours(_cityLatitude, date); 

    for (var array in _systemSettings!.solarArrays) {
      double baseArrayGenerationWh = array.peakPowerKw * 1000 * effectiveSunHours;
      double arrayEfficiency = array.orientationFactor * array.tiltFactor * array.shadingFactor * array.mountFactor * array.lifetimeFactor;
      if (array.bifacial) arrayEfficiency += (array.albedoBonus * 0.1);
      
      // Здесь используем ваш нелинейный метод, который мы сделали на предыдущем шаге
      double cloudImpact = _getCloudFactor(cloudiness); 
      double rainImpact = _getRainFactor(rainMm);
      double tempImpact = _getTemperatureFactor(tempC, 0.5 * cloudImpact);
      double invEfficiency = EssSystemLoader.averageInverterEfficiency(_systemSettings!.inverters) / 100.0;

      totalWh += baseArrayGenerationWh * arrayEfficiency * cloudImpact * rainImpact * tempImpact * invEfficiency;
    }
    return totalWh;
  }
double _getCloudFactor(double cloudiness) {
    if (cloudiness <= 0) return 1.0;
    if (cloudiness <= 20) return 1.0 - (cloudiness / 20.0) * 0.05;          // от 1.0 до 0.95
    if (cloudiness <= 40) return 0.95 - ((cloudiness - 20.0) / 20.0) * 0.15; // от 0.95 до 0.80
    if (cloudiness <= 60) return 0.80 - ((cloudiness - 40.0) / 20.0) * 0.25; // от 0.80 до 0.55
    if (cloudiness <= 80) return 0.55 - ((cloudiness - 60.0) / 20.0) * 0.30; // от 0.55 до 0.25
    if (cloudiness <= 100) return 0.25 - ((cloudiness - 80.0) / 20.0) * 0.15;// от 0.25 до 0.10
    return 0.10;
  }
  double _getRainFactor(double rainMm) {
    if (rainMm <= 0) return 1.0;
    // от 0 до 2 мм -> от 1.0 до 0.92
    if (rainMm <= 2.0) return 1.0 - (rainMm / 2.0) * 0.08;          
    // от 2 до 5 мм -> от 0.92 до 0.82
    if (rainMm <= 5.0) return 0.92 - ((rainMm - 2.0) / 3.0) * 0.10; 
    // от 5 до 10 мм -> от 0.82 до 0.65
    if (rainMm <= 10.0) return 0.82 - ((rainMm - 5.0) / 5.0) * 0.17; 
    // более 10 мм -> плавно снижаем до 0.50 (максимальный штраф)
    return 0.65 - ((rainMm - 10.0).clamp(0.0, 20.0) / 20.0) * 0.15; 
  }
  double _getTemperatureFactor(double ambientTempC, double sunIntensity) {
    // 1. Считаем температуру самой панели. 
    // На ярком солнце панель греется примерно на 25°C выше воздуха.
    double panelTempC = ambientTempC + (sunIntensity * 25.0);

    // 2. Стандартные условия тестирования (STC) = 25°C.
    // Падение мощности: -0.4% на каждый градус нагрева.
    double tempDifference = panelTempC - 25.0;
    double factor = 1.0 - (tempDifference * 0.004); 
    
    // ИСПРАВЛЕНО: Ограничиваем максимальный зимний бонус до +8% (1.08).
    // Это компенсирует отсутствие сложных метеорологических параметров (ветер, NOCT).
    return factor.clamp(0.70, 1.08); 
  }
  IconData _getWeatherIcon(String condition) {
    if (condition.contains('clear') || condition.contains('sun')) return Icons.wb_sunny;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('rain')) return Icons.water_drop;
    if (condition.contains('snow')) return Icons.ac_unit;
    return Icons.wb_cloudy_outlined;
  }

  void _showCitySelectionDialog() {
    final TextEditingController controller = TextEditingController(text: _selectedCity);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: kNeonGreen.withOpacity(0.3), width: 1), // ИСПРАВЛЕНО ЗДЕСЬ
        ),
        title: const Text('Виберіть місто', style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: kTextPrimary),
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: kInnerBackground,
            hintText: 'Наприклад: Lviv, Odesa, Berlin',
            hintStyle: TextStyle(color: kTextSecondary.withOpacity(0.4), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kNeonGreen, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати', style: TextStyle(color: kTextSecondary, fontSize: 13)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kNeonGreen,
              foregroundColor: kAppBackground,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _selectedCity = text;
                });
                Navigator.pop(context);
                _loadSystemAndWeatherData(); 
              }
            },
            child: const Text('Застосувати', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 1100;

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
          ],
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
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Центрируем иконку редактирования по высоте текста
          children: [
            Flexible(
              child: Text(
                // Оптимизируем длину строки для мобильных устройств, чтобы сберечь место
                isMobile 
                    ? 'Прогноз для м. $_selectedCity' 
                    : 'Прогноз генерації для м. $_selectedCity',
                style: const TextStyle(
                  color: kTextPrimary, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2, // Разрешаем перенос на 2 строки — теперь даже длинные города не пропадут
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _showCitySelectionDialog,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kInnerBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.edit_location_alt_outlined, color: kNeonGreen, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Оцінка інсоляції та виробітку системи СЕС',
          style: TextStyle(color: kTextSecondary, fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );

    if (isMobile) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Иконка солнца останется сверху, если текст перенесется на 2 строки
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2), // Аккуратное выравнивание иконки солнца по первой строке
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
    String todayGen = _todayGenerationKw;
    
    // Исправленная логика расчета в кВт·ч
    double averageDayKwh = _totalSolarPeakKw * 3.5;
    double todayGenKwh = double.tryParse(todayGen) ?? 0.0;
    
    int percentage = averageDayKwh > 0 
        ? ((todayGenKwh / averageDayKwh) * 100).round().clamp(0, 150) 
        : 0;

    return _InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Очікувана генерація сьогодні', style: TextStyle(color: kTextSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(todayGen, style: const TextStyle(color: kTextPrimary, fontSize: 32, fontWeight: FontWeight.bold, height: 1.0)),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text('кВт·год', style: TextStyle(color: kTextSecondary, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 5,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              // Ограничиваем ширину бара до 1.0 (100%), чтобы UI не сломался при сверхгенерации
              widthFactor: percentage > 0 ? (percentage.clamp(0, 100) / 100.0) : 0.01,
              child: Container(
                decoration: BoxDecoration(
                  color: kNeonGreen,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('$percentage% від середнього виробітку', style: const TextStyle(color: kTextSecondary, fontSize: 11)),
        ],
      ),
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
      
      // Формуємо чесний текстовий статус замість фейкового тренду
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
              // Виводимо зрозумілий опис потенціалу
              Text(
                statusText, 
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              // Та фактичний відсоток хмарності без стрілок
              Text(
                'Хмарність: ${cloudiness.round()}%', 
                style: const TextStyle(color: kTextSecondary, fontSize: 10),
              ),
            ],
          ),
        ),
      );
      
      // Розділювач між днями
      if (i < _forecastDays.length - 1) {
        children.add(Container(width: 1, height: 70, color: Colors.white10));
      }
    }

    return _InnerCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: children));
  }

  Widget _buildHourlyChartCard() {
    if (_totalSolarPeakKw == 0) {
      return const _InnerCard(
        child: SizedBox(
          height: 140,
          child: Center(
            child: Text('[Будь ласка, додайте сонячну панель]', style: TextStyle(color: kTextSecondary)),
          ),
        ),
      );
    }

    // Ищем максимальную точку для корректного отображения пика в заголовке
    double todayMaxExpected = 0.0;
    if (_todayChartSpots.isNotEmpty) {
      todayMaxExpected = _todayChartSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    }

    return _InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Прогноз інсоляції (сьогодні)', style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              Text('Пік: ${todayMaxExpected.toStringAsFixed(1)} кВт', style: const TextStyle(color: kNeonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: LineChart(
              LineChartData(
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
                        String text = '';
                        switch (value.toInt()) {
                          case 6: text = '06:00'; break;
                          case 9: text = '09:00'; break;
                          case 12: text = '12:00'; break;
                          case 15: text = '15:00'; break;
                          case 18: text = '18:00'; break;
                          case 21: text = '21:00'; break;
                        }
                        return Text(text, style: const TextStyle(color: kTextSecondary, fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 6,
                maxX: 21,
                minY: 0,
                // Немного запаса по высоте оси Y для красоты графика
                maxY: _totalSolarPeakKw > 0 ? _totalSolarPeakKw * 1.1 : 5, 
                lineBarsData: [
                  LineChartBarData(
                    // --> ПЕРЕДАЕМ НАШ ДИНАМИЧЕСКИЙ МАССИВ ТУТ <--
                    spots: _todayChartSpots.isEmpty 
                        ? [const FlSpot(6, 0), const FlSpot(12, 0), const FlSpot(21, 0)] 
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
          _buildFactorRow(Icons.water_drop_outlined, 'Опади', '${_currentRainMm.toStringAsFixed(1)} мм', _currentRainMm > 0 ? Colors.blueAccent : kNeonGreen),
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
    return _InnerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Розумні поради AI', style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kNeonGreen.withOpacity(0.04),
              border: Border.all(color: kNeonGreen.withOpacity(0.12)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_adviceText.isNotEmpty ? _adviceText : 'Оновлення...', style: const TextStyle(color: kTextSecondary, fontSize: 11, height: 1.3)),
          ),
        ],
      ),
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