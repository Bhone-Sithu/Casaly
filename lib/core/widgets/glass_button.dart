import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'glass_container.dart';

enum GlassButtonVariant { primary, info, warning, neutral }

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final GlassButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final double? width;
  final double height;

  const GlassButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = GlassButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    this.width,
    this.height = 48,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          splashColor: _getGlassColor().withOpacity(0.2),
          highlightColor: _getGlassColor().withOpacity(0.1),
          child: GlassContainer(
            type: _getGlassType(),
            opacity: isDisabled ? 0.1 : 0.2,
            borderRadius: AppRadius.button,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getForegroundColor(isDisabled),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 18,
                          color: _getForegroundColor(isDisabled),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        text,
                        style: AppTypography.labelLg.copyWith(
                          color: _getForegroundColor(isDisabled),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  GlassType _getGlassType() {
    switch (variant) {
      case GlassButtonVariant.primary:
        return GlassType.primary;
      case GlassButtonVariant.info:
        return GlassType.info;
      case GlassButtonVariant.warning:
        return GlassType.warning;
      case GlassButtonVariant.neutral:
        return GlassType.neutral;
    }
  }

  Color _getGlassColor() {
    switch (variant) {
      case GlassButtonVariant.primary:
        return AppColors.primary;
      case GlassButtonVariant.info:
        return AppColors.info;
      case GlassButtonVariant.warning:
        return AppColors.warning;
      case GlassButtonVariant.neutral:
        return AppColors.cream600;
    }
  }

  Color _getForegroundColor(bool isDisabled) {
    if (isDisabled) {
      return AppColors.cream400;
    }

    switch (variant) {
      case GlassButtonVariant.primary:
        return AppColors.cyan800;
      case GlassButtonVariant.info:
        return AppColors.orange800;
      case GlassButtonVariant.warning:
        return AppColors.yellow800;
      case GlassButtonVariant.neutral:
        return AppColors.cream800;
    }
  }
}