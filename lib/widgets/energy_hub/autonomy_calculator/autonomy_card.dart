// lib/widgets/energy_hub/autonomy_calculator/autonomy_card.dart

import 'package:flutter/material.dart';
import 'package:nuvit/utils/app_colors.dart';
import '../autonomy_calculator/painters/autonomy_ring_painter.dart';

class AutonomyCard extends StatelessWidget {
  final Duration autonomy;
  final double batteryPercent;
  final String untilTime;
  final bool hasDevices;
  final bool isDischarged; // Флаг: батарея разряжена ниже лимита DoD
  final ValueChanged<double>? onBatteryPercentChanged;
  
  // 🆕 Добавляем callback для нажатия на кнопку информации
  final VoidCallback? onInfoPressed;

  const AutonomyCard({
    super.key,
    required this.autonomy,
    required this.batteryPercent,
    required this.untilTime,
    this.hasDevices = true,
    this.isDischarged = false,
    this.onBatteryPercentChanged,
    this.onInfoPressed, // 🆕 Регистрируем в конструкторе
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    final hours = autonomy.inHours;
    final minutes = autonomy.inMinutes.remainder(60);

    // Определяем главный цвет карточки в зависимости от состояния
    final Color stateColor = isDischarged 
        ? const Color(0xFFFF4554) // Красный неон, если разряжен
        : (hasDevices ? AppColors.neon : AppColors.textMuted.withValues(alpha: 0.4));

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0A153A), // brandCard
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: stateColor.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🆕 Заголовок + Адаптивная интерактивная кнопка информации
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Розрахунок автономності',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: isMobile ? 20 : 26, // Трохи зменшено для вузьких екранів
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2, // Дозволяємо перенесення на мобілках
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12), // Відступ між текстом і кнопкою
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onInfoPressed,
                  borderRadius: BorderRadius.circular(50),
                  // Розширюємо зону тапу для мобільних пристроїв
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: isMobile ? 24 : 26,
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 24 : 32),

          /// Основной блок (Кольцо + Время/Заглушка)
          isMobile
              ? Column(
                  children: [
                    _buildRing(isMobile, stateColor),
                    const SizedBox(height: 24),
                    Center(child: _buildCentralContent(hours, minutes, isMobile)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRing(isMobile, stateColor),
                    const SizedBox(width: 40),
                    Flexible(child: _buildCentralContent(hours, minutes, isMobile)),
                  ],
                ),

          const SizedBox(height: 32),

          /// 🎛️ Интерактивный ползунок
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10,
              activeTrackColor: stateColor,
              inactiveTrackColor: const Color(0xFF051033),
              disabledActiveTrackColor: AppColors.textMuted.withValues(alpha: 0.2),
              thumbColor: stateColor,
              overlayColor: stateColor.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 9.0,
                disabledThumbRadius: 9.0,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
              trackShape: const RectangularSliderTrackShape(),
            ),
            child: Slider(
              value: batteryPercent.clamp(0.0, 100.0),
              min: 0.0,
              max: 100.0,
              onChanged: onBatteryPercentChanged,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                '0%',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Поточний заряд: ${batteryPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '100%',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Выбор контента для отображения по центру карточки
  Widget _buildCentralContent(int hours, int minutes, bool isMobile) {
    if (isDischarged) {
      return _buildDischargedStateText(isMobile);
    } else if (!hasDevices) {
      return _buildEmptyStateText(isMobile);
    } else {
      return _buildTimeInfo(hours, minutes);
    }
  }

  Widget _buildRing(bool isMobile, Color ringColor) {
    final size = isMobile ? 120.0 : 160.0;
    IconData ringIcon = Icons.battery_charging_full_rounded;
    
    if (isDischarged) {
      ringIcon = Icons.battery_alert_rounded;
    } else if (!hasDevices) {
      ringIcon = Icons.battery_unknown_rounded;
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: AutonomyRingPainter(
          // Если разряжен, кольцо пустое (0.0)
          progress: isDischarged ? 0.0 : (batteryPercent / 100),
        ),
        child: Center(
          child: Icon(
            ringIcon,
            color: ringColor,
            size: isMobile ? 36 : 48,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(int hours, int minutes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 260;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$hours',
                    style: TextStyle(
                      color: AppColors.neon,
                      fontSize: compact ? 42 : 56, // Адаптация крупного текста
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' год ',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '$minutes',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: compact ? 30 : 40, // Адаптация крупного текста
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' хв',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Орієнтовний час до $untilTime',
              style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyStateText(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'В пресеті не виявлено пристроїв',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Увімкніть пристрої для розрахунку часу',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDischargedStateText(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Систему розряджено',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Color(0xFFFF4554), // Яркий неоново-красный аларм
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Досягнуто ліміт безпечного розряду (DoD). Резерв енергії вичерпано.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}