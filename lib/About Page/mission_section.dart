import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ===============================================================
/// NUVIT - Mission Section с интерактивной технической анимацией
/// ===============================================================

const Color kAppBackground = Color(0xFF020D2D);
const Color kCardBackground = Color(0xFF081438);
const Color kInnerBackground = Color(0xFF051033);

const Color kNeonGreen = Color(0xFF39FF14);

const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFF8E99B0);

class MissionSection extends StatelessWidget {
  const MissionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool desktop = width > 1100;
    final bool tablet = width > 750;

    return Container(
      width: double.infinity,
      color: kAppBackground,
      padding: EdgeInsets.only(
    left: desktop ? 90 : tablet ? 48 : 24,
    right: desktop ? 90 : tablet ? 48 : 24,
    top: desktop ? 110 : 70,
    bottom: desktop ? 40 : 25, 
  ),
  child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1450),
        child: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 5,
                    child: _Manifesto(),
                  ),
                  const SizedBox(width: 60),
                  Expanded(
                    flex: 6,
                    child: _ValuesGrid(desktop: desktop),
                  ),
                ],
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Manifesto(),
                  SizedBox(height: 55),
                  _ValuesGrid(desktop: false),
                ],
              ),
      ),
    );
  }
}

class _Manifesto extends StatelessWidget {
  const _Manifesto();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isDesktop = width > 1100;
    final titleSize = width > 1200
        ? 46.0
        : width > 900
            ? 40.0
            : 34.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kNeonGreen.withOpacity(.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: kNeonGreen.withOpacity(.25),
            ),
          ),
          child: const Text(
            "МІСІЯ NUVIT",
            style: TextStyle(
              color: kNeonGreen,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          "Більше, ніж моніторинг.\nІнженерія вашої\nенергонезалежності.",
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w800,
            height: 1.1,
            fontSize: titleSize,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          width: 75,
          height: 4,
          decoration: BoxDecoration(
            color: kNeonGreen,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: kNeonGreen.withOpacity(.55),
                blurRadius: 16,
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Nuvit об'єднує складні технічні процеси в єдину, зрозумілу екосистему. "
          "Ми створюємо інструменти для тих, хто вимагає точності в кожному ваті.\n\n"
          "Ми віримо: управління енергією — це не про «бачити графіки», а про «керувати автономією». "
          "Наші алгоритми перетворюють хаотичні дані від інверторів, панелей та зарядних станцій "
          "на чітку стратегію вашої енергетичної стійкості, де кожен вузол системи працює "
          "з максимальною ефективністю.",
          style: TextStyle(
            color: kTextSecondary,
            fontSize: 17,
            height: 1.8,
          ),
        ),
        
        // Интерактивная техническая анимация (включается только на Desktop)
        if (isDesktop) ...[
          const SizedBox(height: 50),
          const _ManifestoAnimation(),
        ],
      ],
    );
  }
}

class _ValuesGrid extends StatelessWidget {
  final bool desktop;

  const _ValuesGrid({
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      const _MissionCard(
        icon: Icons.analytics_outlined,
        title: "Фокус на даних,\nа не на маркетингу",
        description:
            "Ми прибрали все рекламне лушпиння. У базі Nuvit немає довгих "
            "хвалебних описів виробників — лише сухі технічні "
            "характеристики: реальний ККД, клас обладнання та можливість "
            "ручного введення потужності для кожної окремої панелі "
            "у вашій кастомній збірці.",
      ),
      const _MissionCard(
        icon: Icons.query_stats,
        title: "Реалістичне\nпрогнозування",
        description:
            "Сонячна генерація залежить не тільки від географічної широти. "
            "Алгоритми Nuvit використовують астрономічні дані, обчислюють "
            "ефективні сонячні години та враховують Cloud Factor, "
            "щоб будувати максимально реалістичні прогнози генерації.",
      ),
      const _MissionCard(
        icon: Icons.shield_outlined,
        title: "Безпечний контроль\nінфраструктури",
        description:
            "Від домашнього бойлера до EV-зарядки. Ви сформуєте єдиний "
            "каталог обладнання, захищений від логічних помилок. "
            "Система дозволяє швидко вибирати пристрої та миттєво "
            "перераховувати автономність батареї.",
      ),
      const _MissionCard(
        icon: Icons.layers_outlined,
        title: "Масштабована\nекосистема",
        description:
            "Система Nuvit розвивається разом з вами. Легко додавайте нові "
            "інвертори, контролери або джерела споживання в один клік, "
            "зберігаючи цілісність енергетичної моделі об'єкта.",
      ),
    ];

    if (desktop) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[i]),
                    const SizedBox(width: 24),
                    if (i + 1 < cards.length)
                      Expanded(child: cards[i + 1])
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      children: cards
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: e,
              ))
          .toList(),
    );
  }
}

class _MissionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _MissionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<_MissionCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: hovered ? kInnerBackground : kCardBackground,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: hovered
                ? kNeonGreen.withOpacity(.35)
                : Colors.white.withOpacity(.05),
          ),
          boxShadow: [
            BoxShadow(
              color: hovered
                  ? kNeonGreen.withOpacity(.08)
                  : Colors.black.withOpacity(.18),
              blurRadius: hovered ? 28 : 16,
              spreadRadius: hovered ? 2 : 0,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: kNeonGreen.withOpacity(.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: kNeonGreen.withOpacity(.28),
                ),
              ),
              child: Icon(
                widget.icon,
                color: kNeonGreen,
                size: 30,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              widget.title,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.description,
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 15.5,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 30),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: hovered ? 80 : 42,
              height: 3,
              decoration: BoxDecoration(
                color: kNeonGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kNeonGreen.withOpacity(.5),
                    blurRadius: 12,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// НОВЫЙ ВИДЖЕТ: Интерактивная техническая волна-симулятор
/// ===============================================================
class _ManifestoAnimation extends StatefulWidget {
  const _ManifestoAnimation();

  @override
  State<_ManifestoAnimation> createState() => _ManifestoAnimationState();
}

class _ManifestoAnimationState extends State<_ManifestoAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: kCardBackground.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              painter: _EnergyWavePainter(progress: _animController.value),
            ),
          ),
        );
      },
    );
  }
}

class _EnergyWavePainter extends CustomPainter {
  final double progress;

  _EnergyWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double midY = size.height / 2;

    // 1. Отрисовка фоновой технической координатной сетки
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const int gridRows = 6;
    for (int i = 1; i < gridRows; i++) {
      final double y = (size.height / gridRows) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    const int gridCols = 12;
    for (int i = 1; i < gridCols; i++) {
      final double x = (size.width / gridCols) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 2. Отрисовка Основной Неоновой Волны (Генерация/Частота)
    final wavePaint1 = Paint()
      ..color = kNeonGreen.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Эффект размытия / свечения (Glow) вокруг линии
    final waveGlowPaint = Paint()
      ..color = kNeonGreen.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final path1 = Path();
    final glowPath = Path();

    // Вторая, более тонкая фазовая волна для глубины интерфейса
    final wavePaint2 = Paint()
      ..color = const Color(0xff00E5FF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path2 = Path();

    bool first = true;

    for (double x = 0; x <= size.width; x += 2) {
      // Математика волны с затуханием по краям экрана, чтобы линии красиво уходили в края
      final double edgeFade = math.sin((x / size.width) * math.pi);
      
      final double angle1 = (x / size.width) * 2.5 * math.pi - (progress * 2 * math.pi);
      final double y1 = midY + (math.sin(angle1) * 35 * edgeFade);

      final double angle2 = (x / size.width) * 4.0 * math.pi - (progress * 3 * math.pi);
      final double y2 = midY + (math.cos(angle2) * 20 * edgeFade);

      if (first) {
        path1.moveTo(x, y1);
        glowPath.moveTo(x, y1);
        path2.moveTo(x, y2);
        first = false;
      } else {
        path1.lineTo(x, y1);
        glowPath.lineTo(x, y1);
        path2.lineTo(x, y2);
      }
    }

    canvas.drawPath(path2, wavePaint2);
    canvas.drawPath(glowPath, waveGlowPaint);
    canvas.drawPath(path1, wavePaint1);

    // 3. Небольшие технические текстовые маркеры по углам для атмосферы телеметрии
    const textStyle = TextStyle(
      color: kTextSecondary,
      fontSize: 10,
      fontFamily: 'monospace',
      fontWeight: FontWeight.w400,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Левый маркер статуса
    textPainter.text = const TextSpan(text: "СИС.ЛОГ: ІНВЕРТОР_MODBUS // АКТИВНИЙ", style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, const Offset(15, 15));

    // Правый маркер симуляции
    textPainter.text = TextSpan(
      text: "СИМ_ККД: ${(88.4 + math.sin(progress * math.pi) * 2.1).toStringAsFixed(1)}%", 
      style: textStyle.copyWith(color: kNeonGreen.withOpacity(0.7)),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width - 15, 15));
  }

  @override
  bool shouldRepaint(covariant _EnergyWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}