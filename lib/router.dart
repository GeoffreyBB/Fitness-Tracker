import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/runs/log_run_screen.dart';
import 'screens/workouts/log_workout_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/recommendations/recommendations_screen.dart';

GoRouter buildRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final username = ref.read(usernameProvider);
      final onLogin = state.matchedLocation == '/login';
      if (username.isEmpty && !onLogin) return '/login';
      if (username.isNotEmpty && onLogin) return '/';
      return null;
    },
    refreshListenable: _UsernameNotifier(ref),
    routes: [
      ShellRoute(
        builder: (context, state, child) => _ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen()),
          GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen()),
          GoRoute(
              path: '/recommendations',
              builder: (context, state) => const RecommendationsScreen()),
        ],
      ),
      GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/log-run',
          builder: (context, state) => const LogRunScreen()),
      GoRoute(
          path: '/log-workout',
          builder: (context, state) => const LogWorkoutScreen()),
    ],
  );
}

class _ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const _ScaffoldWithNav({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      '/' => 0,
      '/progress' => 1,
      '/recommendations' => 2,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/');
            case 1:
              context.go('/progress');
            case 2:
              context.go('/recommendations');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Progress'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome), label: 'AI Coach'),
        ],
      ),
    );
  }
}

class _UsernameNotifier extends ChangeNotifier {
  final WidgetRef _ref;

  _UsernameNotifier(this._ref) {
    _ref.listenManual(usernameProvider, (prev, next) => notifyListeners());
  }
}
