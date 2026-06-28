import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart'; // Обязательно для kIsWeb
import 'package:flutter/material.dart';
import 'home_page.dart'; // Проверь, чтобы путь к твоей домашней странице был верным

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _energyController;
  late Animation<double> _progressAnimation;

  // Фирменные цвета
  final Color neonColor = const Color(0xFF39FF14);
  final Color backgroundColor = const Color(0xFF020918); 

  @override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  );

  _progressAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ),
  );

  _energyController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  // Переход после завершения анимации
  _controller.addStatusListener((status) {
    if (status == AnimationStatus.completed && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  });

  _startAnimation();
}

Future<void> _startAnimation() async {
  // Небольшая задержка только для iPhone Safari
  if (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  if (!mounted) return;

  _energyController.repeat();

  _controller
    ..reset()
    ..forward();
}

  @override
  void dispose() {
    _controller.dispose();
    _energyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isMobile = size.width < 600; 

    final double canvasWidth = isMobile ? size.width * 0.8 : 340.0;
    final double canvasHeight = isMobile ? canvasWidth * (380 / 340) : 380.0; 
    final double barMaxWidth = isMobile ? size.width * 0.85 : 300.0;
    final double scale = canvasWidth / 340.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: AnimatedBuilder(
                animation: Listenable.merge([_energyController, _controller]), 
                builder: (context, child) {
                  return CustomPaint(
                    painter: NuvitLogoPainter(
                      neonColor: neonColor,
                      energyProgress: _energyController.value,
                      loadingProgress: _progressAnimation.value, 
                      scale: scale,
                      lowPerformanceMode:
      kIsWeb && defaultTargetPlatform == TargetPlatform.iOS,
),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 40), 

            AnimatedBuilder(
              animation: Listenable.merge([
                _progressAnimation,
                _energyController,
              ]),
              builder: (context, child) {
                final progressWidth = barMaxWidth * _progressAnimation.value;
                final pulse = 0.85 + 0.15 * math.sin(_energyController.value * math.pi * 2);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: barMaxWidth,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Container(
                      width: progressWidth,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF005E2B),
                            Color(0xFF39FF14),
                            Color(0xFFB4FF9F),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: neonColor.withValues(alpha: 0.8),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    if (_progressAnimation.value > 0)
                      Positioned(
                        left: progressWidth - 50,
                        top: -3,
                        child: Container(
                          width: 50,
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                neonColor.withValues(alpha: 0.08 * pulse),
                                neonColor.withValues(alpha: 0.25 * pulse),
                                neonColor.withValues(alpha: 0.7 * pulse),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_progressAnimation.value > 0)
                      Positioned(
                        left: progressWidth - 18,
                        top: 1,
                        child: Container(
                          width: 18,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                neonColor.withValues(alpha: 0.3),
                                Colors.white,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: neonColor.withValues(alpha: 0.9),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NuvitLogoPainter extends CustomPainter {
  final Color neonColor;
  final double energyProgress;
  final double loadingProgress; 
  final double scale;
  final bool lowPerformanceMode;

  NuvitLogoPainter({
    required this.neonColor,
    required this.energyProgress,
    required this.loadingProgress,
    required this.scale, 
    required this.lowPerformanceMode,
  });

  Offset pointOnLine(Offset p1, Offset p2, double t) {
    return Offset(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (scale != 1.0) {
      canvas.scale(scale, scale); 
    }

    final w = size.width / scale;
    final h = size.height / scale;

    final textPainter = TextPainter(
      text: TextSpan(
        style: TextStyle(
          fontSize: 57.5, 
          fontWeight: FontWeight.w800,
          letterSpacing: 7.5, 
          shadows: [
            Shadow(
              blurRadius: 30.0, 
              color: neonColor.withValues(alpha: 0.4),
            ),
          ],
        ),
        children: [
          TextSpan(text: 'N', style: TextStyle(color: neonColor)),
          const TextSpan(text: 'U', style: TextStyle(color: Colors.white)),
          TextSpan(text: 'V', style: TextStyle(color: neonColor)),
          const TextSpan(text: 'IT', style: TextStyle(color: Colors.white)),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textX = (w - textPainter.width) / 2;
    final textY = h - textPainter.height - 10; 

    textPainter.paint(canvas, Offset(textX, textY));

    final nLeft = textX + textPainter.getOffsetForCaret(const TextPosition(offset: 0), Rect.zero).dx;
    final uLeft = textX + textPainter.getOffsetForCaret(const TextPosition(offset: 1), Rect.zero).dx;
    final nWidth = uLeft - nLeft - 7.5; 

    final tLeft = textX + textPainter.getOffsetForCaret(const TextPosition(offset: 4), Rect.zero).dx;

    final baseLeft = nLeft + (nWidth * 0.55);
    final baseRight = tLeft;
    final houseWidth = baseRight - baseLeft;

    final textCenterX = textX + (textPainter.width / 2);

    final wallLeftX = textCenterX - (houseWidth / 2);
    final wallRightX = textCenterX + (houseWidth / 2);

    final houseBottomY = textY - 20; 

    final double wallHeight = textPainter.height * 1.5;
    final roofBaseY = houseBottomY - wallHeight; 

    final topPoint = Offset(textCenterX, h * 0.28);

    final roofLeft = Offset(wallLeftX - 14, roofBaseY);
    final roofRight = Offset(wallRightX + 14, roofBaseY);

    final housePath = Path()
      ..moveTo(roofLeft.dx, roofLeft.dy)
      ..lineTo(topPoint.dx, topPoint.dy)
      ..lineTo(roofRight.dx, roofRight.dy)
      ..lineTo(wallRightX, roofBaseY) 
      ..lineTo(wallRightX, houseBottomY)
      ..lineTo(wallLeftX, houseBottomY)
      ..lineTo(wallLeftX, roofBaseY)  
      ..close();                      

    final houseGlow = Paint()
  ..color = Colors.white.withValues(
      alpha: lowPerformanceMode ? 0.06 : 0.12)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 10
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

if (!lowPerformanceMode) {
  houseGlow.maskFilter =
      const MaskFilter.blur(BlurStyle.normal, 10);
}

    final housePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(housePath, houseGlow);
    canvas.drawPath(housePath, housePaint);

    final double wallCenterY = (roofBaseY + houseBottomY) / 2;
    final double angleRad = 20 * math.pi / 180;
    final double deltaX = textCenterX - wallLeftX; 
    final double deltaY = deltaX * math.tan(angleRad); 

    final center = Offset(textCenterX, wallCenterY - deltaY);
    final double exactShiftX = 4.5;
    
    final Offset leftWallStart = Offset(
      wallLeftX + exactShiftX, 
      wallCenterY - exactShiftX * math.tan(angleRad),
    );
    final Offset rightWallStart = Offset(
      wallRightX - exactShiftX, 
      wallCenterY - exactShiftX * math.tan(angleRad),
    );

    final Offset topStart = Offset(topPoint.dx, topPoint.dy + 5.5);

    double lineGrowth = 0.0;
    double circleScale = 0.0;
    double glowProgress = 0.0;

    if (loadingProgress <= 0.5) {
      lineGrowth = loadingProgress / 0.5;
    } else if (loadingProgress <= 0.75) {
      lineGrowth = 1.0;
      circleScale = (loadingProgress - 0.5) / 0.25;
    } else {
      lineGrowth = 1.0;
      circleScale = 1.0;
      glowProgress = (loadingProgress - 0.75) / 0.25;
    }

    if (lineGrowth > 0) {
      final Offset currentLeftEnd = pointOnLine(leftWallStart, center, lineGrowth);
      final Offset currentRightEnd = pointOnLine(rightWallStart, center, lineGrowth);
      final Offset currentTopEnd = pointOnLine(topStart, center, lineGrowth);

      final baseLinePaint = Paint()
        ..color = neonColor.withValues(alpha: 0.35) 
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(leftWallStart, currentLeftEnd, baseLinePaint);
      canvas.drawLine(rightWallStart, currentRightEnd, baseLinePaint);
      canvas.drawLine(topStart, currentTopEnd, baseLinePaint);

      final leftEnergy = pointOnLine(leftWallStart, currentLeftEnd, energyProgress);
      final rightEnergy = pointOnLine(rightWallStart, currentRightEnd, energyProgress);
      final topEnergy = pointOnLine(topStart, currentTopEnd, energyProgress);

      final energyPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
final energyGlowPaint = Paint()
  ..color = neonColor;

if (!lowPerformanceMode) {
  energyGlowPaint.maskFilter =
      const MaskFilter.blur(BlurStyle.normal, 4);
}

      canvas.drawCircle(leftEnergy, 4, energyGlowPaint);
      canvas.drawCircle(rightEnergy, 4, energyGlowPaint);
      canvas.drawCircle(topEnergy, 4, energyGlowPaint);

      canvas.drawCircle(leftEnergy, 2, energyPaint);
      canvas.drawCircle(rightEnergy, 2, energyPaint);
      canvas.drawCircle(topEnergy, 2, energyPaint);
    }

    // ИСПРАВЛЕНО 3: Радиус размытия маски ТЕПЕРЬ СТАТИЧНЫЙ (22.5 и 9.0). 
    // Меняется только прозрачность alpha. Это решает проблему лагов на iOS.
    if (circleScale > 0) {
      if (!lowPerformanceMode) {
  final outerGlow = Paint()
    ..color = neonColor.withValues(alpha: 0.15 * circleScale)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22.5);

  final middleGlow = Paint()
    ..color = neonColor.withValues(alpha: 0.3 * circleScale)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.0);

  canvas.drawCircle(center, 22.5 * circleScale, outerGlow);
  canvas.drawCircle(center, 16.5 * circleScale, middleGlow);
}

      final pulse = (13.5 + math.sin(energyProgress * math.pi * 2) * 1.1) * circleScale;

      canvas.drawCircle(
        center,
        pulse,
        Paint()..color = neonColor.withValues(alpha: circleScale),
      );
    }

    if (glowProgress > 0) {
      final Offset glowLeftEnd = pointOnLine(center, leftWallStart, glowProgress);
      final Offset glowRightEnd = pointOnLine(center, rightWallStart, glowProgress);
      final Offset glowTopEnd = pointOnLine(center, topStart, glowProgress);

      if (!lowPerformanceMode) {
  final backBlurPaint = Paint()
    ..color = neonColor.withValues(alpha: 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12.0
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  canvas.drawLine(center, glowLeftEnd, backBlurPaint);
  canvas.drawLine(center, glowRightEnd, backBlurPaint);
  canvas.drawLine(center, glowTopEnd, backBlurPaint);
}

final backGlowPaint = Paint()
  ..color = neonColor.withValues(alpha: 0.9)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 4.5
  ..strokeCap = StrokeCap.round;

canvas.drawLine(center, glowLeftEnd, backGlowPaint);
canvas.drawLine(center, glowRightEnd, backGlowPaint);
canvas.drawLine(center, glowTopEnd, backGlowPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NuvitLogoPainter oldDelegate) {
    return oldDelegate.energyProgress != energyProgress || 
           oldDelegate.loadingProgress != loadingProgress;
  }
}