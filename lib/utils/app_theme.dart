// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const double defaultRadius = 12.0;
  static final BorderRadius borderRadius = BorderRadius.circular(defaultRadius);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      // 1. Базовий фон додатку (використовуємо верифікований AppColors.bg)
      scaffoldBackgroundColor: AppColors.bg,
      
      // 2. Панель AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false, // Змінено на false, щоб відповідати лівому вирівнюванню десктопного сайдбару
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: AppColors.neon),
      ),

      // 3. Картки (Card) — основа інтерфейсу NUVIT
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0, // У плоскому неоновому стилі краще прибрати дефолтні тіні
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: AppColors.neon.withValues(alpha: 0.15), // Легкий неоновий контур для карток
            width: 1,
          ),
        ),
      ),

      // 4. Поля введення ємності АКБ та потужності (Input)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: Colors.white60),
        hintStyle: const TextStyle(color: Colors.white30),
        border: OutlineInputBorder(
          borderRadius: borderRadius, 
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius, 
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius, 
          borderSide: const BorderSide(color: AppColors.neon, width: 1.5),
        ),
      ),

      // 5. Повзунки конфігурації (Slider) — SoC, DoD
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.neon,
        thumbColor: AppColors.neon,
        inactiveTrackColor: const Color(0xFF1E2235), // Глибокий темний для неактивного треку
        valueIndicatorColor: AppColors.card,
        overlayColor: AppColors.neon.withValues(alpha: 0.2), // Нативний красивий відблиск при натисканні
        valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      // 6. Спливаючі сповіщення системи (SnackBar)
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: AppColors.neon, width: 1),
        ),
      ),

      // 7. Чекбокси вибору приладів (Checkbox)
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neon;
          return null;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // 8. Радіо-кнопки (Radio)
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neon;
          return null;
        }),
      ),

      // 9. Глобальні шрифти та стилі тексту (TextTheme)
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
      ),

      // 10. Кнопки підтвердження та перемикання пресетів режимів
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neon,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
      ),
    );
  }
}