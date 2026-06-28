// lib/widgets/energy_hub/autonomy_calculator/autonomy_calculator_widget.dart

import 'package:flutter/material.dart';
import 'package:nuvit/utils/models/autonomy_result.dart';
import 'dart:math';
// Импорт моделей конфигурации ESS
import 'package:nuvit/utils/autonomy/ess_models.dart';
import 'package:nuvit/utils/autonomy/ess_system_loader.dart';

import 'autonomy_preset_view_page.dart'; 
import '/widgets/energy_hub/autonomy_calculator/autonomy_card.dart';
import '/widgets/energy_hub/autonomy_calculator/consumption_breakdown_card.dart';
import '/widgets/energy_hub/autonomy_calculator/recommendation_card.dart';

class AutonomyCalculatorWidget extends StatefulWidget {
  final AutonomyResult result;

  const AutonomyCalculatorWidget({
    super.key,
    required this.result,
  });

  @override
  State<AutonomyCalculatorWidget> createState() => _AutonomyCalculatorWidgetState();
}

class _AutonomyCalculatorWidgetState extends State<AutonomyCalculatorWidget> {
  String selectedMode = 'balanced';
  List<Map<String, dynamic>> currentPresetDevices = [];

  // Переменные состояния UI
  Duration _dynamicAutonomy = const Duration();
  String _dynamicUntilTime = "";
  bool _hasActiveDevices = true; 
  bool _isBatteryDischarged = false;
  
  // Текущий заряд с ползунка
  double _currentBatteryPercent = 100.0;

  // Модель конфигурации ESS
  EssSystemSettings? _essSettings;
  bool _isLoading = true;

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

    // Подбираем внутреннее сопротивление в зависимости от типа химии из модели
    final String batType = batteryList.isNotEmpty ? batteryList.first.type.toLowerCase() : 'lifepo4';
    double baseInternalResistance = 0.020; // Дефолт для LiFePO4 (~20 мОм)
    
    if (batType.contains('lead') || batType.contains('agm') || batType.contains('свинец')) {
      baseInternalResistance = 0.060; // У свинца/AGM сопротивление значительно выше (~60 мОм)
    } else if (batType.contains('gel') || batType.contains('гель')) {
      baseInternalResistance = 0.045; // Гелевые АКБ
    }

    final int count = batteryList.length > 0 ? batteryList.length : 1;
    final double rInternal = baseInternalResistance / count; 
    final double rCables = 0.005; 
    final double rTotal = rInternal + rCables;

    final double discriminant = (vOc * vOc) - (4 * rTotal * targetPowerWatts);
    
    double current = 0.0;
    if (discriminant >= 0) {
      current = (vOc - sqrt(discriminant)) / (2 * rTotal);
    } else {
      current = targetPowerWatts / (vOc * 0.85); 
    }

    // Проверяем лимит максимального тока разряда (BMS protection)
    double maxSystemDischargeCurrent = 0.0;
    for (var bat in batteryList) {
      // Суммируем токи параллельных сборок
      maxSystemDischargeCurrent += bat.maxDischargeCurrent;
    }
    // Если в моделях зашиты нули, ставим безопасный fallback (например, 100А на батарею)
    if (maxSystemDischargeCurrent <= 0) {
      maxSystemDischargeCurrent = 100.0 * count;
    }

    final bool isOvercurrent = current > maxSystemDischargeCurrent;

    final double voltageSag = current * rTotal;
    final double activeVoltage = (vOc - voltageSag).clamp(nominalVoltage * 0.7, nominalVoltage * 1.2);
    final double lossWatts = current * current * rTotal;

    return {
      'current': current,
      'activeVoltage': activeVoltage,
      'lossWatts': lossWatts,
      'isOvercurrent': isOvercurrent, // Передаем наверх критический статус
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
  double _getPeukertCapacityMultiplier(double totalBatteryDrawWatts, double totalWh) {
    if (totalWh <= 0 || totalBatteryDrawWatts <= 0) return 1.0;
    final double cRate = totalBatteryDrawWatts / totalWh;
    double factor = 1.0 - (0.24 * cRate);
    return factor.clamp(0.78, 1.0);
  }

  /// ℹ️ Динамическая интерактивная подсказка с адаптивной формулой
  void _showInfoDialog(BuildContext context) {
    // Безопасный фолбэк на случай отсутствия конфигурации
    final settings = _essSettings;
    final bool hasSolar = settings != null && settings.solarArrays.isNotEmpty;
    final bool hasGenerator = settings != null && settings.generators.isNotEmpty;

    // Сборка формулы и элементов её расшифровки в зависимости от подключенных источников
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

    // В конце всегда добавляем системные потери
    formulaExplanationBlocks.add(_buildFormulaItem("🔧 Втрати", "Власне споживання інвертора, ККД перетворення струму та живлення плат моніторингу."));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF020D2D), // Твой Electric Blue фон
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                "Як розраховується час? ⏱️",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Уявіть, що акумулятор — це бак з водою, а ваші прилади — відкриті крани. Nuvit аналізує підключене обладнання та будує точну математичну модель:",
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              
              // Контейнер с визуальной формулой
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
                          color: Color(0xFF55FF00), // Твой неоновый акцент
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
              
              // Динамический список расшифровки элементов формулы
              ...formulaExplanationBlocks,
              
              const SizedBox(height: 8),
              const Text(
                "💡 Примітка: якщо ви вмикаєте дуже потужні прилади, акумулятор швидше виснажується фізично (Ефект Пёйкерта) — наш алгоритм автоматично враховує цей захисний коефіцієнт.",
                style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.3),
              ),
              const SizedBox(height: 24),
              SizedBox(
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
            ],
          ),
        );
      },
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

    // Доступная емкость в Ампер-часах (Ah)
    double availableAh = totalAh * ((currentEnergyPercent - minAllowedEnergyPercent) / 100.0);
    if (availableAh < 0) availableAh = 0;

    // Считаем нагрузку дома (Вт)
    double householdLoadWatts = 0.0;
    for (var device in devices) {
      final double power = (device['power'] as num).toDouble();
      final int amount = (device['amount'] as num).toInt();
      householdLoadWatts += (power * amount);
    }

    setState(() {
      _isBatteryDischarged = isDead;
    });

    if (householdLoadWatts <= 0 || isDead) {
      setState(() {
        _dynamicAutonomy = const Duration(hours: 0, minutes: 0);
        _dynamicUntilTime = "--:--";
        _hasActiveDevices = householdLoadWatts > 0; 
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
    
    double netLoadWatts = householdLoadWatts - activeGenerationWatts;

    // Если генерация покрывает дом
    if (netLoadWatts <= 0) {
      double maxGenRuntime = 0.0;
      for (var gen in settings.generators) {
        if (gen.autoStart && _currentBatteryPercent <= gen.startSoc) {
          final double runtime = _calculateGeneratorRuntime(gen, householdLoadWatts);
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
          _hasActiveDevices = householdLoadWatts > 0;
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
      batteryList: settings.batteries, // Передаем весь список для анализа химии и токов
    );

    final double dynamicEff = _getDynamicInverterEfficiency(netLoadWatts, inverterEfficiency, physics['current']!);
    final double finalPowerDrawWatts = (netLoadWatts / dynamicEff) + systemSelfConsumptionW;

    physics = _calculateBatteryPhysics(
      targetPowerWatts: finalPowerDrawWatts,
      soc: _currentBatteryPercent,
      nominalVoltage: nominalVoltage,
      batteryList: settings.batteries,
    );

    final double finalCurrentAmps = physics['current']!;
    final bool isSystemOverloadedByCurrent = physics['isOvercurrent'] as bool;

    // Применяем эффект Пёйкерта
    final double peukertMultiplier = _getPeukertCapacityMultiplier(finalPowerDrawWatts, totalBatteryWh);
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
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    return ConsumptionBreakdownCard(
      items: widget.result.breakdown
          .map((e) => ConsumptionItem(
                name: e.name,
                energyKwh: e.energyKwh,
                icon: e.icon,
              ))
          .toList(),
    );
  }

  Widget _buildRecommendationsCard() {
    return RecommendationCard(
      recommendations: widget.result.recommendations
          .map((e) => RecommendationItem(
                title: e.title,
                description: e.description,
                type: _convertType(e.type),
              ))
          .toList(),
    );
  }

  RecommendationType _convertType(dynamic type) {
    switch (type.toString()) {
      case 'RecommendationType.savings': return RecommendationType.savings;
      case 'RecommendationType.warning': return RecommendationType.warning;
      case 'RecommendationType.solar': return RecommendationType.solar;
      case 'RecommendationType.battery': return RecommendationType.battery;
      case 'RecommendationType.schedule': return RecommendationType.schedule;
      default: return RecommendationType.savings;
    }
  }
}