// lib/layouts/mobile_layout.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MobileLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const MobileLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color customBackgroundColor = Color(0xFF020D2D);

    return Scaffold(
      backgroundColor: customBackgroundColor,
      // Верхняя панель (AppBar) из концепта
      appBar: AppBar(
        backgroundColor: customBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 26),
          onPressed: () {}, // Бургер-меню
        ),
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  blurRadius: 12.0,
                  color: AppColors.neon.withValues(alpha: 0.6),
                ),
              ],
            ),
            children: [
              TextSpan(text: 'N', style: TextStyle(color: AppColors.neon)),
              const TextSpan(text: 'U', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'V', style: TextStyle(color: AppColors.neon)),
              const TextSpan(text: 'IT', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                onPressed: () {},
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.neon,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neon.withValues(alpha: 0.8),
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(child: child),
      // Нижнее меню навигации (4 вкладки из концепта)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.04), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: customBackgroundColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          onTap: onIndexChanged,
          selectedItemColor: AppColors.neon,
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.history_toggle_off),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.history),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.developer_board),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.developer_board),
              ),
              label: 'Devices',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.settings),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}