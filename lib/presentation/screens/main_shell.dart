import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/neumorphic.dart';
import '../../core/theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'accounts/accounts_screen.dart';
import 'history/history_screen.dart';
import 'reports/reports_screen.dart';
import 'add_expense/add_expense_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    ReportsScreen(),
    AccountsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: NeumorphicContainer(
            borderRadius: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, CupertinoIcons.home),
                _buildNavItem(1, CupertinoIcons.list_bullet),
                _buildAddButton(),
                _buildNavItem(2, CupertinoIcons.chart_pie),
                _buildNavItem(3, CupertinoIcons.person),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1D1E0).withOpacity(0.4) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return NeumorphicButton(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddExpenseScreen(),
        );
      },
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: rainbowColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(
            CupertinoIcons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
