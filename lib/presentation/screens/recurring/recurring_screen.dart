import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Recurring Screen',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 24),
        ),
      ),
    );
  }
}
