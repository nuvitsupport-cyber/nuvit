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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _energyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ВАЖНО: Ждем, пока Flutter построит первый кадр (вычислит размеры и шрифты),
    // и только потом даем отмашку на старт анимаций.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _energyController.repeat(); // Запускаем пульсацию

        // Запускаем линию загрузки и ЖДЕМ ЕЁ ЗАВЕРШЕНИЯ (вместо Timer)
        _controller.forward().then((_) {
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
    // 1. ПОЛУЧАЕМ РАЗМЕРЫ ЭКРАНА
    final size = MediaQuery.sizeOf(context);
    final bool isMobile = size.width < 600; // Стандартный брейкпоинт для телефонов

    // 2. ГИБКИЕ РАЗМЕРЫ
    // На телефоне холст занимает 80% ширины, на ПК — фиксированные 340px
    final double canvasWidth = isMobile ? size.width * 0.8 : 340.0;
    
    // Сохраняем пропорции логотипа
    final double canvasHeight = isMobile ? canvasWidth * (380 / 340) : 380.0; 
    
    // Полоса загрузки занимает 85% экрана мобильного или 300px на ПК
    final double barMaxWidth = isMobile ? size.width * 0.85 : 300.0;

    // 3. КОЭФФИЦИЕНТ МАСШТАБА ДЛЯ ХУДОЖНИКА (Canvas)
    final double scale = canvasWidth / 340.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Объединенный холст: Дом + Текст NUVIT + Энергетический узел
            SizedBox(
              width: canvasWidth,
              height: canvasHeight,
              child: AnimatedBuilder(
  // Настраиваем обновление холста от двух анимаций одновременно
  animation: Listenable.merge([_energyController, _controller]), 
  builder: (context, child) {
    return CustomPaint(
      painter: NuvitLogoPainter(
        neonColor: neonColor,
        energyProgress: _energyController.value,
        loadingProgress: _progressAnimation.value, // Передаем прогресс от 0.0 до 1.0
        scale: scale,
      ),
    );
  },
),
            ),
            
            const SizedBox(height: 40), 

            // Минималистичная полоса загрузки (Tesla-style)
            AnimatedBuilder(
  animation: Listenable.merge([
    _progressAnimation,
    _energyController,
  ]),
  builder: (context, child) {
    final progressWidth = barMaxWidth * _progressAnimation.value;

    // Легкая пульсация блика
    final pulse =
        0.85 + 0.15 * math.sin(_energyController.value * math.pi * 2);

    return Stack(
      clipBehavior: Clip.none,
      children: [

        // Фон
        Container(
          width: barMaxWidth,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // Основная полоса
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

        // Движущийся энергетический хвост
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

        // Яркий блик на конце полосы
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
  final double loadingProgress; // Новое поле для анимации роста линий
final double scale;

  NuvitLogoPainter({
    required this.neonColor,
    required this.energyProgress,
    required this.loadingProgress,
    required this.scale, // Добавили в конструктор
  });

  // Вспомогательный метод для расчета движения импульсов по линиям
  Offset pointOnLine(Offset p1, Offset p2, double t) {
    return Offset(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
   // 1. СОХРАНЯЕМ И МАСШТАБИРУЕМ ХОЛСТ
    canvas.save();
    if (scale != 1.0) {
      canvas.scale(scale, scale); // Уменьшает всё, что будет нарисовано
    }

    // 2. КОМПЕНСИРУЕМ ПЕРЕМЕННЫЕ w И h
    // Холст сжат, поэтому логически возвращаем ему эталонный размер 340x380
    final w = size.width / scale;
    final h = size.height / scale;

    // =====================================================
    // ТЕКСТ NUVIT И ВЫЧИСЛЕНИЕ КООРДИНАТ БУКВ
    // =====================================================
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

    // =====================================================
    // ГЕОМЕТРИЯ ДОМА (ПРИЗЕМИСТАЯ КРЫША h * 0.28)
    // =====================================================
    final baseLeft = nLeft + (nWidth * 0.55);
    final baseRight = tLeft;
    final houseWidth = baseRight - baseLeft;

    final textCenterX = textX + (textPainter.width / 2);

    final wallLeftX = textCenterX - (houseWidth / 2);
    final wallRightX = textCenterX + (houseWidth / 2);

    final houseBottomY = textY - 20; 

    // Высота боковых линий (1.5 высоты шрифта)
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

    // Отрисовка контура дома (толщина 5)
    final houseGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final housePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(housePath, houseGlow);
    canvas.drawPath(housePath, housePaint);

    // =====================================================
    // ЦЕНТРАЛЬНЫЙ ЭНЕРГЕТИЧЕСКИЙ УЗЕЛ И НЕОНОВЫЕ ЛИНИИ
    // =====================================================
    // Находим точный геометрический центр боковых стен по вертикали
    final double wallCenterY = (roofBaseY + houseBottomY) / 2;

    // Вычисляем положение центрального узла под углом 20 градусов
    final double angleRad = 20 * math.pi / 180;
    final double deltaX = textCenterX - wallLeftX; 
    final double deltaY = deltaX * math.tan(angleRad); 

    // Координата центра строго привязана к центрам стен и углу 20°
    final center = Offset(textCenterX, wallCenterY - deltaY);

    // Точный математический расчет стыка для боковых стен
    final double exactShiftX = 4.5;
    
    // Вычисляем точки старта боковых линий бесшовно
    final Offset leftWallStart = Offset(
      wallLeftX + exactShiftX, 
      wallCenterY - exactShiftX * math.tan(angleRad),
    );
    final Offset rightWallStart = Offset(
      wallRightX - exactShiftX, 
      wallCenterY - exactShiftX * math.tan(angleRad),
    );

    // Точка старта сверху от козырька (смещена строго вертикально вниз во внутренний угол)
    final Offset topStart = Offset(topPoint.dx, topPoint.dy + 5.5);

    // =====================================================
    // ТРЕХЭТАПНАЯ АНИМАЦИЯ: ЛИНИИ К ЦЕНТРУ (0-50%) -> КРУГ (50-75%) -> ПОДСВЕТКА НАЗАД (75-100%)
    // =====================================================
    double lineGrowth = 0.0;
    double circleScale = 0.0;
    double glowProgress = 0.0;

    if (loadingProgress <= 0.5) {
      // 1 этап: Линии растут к центру
      lineGrowth = loadingProgress / 0.5;
    } else if (loadingProgress <= 0.75) {
      // 2 этап: Линии сомкнулись, круг растет из центра
      lineGrowth = 1.0;
      circleScale = (loadingProgress - 0.5) / 0.25;
    } else {
      // 3 этап: Все готово, подсветка идет из центра обратно к контурам
      lineGrowth = 1.0;
      circleScale = 1.0;
      glowProgress = (loadingProgress - 0.75) / 0.25;
    }

    // -----------------------------------------------------
    // 1. БАЗОВЫЕ ЛИНИИ (Движение ОТ КОНТУРОВ К ЦЕНТРУ)
    // -----------------------------------------------------
    if (lineGrowth > 0) {
      final Offset currentLeftEnd = pointOnLine(leftWallStart, center, lineGrowth);
      final Offset currentRightEnd = pointOnLine(rightWallStart, center, lineGrowth);
      final Offset currentTopEnd = pointOnLine(topStart, center, lineGrowth);

      final baseLinePaint = Paint()
        ..color = neonColor.withValues(alpha: 0.35) // Умеренная базовая яркость до активации импульса подсветки
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(leftWallStart, currentLeftEnd, baseLinePaint);
      canvas.drawLine(rightWallStart, currentRightEnd, baseLinePaint);
      canvas.drawLine(topStart, currentTopEnd, baseLinePaint);

      // БЕГУЩИЕ ИМПУЛЬСЫ (Летят к центру вслед за ростом линий)
      final leftEnergy = pointOnLine(leftWallStart, currentLeftEnd, energyProgress);
      final rightEnergy = pointOnLine(rightWallStart, currentRightEnd, energyProgress);
      final topEnergy = pointOnLine(topStart, currentTopEnd, energyProgress);

      final energyPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      final energyGlowPaint = Paint()
        ..color = neonColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(leftEnergy, 4, energyGlowPaint);
      canvas.drawCircle(rightEnergy, 4, energyGlowPaint);
      canvas.drawCircle(topEnergy, 4, energyGlowPaint);

      canvas.drawCircle(leftEnergy, 2, energyPaint);
      canvas.drawCircle(rightEnergy, 2, energyPaint);
      canvas.drawCircle(topEnergy, 2, energyPaint);
    }

    // -----------------------------------------------------
    // 2. ЦЕНТРАЛЬНЫЙ ЭНЕРГЕТИЧЕСКИЙ КРУГ (Появляется из точки пересечения)
    // -----------------------------------------------------
    if (circleScale > 0) {
      final outerGlow = Paint()
        ..color = neonColor.withValues(alpha: 0.15 * circleScale)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 22.5 * circleScale);

      final middleGlow = Paint()
        ..color = neonColor.withValues(alpha: 0.3 * circleScale)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 9 * circleScale);

      canvas.drawCircle(center, 22.5 * circleScale, outerGlow);
      canvas.drawCircle(center, 16.5 * circleScale, middleGlow);

      // Анимация пульсации ядра
      final pulse = (13.5 + math.sin(energyProgress * math.pi * 2) * 1.1) * circleScale;

      canvas.drawCircle(
        center,
        pulse,
        Paint()..color = neonColor.withValues(alpha: circleScale),
      );
    }

    // -----------------------------------------------------
    // 3. ОБРАТНАЯ ПОДСВЕТКА (Взрыв яркости ИЗ ЦЕНТРА К КРАЯМ)
    // -----------------------------------------------------
    if (glowProgress > 0) {
      // Рассчитываем движение волны света от центра обратно к краям стен и крыши
      final Offset glowLeftEnd = pointOnLine(center, leftWallStart, glowProgress);
      final Offset glowRightEnd = pointOnLine(center, rightWallStart, glowProgress);
      final Offset glowTopEnd = pointOnLine(center, topStart, glowProgress);

      // Кисть для сочного неонового свечения (размытие)
      final backBlurPaint = Paint()
        ..color = neonColor.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Кисть для плотной яркой сердцевины линии
      final backGlowPaint = Paint()
        ..color = neonColor.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;

      // Рисуем бегущую назад световую неоновую подушку
      canvas.drawLine(center, glowLeftEnd, backBlurPaint);
      canvas.drawLine(center, glowRightEnd, backBlurPaint);
      canvas.drawLine(center, glowTopEnd, backBlurPaint);

      // Накладываем сверху супер-яркую сплошную неоновую линию
      canvas.drawLine(center, glowLeftEnd, backGlowPaint);
      canvas.drawLine(center, glowRightEnd, backGlowPaint);
      canvas.drawLine(center, glowTopEnd, backGlowPaint);
    }
    canvas.restore();
  }
// ДОБАВЬ ЭТОТ МЕТОД СРАЗУ ПОСЛЕ МЕТОДА paint:
  @override
  bool shouldRepaint(covariant NuvitLogoPainter oldDelegate) {
    return oldDelegate.energyProgress != energyProgress || 
           oldDelegate.loadingProgress != loadingProgress;
  }
}