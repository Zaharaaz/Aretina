// lib/screen/pages/profile/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/utils/utils.dart';
import 'package:aretina/core/routes/app_router.dart';
import 'package:aretina/logic/controllers/auth_controller.dart';
import 'package:aretina/logic/controllers/detection_controller.dart';
import 'package:aretina/logic/providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, int> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final auth = context.read<AuthController>();
    final detection = context.read<DetectionController>();
    if (auth.currentUser?.id != null) {
      final summary = await detection.getSummary(auth.currentUser!.id!);
      if (mounted) setState(() => _summary = summary);
    }
  }

  Future<void> _pickAvatar() async {
    final auth = context.read<AuthController>();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 500,
    );
    if (picked == null) return;
    if (!mounted) return;
    await auth.updateProfile(avatarPath: picked.path);
  }

  Future<void> _logout() async {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final auth = context.read<AuthController>();
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        title: Text('Keluar', style: textTheme.headlineMedium),
        content: Text('Apakah Anda yakin ingin keluar?',
            style: textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Keluar',
                style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed != true) return;
    await auth.logout();
    if (!mounted) return;
    router.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final user = auth.currentUser;
    final totalScans = _summary.values.fold(0, (a, b) => a + b);

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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Text('Profil', style: textTheme.headlineLarge)
                      .animate().fadeIn(duration: 400.ms),
                ),
              ),

              // Avatar + Name
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: colors.primaryGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: AppTheme.glowShadow(colors.primary),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: user?.avatarPath != null
                                  ? Image.file(File(user!.avatarPath!),
                                      fit: BoxFit.cover)
                                  : Center(
                                      child: Text(
                                        AppUtils.getInitials(user?.name ?? 'U'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned(
                              right: 0, bottom: 0,
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colors.bg, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(user?.name ?? '', style: textTheme.displayMedium),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Pengguna sejak ${AppUtils.formatDate(user?.createdAt ?? DateTime.now())}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                ),
              ),

              // Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Statistik Pemindaian', style: textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _StatItem(label: 'Total', value: '$totalScans', color: colors.primary),
                            const SizedBox(width: 12),
                            _StatItem(label: 'Normal', value: '${_summary['Normal'] ?? 0}', color: colors.diseaseNormal),
                            const SizedBox(width: 12),
                            _StatItem(label: 'Conjunctivitis', value: '${_summary['Conjunctivitis'] ?? 0}', color: colors.diseaseConjunctivitis),
                            const SizedBox(width: 12),
                            _StatItem(label: 'Cataract', value: '${_summary['Cataract'] ?? 0}', color: colors.diseaseCataract),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                ),
              ),

              // Settings label
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Text('Pengaturan', style: textTheme.headlineMedium)
                      .animate(delay: 300.ms).fadeIn(duration: 400.ms),
                ),
              ),

              // Settings list
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      children: [
                        _SettingItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profil',
                          onTap: () => _showEditProfile(context),
                        ),
                        Divider(height: 1, color: colors.border),
                        const _ThemeToggleItem(),
                        Divider(height: 1, color: colors.border),
                        _SettingItem(
                          icon: Icons.lock_outline_rounded,
                          label: 'Ubah Kata Sandi',
                          onTap: () => _showChangePassword(context),
                        ),
                        Divider(height: 1, color: colors.border),
                        _SettingItem(
                          icon: Icons.info_outline_rounded,
                          label: 'Tentang Aplikasi',
                          onTap: () => _showAbout(context),
                        ),
                        Divider(height: 1, color: colors.border),
                        _SettingItem(
                          icon: Icons.logout_rounded,
                          label: 'Keluar',
                          textColor: colors.error,
                          iconColor: colors.error,
                          onTap: _logout,
                          showChevron: false,
                        ),
                      ],
                    ),
                  ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final auth = context.read<AuthController>();
    final nameCtrl = TextEditingController(text: auth.currentUser?.name);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Profil', style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline_rounded)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final nav = Navigator.of(ctx);
                await auth.updateProfile(name: nameCtrl.text);
                nav.pop();
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final auth = context.read<AuthController>();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ubah Kata Sandi', style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 20),
            TextFormField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Kata Sandi Saat Ini'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Kata Sandi Baru'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final success = await auth.changePassword(
                  currentPassword: currentCtrl.text,
                  newPassword: newCtrl.text,
                );
                nav.pop();
                messenger.showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Kata sandi berhasil diubah'
                      : auth.errorMessage ?? 'Gagal mengubah kata sandi'),
                ));
              },
              child: const Text('Perbarui Kata Sandi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Aretina',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Final Year Project',
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: textTheme.headlineLarge?.copyWith(color: color)),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ThemeToggleItem extends StatelessWidget {
  const _ThemeToggleItem();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: colors.primary, size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text('Mode Gelap',
                  style: textTheme.bodyLarge?.copyWith(
                      color: colors.textPrimary, fontWeight: FontWeight.w500)),
            ),
            Switch.adaptive(
              value: isDark,
              activeColor: colors.primary,
              onChanged: (value) =>
                  context.read<ThemeProvider>().setDarkMode(value),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool showChevron;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final effectiveIconColor = iconColor ?? colors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: textTheme.bodyLarge?.copyWith(
                      color: textColor ?? colors.textPrimary,
                      fontWeight: FontWeight.w500)),
            ),
            if (showChevron)
              Icon(Icons.chevron_right_rounded,
                  color: colors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}