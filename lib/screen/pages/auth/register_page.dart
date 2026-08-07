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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthController>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final success = await auth.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    if (success) {
      router.go(AppRoutes.home);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registrasi gagal')),
      );
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Silakan konfirmasi kata sandi Anda';
    if (value != _passwordCtrl.text) return 'Kata sandi tidak cocok';
    return null;
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          color: colors.textPrimary),
                      onPressed: () => context.go(AppRoutes.login),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Buat\nAkun', style: textTheme.displayLarge)
                          .animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text('Mulai pemantauan kesehatan mata Anda hari ini',
                          style: textTheme.bodyMedium)
                          .animate(delay: 100.ms).fadeIn(duration: 500.ms),
                      const SizedBox(height: 36),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _nameCtrl,
                              label: 'Nama Lengkap',
                              hint: 'John Doe',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: AppUtils.validateName,
                              textCapitalization: TextCapitalization.words,
                            ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

                            const SizedBox(height: 16),
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
                              hint: 'Min. 6 karakter',
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
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _confirmCtrl,
                              label: 'Konfirmasi Password',
                              hint: 'Masukkan kembali kata sandi',
                              obscureText: _obscureConfirm,
                              prefixIcon: Icons.lock_outline_rounded,
                              validator: _validateConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: colors.textMuted,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),

                            const SizedBox(height: 28),
                            Consumer<AuthController>(
                              builder: (context, auth, _) => GradientButton(
                                label: 'Buat Akun',
                                isLoading: auth.isLoading,
                                onPressed: _register,
                              ),
                            ).animate(delay: 350.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah punya akun?',
                              style: textTheme.bodyMedium),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: Text('Masuk',
                                style: textTheme.labelLarge
                                    ?.copyWith(color: colors.primary)),
                          ),
                        ],
                      ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}