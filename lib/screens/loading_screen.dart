import 'dart:async';
import 'dart:math' as math;
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

  // Твои фирменные цвета
  final Color neonColor = const Color(0xFF39FF14);
  final Color backgroundColor = const Color(0xFF020918); // Премиальный фон

  @override
  void initState() {
    super.initState();

    // Анимация полосы загрузки на 3 секунды
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Плавное заполнение линии слева направо (Tesla-style)
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward();
_energyController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 2200),
)..repeat();
    // Автоматический переход на HomePage после завершения анимации
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(), 
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

 @override
void dispose() {
  _controller.dispose();
  _energyController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    // Рассчитываем размеры на 25% больше базовых
    final double baseLogoSize = 220;
    final double enlargedLogoSize = baseLogoSize * 1.25;

    final double baseFontSize = 46;
    final double enlargedFontSize = baseFontSize * 1.25;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Логотип PNG с твоим точным путем, увеличенный на 25%
           SizedBox(
  width: enlargedLogoSize,
  height: enlargedLogoSize,
  child: AnimatedBuilder(
    animation: _energyController,
    builder: (context, child) {
      return CustomPaint(
        painter: NuvitLogoPainter(
          neonColor: neonColor,
          energyProgress: _energyController.value,
        ),
      );
    },
  ),
),
            const SizedBox(height: 35), 
            
            // 2. Премиальная надпись NUVIT, увеличенная на 25%
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: enlargedFontSize,
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
            ),
            const SizedBox(height: 75), 

            // 3. Минималистичная полоса загрузки (Tesla-style)
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  width: 300, 
                  height: 2,  
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05), 
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Линия строго слева направо
                    children: [
                      Container(
                        width: 300 * _progressAnimation.value,
                        height: 2,
                        decoration: BoxDecoration(
                          color: neonColor,
                          boxShadow: [
                            BoxShadow(
                              color: neonColor.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  NuvitLogoPainter({
    required this.neonColor,
    required this.energyProgress,
  });

  Offset pointOnLine(
    Offset start,
    Offset end,
    double t,
  ) {
    return Offset(
      start.dx + (end.dx - start.dx) * t,
      start.dy + (end.dy - start.dy) * t,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // =====================================================
    // ГЕОМЕТРИЯ ДОМА
    // =====================================================

    final centerX = w * 0.50;
   final centerY = h * 0.70;

    final center = Offset(centerX, centerY);

    final roofPeak = Offset(
  centerX,
  h * 0.08,
);
   final roofLeft = Offset(
  w * 0.14,
  h * 0.40,
);

final roofRight = Offset(
  w * 0.86,
  h * 0.40,
);

   final wallLeftX = w * 0.18;
final wallRightX = w * 0.82;

    final roofBaseY = h * 0.38;
    final houseBottomY = h * 0.92;

    final housePath = Path()
      ..moveTo(roofLeft.dx, roofLeft.dy)
      ..lineTo(roofPeak.dx, roofPeak.dy)
      ..lineTo(roofRight.dx, roofRight.dy)
      ..lineTo(wallRightX, roofBaseY)
      ..lineTo(wallRightX, houseBottomY)
      ..lineTo(wallLeftX, houseBottomY)
      ..lineTo(wallLeftX, roofBaseY)
      ..close();

    // =====================================================
    // КОНТУР ДОМА
    // =====================================================

    final houseGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter =
          const MaskFilter.blur(
            BlurStyle.normal,
            10,
          );

    final housePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(housePath, houseGlow);
    canvas.drawPath(housePath, housePaint);

    // =====================================================
    // ТОЧКИ ПОДКЛЮЧЕНИЯ
    // =====================================================

    final topPoint = Offset(
      centerX,
      h * 0.03,
    );

    final leftPoint = Offset(
  wallLeftX,
  h * 0.70,
);

final rightPoint = Offset(
  wallRightX,
  h * 0.70,
);

    // =====================================================
    // НЕОНОВЫЕ ЛИНИИ
    // =====================================================

    final lineGlow = Paint()
      ..color = neonColor.withValues(alpha: 0.65)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter =
          const MaskFilter.blur(
            BlurStyle.normal,
            6,
          );

    final linePaint = Paint()
      ..color = neonColor
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      topPoint,
      center,
      lineGlow,
    );

    canvas.drawLine(
      topPoint,
      center,
      linePaint,
    );

    canvas.drawLine(
      leftPoint,
      center,
      lineGlow,
    );

    canvas.drawLine(
      leftPoint,
      center,
      linePaint,
    );

    canvas.drawLine(
      rightPoint,
      center,
      lineGlow,
    );

    canvas.drawLine(
      rightPoint,
      center,
      linePaint,
    );

    // =====================================================
    // ЦЕНТРАЛЬНЫЙ УЗЕЛ
    // =====================================================

    final outerGlow = Paint()
      ..color = neonColor.withValues(alpha: 0.35)
      ..maskFilter =
          const MaskFilter.blur(
            BlurStyle.normal,
            28,
          );

    final middleGlow = Paint()
      ..color = neonColor.withValues(alpha: 0.75)
      ..maskFilter =
          const MaskFilter.blur(
            BlurStyle.normal,
            10,
          );

    canvas.drawCircle(
      center,
      30,
      outerGlow,
    );

    canvas.drawCircle(
      center,
      22,
      middleGlow,
    );

    final pulse =
        18 +
        math.sin(
              energyProgress *
                  math.pi *
                  2,
            ) *
            1.5;

    canvas.drawCircle(
      center,
      pulse,
      Paint()..color = neonColor,
    );

    // =====================================================
    // БЕГУЩИЕ ИМПУЛЬСЫ
    // =====================================================

    final topEnergy = pointOnLine(
      topPoint,
      center,
      energyProgress,
    );

    final leftEnergy = pointOnLine(
      leftPoint,
      center,
      energyProgress,
    );

    final rightEnergy = pointOnLine(
      rightPoint,
      center,
      energyProgress,
    );

    final energyPaint = Paint()
      ..color = neonColor
      ..maskFilter =
          const MaskFilter.blur(
            BlurStyle.normal,
            4,
          );

    canvas.drawCircle(
      topEnergy,
      4,
      energyPaint,
    );

    canvas.drawCircle(
      leftEnergy,
      4,
      energyPaint,
    );

    canvas.drawCircle(
      rightEnergy,
      4,
      energyPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant NuvitLogoPainter oldDelegate,
  ) {
    return oldDelegate.energyProgress !=
        energyProgress;
  }
}