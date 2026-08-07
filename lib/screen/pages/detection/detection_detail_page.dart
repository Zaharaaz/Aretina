import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:aretina/core/constants/constants.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/utils/utils.dart';
import 'package:aretina/data/models/detection_model.dart';
import 'package:aretina/data/repositories/detection_repository.dart';

class DetectionDetailPage extends StatefulWidget {
  final int? detectionId;
  const DetectionDetailPage({super.key, required this.detectionId});

  @override
  State<DetectionDetailPage> createState() => _DetectionDetailPageState();
}

class _DetectionDetailPageState extends State<DetectionDetailPage> {
  DetectionModel? _detection;
  bool _isLoading = true;
  bool _notFound = false;
  late final TextEditingController _notesCtrl;
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController();
    _loadDetection();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetection() async {
    final id = widget.detectionId;
    if (id == null) {
      setState(() {
        _isLoading = false;
        _notFound = true;
      });
      return;
    }

    final result = await DetectionRepository.instance.getDetectionById(id);

    if (!mounted) return;
    setState(() {
      _detection = result;
      _notesCtrl.text = result?.notes ?? '';
      _isLoading = false;
      _notFound = result == null;
    });
  }

  Future<void> _saveNotes() async {
    final detection = _detection;
    if (detection?.id == null) return;

    setState(() => _isSavingNotes = true);
    final messenger = ScaffoldMessenger.of(context);

    final success = await DetectionRepository.instance
        .updateNotes(detection!.id!, _notesCtrl.text.trim());

    if (!mounted) return;
    setState(() => _isSavingNotes = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'Catatan disimpan' : 'Gagal menyimpan catatan'),
      ),
    );
  }

  Future<void> _delete() async {
    final detection = _detection;
    if (detection?.id == null) return;

    // Capture a stable, non-null reference before awaiting async calls
    final det = detection!;
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text('Hapus Catatan', style: AppTheme.headlineMedium),
        content: Text(
          'Hapus deteksi ${det.diagnosis} ini dari riwayat? Tindakan ini tidak dapat dibatalkan.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal '),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed != true) return;

    final success =
        await DetectionRepository.instance.deleteDetection(det.id!);

    if (!mounted) return;
    if (success) {
      router.pop(); // back to history, list refreshes via its own controller
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.bg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.primary),
          ),
        ),
      );
    }

    if (_notFound || _detection == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.colors.bgGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _BackBar(title: 'Detail'),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                          color: context.colors.textMuted, size: 56),
                        const SizedBox(height: 16),
                        Text('Catatan tidak ditemukan', style: AppTheme.headlineMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Catatan ini mungkin telah dihapus.',
                          style: AppTheme.bodyMedium,
                        ),
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

    final result = _detection!;
    final color = AppUtils.getDiseaseColor(result.diagnosis);

    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.colors.bgGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _BackBar(
                  title: 'Detail Scan',
                  trailing: IconButton(
                    onPressed: _delete,
                    icon: Icon(Icons.delete_outline_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.error,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),

              // Image
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
                        color: context.colors.card,
                        child: Center(
                          child: Icon(Icons.image_not_supported_rounded,
                              color: context.colors.textMuted, size: 48),
                        ),
                      ),
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                ),
              ),

              // Diagnosis summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(AppUtils.getDiseaseIcon(result.diagnosis),
                              color: color, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(result.diagnosis,
                                  style: AppTheme.displayMedium.copyWith(color: color)),
                              const SizedBox(height: 4),
                              Text(
                                AppUtils.formatDateTime(result.detectedAt),
                                style: AppTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            AppUtils.formatConfidence(result.confidence),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),
                ),
              ),

              // Confidence breakdown
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _ConfidenceBreakdown(result: result)
                      .animate(delay: 280.ms)
                      .fadeIn(duration: 500.ms),
                ),
              ),

              // Description
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tentang ${result.diagnosis}',
                            style: AppTheme.headlineMedium.copyWith(color: color)),
                        const SizedBox(height: 10),
                        Text(
                          AppConstants.diseaseDescriptions[result.diagnosis] ?? '',
                          style: AppTheme.bodyMedium.copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ).animate(delay: 350.ms).fadeIn(duration: 500.ms),
                ),
              ),

              // Personal notes — unique to detail page
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_note_rounded,
                              color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text('Catatan Pribadi', style: AppTheme.headlineMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesCtrl,
                          maxLines: 3,
                          style: AppTheme.bodyMedium.copyWith(color: context.colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Tambahkan catatan — gejala, catatan dokter, tanggal follow-up...',
                            filled: true,
                            fillColor: context.colors.cardAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isSavingNotes ? null : _saveNotes,
                                icon: _isSavingNotes
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(Icons.save_outlined, size: 18),
                            label: Text(_isSavingNotes ? 'Sedang Menyimpan...' : 'Simpan Catatan'),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 420.ms).fadeIn(duration: 500.ms),
                ),
              ),

              // Disclaimer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.medical_services_outlined,
                          color: AppTheme.warning, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hasil pemindaian yang didukung AI. Selalu konsultasikan dengan dokter mata yang memahami untuk diagnosis yang tepat.',
                            style: AppTheme.bodySmall.copyWith(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 480.ms).fadeIn(duration: 400.ms),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _BackBar({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios_rounded),
            style: IconButton.styleFrom(
              backgroundColor: context.colors.card,
              foregroundColor: context.colors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTheme.headlineLarge)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ConfidenceBreakdown extends StatelessWidget {
  final DetectionModel result;
  const _ConfidenceBreakdown({required this.result});

  @override
  Widget build(BuildContext context) {
    final scores = [
      (label: 'Normal', score: result.normalScore, color: AppTheme.colorNormal),
      (label: 'Conjunctivitis', score: result.conjunctivitisScore, color: AppTheme.colorConjunctivitis),
      (label: 'Cataract', score: result.cataractScore, color: AppTheme.colorCataract),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tingkat Kepercayaan', style: AppTheme.headlineMedium),
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
                      Text(s.label, style: AppTheme.labelLarge),
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
                      backgroundColor: context.colors.border,
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