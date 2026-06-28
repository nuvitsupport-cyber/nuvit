// lib/widgets/energy_hub/autonomy_calculator/painters/autonomy_ring_painter.dart

import 'package:flutter/material.dart';
import 'package:nuvit/utils/app_colors.dart';

class AutonomyRingPainter extends CustomPainter {
  final double progress;

  const AutonomyRingPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2;

    /// Фонове кільце
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(.08)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius - 5,
      backgroundPaint,
    );

    /// Неонове світіння
    final glowPaint = Paint()
      ..color = AppColors.neon.withOpacity(.25)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius - 5,
      ),
      -1.5708,
      6.28318 * progress,
      false,
      glowPaint,
    );

    /// Основне кільце прогресу
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.neon,
          Color(0xFF96EF02),
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      )
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius - 5,
      ),
      -1.5708,
      6.28318 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant AutonomyRingPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}