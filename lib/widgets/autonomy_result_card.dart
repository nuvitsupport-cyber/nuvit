import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class AutonomyResultCard extends StatelessWidget {

  final String statusText;

  final int activeLoad;

  final bool isEmptyBattery;

  final bool isStandby;

  const AutonomyResultCard({
    super.key,
    required this.statusText,
    required this.activeLoad,
    required this.isEmptyBattery,
    required this.isStandby,
  });

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(

        width: double.infinity,

        padding: const EdgeInsets.all(25),

        decoration: BoxDecoration(
          color: AppColors.card,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: AppColors.neon.withValues(
              alpha: 0.3,
            ),
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            const Text(
              'ЧАС АВТОНОМНОЇ РОБОТИ',

              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              statusText,

              style: TextStyle(
                fontSize:
                    (isStandby || isEmptyBattery)
                        ? 32
                        : 40,

                fontWeight: FontWeight.w900,

                color: AppColors.neon,

                shadows: const [
                  Shadow(
                    blurRadius: 20.0,
                    color: AppColors.neon,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(
              '$activeLoad W активного навантаження',

              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(

              isEmptyBattery

                  ? 'Будь ласка, вкажіть коректну ємність акумулятора.'

                  : isStandby

                      ? 'Енергія не витрачається. Система в режимі очікування.'

                      : 'ESS аналітика (ККД інвертора 90%, деградація АКБ врахована)',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}