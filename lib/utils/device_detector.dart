enum DeviceType {
  inverter,
  solar,
  mppt,
  generator,
  battery,
  portableStation,
  windGenerator,
  microHydro,
  ev,
  evCharger,
  grid,
  smartMeter,
  ats,
  stabilizer,
  voltageRelay,
  surgeProtection,
  rcd,

  smartAutomation,
  monitoring,
  loadShedding,
  dryContact,
  diverter,

  batteryBalancer,
  batteryHeater,
  batterySohAnalyzer,
  
  ventilation,

  
  unknown,
}

class DeviceDetector {
  static DeviceType detect(String deviceName) {
    final name = deviceName.toLowerCase();

    final isMppt = name.contains('mppt');

    if (isMppt) {
      return DeviceType.mppt;
    }

    if ((name.contains('панел') || name.contains('соняч')) &&
        !isMppt) {
      return DeviceType.solar;
    }

    if (name.contains('інвертор')) {
      return DeviceType.inverter;
    }

    if (name.contains('генератор') &&
        name.contains('паливни')) {
      return DeviceType.generator;
    }

   if (name.contains('portable') ||
   name.contains('портативна зарядна станція') ||
    name.contains('зарядна станція') ||
    name.contains('ecoflow') ||
    name.contains('bluetti') ||
    name.contains('jackery') ||
    name.contains('anker')) {
  return DeviceType.portableStation;
}
if (name.contains('акумулятор') ||
    name.contains('bms')) {
  return DeviceType.battery;
}

   if (name.contains('вітрогенератор')) {
  return DeviceType.windGenerator;
}

if (name.contains('гідроелектростанція') ||
    name.contains('мікро гес') ||
    name.contains('гес')) {
  return DeviceType.microHydro;
}

    if (name.contains('смарт-контролер зарядки') ||
    name.contains('ev charger') ||
    name.contains('зарядки ем')) {
  return DeviceType.evCharger;
}

if (name.contains('електромобіль') ||
    name.contains('v2l') ||
    name.contains('v2h')) {
  return DeviceType.ev;
}

    if (name.contains('електромережа') ||
        name.contains('двозонний')) {
      return DeviceType.grid;
    }

    if (name.contains('лічильник') ||
        name.contains('smart meter') ||
        name.contains('meter')) {
      return DeviceType.smartMeter;
    }

    if (name.contains('авр') ||
        name.contains('автоматичне введення резерву') ||
        name.contains('резерву') ||
        name.contains('ats')) {
      return DeviceType.ats;
    }
if (name.contains('стабілізатор')) {
  return DeviceType.stabilizer;
}
if (name.contains('реле напруги')) {
  return DeviceType.voltageRelay;
}
if (name.contains('пзіп') ||
    name.contains('заземлення')) {
  return DeviceType.surgeProtection;
}
if (name.contains('пзв') ||
    name.contains('диференцій')) {
  return DeviceType.rcd;
}
    

    // ================= LOAD SHEDDING =================

    if (name.contains('load shedding') ||
        name.contains('shedding') ||
        name.contains('скидання навантаження')) {
      return DeviceType.loadShedding;
    }

    // ================= DRY CONTACT =================

    if (name.contains('dry contact') ||
        name.contains('сухий контакт')) {
      return DeviceType.dryContact;
    }

    // ================= MONITORING =================

    if (name.contains('моніторинг') ||
        name.contains('моніторингу') ||
        name.contains('dongle') ||
        name.contains('wi-fi/4g')) {
      return DeviceType.monitoring;
    }

    // ================= SMART HOME =================

    if (name.contains('розумний будинок') ||
        name.contains('home assistant') ||
        name.contains('tuya') ||
        name.contains('openhab') ||
        name.contains('iobroker') ||
        name.contains('node-red')) {
      return DeviceType.smartAutomation;
    }


        // ================= DIVERTER =================

    if (name.contains('diverter') ||
        name.contains('дивертер') ||
        name.contains('надлишків') ||
        name.contains('pv diverter') ||
        name.contains('pv-diverter') ||
        name.contains('pv_diverter')) {
      return DeviceType.diverter;
    }
// ================= BATTERY BALANCER =================

if (name.contains('балансир')) {
  return DeviceType.batteryBalancer;
}

// ================= BATTERY HEATER =================

if (name.contains('термокожух') ||
    name.contains('підігрів')) {
  return DeviceType.batteryHeater;
}

// ================= SOH =================

if (name.contains('soh') ||
    name.contains('деградації')) {
  return DeviceType.batterySohAnalyzer;
}





// ================= VENTILATION =================

if (name.contains('вентиляц') ||
    name.contains('охолодження')) {
  return DeviceType.ventilation;
}
    return DeviceType.unknown;
  }
}