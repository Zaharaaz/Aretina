import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aretina/core/theme/theme.dart';
import 'package:aretina/core/theme/theme_extension.dart';
import 'package:aretina/core/utils/utils.dart';
import 'package:aretina/data/models/detection_model.dart';

class DetectionCard extends StatelessWidget {
  final DetectionModel detection;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DetectionCard({
    super.key,
    required this.detection,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.getDiseaseColor(detection.diagnosis);
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            // Image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: SizedBox(
                width: 60, height: 60,
                child: Image.file(
                  File(detection.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: colors.cardAlt,
                    child: Icon(Icons.image_not_supported_rounded,
                        color: colors.textMuted, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(detection.diagnosis,
                          style: textTheme.labelLarge?.copyWith(color: color)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(AppUtils.formatConfidence(detection.confidence),
                          style: textTheme.bodySmall
                              ?.copyWith(color: color.withValues(alpha: 0.8))),
                      Text(' kepercayaan', style: textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(AppUtils.formatTimeAgo(detection.detectedAt),
                      style: textTheme.bodySmall),
                ],
              ),
            ),

            // Badge + delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    AppUtils.getConfidenceLabel(detection.confidence),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline_rounded,
                        color: colors.textMuted, size: 18),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}