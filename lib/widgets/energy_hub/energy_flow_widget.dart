import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class EnergyFlowWidget extends StatelessWidget {
  const EnergyFlowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Верхній ряд: Solar + Grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEnergyCard(
              icon: Icons.wb_sunny,
              title: 'Solar Production',
              value: '4.2 kW',
              color: AppColors.warning,
            ),
            _buildEnergyCard(
              icon: Icons.electric_bolt,
              title: 'Grid',
              value: '1.3 kW',
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Центральний блок: Home
        _buildEnergyCard(
          icon: Icons.home,
          title: 'Home Consumption',
          value: '2.1 kW',
          color: AppColors.textMain,
        ),

        const SizedBox(height: 24),

        // Баланс енергії
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '+2.1 kWh Surplus',
                  style: const TextStyle(
                    color: AppColors.neon,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: Placeholder(
                    color: AppColors.neonDim,
                    strokeWidth: 2,
                  ), // тут буде графік балансу (00:00–24:00)
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
