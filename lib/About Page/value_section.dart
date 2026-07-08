import 'package:flutter/material.dart';

/// ===============================================================
/// NUVIT - Value Section (Постійна інженерна підсвітка без Hover)
/// ===============================================================

const Color kAppBackground = Color(0xFF020D2D);
const Color kCardBackground = Color(0xFF081438);
const Color kInnerBackground = Color(0xFF051033);

const Color kNeonGreen = Color(0xFF39FF14);
const Color kWarningRed = Color(0xFFFF4D4D);

const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFF8E99B0);

class ValueSection extends StatelessWidget {
  const ValueSection({super.key});

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
        top: desktop ? 60 : 40,
        bottom: desktop ? 110 : 70,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1450),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Хедер секції
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: kNeonGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  "ПОРІВНЯННЯ ТА ЦІННІСТЬ",
                  style: TextStyle(
                    color: kNeonGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Як Nuvit трансформує\nуправління енергією?",
              style: TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w800,
                height: 1.15,
                fontSize: width > 900 ? 42.0 : 32.0,
              ),
            ),
            const SizedBox(height: 50),

            // Двоколонкова сітка
            _ProblemSolutionLayout(desktop: desktop),
          ],
        ),
      ),
    );
  }
}

class _ProblemSolutionLayout extends StatelessWidget {
  final bool desktop;

  const _ProblemSolutionLayout({required this.desktop});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _ValueData(
        painIcon: Icons.battery_alert_outlined,
        painText: "Розрахунок заряду «на око», раптова втрата живлення об'єкта та постійна тривога через невідомість.",
        solutionIcon: Icons.battery_charging_full_outlined,
        solutionTitle: "Автоматичний калькулятор автономності",
        solutionDescription: "Алгоритм миттєво вираховує точний час роботи батареї у годинах та хвилинах, динамічно адаптуючись під поточні навантаження будинку.",
      ),
      const _ValueData(
        painIcon: Icons.cloud_off_outlined,
        painText: "Стандартні сонячні прогнози не враховують локальну хмарність, динамічну зміну погоди та реальну інсоляцію.",
        solutionIcon: Icons.wb_sunny_outlined,
        solutionTitle: "Прогнозування через OpenWeather",
        solutionDescription: "Система аналізує хмарність, географічну широту та астрономічні сонячні години для побудови безпомилкових графіків генерації.",
      ),
      const _ValueData(
        painIcon: Icons.widgets_outlined,
        painText: "Хаос у додатках: окремий софт для інвертора, окремий для акумулятора та для розумної EV-зарядки.",
        solutionIcon: Icons.tungsten_outlined,
        solutionTitle: "Єдина безшовна екосистема",
        solutionDescription: "Об'єднує Deye, Victron, Huawei, Growatt та інші бренди в один інженерний каталог без маркетингового шуму та реклами.",
      ),
      const _ValueData(
        painIcon: Icons.gpp_bad_outlined,
        painText: "Ризик критичних помилок у конфігураціях, випадкове дублювання пристроїв у базі та неоптимальний розподіл ватів.",
        solutionIcon: Icons.verified_user_outlined,
        solutionTitle: "Захищений Smart PV Config",
        solutionDescription: "Інтелектуальне блокування логічних помилок. Можливість ручного введення потужності кожної панелі для ювелірного налаштування.",
      ),
    ];

    if (desktop) {
      return Column(
        children: [
          // Заголовки колонок для десктопа
          const Padding(
            padding: EdgeInsets.only(bottom: 24, left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "КРИТИЧНА БІЛЬ СИСТЕМИ",
                    style: TextStyle(
                      color: kWarningRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(width: 32),
                Expanded(
                  child: Text(
                    "ІНЖЕНЕРНЕ РІШЕННЯ NUVIT",
                    style: TextStyle(
                      color: kNeonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Рядки "Проблема -> Рішення"
          for (var item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _SplitCard(data: item, isSolution: false)),
                    const SizedBox(width: 32),
                    Expanded(child: _SplitCard(data: item, isSolution: true)),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // Мобільний / Планшетний вигляд
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              _SplitCard(data: item, isSolution: false),
              const SizedBox(height: 12),
              const Icon(Icons.arrow_downward_rounded, color: kNeonGreen, size: 20),
              const SizedBox(height: 12),
              _SplitCard(data: item, isSolution: true),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ValueData {
  final IconData painIcon;
  final String painText;
  final IconData solutionIcon;
  final String solutionTitle;
  final String solutionDescription;

  const _ValueData({
    required this.painIcon,
    required this.painText,
    required this.solutionIcon,
    required this.solutionTitle,
    required this.solutionDescription,
  });
}

// Теперь это чистый, производительный StatelessWidget
class _SplitCard extends StatelessWidget {
  final _ValueData data;
  final bool isSolution;

  const _SplitCard({
    required this.data,
    required this.isSolution,
  });

  @override
  Widget build(BuildContext context) {
    // Определяем цвета на основе назначения колонки (Проблема или Решение)
    final Color accentColor = isSolution ? kNeonGreen : kWarningRed;
    final String tagText = isSolution ? "// NUVIT_SOLVED" : "// SYS_ERROR";
    
    // Мягкий фоновый цвет подложки (Решение делаем чуть глубже/футуристичнее)
    final Color currentBackground = isSolution ? kInnerBackground : kCardBackground;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: currentBackground,
        borderRadius: BorderRadius.circular(20),
        // Постоянная неоновая граница соответствующего цвета
        border: Border.all(
          color: accentColor.withOpacity(isSolution ? 0.35 : 0.15),
          width: isSolution ? 1.2 : 1.0,
        ),
        // Перманентное неоновое свечение (Glow Effect)
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isSolution ? 0.05 : 0.02),
            blurRadius: isSolution ? 20 : 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Сервісний заголовок картки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withOpacity(0.25),
                  ),
                ),
                child: Icon(
                  isSolution ? data.solutionIcon : data.painIcon,
                  color: accentColor,
                  size: 22,
                ),
              ),
              Text(
                tagText,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: accentColor.withOpacity(0.5),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Контентна частина
          if (!isSolution) ...[
            const Text(
              "Спостереження проблеми:",
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                data.painText,
                style: TextStyle(
                  color: kTextPrimary.withOpacity(0.85),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ] else ...[
            Text(
              data.solutionTitle,
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                data.solutionDescription,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}