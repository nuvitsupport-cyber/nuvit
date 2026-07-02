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

class EnergyNode {
  const EnergyNode({
    required this.id,
    required this.type,
    required this.name,

    this.powerWatts = 0,

    this.connected = true,

    this.visible = true,
  });

  final String id;

  final EnergyNodeType type;

  final String name;

  final double powerWatts;

  final bool connected;

  final bool visible;
}