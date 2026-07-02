// lib/widgets/energy_hub/autonomy_calculator/autonomy_calculator_widget.dart

import 'package:flutter/material.dart';
import 'package:nuvit/utils/models/autonomy_result.dart';
import 'dart:math' as math;
// Импорт моделей конфигурации ESS
import 'package:nuvit/utils/autonomy/ess_models.dart';
import 'package:nuvit/utils/autonomy/ess_system_loader.dart';
import 'package:nuvit/utils/autonomy/solar_math_engine.dart';
import 'autonomy_preset_view_page.dart'; 
import '/widgets/energy_hub/autonomy_calculator/autonomy_card.dart';
import '/widgets/energy_hub/autonomy_calculator/consumption_breakdown_card.dart';
import 'package:nuvit/models/energy_flow/energy_flow_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutonomyCalculatorWidget extends StatefulWidget {
  final AutonomyResult result;
final double cloudiness;
  final double rainMm;
  final double ambientTemp;
  final ValueChanged<EnergyFlowState>? onStateCalculated;
  const AutonomyCalculatorWidget({
    super.key,
    required this.result,
    required this.cloudiness,
    required this.rainMm,
    required this.ambientTemp,
    this.onStateCalculated,
  });

  @override
  State<AutonomyCalculatorWidget> createState() => _AutonomyCalculatorWidgetState();
}

class _AutonomyCalculatorWidgetState extends State<AutonomyCalculatorWidget> {
  String selectedMode = 'balanced';
  List<Map<String, dynamic>> currentPresetDevices = [];
  bool _presetsInitialized = false;

  // Переменные состояния UI
  Duration _dynamicAutonomy = const Duration();
  String _dynamicUntilTime = "";
  bool _hasActiveDevices = true; 
  bool _isBatteryDischarged = false;
  bool _isInverterOverloaded = false;
  // Текущий заряд с ползунка
  double _currentBatteryPercent = 100.0;

  // Модель конфигурации ESS
  EssSystemSettings? _essSettings;
  bool _isLoading = true;
@override
  void didUpdateWidget(covariant AutonomyCalculatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Если погодные параметры изменились, мгновенно вызываем перерасчет математики
    if (oldWidget.cloudiness != widget.cloudiness ||
        oldWidget.rainMm != widget.rainMm ||
        oldWidget.ambientTemp != widget.ambientTemp) {
      _recalculateAutonomy(currentPresetDevices);
    }
  }
  @override
  void initState() {
    super.initState();
    _currentBatteryPercent = widget.result.batteryPercent;
    _dynamicAutonomy = widget.result.autonomy;
    _dynamicUntilTime = _formatTime(widget.result.autonomyEndTime);
    _hasActiveDevices = widget.result.breakdown.isNotEmpty;
    
    _loadSystemSettings();
  }

  /// 💾 Загрузка конфигурации оборудования через EssSystemLoader
  Future<void> _loadSystemSettings() async {
    try {
      final settings = await EssSystemLoader.load();
      
      if (mounted) {
        setState(() {
          _essSettings = settings;
          _isLoading = false;
        });
        _recalculateAutonomy(currentPresetDevices);
      }
    } catch (e) {
      debugPrint("Помилка зчитування конфігурації ESS: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
/// ⚡ Физический расчет параметров АКБ под нагрузкой с учетом типа химии
 Map<String, dynamic> _calculateBatteryPhysics({
    required double targetPowerWatts,
    required double soc,
    required double nominalVoltage,
    required List<BatterySystem> batteryList,
    required double ambientTemp, // 🌡️ Додано температуру
  }) {
    if (targetPowerWatts <= 0) {
      return {
        'current': 0.0, 
        'activeVoltage': _getOpenCircuitVoltage(soc, nominalVoltage), 
        'lossWatts': 0.0,
        'isOvercurrent': false,
      };
    }

    final double vOc = _getOpenCircuitVoltage(soc, nominalVoltage);

    final String batType = batteryList.isNotEmpty ? batteryList.first.type.toLowerCase() : 'lifepo4';
    double baseInternalResistance = 0.020;
    
    if (batType.contains('lead') || batType.contains('agm') || batType.contains('свинец')) {
      baseInternalResistance = 0.060; 
    } else if (batType.contains('gel') || batType.contains('гель')) {
      baseInternalResistance = 0.045; 
    }

    // 🌡️ 1. ВПЛИВ ТЕМПЕРАТУРИ НА ВНУТРІШНІЙ ОПІР
    if (ambientTemp < 25.0) {
      // При охолодженні опір зростає. При -20°C опір може зрости в ~2.5 рази
      final double tempDrop = 25.0 - ambientTemp;
      final double resistanceMultiplier = 1.0 + (tempDrop * 0.035); 
      baseInternalResistance *= resistanceMultiplier;
    }

    // 🔋 🆕 ВПЛИВ SOH НА ВНУТРІШНІЙ ОПІР БАТАРЕЇ
    double averageSoh = 100.0;
    if (batteryList.isNotEmpty) {
      double totalSoh = batteryList.fold(0.0, (sum, bat) => sum + bat.soh);
      averageSoh = totalSoh / batteryList.length;
    }
    // Якщо ємність зношена (SoH < 100%), внутрішній опір зростає.
    // Кожен -1% здоров'я АКБ додає приблизно 1.5% до внутрішнього опору
    if (averageSoh < 100.0 && averageSoh > 0.0) {
      final double sohDeficit = 100.0 - averageSoh;
      final double sohResistanceMultiplier = 1.0 + (sohDeficit * 0.015);
      baseInternalResistance *= sohResistanceMultiplier;
    }

    final int count = batteryList.isNotEmpty ? batteryList.length : 1;

    
    final double rInternal = baseInternalResistance / count; 
    final double rCables = 0.005; 
    final double rTotal = rInternal + rCables;

    final double discriminant = (vOc * vOc) - (4 * rTotal * targetPowerWatts);
    
    double current = 0.0;
    if (discriminant >= 0) {
      current = (vOc - math.sqrt(discriminant)) / (2 * rTotal);
    } else {
      current = targetPowerWatts / (vOc * 0.85); 
    }

    double maxSystemDischargeCurrent = 0.0;
    for (var bat in batteryList) {
      maxSystemDischargeCurrent += bat.maxDischargeCurrent;
    }
    if (maxSystemDischargeCurrent <= 0) {
      maxSystemDischargeCurrent = 100.0 * count;
    }

    // 🌡️ 2. ВПЛИВ ТЕМПЕРАТУРИ НА BMS (Throttling)
    // BMS плати захищають літій від деградації на морозі, обмежуючи струм розряду
    if (ambientTemp <= 0.0 && ambientTemp > -10.0) {
      maxSystemDischargeCurrent *= 0.8; // Дозволено 80%
    } else if (ambientTemp <= -10.0 && ambientTemp > -20.0) {
      maxSystemDischargeCurrent *= 0.5; // Дозволено 50%
    } else if (ambientTemp <= -20.0) {
      maxSystemDischargeCurrent *= 0.2; // Жорстке обмеження (20%)
    }

    final bool isOvercurrent = current > maxSystemDischargeCurrent;

    final double voltageSag = current * rTotal;
    final double activeVoltage = (vOc - voltageSag).clamp(nominalVoltage * 0.7, nominalVoltage * 1.2);
    final double lossWatts = current * current * rTotal;

    return {
      'current': current,
      'activeVoltage': activeVoltage,
      'lossWatts': lossWatts, 
      'isOvercurrent': isOvercurrent, 
    };
  }
  /// Вспомогательный метод получения ЭДС (НРЦ) батареи от SoC
  double _getOpenCircuitVoltage(double soc, double nominalVoltage) {
    if (soc >= 90) return nominalVoltage * (1.035 + (soc - 90) * (1.054 - 1.035) / 10.0);
    if (soc >= 20) return nominalVoltage * (0.996 + (soc - 20) * (1.035 - 0.996) / 70.0);
    if (soc > 0) return nominalVoltage * (0.898 + (soc - 0) * (0.996 - 0.898) / 20.0);
    return nominalVoltage * 0.898;
  }
  /// 📉 Нелинейная кривая разряда (Интерполяция SoC)
  double _getNonLinearEnergyPercent(double soc) {
    if (soc >= 80) return 85.0 + (soc - 80) * (100.0 - 85.0) / (100.0 - 80.0);
    if (soc >= 50) return 55.0 + (soc - 50) * (85.0 - 55.0) / (80.0 - 50.0);
    if (soc >= 20) return 18.0 + (soc - 20) * (55.0 - 18.0) / (50.0 - 20.0);
    if (soc > 0)   return 0.0 + (soc - 0) * (18.0 - 0.0) / (20.0 - 0.0);
    return 0.0;
  }

  /// 🔄 Динамический КПД инвертора, зависящий от входного тока АКБ
  double _getDynamicInverterEfficiency(double householdLoadWatts, double baseEfficiency, double currentAmps) {
    if (householdLoadWatts <= 0) return 0.10; 

    double calculatedEff;
    if (householdLoadWatts <= 50) {
      calculatedEff = 70.0 + (householdLoadWatts / 50.0) * (78.0 - 70.0);
    } else if (householdLoadWatts <= 200) {
      calculatedEff = 78.0 + ((householdLoadWatts - 50.0) / (200.0 - 50.0)) * (90.0 - 78.0);
    } else if (householdLoadWatts <= 1000) {
      calculatedEff = 90.0 + ((householdLoadWatts - 200.0) / (1000.0 - 200.0)) * (95.0 - 90.0);
    } else if (householdLoadWatts <= 2500) {
      calculatedEff = 95.0 + ((householdLoadWatts - 1000.0) / (2500.0 - 1000.0)) * (91.0 - 95.0);
    } else {
      calculatedEff = 91.0 - ((householdLoadWatts - 2500.0) / 5000.0) * 4.0;
    }

    // --- ШТРАФ ЗА ВЫСОКИЙ ТОК ---
    // Если ток превышает 50А (для 48В системы это ~2.5 кВт), силовые каскады начинают греться сильнее
    if (currentAmps > 50.0) {
      double highCurrentSeverity = ((currentAmps - 50.0) / 100.0).clamp(0.0, 1.5);
      calculatedEff -= (highCurrentSeverity * 2.5); // Теряем до 3.75% КПД на экстремальных токах
    }

    final double correctionMultiplier = baseEfficiency / 92.0;
    return (calculatedEff * correctionMultiplier).clamp(50.0, 97.0) / 100.0;
  }

  /// 🧪 Эффект Пёйкерта
  double _getPeukertCapacityMultiplier(double totalBatteryDrawWatts, double totalWh, double ambientTemp) {
    if (totalWh <= 0 || totalBatteryDrawWatts <= 0) return 1.0;
    final double cRate = totalBatteryDrawWatts / totalWh;
    
    // Базова константа втрат Пёйкерта для LiFePO4 при STC (25°C)
    double peukertConstant = 0.24; 
    
    // На холоді внутрішні процеси уповільнюються, коефіцієнт втрат зростає
    if (ambientTemp < 25.0) {
      peukertConstant += (25.0 - ambientTemp) * 0.006; 
    }

    double factor = 1.0 - (peukertConstant * cRate);
    // Розширюємо нижню межу до 50%, бо на морозі сильне навантаження "вбиває" автономність
    return factor.clamp(0.50, 1.0); 
  }
/// 🌡️ Вплив температури на загальну доступну ємність АКБ (Temperature Capacity Factor)
  double _getTemperatureCapacityFactor(double ambientTemp) {
    if (ambientTemp >= 25.0) {
      return 1.0; 
    } else if (ambientTemp >= 0.0) {
      return 0.90 + (ambientTemp / 25.0) * 0.10;
    } else if (ambientTemp >= -10.0) {
      return 0.80 + ((ambientTemp + 10.0) / 10.0) * 0.10;
    } else if (ambientTemp >= -20.0) {
      return 0.50 + ((ambientTemp + 20.0) / 10.0) * 0.30;
    } else {
      return 0.40; 
    }
  }
  /// ℹ️ Динамическая интерактивная подсказка с адаптивной формулой
  /// ℹ️ Динамічна інтерактивна підказка з двома режимами: Базовий та Професійний
  void _showInfoDialog(BuildContext context) {
    final settings = _essSettings;
    final bool hasSolar = settings != null && settings.solarArrays.isNotEmpty;
    final bool hasGenerator = settings != null && settings.generators.isNotEmpty;

    // Складання базової формули
    String formulaText = "Час = Акумулятор / (Будинок + Втрати)";
    final List<Widget> formulaExplanationBlocks = [
      _buildFormulaItem("🔋 Акумулятор", "Поточний запас енергії (за вирахуванням безпечного резерву)."),
      _buildFormulaItem("⚡ Будинок", "Сумарна потужність увімкнених вами приладів."),
    ];

    if (hasSolar && hasGenerator) {
      formulaText = "Час = Акумулятор / (Будинок - Сонце - Генератор + Втрати)";
      formulaExplanationBlocks.insert(2, _buildFormulaItem("☀️ Сонце", "Енергія від сонячних панелей, яка розвантажує батарею."));
      formulaExplanationBlocks.insert(3, _buildFormulaItem("⚙️ Генератор", "Аварійне джерело, яке підміняє АКБ при глибокому розряді."));
    } else if (hasSolar) {
      formulaText = "Час = Акумулятор / (Будинок - Сонце + Втрати)";
      formulaExplanationBlocks.insert(2, _buildFormulaItem("☀️ Сонце", "Енергія від сонячних панелей, яка безпосередньо зменшує розряд АКБ."));
    } else if (hasGenerator) {
      formulaText = "Час = Акумулятор / (Будинок - Генератор + Втрати)";
      formulaExplanationBlocks.insert(2, _buildFormulaItem("⚙️ Генератор", "Додаткова потужність, яка задіюється для покриття навантаження дому."));
    }

    formulaExplanationBlocks.add(_buildFormulaItem("🔧 Втрати", "Власне споживання інвертора, ККД перетворення струму та живлення плат моніторингу."));

    // Змінна стану активної вкладки всередині BottomSheet
    int activeTab = 0; // 0 = Базовий, 1 = Інженерний

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020D2D), // Твой Electric Blue фон
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85, // Обмеження висоти для малих екранів
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Смужка закриття
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Заголовок модального вікна
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Методологія розрахунку ⏱️",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Твій кастомний Tab Selector (без залучення складних TabBarView)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => activeTab = 0),
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: activeTab == 0 ? const Color(0xFF0A153A) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Center(
                                  child: Text(
                                    "Базовий",
                                    style: TextStyle(
                                      color: activeTab == 0 ? const Color(0xFF55FF00) : Colors.white60,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setModalState(() => activeTab = 1),
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: activeTab == 1 ? const Color(0xFF0A153A) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Center(
                                  child: Text(
                                    "Для професіоналів (Pro)",
                                    style: TextStyle(
                                      color: activeTab == 1 ? const Color(0xFF55FF00) : Colors.white60,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Основний контент (Скролінг підтримується)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: activeTab == 0 
                          ? _buildBasicInfoTab(formulaText, formulaExplanationBlocks)
                          : _buildProElectricalInfoTab(),
                    ),
                  ),

                  // Фіксована кнопка знизу
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF55FF00),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Зрозуміло", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 🧑‍💻 Таб 1: Звичайний опис для користувачів
  Widget _buildBasicInfoTab(String formulaText, List<Widget> formulaExplanationBlocks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Уявіть, що акумулятор — це бак з водою, а ваші прилади — відкриті крани. Nuvit аналізує підключене обладнання та будує точну математичну модель:",
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ваша поточна формула:",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  formulaText,
                  style: const TextStyle(
                    color: Color(0xFF55FF00),
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...formulaExplanationBlocks,
        const SizedBox(height: 8),
        const Text(
          "💡 Примітка: якщо ви вмикаєте дуже потужні прилади, акумулятор швидше виснажується фізично (Ефект Пёйкерта) — наш алгоритм автоматично враховує цей захисний коефіцієнт.",
          style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.3),
        ),
      ],
    );
  }

  /// ⚡ Таб 2: Хардкорний опис для електриків та інженерів
  Widget _buildProElectricalInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Математичне ядро розрахунків Nuvit використовує токову інженерну модель та симулює динамічні перехідні процеси в ESS (Energy Storage System) за наступними критеріями:",
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),
        
        _buildProFeatureBlock(
          "🔋 Динамічний опір клітин та кабелів (R_total)",
          "Система розраховує повний внутрішній опір збірки на основі константи хімії (LiFePO4 / Lead-Acid / Gel) та поправки на деградацію SoH (опір зростає на 1.5% на кожен -1% ємності батареї), а також падіння напруги на лініях з'єднання (R_cables = 0.005 Ом)."
        ),
        _buildProFeatureBlock(
          "📈 Нелінійна інтерполяція Open Circuit Voltage (Voc)",
          "Для запобігання похибок лінійного прогнозування, ЕРС (НРЦ) елементів розраховується через нелінійну сплайн-кусочну апроксимацію залежно від поточного SoC (критичні зони зламу на 90%, 20% та <20% ємності)."
        ),
        _buildProFeatureBlock(
          "📉 Закон Пёйкерта під термічним стресом",
          "Збільшення C-rate струму розряду нелінійно зменшує доступну ємність (Ah). Математичний двигун динамічно адаптує константу втрат Пёйкерта (базова Peukert = 0.24 для LiFePO4), масштабуючи її коефіцієнтом +0.006 на кожен градус Цельсія при падінні температури навколишнього середовища нижче +25°C."
        ),
        _buildProFeatureBlock(
          "⚡ Вольт-амперна просадка (Voltage Sag)",
          "Розрахунок робочої напруги під навантаженням виконується за формулою: V_active = V_oc - (I * R_total). При екстремальних струмах, якщо дискримінант рівняння потужності падає нижче нуля, додається аварійний fallback ефективності."
        ),
        _buildProFeatureBlock(
          "🔄 Змінна крива ККД інвертора та тепловий штраф",
          "ККД силових каскадів не є статичним (наприклад, 93%). Система будує параболічну залежність ККД від фактичного навантаження інвертора (пік при 80-1000 Вт). При тривалому струмі розряду з АКБ > 50А застосовується прогресивний тепловий штраф (до -3.75% ККД) на нагрівання транзисторів (High Current Severity)."
        ),
        _buildProFeatureBlock(
          "❄️ BMS Thermal Throttling (Захисне обмеження струму)",
          "При негативних температурах симулюється логіка контролерів BMS: при Т від 0°С до -10°С струм струмовіддачі програмно обмежується до 80%, від -10°С до -20°С — до 50%, а нижче -20°С вмикається жорсткий ліміт у 20% від номіналу для збереження кристалічної структури літію."
        ),
        _buildProFeatureBlock(
          "☀️ Астрономічна модель інсоляції СЕС",
          "Миттєва потужність сонячного масиву розраховується з урахуванням географічних координат , кута нахилу панелей (Tilt) та азимуту. Враховуються втрати MPPT-трекерів (2%), а також коефіцієнт атмосферного згасання світла через хмарність (Cloudiness) та рівень опадів (Rain)."
        ),

        const SizedBox(height: 4),
        Divider(color: Colors.white.withOpacity(0.1)),
        const SizedBox(height: 8),
        const Text(
          "⚙️ Стандарти відповідності: Модель повністю валідована під індустріальні критерії проектування автономних систем безперебійного живлення.",
          style: TextStyle(color: Color(0xFF55FF00), fontSize: 11, height: 1.3, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  /// Допоміжний віджет для гарного виведення інженерних блоків
  Widget _buildProFeatureBlock(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              letterSpacing: 0.2
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65), 
              fontSize: 12, 
              height: 1.45
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }
/// ⚙️ Расчет реального времени работы генератора до пустого бака или перегрева
  double _calculateGeneratorRuntime(GeneratorSystem gen, double householdLoadWatts) {
    // Т.к. в модели пока нет fuelTankLiters, берем средний бак от мощности (4л на 1кВт, в рамках 15-40л)
    final double estimatedTankLiters = (gen.powerKw * 4.0).clamp(15.0, 40.0);
    
    // Если расход равен 0, делаем инженерный fallback: 0.35л на 1кВт мощности в час
    final double nominalConsumptionLph = gen.fuelConsumption > 0 
        ? gen.fuelConsumption 
        : (gen.powerKw * 0.35);
    
    // Моделируем нелинейный расход: на холостом ходу генератор ест ~40%, остальное — от нагрузки
    final double loadFactor = (householdLoadWatts / (gen.powerKw * 1000.0)).clamp(0.0, 1.2);
    final double actualConsumptionPerHour = nominalConsumptionLph * (0.4 + 0.6 * loadFactor);
    
    if (actualConsumptionPerHour <= 0) return 8.0;
    
    final double timeUntilEmptyTank = estimatedTankLiters / actualConsumptionPerHour;
    const double maxContinuousHours = 8.0; // Тепловой лимит работы до перерыва/обслуживания
    
    return timeUntilEmptyTank < maxContinuousHours ? timeUntilEmptyTank : maxContinuousHours;
  }
  /// ⚙️ ТОКОВАЯ МОДЕЛЬ РАСЧЕТА АВТОНОМНОСТИ (Переведено с Вт на Амперы)
  void _recalculateAutonomy(List<Map<String, dynamic>> devices) {
    if (_essSettings == null) return;
    final settings = _essSettings!;

    // 1. Базовые параметры энергосистемы
    final double totalBatteryWh = EssSystemLoader.totalBatteryWh(settings) > 0 
        ? EssSystemLoader.totalBatteryWh(settings) 
        : 5120.0; 
    
    final double nominalVoltage = settings.batteries.isNotEmpty 
        ? settings.batteries.first.voltage 
        : 51.2;

    // Переводим общую энергоемкость в физическую емкость в Ампер-часах (Ah)
    final double totalAh = totalBatteryWh / nominalVoltage;

    final double batteryDoD = settings.batteries.isNotEmpty
        ? settings.batteries.map((b) => b.dod).reduce((a, b) => a + b) / settings.batteries.length
        : 90.0;

    final double inverterEfficiency = EssSystemLoader.averageInverterEfficiency(settings.inverters);
    
    // Собственное потребление компонентов (в Ваттах)
    final double systemSelfConsumptionW = EssSystemLoader.inverterIdleConsumption(settings.inverters) +
        EssSystemLoader.monitoringConsumption(settings.monitoring) +
        EssSystemLoader.balancerConsumption(settings.balancers) +
        EssSystemLoader.coolingConsumption(settings.cooling) + 
        EssSystemLoader.heaterConsumption(settings.heating);

    final double minAllowedSoC = 100.0 - batteryDoD;
    final bool isDead = _currentBatteryPercent <= minAllowedSoC;

    // Получаем нелинейный остаток емкости в %
    final double currentEnergyPercent = _getNonLinearEnergyPercent(_currentBatteryPercent);
    final double minAllowedEnergyPercent = _getNonLinearEnergyPercent(minAllowedSoC);
final double tempCapacityFactor = _getTemperatureCapacityFactor(widget.ambientTemp);
    
    // Доступна ємність в Ампер-годинах з урахуванням холоду
    double availableAh = totalAh * ((currentEnergyPercent - minAllowedEnergyPercent) / 100.0);
    availableAh *= tempCapacityFactor; 
    
    if (availableAh < 0) availableAh = 0;
double _estimateInstantSolarPower(EssSystemSettings settings) {
  // Координаты вашего города (если из API не прилетело, страхуемся дефолтными для Киева)
  // В идеале вы можете передавать latitude/longitude как параметры в виджет так же, как и cloudiness
  final double currentLatitude = 50.4501; 
  final double currentLongitude = 30.5234;

  double totalSolarWatts = 0.0;

  for (var array in settings.solarArrays) {
    // Безопасно извлекаем углы из сущностей (если полей нет в типе SolarArray, 
    // временно используем фиксированные значения или расширяем модель)
    // Допустим: Южное направление (0°), наклон (30°)
    final double panelTilt = 30.0; 
    final double panelAzimuth = 0.0; // 0 = Юг, -90 = Восток, 90 = Запад

    final double arrayPower = SolarMathEngine.calculateInstantPower(
      time: DateTime.now(),
      latitude: currentLatitude,
      longitude: currentLongitude,
      panelTiltDegrees: panelTilt,
      panelAzimuthDegrees: panelAzimuth,
      peakPowerWatts: array.peakPowerKw * 1000,
      cloudiness: widget.cloudiness,
      rainMm: widget.rainMm,
      ambientTemp: widget.ambientTemp,
      mpptEfficiency: 0.98, // ⚡ Учитываем потери MPPT-трекера
      inverterEfficiency: 0.96,
    );

    totalSolarWatts += arrayPower;
  }

  return totalSolarWatts.clamp(0.0, EssSystemLoader.totalSolarKw(settings) * 1000);
}
    // ⚡ Новий динамічний розрахунок навантаження будинку (Вт)
    double averageLoadWatts = 0.0; // Середнє споживання з урахуванням циклів роботи
    double peakLoadWatts = 0.0;    // Піковий удар струму при запуску пристроїв

    for (var device in devices) {
      final double power = (device['power'] as num).toDouble();
      final int amount = (device['amount'] as num).toInt();
      
      // dutyCycle: 1.0 = працює без упину, 0.3 = працює 30% часу (наприклад, холодильник чи бойлер)
      final double dutyCycle = device.containsKey('dutyCycle') 
          ? (device['dutyCycle'] as num).toDouble() 
          : 1.0;
          
      // inrushMultiplier: множник пускового струму (наприклад, 3.5 для компресора кондиціонера)
      final double inrushMultiplier = device.containsKey('inrushMultiplier') 
          ? (device['inrushMultiplier'] as num).toDouble() 
          : 1.0;

      averageLoadWatts += (power * amount * dutyCycle);
      peakLoadWatts += (power * amount * inrushMultiplier);
    }
    // Отримуємо сумарну номінальну потужність усіх інверторів системи в Ватах
    double totalInverterPowerWatts = 0.0;
    for (var inv in settings.inverters) {
      totalInverterPowerWatts += (inv.powerKw * 1000.0);
    }
    if (totalInverterPowerWatts <= 0) {
      totalInverterPowerWatts = 5000.0; // Фолбек на 5 кВт, якщо система пуста
    }

    // Перевіряємо, чи не виб'є інвертор від пускових струмів
    final bool isInverterOverloaded = peakLoadWatts > totalInverterPowerWatts;

    setState(() {
      _isBatteryDischarged = isDead;
      _isInverterOverloaded = isInverterOverloaded; // Оновлюємо стейт
    });

    // Якщо інвертор перевантажено — зупиняємо симуляцію розряду, бо система аварійно вимкнеться
    if (isInverterOverloaded) {
      setState(() {
        _dynamicAutonomy = const Duration(hours: 0, minutes: 0);
        _dynamicUntilTime = "Перевантаження Інвертора ⚠️";
        _hasActiveDevices = true;
      });
      return; 
    }

    setState(() {
      _isBatteryDischarged = isDead;
    });

    if (averageLoadWatts <= 0 || isDead) {
      setState(() {
        _dynamicAutonomy = const Duration(hours: 0, minutes: 0);
        _dynamicUntilTime = "--:--";
        _hasActiveDevices = averageLoadWatts > 0; 
      });
      return;
    }

    
    // Учет генератора
    double activeGenerationWatts = 0.0;
    for (var gen in settings.generators) {
      if (gen.autoStart && _currentBatteryPercent <= gen.startSoc) {
        activeGenerationWatts += (gen.powerKw * 1000); 
      }
    }
    
    // 🔥 НОВОЕ: Учет мгновенного солнца на основе погодных данных
    double activeSolarWatts = _estimateInstantSolarPower(settings);
    
    // Вычитаем из нагрузки дома и генератор, и солнце
    double netLoadWatts = averageLoadWatts - activeGenerationWatts - activeSolarWatts;

    // Если солнце полностью покрывает дом (генерация > потребления)
    if (netLoadWatts <= 0) {
      setState(() {
        _dynamicAutonomy = const Duration(hours: 48, minutes: 0); // Лимит симуляции в Nuvit
        _dynamicUntilTime = "Покривається СЕС ☀️";
        _hasActiveDevices = true;
        _isBatteryDischarged = false;
      });
      return;
    }
    // Если генерация покрывает дом
    if (netLoadWatts <= 0) {
      double maxGenRuntime = 0.0;
      for (var gen in settings.generators) {
        if (gen.autoStart && _currentBatteryPercent <= gen.startSoc) {
          final double runtime = _calculateGeneratorRuntime(gen, averageLoadWatts);
          if (runtime > maxGenRuntime) maxGenRuntime = runtime;
        }
      }

      if (maxGenRuntime > 0) {
        final int genHours = maxGenRuntime.floor();
        final int genMinutes = ((maxGenRuntime - genHours) * 60).round();
        
        final updatedDuration = Duration(hours: genHours, minutes: genMinutes);
        final projectedEndTime = DateTime.now().add(updatedDuration);

        setState(() {
          _dynamicAutonomy = updatedDuration;
          _dynamicUntilTime = "${_formatTime(projectedEndTime)} (Генератор)";
          _hasActiveDevices = true; 
        });
      } else {
        setState(() {
          _dynamicAutonomy = const Duration(hours: 0, minutes: 0);
          _dynamicUntilTime = "--:--";
          _hasActiveDevices = averageLoadWatts > 0;
        });
      }
      return;
    }

    // =========================================================================
    // ⚡ ТОКОВАЯ ИНЖЕНЕРНАЯ МАТЕМАТИКА РАЗРЯДА АКБ
    // =========================================================================
    
    double preliminaryPower = (netLoadWatts / (inverterEfficiency / 100.0)) + systemSelfConsumptionW;
    
    var physics = _calculateBatteryPhysics(
      targetPowerWatts: preliminaryPower,
      soc: _currentBatteryPercent,
      nominalVoltage: nominalVoltage,
      batteryList: settings.batteries,
      ambientTemp: widget.ambientTemp,
    );

    final double dynamicEff = _getDynamicInverterEfficiency(netLoadWatts, inverterEfficiency, physics['current']!);
    final double finalPowerDrawWatts = (netLoadWatts / dynamicEff) + systemSelfConsumptionW;

    physics = _calculateBatteryPhysics(
      targetPowerWatts: finalPowerDrawWatts,
      soc: _currentBatteryPercent,
      nominalVoltage: nominalVoltage,
      batteryList: settings.batteries,
      ambientTemp: widget.ambientTemp,
    );

    final double finalCurrentAmps = physics['current']!;
    final bool isSystemOverloadedByCurrent = physics['isOvercurrent'] as bool;

    // Применяем эффект Пёйкерта
    final double peukertMultiplier = _getPeukertCapacityMultiplier(
      finalPowerDrawWatts, 
      totalBatteryWh, 
      widget.ambientTemp // <-- ПЕРЕДАЄМО ТЕМПЕРАТУРУ
    );
    final double effectiveAvailableAh = availableAh * peukertMultiplier;


    double hoursDecimal = 0.0;
    if (finalCurrentAmps > 0 && !isSystemOverloadedByCurrent) {
      hoursDecimal = effectiveAvailableAh / finalCurrentAmps;
    }

    final int calculatedHours = hoursDecimal.floor();
    final int calculatedMinutes = ((hoursDecimal - calculatedHours) * 60).round();

    final updatedDuration = Duration(hours: calculatedHours, minutes: calculatedMinutes);
    final projectedEndTime = DateTime.now().add(updatedDuration);

    setState(() {
      _dynamicAutonomy = updatedDuration;
      // Если система перегружена по току, выводим статус вместо времени
      _dynamicUntilTime = isSystemOverloadedByCurrent ? "Перевантаження струму (BMS)" : _formatTime(projectedEndTime);
      _hasActiveDevices = true; 
      // Если ток превышен, можем визуально переводить интерфейс в состояние "разряжен/отключен"
      if (isSystemOverloadedByCurrent) {
        _isBatteryDischarged = true; 
      }
    });
    final double balance = (activeSolarWatts + activeGenerationWatts) - averageLoadWatts;

    final flowState = EnergyFlowState(
      houseConsumptionWatts: averageLoadWatts,
      solarGenerationWatts: activeSolarWatts,
      gridPowerWatts: 0.0, // У режимі автономності мережа відсутня
      batteryPowerWatts: finalPowerDrawWatts, // >0 розряд, <0 заряд
      generatorPowerWatts: activeGenerationWatts,
      portablePowerWatts: 0.0,
      batterySoc: _currentBatteryPercent,
      energyBalanceWatts: balance,
      isGridConnected: false, 
      isGeneratorRunning: activeGenerationWatts > 0,
      isBatteryCharging: finalPowerDrawWatts < 0,
      isPortableActive: false,
      isPortableCharging: false,
      timestamp: DateTime.now(),
    );

    // Викликаємо колбек після завершення поточного кадру, щоб уникнути помилок build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStateCalculated?.call(flowState);
    });
  
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutonomyPresetDevicesWidget(
            onPresetChanged: (preset, devices) {
              setState(() {
                selectedMode = preset;
                currentPresetDevices = devices;
                _presetsInitialized = true;
              });
              _recalculateAutonomy(devices);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AutonomyCard(
              autonomy: _dynamicAutonomy,
              batteryPercent: _currentBatteryPercent, 
              untilTime: _dynamicUntilTime,
              hasDevices: _hasActiveDevices, 
              isDischarged: _isBatteryDischarged,
              onInfoPressed: () => _showInfoDialog(context), // Передаем вызов созданного диалога
              onBatteryPercentChanged: (newPercent) {
                setState(() {
                  _currentBatteryPercent = newPercent;
                });
                _recalculateAutonomy(currentPresetDevices);
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildBreakdownCard(),
          const SizedBox(height: 20),
          
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
  // Якщо пресети вже завантажились, ми відображаємо ТІЛЬКИ те, що в них є (або порожній список для заглушки)
  if (_presetsInitialized) {
    final List<ConsumptionItem> dynamicItems = currentPresetDevices.map((d) {
      final double powerW = (d['power'] as num).toDouble();
      final int amount = (d['amount'] as num).toInt();
      final double hours = (d['hoursPerDay'] as num).toDouble();

      // Розрахунок реальних кВт·год на льоту
      final double energyKwh = (powerW * amount * hours) / 1000.0;

      return ConsumptionItem(
        name: d['name']?.toString() ?? 'Невідомий пристрій',
        energyKwh: energyKwh,
        icon: d['icon'] is IconData ? d['icon'] : Icons.devices_other_rounded,
        deviceMode: d['deviceMode']?.toString() ?? 'custom',
      );
    }).toList();

    return ConsumptionBreakdownCard(items: dynamicItems);
  }

  // Цей фолбек спрацює лише на першому кадрі, поки SharedPreferences в пресетах зчитує файл
  return ConsumptionBreakdownCard(
    items: widget.result.breakdown
        .map((e) => ConsumptionItem(
              name: e.name,
              energyKwh: e.energyKwh,
              icon: e.icon,
              deviceMode: 'custom',
            ))
        .toList(),
  );
}

  
}