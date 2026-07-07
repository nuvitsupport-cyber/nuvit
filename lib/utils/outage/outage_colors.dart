import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../../models/outage/outage_probability.dart';
import '../../models/outage/outage_state.dart';

/// Цветовая схема модуля "Графік відключень".
///
/// Все цвета, связанные с отображением состояний,
/// находятся здесь.
///
/// Не храните цвета внутри виджетов.
class OutageColors {
  OutageColors._();

  // ==========================================================
  // Основные цвета (NUVIT)
  // ==========================================================

  static const Color background = Color(0xFF020D2D);

  static const Color card = Color(0xFF0C1940);

  static const Color innerCard = Color(0xFF051033);

  static const Color divider = Color(0xFF1A2A56);

  static const Color border = Color(0xFF23335E);

  // ==========================================================
  // Текст
  // ==========================================================

  static const Color textPrimary = Colors.white;

  static const Color textSecondary = Color(0xFF8E99B0);

  // ==========================================================
  // Акцент
  // ==========================================================

  static const Color accent = AppColors.neon;

  static Color get glow => accent.withOpacity(.35);

  // ==========================================================
  // Состояния сети
  // ==========================================================

  static const Color powerOn = Color(0xFF39FF14);

  static const Color possibleOutage = Color(0xFFFFC83D);

  static const Color outage = Color(0xFFFF4D57);

  static const Color unknown = Color(0xFF5D6885);

  // ==========================================================
  // AI Card
  // ==========================================================

  static Color get aiCardBackground =>
      accent.withOpacity(.08);

  static Color get aiCardBorder =>
      accent.withOpacity(.30);

  // ==========================================================
  // Helpers
  // ==========================================================

  /// Цвет по состоянию сети.
  static Color state(OutageState state) {
    switch (state) {
      case OutageState.powerOn:
        return powerOn;

      case OutageState.possibleOutage:
        return possibleOutage;

      case OutageState.outage:
        return outage;

      case OutageState.unknown:
        return unknown;
    }
  }

  /// Цвет кольца вероятности.
  static Color probability(
    OutageProbability probability,
  ) {
    switch (probability.level) {
      case OutageRiskLevel.low:
        return powerOn;

      case OutageRiskLevel.medium:
        return possibleOutage;

      case OutageRiskLevel.high:
      case OutageRiskLevel.critical:
        return outage;
    }
  }

  /// Цвет текста по состоянию.
  static Color stateText(OutageState state) {
    switch (state) {
      case OutageState.powerOn:
        return powerOn;

      case OutageState.possibleOutage:
        return possibleOutage;

      case OutageState.outage:
        return outage;

      case OutageState.unknown:
        return textSecondary;
    }
  }
}