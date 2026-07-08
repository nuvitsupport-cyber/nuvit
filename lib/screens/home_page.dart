
// lib/screens/home_page.dart

import 'package:flutter/material.dart';

// Імпорти, які відповідають за систему (лейаути, кольори, сторінки)
import '../layouts/desktop_layout.dart';
import '../layouts/mobile_layout.dart';
import '../utils/app_colors.dart';

// Імпорти інших сторінок для навігації
import 'devices_page.dart';
import 'energy_hub_page.dart';
import '../About Page/hero_section.dart';
import '../About Page/mission_section.dart';
import '../About Page/value_section.dart';
// Тимчасові заглушки для інших вкладок
class HistoryPage extends StatelessWidget { 
  const HistoryPage({super.key}); 
  @override 
  Widget build(BuildContext context) => const Center(child: Text('Історія подій та відключень', style: TextStyle(color: Colors.white, fontSize: 20))); 
}

class ReportsPage extends StatelessWidget { 
  const ReportsPage({super.key}); 
  @override 
  Widget build(BuildContext context) => const Center(child: Text('Аналітика та Звіти генерації СЕС', style: TextStyle(color: Colors.white, fontSize: 20))); 
}

class SettingsPage extends StatelessWidget { 
  const SettingsPage({super.key}); 
  @override 
  Widget build(BuildContext context) => const Center(child: Text('Налаштування профілю користувача', style: TextStyle(color: Colors.white, fontSize: 20))); 
}

// =========================================================================
// ГОЛОВНА СТОРІНКА (СИСТЕМА НАВІГАЦІЇ ТА АДАПТИВНОСТІ)
// =========================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Змінна для контролю вкладок сайдбара

  // Метод, який перемикає тіла екранів залежно від обраного пункту меню
  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return MainDashboardContent(
          onDevicesPageRequested: () {
            setState(() {
              _selectedIndex = 2; // Перемикаємось на вкладку інфраструктури всередині сайдбара
            });
          },
        );
      case 1:
        return const EnergyHubPage();
      case 2:
        return const InfrastructureHistoryPreviewPage(); // Сторінка інфраструктури
      case 3:
        return const ReportsPage();
      case 4:
        return const SettingsPage();
      default:
        return MainDashboardContent(
          onDevicesPageRequested: () => setState(() => _selectedIndex = 2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Якщо ширина екрану менша за 900, використовуємо мобільну оболонку
          if (constraints.maxWidth < 900) {
            return MobileLayout(
              selectedIndex: _selectedIndex,
              onIndexChanged: (int newIndex) {
                setState(() {
                  _selectedIndex = newIndex;
                });
              },
              child: _getSelectedPage(_selectedIndex),
            );
          }

          // Для великих екранів залишаємо DesktopLayout
          return DesktopLayout(
            selectedIndex: _selectedIndex,
            onIndexChanged: (int newIndex) async {
              setState(() {
                _selectedIndex = newIndex;
              });
            },
            child: _getSelectedPage(_selectedIndex),
          );
        },
      ),
    );
  }
}

// =========================================================================
// КАРКАС ДЛЯ ГОЛОВНОЇ ПАНЕЛІ МОНІТОРИНГУ 
// =========================================================================
class MainDashboardContent extends StatefulWidget {
  final VoidCallback onDevicesPageRequested;

  const MainDashboardContent({
    super.key,
    required this.onDevicesPageRequested,
  });

  @override
  State<MainDashboardContent> createState() => _MainDashboardContentState();
}

class _MainDashboardContentState extends State<MainDashboardContent> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent, // Дозволяє DesktopLayout керувати фоном
      
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            AboutHeroSection(),
            MissionSection(),
            ValueSection(),
          ],
        ),
      ),
    );
  }
}