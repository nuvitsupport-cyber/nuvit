import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GenerationBreakdownCard extends StatelessWidget {
  final double solarKwh;
  final double windKwh;
  final double hydroKwh;

  const GenerationBreakdownCard({
    super.key,
    required this.solarKwh,
    required this.windKwh,
    required this.hydroKwh,
  });

  @override
  Widget build(BuildContext context) {
    // Рассчитываем сумму всех доступных источников
    final double totalKwh = solarKwh + windKwh + hydroKwh;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // Оптимизированный отступ для мобильных экранов
      decoration: BoxDecoration(
        color: const Color(0xFF051033),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neon.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ПРОГНОЗ ГЕНЕРАЦІЇ',
            style: TextStyle(
              fontSize: 14, // Чуть компактнее для лучшего скейлинга
              fontWeight: FontWeight.bold,
              color: AppColors.neon,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Если генерация полностью на нуле
          if (totalKwh == 0) ...[
            _buildSourceRow(
              icon: Icons.power_off_rounded,
              iconColor: Colors.white38,
              label: 'Поточна генерація відсутня',
              value: 0.0,
            ),
            const SizedBox(height: 12),
          ] else ...[
            // Отображаем строку только если в системе есть панели и они генерируют
            if (solarKwh > 0) ...[
              _buildSourceRow(
                icon: Icons.wb_sunny_rounded,
                iconColor: Colors.amber,
                label: 'Сонячна генерація',
                value: solarKwh,
              ),
              const SizedBox(height: 12),
            ],
            
            // Отображаем ветрогенерацию, если она больше нуля
            if (windKwh > 0) ...[
              _buildSourceRow(
                icon: Icons.air_rounded,
                iconColor: Colors.lightBlueAccent,
                label: 'Вітрова генерація',
                value: windKwh,
              ),
              const SizedBox(height: 12),
            ],
            
            // Отображаем микроГЭС, если она больше нуля
            if (hydroKwh > 0) ...[
              _buildSourceRow(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blue,
                label: 'МікроГЕС',
                value: hydroKwh,
              ),
              const SizedBox(height: 12),
            ],
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(
              color: Colors.white10,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          
          // Блок общей итоговой генерации
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Загальна прогнозована',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${totalKwh.toStringAsFixed(1)} кВт·год',
                style: const TextStyle(
                  fontSize: 18, // Защита от переполнения числового значения
                  fontWeight: FontWeight.bold,
                  color: AppColors.neon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toStringAsFixed(1)} кВт·год',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}