import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const ProviderScope(child: TrackerApp()));
}

class TrackerApp extends ConsumerWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isOnboarded = ref.watch(isOnboardedProvider);

    return MaterialApp(
      title: 'SafeSpend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: isOnboarded ? const MainShell() : const OnboardingScreen(),
    );
  }
}
