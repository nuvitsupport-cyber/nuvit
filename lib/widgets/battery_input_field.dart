import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';

class BatteryInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onEditingComplete; // Добавили параметр для оптимизации виджета

  const BatteryInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onEditingComplete, // Сделали его необязательным (nullable)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Номінальна ємність вашого АКБ (Wh):',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete, // Пробросили коллбек во внутренний TextField
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.neon,
                width: 2,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            hintText: 'Наприклад: 1000',
            suffixText: 'Wh',
          ),
        ),
      ],
    );
  }
}