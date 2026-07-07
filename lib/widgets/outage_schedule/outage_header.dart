import 'package:flutter/material.dart';

import '../../models/outage/outage_forecast.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import '../../utils/outage/outage_formatter.dart';
import '../../utils/outage/outage_icons.dart';

class OutageHeader extends StatelessWidget {
  final OutageForecast forecast;

  const OutageHeader({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final compact = width < 420;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(
        OutageConstants.cardPadding,
      ),

      decoration: BoxDecoration(
        color: OutageColors.card,
        borderRadius: BorderRadius.circular(
          OutageConstants.cardRadius,
        ),
        border: Border.all(
          color: OutageColors.border,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: OutageColors.aiCardBackground,
                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: Icon(
                  OutageIcons.schedule,
                  color: OutageColors.accent,
                  size: compact ? 22 : 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Графік відключень',
                      style: TextStyle(
                        color:
                            OutageColors.textPrimary,
                        fontWeight:
                            FontWeight.bold,
                        fontSize:
                            compact ? 18 : 22,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Планові та прогнозовані відключення',
                      style: TextStyle(
                        color:
                            OutageColors.textSecondary,
                        fontSize:
                            compact ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.12),
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  forecast.source.name,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight:
                        FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                OutageConstants.sectionSpacing,
          ),

          Row(
            children: [

              Icon(
                Icons.update_rounded,
                color:
                    OutageColors.textSecondary,
                size: 16,
              ),

              const SizedBox(width: 6),

              Text(
                'Оновлено ${OutageFormatter.updated(forecast.updatedAt)}',
                style: const TextStyle(
                  color:
                      OutageColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}