// lib/screen/pages/onboarding/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/routes/app_router.dart';

class _OnboardItem {
  final IconData icon;
  final String title;
  final String description;
  final Color Function(BuildContext) colorFn;

  const _OnboardItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.colorFn,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

  static final _items = [
    _OnboardItem(
      icon: Icons.remove_red_eye_rounded,
      title: 'Analisis Mata\nBerbasis AI',
      description:
          'Model machine learning canggih yang dilatih untuk mendeteksi kondisi Normal, Conjunctivitis, dan Cataract dari gambar mata.',
      colorFn: (ctx) => ctx.colors.primary,
    ),
    _OnboardItem(
      icon: Icons.camera_alt_rounded,
      title: 'Deteksi\nInstan',
      description:
          'Ambil foto atau unggah dari galeri Anda. Dapatkan hasil dalam hitungan detik dengan skor kepercayaan dan penjelasan rinci.',
      colorFn: (ctx) => ctx.colors.secondary,
    ),
    _OnboardItem(
      icon: Icons.history_rounded,
      title: 'Lacak Riwayat\nAnda',
      description:
          'Setiap pemindaian disimpan secara lokal. Tinjau hasil sebelumnya, pantau tren, dan bagikan laporan dengan dokter Anda.',
      colorFn: (ctx) => ctx.colors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _items.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final router = GoRouter.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) router.go(AppRoutes.login);
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
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Lewati',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colors.primary)),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemCount: _items.length,
                  itemBuilder: (context, i) =>
                      _OnboardCard(item: _items[i]),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == i
                                ? colors.primary
                                : colors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: Text(
                        _currentIndex == _items.length - 1
                            ? 'Mulai'
                            : 'Selanjutnya',
                        style: textTheme.labelLarge
                            ?.copyWith(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardCard extends StatelessWidget {
  final _OnboardItem item;
  const _OnboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.colorFn(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(
                  color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(item.icon, size: 60, color: color),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut),

          const SizedBox(height: 40),
          Text(item.title, textAlign: TextAlign.center,
              style: textTheme.displayMedium)
              .animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(item.description, textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(height: 1.6))
              .animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}