// lib/layouts/desktop_layout.dart
import 'package:flutter/material.dart';

class DesktopLayout extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const DesktopLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _SidebarItem {
  final IconData icon;
  final String title;
  _SidebarItem({required this.icon, required this.title});
}

class _DesktopLayoutState extends State<DesktopLayout> {
  final Color neonColor = const Color(0xFF39FF14);

  final List<_SidebarItem> items = [
    _SidebarItem(icon: Icons.home_outlined, title: 'Home'),
    _SidebarItem(icon: Icons.bolt_outlined, title: 'Енергохаб'),
    _SidebarItem(icon: Icons.account_tree_outlined, title: 'Налаштування інфраструктури'),
    _SidebarItem(icon: Icons.assignment_outlined, title: 'Reports'),
    _SidebarItem(icon: Icons.settings_outlined, title: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    const Color customBackgroundColor = Color(0xFF020D2D);

    return Scaffold(
      backgroundColor: customBackgroundColor,
      body: Row(
        children: [
          // ================= SIDEBAR =================
          Container(
            width: 260,
            color: customBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // ================= LOGO =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            widget.onIndexChanged(0); // Возврат на Home
                          },
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.8,
                                shadows: [
                                  Shadow(
                                    blurRadius: 15.0,
                                    color: neonColor.withValues(alpha: 0.7),
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              children: [
                                TextSpan(text: 'N', style: TextStyle(color: neonColor)),
                                const TextSpan(text: 'U', style: TextStyle(color: Colors.white)),
                                TextSpan(text: 'V', style: TextStyle(color: neonColor)),
                                const TextSpan(text: 'IT', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // ================= NAVIGATION =================
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = widget.selectedIndex == index;

                      return InkWell(
                        onTap: () {
                          widget.onIndexChanged(index); // Передаем индекс наверх в HomePage
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? neonColor.withValues(alpha: 0.05)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 24),
                              Icon(
                                item.icon,
                                color: isSelected ? neonColor : Colors.white60,
                                size: 24,
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected ? neonColor : Colors.white70,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 3,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: neonColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: neonColor.withValues(alpha: 0.8),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const SizedBox(width: 3),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ================= SYSTEM STATUS =================
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF09111C).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'System Status',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.shield,
                                color: neonColor.withValues(alpha: 0.15),
                                size: 38,
                              ),
                              Icon(
                                Icons.check,
                                color: neonColor,
                                size: 22,
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All systems normal',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Last update: 10:30 AM',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Вертикальный разделитель
          Container(
            width: 1,
            color: Colors.white.withValues(alpha: 0.05),
          ),

          // ================= MAIN CONTENT =================
          Expanded(
            child: Container(
              color: customBackgroundColor,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}