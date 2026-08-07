// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../logic/controllers/auth_controller.dart';
import '../../screen/pages/splash/splash_page.dart';
import '../../screen/pages/onboarding/onboarding_page.dart';
import '../../screen/pages/shell_page.dart';
import '../../screen/pages/home/home_page.dart';
import '../../screen/pages/detection/detection_page.dart';
import '../../screen/pages/detection/result_page.dart';
import '../../screen/pages/detection/detection_detail_page.dart';
import '../../screen/pages/history/history_page.dart';
import '../../screen/pages/profile/profile_page.dart';
import '../../screen/pages/auth/login_page.dart';
import '../../screen/pages/auth/register_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String shell = '/app';
  static const String home = '/app/home';
  static const String detection = '/app/detection';
  static const String result = '/app/result';
  static const String history = '/app/history';
  static const String profile = '/app/profile';

  /// Detail route uses a path parameter so a specific detection
  /// can be deep-linked / survives refresh, unlike `extra`.
  static const String detectionDetail = '/app/history/:id';

  /// Helper to build a concrete path for navigation.
  static String detectionDetailPath(int id) => '/app/history/$id';
}

GoRouter createRouter(BuildContext context) {
  final authController = Provider.of<AuthController>(context, listen: false);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    // No refreshListenable — splash handles auth routing manually
    // to avoid setState() during build errors
    redirect: (context, state) {
      final isLoggedIn = authController.isAuthenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.onboarding;

      if (isLoggedIn && isAuthRoute &&
          state.matchedLocation != AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.detection,
            builder: (context, state) => const DetectionPage(),
          ),
          GoRoute(
            path: AppRoutes.result,
            builder: (context, state) {
              // Result page right after a fresh scan — reads controller state.
              return const ResultPage();
            },
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: AppRoutes.detectionDetail,
            builder: (context, state) {
              final idParam = state.pathParameters['id'];
              final id = int.tryParse(idParam ?? '');
              return DetectionDetailPage(detectionId: id);
            },
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}