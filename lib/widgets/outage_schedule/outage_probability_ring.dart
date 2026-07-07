import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/outage/outage_probability.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import '../../utils/outage/outage_formatter.dart';

class OutageProbabilityRing extends StatelessWidget {
  final OutageProbability probability;

  const OutageProbabilityRing({
    super.key,
    required this.probability,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем цвет в зависимости от уровня риска (зеленый/желтый/красный)
    final color = OutageColors.probability(probability);

    return SizedBox(
      width: OutageConstants.probabilityRingSize,
      height: OutageConstants.probabilityRingSize,
      child: Stack(
        fit: StackFit.expand,
        children: [
          
          // 1. Само кольцо с помощью кастомного пейнтера
          CustomPaint(
            painter: _RingPainter(
              // Предполагаю, что в модели есть поле percent исходя из твоего toString в forecast
              percent: probability.percent.toDouble(),
              color: color,
              backgroundColor: OutageColors.innerCard, // Темная подложка кольца
              strokeWidth: OutageConstants.probabilityStroke,
            ),
          ),
          
          // 2. Текст внутри кольца
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  OutageFormatter.percent(probability.percent),
                  style: const TextStyle(
                    color: OutageColors.textPrimary,
                    fontSize: 26, // Крупный размер для процентов
                    fontWeight: OutageConstants.titleWeight,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                const Text(
                  'Ймовірність\nнаявності світла', 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: OutageColors.textSecondary,
                    fontSize: 10,
                    fontWeight: OutageConstants.bodyWeight,
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}

/// Пейнтер для отрисовки кольца вероятности со свечением
class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.percent,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Фон кольца (темный трек)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius, bgPaint);

    // Переводим проценты в угол (360 градусов = 2 * PI)
    final sweepAngle = 2 * math.pi * (percent / 100);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -math.pi / 2; // Начинаем с 12 часов (сверху)

    // 2. Неоновое свечение под основным баром
    final glowPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal, 
        OutageConstants.glowBlur, // Используем твою константу 16.0
      );

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

    // 3. Основной прогресс-бар
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Закругленные края

    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percent != percent ||
           oldDelegate.color != color ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}