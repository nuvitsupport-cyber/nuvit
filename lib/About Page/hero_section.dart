import 'dart:math' as math;
import 'package:flutter/material.dart';

// Кольорові константи екосистеми

const Color kAppBackground = Color(0xFF020D2D);
const Color kCardBackground = Color(0xFF081438);
const Color kInnerBackground = Color(0xFF051033); 
const Color kNeonGreen = Color(0xFF39FF14);
const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFF8E99B0);

class AboutHeroSection extends StatefulWidget {
  const AboutHeroSection({super.key});

  @override
  State<AboutHeroSection> createState() => _AboutHeroSectionState();
}

class _AboutHeroSectionState extends State<AboutHeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Анімація для логотипу (пульсує туди-сюди)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final desktop = width > 900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24, 
        vertical: 20,
      ),
      decoration: const BoxDecoration(
        color: kAppBackground,
      ),
      child: Container(
        width: double.infinity, 
        // Важливо: обрізаємо контент, щоб хвилі не виходили за межі border-radius
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: kCardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: kNeonGreen.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // --- ЖИВІ ЕНЕРГЕТИЧНІ ХВИЛІ НА ФОНІ ---
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180, // Висота блоку для хвиль
              child: EnergyWaves(),
            ),
            
            // --- ОСНОВНИЙ КОНТЕНТ КАРТКИ ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 55,
              ),
              child: desktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          flex: 6, 
                          child: _HeroTexts(),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 4, 
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (_, __) {
                                return _AnimatedLogo(
                                  progress: _controller.value,
                                  isMobile: false,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, __) {
                            return _AnimatedLogo(
                              progress: _controller.value,
                              isMobile: true,
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        const _HeroTexts(
                          center: true,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ВІДЖЕТ ДИНАМІЧНИХ ХВИЛЬ ---
class EnergyWaves extends StatefulWidget {
  const EnergyWaves({super.key});

  @override
  State<EnergyWaves> createState() => _EnergyWavesState();
}

class _EnergyWavesState extends State<EnergyWaves>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Контролер для хвиль (рухається лінійно і безкінечно)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary оптимізує перемальовування, ізолюючи анімацію хвиль від решти дерева
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          return CustomPaint(
            painter: WavePainter(
              progress: _waveController.value,
              neonColor: kNeonGreen,
            ),
          );
        },
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final Color neonColor;

  WavePainter({
    required this.progress,
    required this.neonColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Зсув фази: 2 * pi * progress забезпечує повний безшовний цикл за час анімації
    final double phase = progress * 2 * math.pi;

    // Налаштування для першої (швидшої/високої) хвилі
    _drawWave(
      canvas: canvas,
      size: size,
      amplitude: 25.0,
      wavelengths: 1.5, // 1.5 повні хвилі на ширину екрану
      phaseShift: phase,
      opacity: 0.15,
      strokeWidth: 2.5,
      blurRadius: 4.0,
      yOffset: size.height * 0.7,
    );

    // Налаштування для другої (повільнішої/нижчої) хвилі
    _drawWave(
      canvas: canvas,
      size: size,
      amplitude: 15.0,
      wavelengths: 2.0,
      // Зворотний або повільніший рух створює ефект інтерференції (накладання хвиль)
      phaseShift: phase * 0.7 + math.pi, 
      opacity: 0.25,
      strokeWidth: 1.5,
      blurRadius: 2.0,
      yOffset: size.height * 0.8,
    );
    
    // Третя, найтонша хвиля для глибини
    _drawWave(
      canvas: canvas,
      size: size,
      amplitude: 10.0,
      wavelengths: 1.2,
      phaseShift: phase * 1.2,
      opacity: 0.1,
      strokeWidth: 1.0,
      blurRadius: 8.0,
      yOffset: size.height * 0.65,
    );
  }

  void _drawWave({
    required Canvas canvas,
    required Size size,
    required double amplitude,
    required double wavelengths,
    required double phaseShift,
    required double opacity,
    required double strokeWidth,
    required double blurRadius,
    required double yOffset,
  }) {
    final Path path = Path();
    // B = 2 * pi * wavelengths / width
    final double frequency = (math.pi * 2 * wavelengths) / size.width;

    for (double x = 0; x <= size.width; x++) {
      // y = A * sin(B * x - C)
      final double y = yOffset + amplitude * math.sin(frequency * x - phaseShift);

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint paint = Paint()
      ..color = neonColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// --- ДАЛІ ЙДЕ ВАШ ОРИГІНАЛЬНИЙ КОД БЕЗ ЗМІН ---

class _HeroTexts extends StatelessWidget {
  final bool center;

  const _HeroTexts({
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        /// РОЗШИФРОВКА АБРЕВІАТУРИ
        RichText(
          textAlign: center ? TextAlign.center : TextAlign.left,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 40,
              color: kTextPrimary,
              letterSpacing: 1.2,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
            children: [
              _green("N"),
              const TextSpan(text: "ext "),

              _green("U"),
              const TextSpan(text: "nified "),

              _green("V"),
              const TextSpan(text: "oltage "),

              _green("I"),
              const TextSpan(text: "ntegration "),

              _green("T"),
              const TextSpan(text: "echnology"),
            ],
          ),
        ),

        const SizedBox(height: 24),

        /// ПОДЗАГОЛОВОК
        Text(
          "Ваш професійний асистент для контролю, прогнозування та управління домашньою енергетикою.",
          textAlign: center ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            fontSize: 19,
            color: kTextSecondary,
            height: 1.6,
            letterSpacing: .3,
          ),
        ),
      ],
    );
  }

  static TextSpan _green(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: kNeonGreen, 
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  final double progress;
  final bool isMobile;

  const _AnimatedLogo({
    required this.progress,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final canvasWidth = isMobile ? 260.0 : 340.0;
    final canvasHeight = isMobile ? canvasWidth * (380 / 340) : 380.0; 
    final scale = canvasWidth / 340.0; 

    return SizedBox(
      width: canvasWidth,
      height: canvasHeight,
      child: CustomPaint(
        painter: NuvitLogoPainter(
          neonColor: kNeonGreen, 
          energyProgress: progress, 
          loadingProgress: 1.0, 
          scale: scale, 
          lowPerformanceMode: false, 
        ),
      ),
    );
  }
}

// --- Функції малювання логотипу ---

Offset pointOnLine(Offset p1, Offset p2, double t) {
  return Offset(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
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
              color: neonColor.withOpacity(0.4),
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
    final textY = h - textPainter.height - 55; 

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

    final topPoint = Offset(textCenterX, (h * 0.28) - 45);

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
      ..color = Colors.white.withOpacity(
          lowPerformanceMode ? 0.06 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (!lowPerformanceMode) {
      houseGlow.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
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
        ..color = neonColor.withOpacity(0.35) 
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
        energyGlowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      }

      canvas.drawCircle(leftEnergy, 4, energyGlowPaint);
      canvas.drawCircle(rightEnergy, 4, energyGlowPaint);
      canvas.drawCircle(topEnergy, 4, energyGlowPaint);

      canvas.drawCircle(leftEnergy, 2, energyPaint);
      canvas.drawCircle(rightEnergy, 2, energyPaint);
      canvas.drawCircle(topEnergy, 2, energyPaint);
    }

    if (circleScale > 0) {
      if (!lowPerformanceMode) {
        final outerGlow = Paint()
          ..color = neonColor.withOpacity(0.15 * circleScale)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22.5);

        final middleGlow = Paint()
          ..color = neonColor.withOpacity(0.3 * circleScale)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.0);

        canvas.drawCircle(center, 22.5 * circleScale, outerGlow);
        canvas.drawCircle(center, 16.5 * circleScale, middleGlow);
      }

      final pulse = (13.5 + math.sin(energyProgress * math.pi * 2) * 1.1) * circleScale;

      canvas.drawCircle(
        center,
        pulse,
        Paint()..color = neonColor.withOpacity(circleScale),
      );
    }

    if (glowProgress > 0) {
      final Offset glowLeftEnd = pointOnLine(center, leftWallStart, glowProgress);
      final Offset glowRightEnd = pointOnLine(center, rightWallStart, glowProgress);
      final Offset glowTopEnd = pointOnLine(center, topStart, glowProgress);

      if (!lowPerformanceMode) {
        final backBlurPaint = Paint()
          ..color = neonColor.withOpacity(0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawLine(center, glowLeftEnd, backBlurPaint);
        canvas.drawLine(center, glowRightEnd, backBlurPaint);
        canvas.drawLine(center, glowTopEnd, backBlurPaint);
      }

      final backGlowPaint = Paint()
        ..color = neonColor.withOpacity(0.9)
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