import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aretina/core/constants/constants.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/utils/utils.dart';
import 'package:aretina/data/models/detection_model.dart';
import 'package:aretina/data/repositories/detection_repository.dart';
import 'package:aretina/logic/controllers/auth_controller.dart';
import 'package:aretina/logic/controllers/detection_controller.dart';
import 'package:aretina/core/routes/app_router.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  DetectionModel? _result;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final detection = context.read<DetectionController>();
    final auth = context.read<AuthController>();

    if (detection.lastResult != null) {
      setState(() {
        _result = detection.lastResult;
        _isLoading = false;
      });
      return;
    }


    if (auth.currentUser?.id != null) {
      final recent = await DetectionRepository.instance
          .getRecentDetections(auth.currentUser!.id!, limit: 1);
      if (!mounted) return;
      setState(() {
        _result = recent.isNotEmpty ? recent.first : null;
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.bg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
      );
    }

    if (_result == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors.bgGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: colors.textMuted, size: 48),
                const SizedBox(height: 12),
                Text('Hasil tidak ditemukan', style: textTheme.headlineLarge),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.detection),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final result = _result!;
    final diseaseColor = AppUtils.getDiseaseColor(result.diagnosis);

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
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go(AppRoutes.detection),
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.card,
                          foregroundColor: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Hasil Pemindaian', style: textTheme.headlineLarge),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ),

              // Eye Image
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    child: Image.file(
                      File(result.imagePath),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: colors.card,
                        child: Center(
                          child: Icon(Icons.image_not_supported_rounded,
                              color: colors.textMuted, size: 48),
                        ),
                      ),
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                ),
              ),

              // Diagnosis Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _DiagnosisCard(result: result, color: diseaseColor)
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2),
                ),
              ),

              // Confidence Bars
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _ConfidenceBars(result: result)
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 500.ms),
                ),
              ),

              // Description
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _DescriptionCard(diagnosis: result.diagnosis)
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 500.ms),
                ),
              ),

              // Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go(AppRoutes.detection),
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: const Text('Pindai Gambar Lain'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.go(AppRoutes.history),
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('Lihat Riwayat'),
                      ),
                    ],
                  ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final DetectionModel result;
  final Color color;
  const _DiagnosisCard({required this.result, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(AppUtils.getDiseaseIcon(result.diagnosis),
                color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.isUnknown ? 'Hasil' : 'Diagnosis',
                  style: textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.8)),
                ),
                Text(result.diagnosis,
                    style: textTheme.displayMedium?.copyWith(color: color)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      result.isUnknown ? 'Skor tertinggi: ' : 'Kepercayaan: ',
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      AppUtils.formatConfidence(result.confidence),
                      style: textTheme.bodySmall?.copyWith(
                          color: color, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result.isUnknown
                            ? 'Tidak Meyakinkan'
                            : AppUtils.getConfidenceLabel(result.confidence),
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBars extends StatelessWidget {
  final DetectionModel result;
  const _ConfidenceBars({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final scores = [
      (label: 'Katarak', score: result.cataractScore, color: colors.diseaseCataract),
      (label: 'Konjungtivitis', score: result.conjunctivitisScore, color: colors.diseaseConjunctivitis),
      (label: 'Normal', score: result.normalScore, color: colors.diseaseNormal),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skor Kepercayaan', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          ...scores.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.label, style: textTheme.labelLarge),
                      Text(
                        AppUtils.formatConfidence(s.score),
                        style: TextStyle(
                          color: s.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: s.score,
                      backgroundColor: colors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(s.color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String diagnosis;
  const _DescriptionCard({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    final isUnknown = diagnosis.toLowerCase() == 'unknown';
    final description = AppConstants.diseaseDescriptions[diagnosis] ?? '';
    final color = AppUtils.getDiseaseColor(diagnosis);
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                isUnknown ? 'Mengapa ini terjadi' : 'Tentang $diagnosis',
                style: textTheme.headlineMedium?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description,
              style: textTheme.bodyMedium?.copyWith(height: 1.6)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                  color: colors.warning.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(
                  isUnknown
                      ? Icons.camera_alt_outlined
                      : Icons.medical_services_outlined,
                  color: colors.warning,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isUnknown
                        ? 'Coba pindai ulang dengan pencahayaan yang baik, mata terpusat, dan tidak ada silau.'
                        : 'Ini adalah alat skrining berbasis AI. Selalu konsultasikan dengan dokter mata yang berkualifikasi untuk diagnosis yang tepat.',
                    style: textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}