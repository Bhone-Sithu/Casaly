import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum GlassType {
  primary,   // Cyan - main UI elements
  neutral,   // Transparent - subtle elements  
  success,   // Green - success states
  warning,   // Yellow - warning states
  error,     // Berry - error states
  info,      // Orange - info states
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final GlassType type;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double blurIntensity;
  final double opacity;
  final double borderRadius;
  final bool hasBorder;
  final bool hasShadow;

  const GlassContainer({
    required this.child,
    this.type = GlassType.neutral,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blurIntensity = 20.0,  // Stronger blur for editorial effect
    this.opacity = 0.1,         // Much lower opacity for "no background" effect
    this.borderRadius = AppRadius.glassCard,
    this.hasBorder = true,
    this.hasShadow = false,      // Use tonal layering instead of shadows
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: _getShadowColor().withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: _getShadowColor().withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: hasBorder
                  ? Border.all(color: _getBorderColor(), width: 0.5)
                  : null,
              gradient: _getGradient(),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  Color _getGlassColor() {
    final baseColor = _getBaseColor();
    return baseColor.withOpacity(opacity);
  }

  Color _getBaseColor() {
    switch (type) {
      case GlassType.primary:
        return AppColors.primary;
      case GlassType.success:
        return AppColors.success;
      case GlassType.warning:
        return AppColors.warning;
      case GlassType.error:
        return AppColors.error;
      case GlassType.info:
        return AppColors.info;
      case GlassType.neutral:
        return AppColors.cream400;
    }
  }

  Color _getBorderColor() {
    // Editorial "Ghost Border" - felt, not seen
    return AppColors.outlineVariant.withValues(alpha: 0.2);
  }

  Color _getShadowColor() {
    return _getBaseColor();
  }

  LinearGradient _getGradient() {
    // "NO BACKGROUND COLOR" glass morphism - pure transparency with subtle borders
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.05), // Extremely subtle white highlight
        Colors.transparent,                    // Complete transparency in center
        Colors.transparent,                    // Keep transparency
        Colors.white.withValues(alpha: 0.02), // Barely visible white lowlight
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }
}
