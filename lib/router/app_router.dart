import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/guest_landing_screen.dart';
import '../screens/parent_login_screen.dart';
import '../screens/child_profile_screen.dart';
import '../screens/mission_screen.dart';
import '../screens/result_screen.dart';
import '../screens/progress_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'guest_landing',
        builder: (context, state) => const GuestLandingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const ParentLoginScreen(),
      ),
      GoRoute(
        path: '/children',
        name: 'children',
        builder: (context, state) => const ChildProfileScreen(),
      ),
      GoRoute(
        path: '/mission',
        name: 'mission',
        builder: (context, state) => const MissionScreen(),
      ),
      GoRoute(
        path: '/result',
        name: 'result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          
          if (extra == null) {
            return const Scaffold(
              body: Center(
                child: Text('Invalid result data'),
              ),
            );
          }
          
          return ResultScreen(
            userAnswer: extra['userAnswer'] as bool,
            timeSpent: extra['timeSpent'] as Duration,
          );
        },
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Page Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Page not found 😅',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}