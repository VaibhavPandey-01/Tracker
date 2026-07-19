import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/neumorphic.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/history_screen.dart';
import 'reports/reports_screen.dart';
import 'add_expense/add_expense_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  final _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const ReportsScreen(),
    const AddExpenseScreen(isTab: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          
          // ── Bottom Nav Pill ───────────────────────────────────────────────
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: NeumorphicContainer(
              borderRadius: 35,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavBarItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _NavBarItem(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long_rounded,
                    isSelected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _NavBarItem(
                    icon: Icons.bar_chart_outlined,
                    selectedIcon: Icons.bar_chart_rounded,
                    isSelected: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _NavBarItem(
                    icon: Icons.add_rounded,
                    selectedIcon: Icons.add_rounded,
                    isSelected: _selectedIndex == 3,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      width: 48,
      height: 48,
      borderRadius: 24,
      isInset: isSelected, // Carved-in if active, raised if inactive
      onTap: onTap,
      child: Center(
        child: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? const Color(0xFFF5F5F7) : const Color(0xFFB8B8C0),
          size: 20,
        ),
      ),
    );
  }
}
