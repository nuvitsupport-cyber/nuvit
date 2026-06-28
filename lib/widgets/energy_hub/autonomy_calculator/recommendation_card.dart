// lib/widgets/energy_hub/autonomy_calculator/widgets/recommendation_card.dart

import 'package:flutter/material.dart';
import 'package:nuvit/utils/app_colors.dart';
import 'package:nuvit/utils/models/autonomy_result.dart';



class RecommendationItem {
  final String title;
  final String description;
  final RecommendationType type;

  const RecommendationItem({
    required this.title,
    required this.description,
    required this.type,
  });
}

class RecommendationCard extends StatelessWidget {
  final List<RecommendationItem> recommendations;

  const RecommendationCard({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 700;

    return Container(
      padding: EdgeInsets.all(
        isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neon.withOpacity(.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neon.withOpacity(.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.neon,
              ),

              const SizedBox(width: 10),

              Text(
                'Рекомендації NUVIT AI',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize:
                      isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (recommendations.isEmpty)
            Container(
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.optimal,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Система працює оптимально. Додаткових рекомендацій немає.',
                      style: TextStyle(
                        color:
                            AppColors.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ...recommendations.map(
            (recommendation) =>
                Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 14,
              ),
              child: _buildRecommendation(
                recommendation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(
    RecommendationItem item,
  ) {
    final config =
        _getRecommendationConfig(
      item.type,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.color.withOpacity(
          .08,
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: config.color.withOpacity(
            .25,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: config.color
                  .withOpacity(.15),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              config.icon,
              color: config.color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color:
                        AppColors.textMain,
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  item.description,
                  style: const TextStyle(
                    color:
                        AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _RecommendationConfig
      _getRecommendationConfig(
    RecommendationType type,
  ) {
    switch (type) {
      case RecommendationType.savings:
        return const _RecommendationConfig(
          icon:
              Icons.energy_savings_leaf,
          color: AppColors.neon,
        );

      case RecommendationType.warning:
        return const _RecommendationConfig(
          icon:
              Icons.warning_amber_rounded,
          color: AppColors.warning,
        );

      case RecommendationType.solar:
        return const _RecommendationConfig(
          icon:
              Icons.solar_power_rounded,
          color: AppColors.optimal,
        );

      case RecommendationType.battery:
        return const _RecommendationConfig(
          icon:
              Icons.battery_alert_rounded,
          color: AppColors.critical,
        );

      case RecommendationType.schedule:
        return const _RecommendationConfig(
          icon:
              Icons.schedule_rounded,
          color: Colors.lightBlue,
        );
    }
  }
}

class _RecommendationConfig {
  final IconData icon;
  final Color color;

  const _RecommendationConfig({
    required this.icon,
    required this.color,
  });
}