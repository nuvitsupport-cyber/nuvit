import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class WeatherInsightsCard extends StatelessWidget {

  final bool isLoading;

  final String adviceText;

  const WeatherInsightsCard({
    super.key,
    required this.isLoading,
    required this.adviceText,
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
          color: AppColors.neon.withValues(
            alpha: 0.3,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(

            'AI WEATHER INSIGHTS',

            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.neon,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 15),

          isLoading

              ? const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 10,
                    ),

                    child:
                        CircularProgressIndicator(
                      color: AppColors.neon,
                    ),
                  ),
                )

              : Text(

                  adviceText,

                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
        ],
      ),
    );
  }
}