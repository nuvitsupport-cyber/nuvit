import 'package:flutter/material.dart';

import '../../models/outage/outage_insight.dart';
import '../../models/outage/outage_state.dart';

/// Иконки модуля "Графік відключень".
///
/// Все иконки находятся в одном месте.
/// Виджеты не должны использовать Icons.xxx напрямую.
class OutageIcons {
  OutageIcons._();

  // ==========================================================
  // Основные
  // ==========================================================

  static const IconData schedule = Icons.bolt_rounded;

  static const IconData timeline = Icons.schedule_rounded;

  static const IconData probability = Icons.analytics_rounded;

  static const IconData statistics = Icons.bar_chart_rounded;

  static const IconData ai = Icons.auto_awesome_rounded;

  static const IconData source = Icons.cloud_done_rounded;

  static const IconData refresh = Icons.refresh_rounded;

  // ==========================================================
  // Следующее событие
  // ==========================================================

  static const IconData nextEvent = Icons.access_time_filled_rounded;

  static const IconData duration = Icons.timer_rounded;

  // ==========================================================
  // Состояния сети
  // ==========================================================

  static const IconData powerOn = Icons.flash_on_rounded;

  static const IconData outage = Icons.power_off_rounded;

  static const IconData possibleOutage = Icons.warning_amber_rounded;

  static const IconData unknown = Icons.help_outline_rounded;

  // ==========================================================
  // AI
  // ==========================================================

  static const IconData recommendation = Icons.lightbulb_rounded;

  static const IconData info = Icons.info_outline_rounded;

  static const IconData warning = Icons.warning_rounded;

  static const IconData critical = Icons.error_rounded;

  // ==========================================================
  // Helpers
  // ==========================================================

  /// Иконка по состоянию сети.
  static IconData state(OutageState state) {
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

  /// Иконка по типу AI-инсайта.
  static IconData insight(OutageInsightType type) {
    switch (type) {
      case OutageInsightType.info:
        return info;

      case OutageInsightType.recommendation:
        return recommendation;

      case OutageInsightType.warning:
        return warning;

      case OutageInsightType.critical:
        return critical;
    }
  }
}