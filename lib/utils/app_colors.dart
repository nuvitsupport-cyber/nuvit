// lib/utils/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Базові кольори інтерфейсу (Твоя оновлена глибока палітра)
  static const Color bg = Color(0xFF1A2238);       // Основний фон додатку (Глибокий синьо-кібернетичний)
  static const Color background = Color(0xFF1A2238); // Аліас для сумісності з HomePage геттерами
  static const Color card = Color(0xFF222E4B);     // Фон інформаційних карток та блоків меню
  static const Color neon = Color(0xFF60E302);     // Фірмовий інженерний зелений неон (Акценти, кнопки, заряд)

  // Допоміжні акценти для систем моніторингу NUVIT
  static const Color neonDim = Color(0x3360E302);  // Напівпрозорий неон для ефектів світіння та оверлеїв (alpha 0.2)
  static const Color textMain = Color(0xFFFFFFFF); // Основний білий текст
  static const Color textMuted = Color(0xFF7F8C8D); // 🔥 ВИПРАВЛЕНО: Приглушений текст / іконки підказок (сірий)

  // Функціональні кольори статусів енергомережі та приладів
  static const Color critical = Color(0xFFFF3B30); // Критичний розряд АКБ / Блекаут / Перевантаження
  static const Color warning = Color(0xFFFF9500);  // Попередження / Робота в пікових режимах
  static const Color optimal = Color(0xFF34C759);  // Стабільна генерація від СЕС / Оптимальний рівень SoC

  // Градієнти для бекграундів карт та прогрес-барів автономності
  static const Gradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A2238),
      Color(0xFF111625),
    ],
  );

  static const Gradient neonGradient = LinearGradient(
    colors: [
      Color(0xFF60E302),
      Color(0xFF96EF02),
    ],
  );
}