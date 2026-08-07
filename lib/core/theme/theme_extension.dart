import 'package:flutter/material.dart';
import 'app_colors.dart';


extension ThemeContextExt on BuildContext {
	AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
	bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

extension ColorHelpers on Color {
	/// Apply opacity/alpha without changing the original color object.
	/// Uses integer ARGB construction to avoid deprecated APIs.
	Color withValues({double? alpha}) {
		final currentAlpha = alpha ?? a;
		final clamped = currentAlpha.clamp(0.0, 1.0);
		final intA = (clamped * 255).round().clamp(0, 255);
		final intR = (r * 255).round().clamp(0, 255);
		final intG = (g * 255).round().clamp(0, 255);
		final intB = (b * 255).round().clamp(0, 255);
		return Color.fromARGB(intA, intR, intG, intB);
	}
}

extension GradientHelpers on LinearGradient {
	Shader createShaderSafe(Rect rect) => createShader(rect);
}

