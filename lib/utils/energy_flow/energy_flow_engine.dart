// lib/utils/energy_flow/energy_flow_engine.dart

import 'dart:math' as math;
import '../../models/energy_flow/energy_system_snapshot.dart';
import '../../models/energy_flow/energy_flow_state.dart';
import '../../models/energy_flow/energy_node.dart';
import '../../models/energy_flow/energy_connection.dart';

class EnergyFlowEngine {
  const EnergyFlowEngine();

  EnergyFlowState calculate(EnergySystemSnapshot snapshot) {
    // ========================================================================
    // 1. СБОР ДОСТУПНОЙ ЭНЕРГИИ (Available Energy)
    // ========================================================================
    // Берем потенциальную генерацию, которую могут выдать источники прямо сейчас
    double availSolar = snapshot.solarGenerationWatts;
    double availWind = snapshot.windPowerWatts;
    double availHydro = snapshot.hydroPowerWatts;
    
    // Для генератора учитываем, запущен ли он вообще
    double availGen = snapshot.isGeneratorRunning ? snapshot.generatorMaxPowerWatts : 0.0;
    
    // Потребность дома
    double remainingHouseLoad = snapshot.houseLoadWatts;

    // ========================================================================
    // 2. ПРОВЕРКА ОГРАНИЧЕНИЙ (Constraints & Limits)
    // ========================================================================
    // Лимиты инвертора и сети
    final double maxBatDischarge = snapshot.batteryDischargeLimitWatts;
    final double maxBatCharge = snapshot.batteryChargeLimitWatts;
    final double maxGridImport = snapshot.isGridAvailable ? snapshot.gridImportLimitWatts : 0.0;
    final double maxGridExport = snapshot.isGridAvailable ? snapshot.gridExportLimitWatts : 0.0;

    // Защита от глубокого разряда (если SoC слишком мал, запрещаем разряд)
    final bool canDischargeBattery = snapshot.batterySocPercent > 10.0; 
    double availBat = canDischargeBattery ? maxBatDischarge : 0.0;

    // Доступная емкость для заряда
    final bool canChargeBattery = snapshot.batterySocPercent < 100.0;
    double batteryNeeds = canChargeBattery ? maxBatCharge : 0.0;
    double portableNeeds = 0.0; // Сюда можно прокинуть лимит заряда портативной станции
    double evNeeds = 0.0;       // Лимит заряда электромобиля

    // Инициализация переменных потоков (Flows)
    double solarToHouse = 0, windToHouse = 0, hydroToHouse = 0;
    double batToHouse = 0, gridToHouse = 0, genToHouse = 0;
    
    double solarToBat = 0, windToBat = 0, hydroToBat = 0;
    double gridToBat = 0, genToBat = 0;
    
    double solarToGrid = 0, windToGrid = 0, hydroToGrid = 0;
    double batToGrid = 0; // Для режима продажи из АКБ по тарифу

    // ========================================================================
    // 3. ЗАКРЫТИЕ НАГРУЗКИ ДОМА (Load Fulfillment)
    // Приоритет: Renewables -> Battery -> Grid -> Generator
    // ========================================================================
    
    // 3.1. Солнце
    if (availSolar > 0 && remainingHouseLoad > 0) {
      solarToHouse = math.min(availSolar, remainingHouseLoad);
      availSolar -= solarToHouse;
      remainingHouseLoad -= solarToHouse;
    }
    // 3.2. Ветер и Гидро (работают аналогично Солнцу)
    if (availWind > 0 && remainingHouseLoad > 0) {
      windToHouse = math.min(availWind, remainingHouseLoad);
      availWind -= windToHouse;
      remainingHouseLoad -= windToHouse;
    }
    if (availHydro > 0 && remainingHouseLoad > 0) {
      hydroToHouse = math.min(availHydro, remainingHouseLoad);
      availHydro -= hydroToHouse;
      remainingHouseLoad -= hydroToHouse;
    }
    
    // 3.3. Аккумулятор (Self-Consumption Mode)
    if (availBat > 0 && remainingHouseLoad > 0) {
      batToHouse = math.min(availBat, remainingHouseLoad);
      availBat -= batToHouse;
      remainingHouseLoad -= batToHouse;
    }

    // 3.4. Внешняя сеть
    if (maxGridImport > 0 && remainingHouseLoad > 0) {
      gridToHouse = math.min(maxGridImport, remainingHouseLoad);
      // Уменьшаем лимит сети на будущее (если захотим заряжать АКБ от сети)
      remainingHouseLoad -= gridToHouse;
    }

    // 3.5. Генератор (Последний рубеж обороны)
    if (availGen > 0 && remainingHouseLoad > 0) {
      genToHouse = math.min(availGen, remainingHouseLoad);
      availGen -= genToHouse;
      remainingHouseLoad -= genToHouse;
    }

    final bool isLoadSheddingActive = remainingHouseLoad > 0.1;

    // ========================================================================
    // 4. ЗАРЯД НАКОПИТЕЛЕЙ (Charging Storage)
    // Приоритет: Solar -> Wind -> Hydro -> Grid/Gen (зависит от настроек)
    // ========================================================================
    
    if (batteryNeeds > 0) {
      // Заряд от излишков Солнца
      if (availSolar > 0) {
        solarToBat = math.min(availSolar, batteryNeeds);
        availSolar -= solarToBat;
        batteryNeeds -= solarToBat;
      }
      // Заряд от излишков Ветра
      if (availWind > 0 && batteryNeeds > 0) {
        windToBat = math.min(availWind, batteryNeeds);
        availWind -= windToBat;
        batteryNeeds -= windToBat;
      }
      // Принудительный заряд от Сети (если разрешено настройками инвертора)
      // Например, ночью по ночному тарифу
      final double remainingGridImport = maxGridImport - gridToHouse;
      if (remainingGridImport > 0 && batteryNeeds > 0 && snapshot.batteryPowerWatts < -0.1) {
        // Условие snapshot.batteryPowerWatts < -0.1 тут как флаг того, 
        // что инвертор физически тянет энергию в батарею от AC-входа
        gridToBat = math.min(remainingGridImport, batteryNeeds);
        batteryNeeds -= gridToBat;
      }
      // Заряд от излишков работающего Генератора
      if (availGen > 0 && batteryNeeds > 0) {
        genToBat = math.min(availGen, batteryNeeds);
        availGen -= genToBat;
        batteryNeeds -= genToBat;
      }
    }

    // TODO: Здесь можно добавить логику заряда Portable Station (EcoFlow) и EV Backup

    // ========================================================================
    // 5. ЭКСПОРТ (Grid Export)
    // ========================================================================
    if (maxGridExport > 0) {
      if (availSolar > 0) {
        solarToGrid = math.min(availSolar, maxGridExport);
        availSolar -= solarToGrid;
        // Уменьшаем maxGridExport, если будем экспортировать еще ветер/акб
      }
    }

    // ========================================================================
    // 6. CURTAILMENT (Ограничение генерации)
    // Если энергия осталась, но девать ее некуда (сеть отключена, батарея полна)
    // ========================================================================
    final double curtailedSolar = availSolar; // MPPT трекер сместит рабочую точку
    final bool isCurtailmentActive = curtailedSolar > 10;

    // ========================================================================
    // 7. ФОРМИРОВАНИЕ ПОТОКОВ (Generate Connections)
    // ========================================================================
    final List<EnergyConnection> connections = [
      _conn('solar', 'house', solarToHouse),
      _conn('wind', 'house', windToHouse),
      _conn('hydro', 'house', hydroToHouse),
      _conn('battery', 'house', batToHouse),
      _conn('grid', 'house', gridToHouse),
      _conn('generator', 'house', genToHouse),

      _conn('solar', 'battery', solarToBat),
      _conn('wind', 'battery', windToBat),
      _conn('hydro', 'battery', hydroToBat),
      _conn('grid', 'battery', gridToBat),
      _conn('generator', 'battery', genToBat),

      _conn('solar', 'grid', solarToGrid),
      _conn('wind', 'grid', windToGrid),
      _conn('hydro', 'grid', hydroToGrid),
      _conn('battery', 'grid', batToGrid),
    ]..removeWhere((c) => !c.active);

    // ========================================================================
    // 8. ПОДСЧЕТ СТАТИСТИКИ И ФОРМИРОВАНИЕ СОСТОЯНИЯ (Calculate Summary)
    // ========================================================================
    
    // Фактические итоговые значения узлов (после диспетчеризации)
    final double totalSolarUsed = solarToHouse + solarToBat + solarToGrid;
    final double totalWindUsed = windToHouse + windToBat + windToGrid;
    final double totalBatteryPower = batToHouse + batToGrid - (solarToBat + windToBat + hydroToBat + gridToBat + genToBat); 
    final double totalGridPower = (gridToHouse + gridToBat) - (solarToGrid + windToGrid + hydroToGrid + batToGrid);
    final double totalGenPower = genToHouse + genToBat;

    // Динамическое определение режимов (SystemMode)
    SystemMode mode = SystemMode.gridTied;
    if (totalGenPower > 0) {
      mode = SystemMode.emergencyBackup;
    } else if (!snapshot.isGridAvailable) {
      mode = SystemMode.island;
    } else if (totalSolarUsed > 0 && totalGridPower <= 0) {
      mode = SystemMode.eco;
    }

    // Собираем узлы
    final List<EnergyNode> nodes = [
      EnergyNode(
        id: 'house',
        type: EnergyNodeType.house,
        name: isLoadSheddingActive ? 'Дом (Дефицит)' : 'Дом',
        powerWatts: snapshot.houseLoadWatts,
        priority: 0,
        status: isLoadSheddingActive ? EnergyNodeStatus.warning : EnergyNodeStatus.online,
      ),
      EnergyNode(
        id: 'solar',
        type: EnergyNodeType.solar,
        name: 'Солнце',
        powerWatts: totalSolarUsed,
        visible: totalSolarUsed > 0 || isCurtailmentActive,
        priority: 1,
        status: isCurtailmentActive 
            ? EnergyNodeStatus.warning 
            : (totalSolarUsed > 10 ? EnergyNodeStatus.discharging : EnergyNodeStatus.idle),
      ),
      EnergyNode(
        id: 'battery',
        type: EnergyNodeType.battery,
        name: 'АКБ',
        powerWatts: totalBatteryPower.abs(),
        priority: 1,
        status: !canDischargeBattery && !canChargeBattery
            ? EnergyNodeStatus.offline
            : (totalBatteryPower < -10 
                ? EnergyNodeStatus.charging 
                : (totalBatteryPower > 10 ? EnergyNodeStatus.discharging : EnergyNodeStatus.idle)),
      ),
      EnergyNode(
        id: 'grid',
        type: EnergyNodeType.grid,
        name: 'Сеть',
        powerWatts: totalGridPower.abs(),
        connected: snapshot.isGridAvailable,
        priority: 2,
        status: !snapshot.isGridAvailable
            ? EnergyNodeStatus.offline 
            : (totalGridPower > 10 
                ? EnergyNodeStatus.discharging  // Импорт из сети (сеть отдает нам)
                : (totalGridPower < -10 ? EnergyNodeStatus.charging : EnergyNodeStatus.idle)), // Экспорт
      ),
      EnergyNode(
        id: 'generator',
        type: EnergyNodeType.generator,
        name: 'Генератор',
        powerWatts: totalGenPower,
        visible: snapshot.isGeneratorRunning || totalGenPower > 0,
        priority: 2,
        status: totalGenPower > 10 ? EnergyNodeStatus.discharging : EnergyNodeStatus.idle,
      ),
    ];

    // Формируем текстовые подсказки для UI
    final String currentSource = _compileSourcesText(
      solarToHouse, windToHouse, batToHouse, gridToHouse, genToHouse
    );

    return EnergyFlowState(
      summary: EnergySummary(
        houseConsumptionWatts: snapshot.houseLoadWatts,
        solarGenerationWatts: totalSolarUsed,
        gridPowerWatts: totalGridPower,
        batteryPowerWatts: totalBatteryPower,
        generatorPowerWatts: totalGenPower,
        portablePowerWatts: 0.0, // Добавите после имплементации EcoFlow
        batterySoc: snapshot.batterySocPercent,
      ),
      nodes: nodes,
      connections: connections,
      statistics: EnergyStatistics(
        energyBalanceWatts: (totalSolarUsed + totalWindUsed + totalGenPower) - snapshot.houseLoadWatts,
        timestamp: snapshot.timestamp,
        isGridConnected: snapshot.isGridAvailable,
        isGeneratorRunning: totalGenPower > 0,
        isBatteryCharging: totalBatteryPower < -10,
        isPortableActive: false,
        isPortableCharging: false,
      ),
      systemMode: mode,
      currentSource: currentSource,
      currentConsumer: isCurtailmentActive ? 'Ограничение MPPT' : 'Нагрузка Дома',
    );
  }

  EnergyConnection _conn(String from, String to, double watts) {
    return EnergyConnection(
      from: from,
      to: to,
      powerWatts: watts,
      direction: watts > 0.1 ? EnergyFlowDirection.forward : EnergyFlowDirection.none,
      active: watts > 0.1,
    );
  }

  String _compileSourcesText(double s, double w, double b, double g, double gen) {
    final List<String> src = [];
    if (s > 50) src.add('Солнце');
    if (w > 50) src.add('Ветер');
    if (b > 50) src.add('АКБ');
    if (g > 50) src.add('Сеть');
    if (gen > 50) src.add('Генератор');
    return src.isEmpty ? 'Нет источников' : src.join(' + ');
  }
}