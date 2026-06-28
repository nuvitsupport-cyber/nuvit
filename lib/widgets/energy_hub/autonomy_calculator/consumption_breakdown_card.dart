// lib/widgets/energy_hub/autonomy_calculator/widgets/consumption_breakdown_card.dart

import 'package:flutter/material.dart';
import 'package:nuvit/utils/app_colors.dart';

class ConsumptionItem {
  final String name;
  final double energyKwh;
  final IconData icon;

  const ConsumptionItem({
    required this.name,
    required this.energyKwh,
    required this.icon,
  });
}

class ConsumptionBreakdownCard extends StatelessWidget {
  final List<ConsumptionItem> items;

  const ConsumptionBreakdownCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 700;

    final totalConsumption = items.fold<double>(
      0,
      (sum, item) => sum + item.energyKwh,
    );

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
          /// Header
          Row(
            children: [
              const Icon(
                Icons.pie_chart_rounded,
                color: AppColors.neon,
              ),

              const SizedBox(width: 10),

              Text(
                'Структура споживання',
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

          /// Total
          Container(
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.neon,
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Text(
                    'Загальне споживання',
                    style: TextStyle(
                      color:
                          AppColors.textMuted,
                    ),
                  ),
                ),

                Text(
                  '${totalConsumption.toStringAsFixed(1)} кВт·год',
                  style: const TextStyle(
                    color:
                        AppColors.textMain,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Devices
          ...items.map(
            (item) {
              final percent =
                  totalConsumption == 0
                      ? 0.0
                      : item.energyKwh /
                          totalConsumption;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                child: _buildRow(
                  item,
                  percent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    ConsumptionItem item,
    double percent,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.neon
                    .withOpacity(.12),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                item.icon,
                color: AppColors.neon,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color:
                          AppColors.textMain,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  Text(
                    '${item.energyKwh.toStringAsFixed(1)} кВт·год',
                    style: const TextStyle(
                      color:
                          AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '${(percent * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.neon,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor:
                Colors.white.withOpacity(
              .06,
            ),
            valueColor:
                const AlwaysStoppedAnimation(
              AppColors.neon,
            ),
          ),
        ),
      ],
    );
  }
}