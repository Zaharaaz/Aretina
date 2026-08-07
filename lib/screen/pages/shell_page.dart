// lib/screen/pages/shell_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/routes/app_router.dart';

class ShellPage extends StatelessWidget {
  final Widget child;
  const ShellPage({super.key, required this.child});

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda', route: AppRoutes.home),
    _NavItem(icon: Icons.document_scanner_rounded, label: 'Deteksi', route: AppRoutes.detection),
    _NavItem(icon: Icons.history_rounded, label: 'Riwayat', route: AppRoutes.history),
    _NavItem(icon: Icons.person_rounded, label: 'Profil', route: AppRoutes.profile),
  ];

  int _currentIndex(String location) {
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.detection) ||
        location.startsWith(AppRoutes.result)) return 1;
    if (location.startsWith(AppRoutes.history)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: Border(
            top: BorderSide(color: colors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isSelected = currentIndex == i;

                return GestureDetector(
                  onTap: () => context.go(item.route),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Detect tab — special circle button
                        i == 1
                            ? AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: colors.primaryGradient,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  // In light mode unselected: use cardAlt
                                  // so the circle is visible against white bg
                                  color: isSelected
                                      ? null
                                      : isDark
                                          ? colors.card
                                          : colors.cardAlt,
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? AppTheme.glowShadow(colors.primary)
                                      : null,
                                ),
                                child: Icon(
                                  Icons.document_scanner_rounded,
                                  // White when selected (on gradient bg)
                                  // Primary color when unselected (visible on both modes)
                                  color: isSelected
                                      ? Colors.white
                                      : colors.primary,
                                  size: 20,
                                ),
                              )
                            // Regular nav icons
                            : Icon(
                                item.icon,
                                color: isSelected
                                    ? colors.primary
                                    : colors.textMuted,
                                size: 24,
                              ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? colors.primary
                                : colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(
      {required this.icon, required this.label, required this.route});
}