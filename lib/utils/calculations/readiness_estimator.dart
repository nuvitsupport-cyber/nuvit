class ReadinessEstimator {
  static int calculateReadinessScore({
    required double batteryHealth,
    required double autonomyHours,
    required int activeLoad,
    required String weatherAdvice,
  }) {
    double score = 100.0;

    // 1. Штраф за деградацию батареи
    if (batteryHealth < 80) {
      score -= (80 - batteryHealth) * 1.2;
    }

    // 2. Оценка запаса автономности (идеально — более 6 часов работы)
    if (autonomyHours < 2.0) {
      score -= 40;
    } else if (autonomyHours < 6.0) {
      score -= 20;
    }

    // 3. Штраф за перегрузку инвертора (высокая текущая нагрузка)
    if (activeLoad > 2500) {
      score -= 15;
    }

    // 4. Анализ внешних метео-рисков по ключевым маркерам в совете погоды
    if (weatherAdvice.contains('📉') || weatherAdvice.contains('штормовий вітер')) {
      score -= 20; // Опасность затяжного блэкаута или отсутствия генерации
    }

    return score.clamp(0, 100).round();
  }
}