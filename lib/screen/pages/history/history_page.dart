import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aretina/core/routes/app_router.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/utils/utils.dart';
import 'package:aretina/logic/controllers/auth_controller.dart';
import 'package:aretina/logic/controllers/detection_controller.dart';
import 'package:aretina/screen/widgets/detection_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filterLabel = 'Semua';
  final _filters = ['Semua', 'Normal', 'Conjunctivitis', 'Cataract', 'Tidak dikenali'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final auth = context.read<AuthController>();
    final detection = context.read<DetectionController>();
    if (auth.currentUser?.id != null) {
      await detection.loadHistory(auth.currentUser!.id!);
    }
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthController>();
    final detection = context.read<DetectionController>();
    if (auth.currentUser?.id != null) {
      await detection.refreshHistory(auth.currentUser!.id!);
    }
  }

  Future<void> _delete(int id, String diagnosis) async {
    // Capture before async gap
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final detection = context.read<DetectionController>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        title: Text('Hapus Catatan', style: textTheme.headlineMedium),
        content: Text('Hapus deteksi $diagnosis ini dari riwayat?',
            style: textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus',
                style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed != true) return;

    final success = await detection.deleteDetection(id);

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'Catatan dihapus' : 'Gagal menghapus'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detection = context.watch<DetectionController>();
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final filtered = _filterLabel == 'Semua'
        ? detection.history
        : detection.history
            .where((d) => d.diagnosis == _filterLabel)
            .toList();

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Riwayat Pemindaian', style: textTheme.headlineLarge),
                        Text('${detection.history.length} total catatan',
                            style: textTheme.bodyMedium),
                      ],
                    ),
                    IconButton(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.card,
                        foregroundColor: colors.textPrimary,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 24),
                  child: Row(
                    children: _filters.map((f) {
                      final isSelected = _filterLabel == f;
                      final color = f == 'Semua'
                          ? colors.primary
                          : AppUtils.getDiseaseColor(f);
                      return GestureDetector(
                        onTap: () => setState(() => _filterLabel = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : colors.card,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: isSelected ? color : colors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              color: isSelected
                                  ? color
                                  : colors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              ),

              const SizedBox(height: 16),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded,
                                color: colors.textMuted, size: 64),
                            const SizedBox(height: 16),
                            Text('Tidak ada catatan yang ditemukan',
                                style: textTheme.headlineMedium),
                            Text(
                              _filterLabel == 'Semua'
                                  ? 'Mulai pemindaian untuk melihat riwayat Anda'
                                  : 'Tidak ada pindai $_filterLabel yang direkam',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        color: colors.primary,
                        backgroundColor: colors.card,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final item = filtered[i];
                            return Dismissible(
                              key: Key('detection_${item.id}'),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                await _delete(item.id!, item.diagnosis);
                                return false;
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: colors.error
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusLarge),
                                ),
                                child: Icon(Icons.delete_rounded,
                                    color: colors.error),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: DetectionCard(
                                  detection: item,
                                  onTap: () => context.push(
                                    AppRoutes.detectionDetailPath(item.id!),
                                  ),
                                  onDelete: () =>
                                      _delete(item.id!, item.diagnosis),
                                )
                                    .animate(
                                      delay:
                                          Duration(milliseconds: 60 * i),
                                    )
                                    .fadeIn(duration: 300.ms)
                                    .slideX(begin: 0.1),
                              ),
                            );
                          },
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