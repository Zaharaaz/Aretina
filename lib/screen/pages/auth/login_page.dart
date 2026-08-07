import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/utils/utils.dart';
import 'package:aretina/logic/controllers/auth_controller.dart';
import 'package:aretina/core/routes/app_router.dart';
import 'package:aretina/screen/widgets/gradient_button.dart';
import 'package:aretina/screen/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthController>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final success = await auth.login(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      router.go(AppRoutes.home);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login ')),
      );
    }
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: AppTheme.glowShadow(colors.primary),
                      ),
                      child: const Icon(Icons.remove_red_eye_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text('Aretina',
                        style: textTheme.headlineLarge
                            ?.copyWith(color: colors.primary)),
                  ],
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),

                const SizedBox(height: 48),
                Text('Selamat\nDatang', style: textTheme.displayLarge)
                    .animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text('Masuk untuk melanjutkan perjalanan kesehatan mata Anda',
                    style: textTheme.bodyMedium)
                    .animate(delay: 150.ms).fadeIn(duration: 500.ms),
                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _emailCtrl,
                        label: 'Alamat Email',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: AppUtils.validateEmail,
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: AppUtils.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colors.textMuted,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Lupa password?',
                              style: textTheme.bodySmall
                                  ?.copyWith(color: colors.primary)),
                        ),
                      ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),
                      Consumer<AuthController>(
                        builder: (context, auth, _) => GradientButton(
                          label: 'Masuk',
                          isLoading: auth.isLoading,
                          onPressed: _login,
                        ),
                      ).animate(delay: 350.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau', style: textTheme.bodySmall),
                    ),
                    Expanded(child: Divider(color: colors.border)),
                  ],
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun?", style: textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: Text('Daftar',
                          style: textTheme.labelLarge
                              ?.copyWith(color: colors.primary)),
                    ),
                  ],
                ).animate(delay: 450.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}