import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ProfileDropdown extends StatelessWidget {

  final List<String> profiles;

  final String selectedProfile;

  final ValueChanged<String?> onChanged;

  const ProfileDropdown({
    super.key,
    required this.profiles,
    required this.selectedProfile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          'Оберіть сценарій використання:',

          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        Container(

          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
          ),

          decoration: BoxDecoration(

            border: Border.all(
              color: Colors.grey[700]!,
            ),

            borderRadius:
                BorderRadius.circular(8),
          ),

          child: DropdownButtonHideUnderline(

            child: DropdownButton<String>(

              value: selectedProfile,

              isExpanded: true,

              dropdownColor: AppColors.bg,

              items: profiles.map(
                (String profile) {

                  return DropdownMenuItem(

                    value: profile,

                    child: Text(

                      'Сценарій: $profile',

                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  );
                },
              ).toList(),

              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}