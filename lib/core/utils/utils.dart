import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/constants/constants.dart';

class AppUtils {
  AppUtils._();

  // ── Password Hashing ──────────────────────────────────────────
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ── Date Formatting ───────────────────────────────────────────
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Baru Saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit yang lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam yang lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari yang lalu';
    return formatDate(date);
  }

  // ── Disease Color ─────────────────────────────────────────────
  static Color getDiseaseColor(String disease) {
    switch (disease.toLowerCase()) {
      case 'normal':
        return AppTheme.colorNormal;
      case 'conjunctivitis':
        return AppTheme.colorConjunctivitis;
      case 'cataract':
        return AppTheme.colorCataract;
      case 'unknown':
        return AppTheme.colorUnknown;
      default:
        return AppTheme.textSecondary;
    }
  }

  static Color getDiseaseBackgroundColor(String disease) {
    return getDiseaseColor(disease).withValues(alpha: 0.12);
  }

  static IconData getDiseaseIcon(String disease) {
    switch (disease.toLowerCase()) {
      case 'normal':
        return Icons.check_circle_rounded;
      case 'conjunctivitis':
        return Icons.visibility_outlined;
      case 'cataract':
        return Icons.remove_red_eye_rounded;
      case 'unknown':
        return Icons.help_outline_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  // ── Confidence Formatting ─────────────────────────────────────
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  static String getConfidenceLabel(double confidence) {
    if (confidence >= 0.85) return 'Sangat Tinggi';
    if (confidence >= 0.70) return 'Tinggi';
    if (confidence >= 0.55) return 'Sedang';
    return 'Rendah';
  }

  // ── Validation ────────────────────────────────────────────────
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length > AppConstants.maxNameLength) {
      return 'Name too long (max ${AppConstants.maxNameLength} chars)';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  // ── SnackBar Helpers ──────────────────────────────────────────
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
              color: AppTheme.success, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: context.colors.cardAlt,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: AppTheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: context.colors.cardAlt,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Image Helpers ─────────────────────────────────────────────
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}