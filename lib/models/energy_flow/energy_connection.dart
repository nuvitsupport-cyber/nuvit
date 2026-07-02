enum EnergyFlowDirection {
  none,

  forward,

  reverse,

  bidirectional,
}

class EnergyConnection {
  const EnergyConnection({
    required this.from,

    required this.to,

    required this.powerWatts,

    required this.direction,

    this.active = false,
  });

  final String from;

  final String to;

  final double powerWatts;

  final EnergyFlowDirection direction;

  final bool active;
}