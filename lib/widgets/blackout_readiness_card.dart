import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class BlackoutReadinessCard extends StatelessWidget {

  final int score;

  final String status;

  final Color color;

  const BlackoutReadinessCard({
    super.key,
    required this.score,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: AppColors.card,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: color.withValues(
            alpha: 0.4,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Icon(
                Icons.flash_on,
                color: color,
              ),

              const SizedBox(width: 8),

              Text(
                'BLACKOUT READINESS',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [

                Text(
                  '$score%',

                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  status,

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          LinearProgressIndicator(

            value: score / 100,

            minHeight: 8,

            backgroundColor:
                Colors.grey[800],

            color: color,
          ),

          const SizedBox(height: 20),

          Text(

            score >= 80

                ? 'Система готова до можливих відключень електроенергії.'

                : score >= 50

                    ? 'Рекомендується оптимізувати навантаження або зарядити АКБ.'

                    : 'Критично низька готовність. Рекомендується негайний заряд АКБ.',

            style: TextStyle(
              fontSize: 14,

              color: Colors.white.withValues(
                alpha: 0.9,
              ),

              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}