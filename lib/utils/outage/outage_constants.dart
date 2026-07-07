import 'package:flutter/material.dart';

/// Константы модуля "Графік відключень".
///
/// Все размеры, радиусы, отступы и значения
/// находятся здесь.
class OutageConstants {
  OutageConstants._();

  // ==========================================================
  // Padding
  // ==========================================================

  static const double screenPadding = 16.0;

  static const double cardPadding = 18.0;

  static const double innerPadding = 14.0;

  // ==========================================================
  // Radius
  // ==========================================================

  static const double cardRadius = 18.0;

  static const double innerRadius = 14.0;

  static const double chipRadius = 20.0;

  // ==========================================================
  // Border
  // ==========================================================

  static const double borderWidth = 1.0;

  // ==========================================================
  // Timeline
  // ==========================================================

  static const double timelineHeight = 18.0;

  static const double timelineRadius = 10.0;

  static const double timelineSpacing = 2.0;

  // ==========================================================
  // Probability Ring
  // ==========================================================

  static const double probabilityRingSize = 130.0;

  static const double probabilityStroke = 10.0;

  // ==========================================================
  // Icons
  // ==========================================================

  static const double largeIcon = 28.0;

  static const double normalIcon = 22.0;

  static const double smallIcon = 18.0;

  // ==========================================================
  // Typography
  // ==========================================================

  static const double titleSize = 22.0;

  static const double subtitleSize = 16.0;

  static const double bodySize = 14.0;

  static const double captionSize = 12.0;

  static const FontWeight titleWeight =
      FontWeight.w700;

  static const FontWeight subtitleWeight =
      FontWeight.w600;

  static const FontWeight bodyWeight =
      FontWeight.w500;

  // ==========================================================
  // Animation
  // ==========================================================

  static const Duration animationDuration =
      Duration(milliseconds: 300);

  static const Duration refreshDuration =
      Duration(milliseconds: 700);

  // ==========================================================
  // Shadow
  // ==========================================================

  static const double glowBlur = 16.0;

  static const double glowSpread = 1.0;

  // ==========================================================
  // AI Card
  // ==========================================================

  static const int maxInsights = 3;

  // ==========================================================
  // Statistics
  // ==========================================================

  static const int statisticsColumns = 2;

  // ==========================================================
  // Forecast
  // ==========================================================

  static const int hoursInDay = 24;

  static const int maxProbability = 100;

  static const int minProbability = 0;

  // ==========================================================
  // Auto Refresh
  // ==========================================================

  static const Duration autoRefreshInterval =
      Duration(minutes: 30);

  // ==========================================================
  // Layout
  // ==========================================================

  static const double sectionSpacing = 24.0;

  static const double itemSpacing = 16.0;

  static const double smallSpacing = 8.0;
}