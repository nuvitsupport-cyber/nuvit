import 'package:flutter/material.dart';

import '../../models/outage/outage_forecast.dart';
import '../../utils/outage/outage_colors.dart';
import '../../utils/outage/outage_constants.dart';
import 'outage_ai_card.dart';
import 'outage_empty_state.dart';
import 'outage_header.dart';
import 'outage_loading.dart';
import 'outage_next_card.dart';
import 'outage_probability_ring.dart';
import 'outage_stats_grid.dart';
import 'outage_timeline.dart';

class OutageScheduleWidget extends StatelessWidget {
  final OutageForecast? forecast;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const OutageScheduleWidget({
    super.key,
    required this.forecast,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Обработка состояния загрузки данных
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(OutageConstants.screenPadding),
          child: OutageLoading(),
        ),
      );
    }

    // 2. Обработка состояния отсутствия данных
    if (forecast == null || !forecast!.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(OutageConstants.screenPadding),
          child: OutageEmptyState(onRefresh: onRefresh),
        ),
      );
    }

    final data = forecast!;

    // Использование LayoutBuilder для адаптивного построения интерфейса
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        if (isMobile) {
          return _buildMobileLayout(data);
        } else {
          return _buildWideLayout(data, constraints.maxWidth);
        }
      },
    );
  }

  /// Вертикальный слой (Вёрстка для мобильных экранов и узких колонок < 850px)
  Widget _buildMobileLayout(OutageForecast data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(OutageConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutageHeader(forecast: data),
          const SizedBox(height: OutageConstants.sectionSpacing),
          
          OutageTimeline(periods: data.periods),
          const SizedBox(height: OutageConstants.sectionSpacing),
          
          // Для мобильного вида объединяем кольцо вероятности и карточку следующего события в один ряд,
          // если позволяет место, либо выстраиваем аккуратной колонкой
          LayoutBuilder(
            builder: (context, innerConstraints) {
              if (innerConstraints.maxWidth > 480) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutageProbabilityRing(probability: data.probability),
                    const SizedBox(width: OutageConstants.itemSpacing),
                    Expanded(child: OutageNextCard(event: data.nextEvent)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Center(child: OutageProbabilityRing(probability: data.probability)),
                    const SizedBox(height: OutageConstants.itemSpacing),
                    OutageNextCard(event: data.nextEvent),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: OutageConstants.sectionSpacing),
          
          OutageStatsGrid(forecast: data),
          
          if (data.hasInsights) ...[
            const SizedBox(height: OutageConstants.sectionSpacing),
            OutageAiCard(insights: data.insights),
          ],
        ],
      ),
    );
  }

  /// Двухколоночный слой (Вёрстка для десктопных интерфейсов и широких панелей >= 850px)
  Widget _buildWideLayout(OutageForecast data, double maxWidth) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(OutageConstants.screenPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Левая колонка: Основная информация (Шапка, График, AI аналитика)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutageHeader(forecast: data),
                const SizedBox(height: OutageConstants.sectionSpacing),
                
                OutageTimeline(periods: data.periods),
                
                if (data.hasInsights) ...[
                  const SizedBox(height: OutageConstants.sectionSpacing),
                  OutageAiCard(insights: data.insights),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: OutageConstants.sectionSpacing),
          
          // Правая колонка: Оперативные метрики и аналитика (Кольцо риска, Статистика, Следующее событие)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Карточка с кольцом вероятности и информером следующего события
                Container(
                  padding: const EdgeInsets.all(OutageConstants.cardPadding),
                  decoration: BoxDecoration(
                    color: OutageColors.card,
                    borderRadius: BorderRadius.circular(OutageConstants.cardRadius),
                    border: Border.all(
                      color: OutageColors.border,
                      width: OutageConstants.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      OutageProbabilityRing(probability: data.probability),
                      const SizedBox(width: OutageConstants.itemSpacing),
                      Expanded(
                        child: OutageNextCard(event: data.nextEvent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: OutageConstants.sectionSpacing),
                
                // Сетка со статистическими показателями за сутки
                OutageStatsGrid(forecast: data),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}