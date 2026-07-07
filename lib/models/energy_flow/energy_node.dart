// lib/models/energy_flow/energy_node.dart

/// Типы узлов энергосистемы
enum EnergyNodeType {
  house,
  solar,
  battery,
  grid,
  generator,
  wind,
  hydro,
  ev,
  portablePowerStation,
}

/// Текущие операционные статусы узла для UI-индикации и логики управления
enum EnergyNodeStatus {
  online,       // Узел активен и работает штатно
  offline,      // Узел отключен (например, авария на линии сети или выключен инвертор)
  warning,      // Работает с предупреждением (перегрузка, высокая температура, низкий заряд)
  charging,     // Активно поглощает энергию (актуально для АКБ, Portable Station, EV)
  discharging,  // Активно отдает энергию (АКБ, Генератор, Солнце, Сеть при импорте)
  idle,         // Подключен, но находится в режиме ожидания (поток энергии равен 0)
}

class EnergyNode {
  final String id;
  final EnergyNodeType type;
  final String name;
  final double powerWatts;
  final bool visible;
  
  /// Текущий детальный статус узла
  final EnergyNodeStatus status;

  /// Приоритет узла в энергосистеме (например, для сценариев балансировки).
  /// Чем меньше число, тем выше приоритет (0 - критическая нагрузка/главный источник, 3 - второстепенный).
  final int priority;

  /// Оставляем для обратной совместимости, но логически теперь дублируется статусом online/offline
  final bool connected; 

  const EnergyNode({
    required this.id,
    required this.type,
    required this.name,
    this.powerWatts = 0.0,
    this.connected = true,
    this.visible = true,
    this.status = EnergyNodeStatus.online,
    this.priority = 0,
  });

  /// Метод для иммутабельного обновления узла
  EnergyNode copyWith({
    String? id,
    EnergyNodeType? type,
    String? name,
    double? powerWatts,
    bool? connected,
    bool? visible,
    EnergyNodeStatus? status,
    int? priority,
  }) {
    return EnergyNode(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      powerWatts: powerWatts ?? this.powerWatts,
      connected: connected ?? this.connected,
      visible: visible ?? this.visible,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}