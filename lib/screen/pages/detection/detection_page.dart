// lib/screen/pages/detection/detection_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/logic/controllers/auth_controller.dart';
import 'package:aretina/logic/controllers/detection_controller.dart';
import 'package:aretina/core/routes/app_router.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _scanAnimController;
  late DetectionController _detectionController; 

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  
    _detectionController = context.read<DetectionController>();
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    _detectionController.reset(); 
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (!mounted) return;
      if (picked == null) return;
      setState(() => _selectedImage = File(picked.path));
      _detectionController.reset();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _analyze() async {
    if (_selectedImage == null) return;
    final auth = context.read<AuthController>();
    final router = GoRouter.of(context); 

    if (auth.currentUser?.id == null) return;

    final result = await _detectionController.analyzeImage(
      imagePath: _selectedImage!.path,
      userId: auth.currentUser!.id!,
    );

    if (!mounted) return;
    if (result != null) {
      router.go(AppRoutes.result); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final detection = context.watch<DetectionController>();
    final isAnalyzing = detection.isAnalyzing;
    final colors = context.colors;

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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Text('Pemindaian Mata',
                        style: Theme.of(context).textTheme.headlineLarge),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _ImagePreview(
                        image: _selectedImage,
                        isAnalyzing: isAnalyzing,
                        scanController: _scanAnimController,
                        onPickCamera: () => _pickImage(ImageSource.camera),
                        onPickGallery: () => _pickImage(ImageSource.gallery),
                      ).animate(delay: 100.ms).fadeIn(duration: 500.ms),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _SourceButton(
                              icon: Icons.camera_alt_rounded,
                              label: 'Kamera',
                              onTap: isAnalyzing
                                  ? null
                                  : () => _pickImage(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SourceButton(
                              icon: Icons.photo_library_rounded,
                              label: 'Galeri',
                              onTap: isAnalyzing
                                  ? null
                                  : () => _pickImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 20),

                      const _TipsCard()
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      if (_selectedImage != null)
                        _AnalyzeButton(
                          isAnalyzing: isAnalyzing,
                          onTap: isAnalyzing ? null : _analyze,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.3),
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

class _ImagePreview extends StatelessWidget {
  final File? image;
  final bool isAnalyzing;
  final AnimationController scanController;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;

  const _ImagePreview({
    required this.image,
    required this.isAnalyzing,
    required this.scanController,
    required this.onPickCamera,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primary = colors.primary;

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: image != null
              ? primary.withValues(alpha: 0.4)
              : colors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: image != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(image!, fit: BoxFit.cover),
                if (isAnalyzing)
                  AnimatedBuilder(
                    animation: scanController,
                    builder: (context, _) {
                      return Stack(
                        children: [
                          Container(
                              color: Colors.black.withValues(alpha: 0.4)),
                          Positioned(
                            top: 280 * scanController.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    primary,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor:
                                        AlwaysStoppedAnimation(primary),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text('Menganalisis...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    )),
                                const SizedBox(height: 4),
                                Text('AI sedang memproses gambar Anda',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 13,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: primary.withValues(alpha: 0.3)),
                  ),
                  child:
                      Icon(Icons.add_a_photo_rounded, color: primary, size: 32),
                ),
                const SizedBox(height: 16),
                Text('Tidak ada gambar yang dipilih',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Gunakan Kamera atau Galeri di bawah',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primary = colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.5 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: primary, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: primary, size: 18),
              const SizedBox(width: 8),
              Text('Tips untuk hasil terbaik',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: primary)),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            'Gunakan foto mata yang jelas dan terang',
            'Pastikan mata berada di tengah dan fokus',
            'Hindari gambar yang buram atau resolusi rendah',
            'Hasil terbaik dengan foto mata langsung dari depan',
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(tip,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(height: 1.5)),
              )),
        ],
      ),
    );
  }
}

class _AnalyzeButton extends StatelessWidget {
  final bool isAnalyzing;
  final VoidCallback? onTap;

  const _AnalyzeButton({required this.isAnalyzing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: colors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled ? null : colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: isEnabled ? AppTheme.glowShadow(colors.primary) : null,
        ),
        child: Center(
          child: isAnalyzing
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Menganalisis...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    Text('Analisis Gambar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      )
                  ],
                ),
        ),
      ),
    );
  }
}