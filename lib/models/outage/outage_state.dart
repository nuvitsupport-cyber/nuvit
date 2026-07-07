/// Состояние электросети.
///
/// Используется:
/// • в таймлайне;
/// • в карточке следующего события;
/// • в статистике;
/// • при расчёте вероятности.
enum OutageState {
  /// Электроснабжение присутствует.
  powerOn,

  /// Возможное отключение.
  possibleOutage,

  /// Активное отключение.
  outage,

  /// Неизвестное состояние.
  unknown,
}

/// Дополнительные свойства состояния.
extension OutageStateExtension on OutageState {
  /// Украинское название.
  String get label {
    switch (this) {
      case OutageState.powerOn:
        return 'Є світло';

      case OutageState.possibleOutage:
        return 'Можливе відключення';

      case OutageState.outage:
        return 'Відключення';

      case OutageState.unknown:
        return 'Невідомо';
    }
  }

  /// Короткое название.
  String get shortLabel {
    switch (this) {
      case OutageState.powerOn:
        return 'Світло';

      case OutageState.possibleOutage:
        return 'Ймовірно';

      case OutageState.outage:
        return 'Без світла';

      case OutageState.unknown:
        return '--';
    }
  }

  /// Emoji для быстрых списков.
  String get emoji {
    switch (this) {
      case OutageState.powerOn:
        return '🟢';

      case OutageState.possibleOutage:
        return '🟡';

      case OutageState.outage:
        return '🔴';

      case OutageState.unknown:
        return '⚪';
    }
  }

  /// Есть электроснабжение.
  bool get hasPower => this == OutageState.powerOn;

  /// Есть отключение.
  bool get isOutage => this == OutageState.outage;

  /// Возможное отключение.
  bool get isPossible => this == OutageState.possibleOutage;

  /// Нет информации.
  bool get isUnknown => this == OutageState.unknown;
}