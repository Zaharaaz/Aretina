import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/constants/constants.dart';
import 'package:aretina/logic/controllers/auth_controller.dart';
import 'package:aretina/core/routes/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    // Capture before awaits
    final auth = context.read<AuthController>();
    final router = GoRouter.of(context);

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2800)),
      auth.checkAuthStatus(),
    ]);

    if (!mounted) return;

    if (auth.isAuthenticated) {
      router.go(AppRoutes.home);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    router.go(seenOnboarding ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.bgGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Glow orbs
            Positioned(
              top: -100, right: -100,
              child: Container(
                width: 350, height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [colors.primary.withValues(alpha: 0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150, left: -100,
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [colors.secondary.withValues(alpha: 0.12), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                          gradient: LinearGradient(
                            colors: colors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(
                                  alpha: 0.3 + 0.2 * _pulseController.value),
                              blurRadius: 30 + 10 * _pulseController.value,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: const Center(
                      child: Icon(Icons.remove_red_eye_rounded,
                          color: Colors.white, size: 52),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.5, 0.5), duration: 700.ms,
                          curve: Curves.elasticOut),

                  const SizedBox(height: 28),

                  // App name with gradient text
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: colors.primaryGradient,
                    ).createShader(bounds),
                    child: Text(
                      AppConstants.appName,
                      style: textTheme.displayLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, duration: 600.ms,
                          curve: Curves.easeOutCubic),

                  const SizedBox(height: 8),
                  Text(AppConstants.appTagline, style: textTheme.bodyMedium)
                      .animate(delay: 500.ms).fadeIn(duration: 600.ms),

                  const SizedBox(height: 80),

                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      backgroundColor: colors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 3,
                    ),
                  ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),

            Positioned(
              bottom: 32, left: 0, right: 0,
              child: Text(
                'v${AppConstants.appVersion}',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ).animate(delay: 800.ms).fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}