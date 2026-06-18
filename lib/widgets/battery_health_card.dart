import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class BatteryHealthCard extends StatelessWidget {

  final String batteryType;

  final double health;

  final double currentCycles;

  final int maxCycles;

  final int dailyDoD;

  final double expectedYears;

  final VoidCallback onAddCycle;

  final VoidCallback onResetCycles;

  const BatteryHealthCard({
    super.key,
    required this.batteryType,
    required this.health,
    required this.currentCycles,
    required this.maxCycles,
    required this.dailyDoD,
    required this.expectedYears,
    required this.onAddCycle,
    required this.onResetCycles,
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
          color: Colors.blueAccent.withValues(
            alpha: 0.3,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              const Row(
                children: [

                  Icon(
                    Icons.battery_charging_full,
                    color: AppColors.neon,
                  ),

                  SizedBox(width: 8),

                  Text(
                    '🔋 BATTERY HEALTH',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              Text(
                'SOH: ${health.toStringAsFixed(1)}%',

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neon,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          LinearProgressIndicator(
            value: health / 100,

            backgroundColor: Colors.grey[800],

            color:
                health > 80
                    ? AppColors.neon
                    : (health > 50
                        ? Colors.orange
                        : Colors.red),

            minHeight: 6,
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    'Тип АКБ: $batteryType',

                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Циклів: ${currentCycles.toStringAsFixed(1)} / $maxCycles',

                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,

                children: [

                  Text(
                    'Середній розряд: $dailyDoD%',

                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(
                        alpha: 0.9,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Ресурс: ~${expectedYears.toStringAsFixed(1)} років',

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Divider(
            color: Colors.white10,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,

            children: [

              TextButton(
                onPressed: onResetCycles,

                child: const Text(
                  'Скинути',

                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: onAddCycle,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.neon.withValues(
                        alpha: 0.2,
                      ),

                  foregroundColor:
                      AppColors.neon,

                  elevation: 0,
                ),

                child: const Text(
                  '+ Симулювати день',

                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}