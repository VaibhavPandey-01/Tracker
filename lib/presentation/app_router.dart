import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/fund_state_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/setup_screen.dart';
import 'screens/expense/add_expense_screen.dart';
import 'screens/expense/edit_expense_screen.dart';
import 'screens/fund/edit_fund_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/summary/summary_screen.dart';
import '../domain/models/ledger_entry.dart';

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------
abstract class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const setup = '/setup';
  static const home = '/';
  static const addExpense = '/add-expense';
  static const editExpense = '/edit-expense';
  static const editFund = '/edit-fund';
  static const history = '/history';
  static const summary = '/summary';
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) async {
      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isOnSetup = state.matchedLocation == AppRoutes.setup;

      if (!isLoggedIn) {
        return isOnAuthPage ? null : AppRoutes.login;
      }

      if (isOnAuthPage) {
        // Check if user has completed setup
        final fundState = await ref.read(fundStateRepositoryProvider).getFundState();
        if (fundState == null) return AppRoutes.setup;
        return AppRoutes.home;
      }

      if (isOnSetup) return null;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fadeTransition(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.setup,
        pageBuilder: (context, state) => _fadeTransition(
          state,
          const SetupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _fadeTransition(
          state,
          const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.addExpense,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const AddExpenseScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editExpense,
        pageBuilder: (context, state) {
          final entry = state.extra as LedgerEntry;
          return _slideTransition(state, EditExpenseScreen(entry: entry));
        },
      ),
      GoRoute(
        path: AppRoutes.editFund,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const EditFundScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.summary,
        pageBuilder: (context, state) => _slideTransition(
          state,
          const SummaryScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

// ---------------------------------------------------------------------------
// Page transitions
// ---------------------------------------------------------------------------
CustomTransitionPage<void> _fadeTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

CustomTransitionPage<void> _slideTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0.0, 0.08),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// ---------------------------------------------------------------------------
// Auth state listenable for GoRouter refresh
// ---------------------------------------------------------------------------
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    _sub = ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
