// lib/screen/pages/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/utils/utils.dart';
import 'package:aretina/core/constants/constants.dart';
import 'package:aretina/logic/controllers/auth_controller.dart';
import 'package:aretina/logic/controllers/detection_controller.dart';
import 'package:aretina/core/routes/app_router.dart';
import 'package:aretina/screen/widgets/detection_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthController>();
    final detection = context.read<DetectionController>();
    if (auth.currentUser?.id != null) {
      await detection.loadHistory(auth.currentUser!.id!);
      final summary = await detection.getSummary(auth.currentUser!.id!);
      if (mounted) setState(() => _summary = summary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final detection = context.watch<DetectionController>();
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final user = auth.currentUser;
    final recentHistory = detection.history.take(3).toList();
    final totalScans = detection.history.length;

    return Scaffold(
      body: Container(
        color: colors.bg,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: colors.primary,
            backgroundColor: colors.card,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: textTheme.bodyMedium,
                            ),
                            Text(
                              user?.name.split(' ').first ?? 'Pengguna',
                              style: textTheme.displayMedium,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.profile),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colors.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                AppUtils.getInitials(user?.name ?? 'P'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                  ),
                ),

                // Hero Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _HeroBanner(
                      onTap: () => context.go(AppRoutes.detection),
                    ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                  ),
                ),

                // Stats Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total Pindaian',
                            value: '$totalScans',
                            icon: Icons.document_scanner_rounded,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Normal',
                            value: '${_summary['Normal'] ?? 0}',
                            icon: Icons.check_circle_rounded,
                            color: colors.diseaseNormal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Terdeteksi',
                            value:
                                '${(_summary['Conjunctivitis'] ?? 0) + (_summary['Cataract'] ?? 0)}',
                            icon: Icons.warning_rounded,
                            color: colors.diseaseConjunctivitis,
                          ),
                        ),
                      ],
                    ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
                  ),
                ),

                // Disease Info Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Text('Kondisi yang Dapat Diidentifikasi',
                        style: textTheme.headlineMedium),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      scrollDirection: Axis.horizontal,
                      children: AppConstants.diseaseLabels
                          .map((label) => _DiseaseChip(label: label))
                          .toList(),
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
                ),

                // Recent History header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pemindaian Terbaru',
                            style: textTheme.headlineMedium),
                        if (detection.history.isNotEmpty)
                          TextButton(
                            onPressed: () => context.go(AppRoutes.history),
                            child: Text('Lihat Semua',
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: colors.primary)),
                          ),
                      ],
                    ),
                  ),
                ),

                if (recentHistory.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: _EmptyState(
                        onTap: () => context.go(AppRoutes.detection),
                      ),
                    ).animate(delay: 350.ms).fadeIn(duration: 500.ms),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: DetectionCard(
                          detection: recentHistory[i],
                          onTap: () => context.push(
                            AppRoutes.detectionDetailPath(
                                recentHistory[i].id!),
                          ),
                        )
                            .animate(delay: (350 + i * 80).ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2),
                      ),
                      childCount: recentHistory.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi,';
    if (hour < 17) return 'Selamat siang,';
    return 'Selamat malam,';
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _HeroBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: AppTheme.glowShadow(colors.primary),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mulai Pemindaian Mata',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ambil atau unggah foto untuk\nanalisis AI instan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Pindai Sekarang',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove_red_eye_rounded,
                  color: Colors.white, size: 42),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: textTheme.headlineLarge?.copyWith(color: color)),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DiseaseChip extends StatelessWidget {
  final String label;
  const _DiseaseChip({required this.label});

  // Translation map — model outputs English, display in Indonesian
  static const _labelMap = {
    'Cataract': 'Katarak',
    'Conjunctivitis': 'Konjungtivitis',
    'Normal': 'Normal',
  };

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.getDiseaseColor(label);
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final displayLabel = _labelMap[label] ?? label;

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppUtils.getDiseaseIcon(label), color: color, size: 24),
          const SizedBox(height: 8),
          Text(displayLabel,
              style: textTheme.labelLarge?.copyWith(color: color)),
          Text(
            label == 'Normal' ? 'Sehat' : 'Penyakit',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.document_scanner_outlined,
                color: colors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text('Belum ada pindaian', style: textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Ketuk di sini untuk memulai pemindaian mata pertama Anda',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}