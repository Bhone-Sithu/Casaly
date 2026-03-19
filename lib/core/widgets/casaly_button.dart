import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum ButtonVariant { primary, secondary, outline, text, glass }

class CasalyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  const CasalyButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(variant, isDisabled),
          foregroundColor: _getForegroundColor(variant, isDisabled),
          elevation: variant == ButtonVariant.outline || variant == ButtonVariant.text ? 0 : 2,
          shadowColor: AppColors.cream800.withOpacity(0.1),
          side: _getBorder(variant, isDisabled),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getForegroundColor(variant, false),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLg.copyWith(
                      color: _getForegroundColor(variant, isDisabled),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor(ButtonVariant variant, bool isDisabled) {
    if (isDisabled) {
      return switch (variant) {
        ButtonVariant.primary => AppColors.cream200,
        ButtonVariant.secondary => AppColors.cream200,
        ButtonVariant.outline => Colors.transparent,
        ButtonVariant.text => Colors.transparent,
        ButtonVariant.glass => Colors.transparent,
      };
    }

    return switch (variant) {
      ButtonVariant.primary => AppColors.green400,
      ButtonVariant.secondary => AppColors.orange400,
      ButtonVariant.outline => Colors.transparent,
      ButtonVariant.text => Colors.transparent,
      ButtonVariant.glass => Colors.transparent,
    };
  }

  Color _getForegroundColor(ButtonVariant variant, bool isDisabled) {
    if (isDisabled) {
      return AppColors.cream400;
    }

    return switch (variant) {
      ButtonVariant.primary => Colors.white,
      ButtonVariant.secondary => Colors.white,
      ButtonVariant.outline => AppColors.green400,
      ButtonVariant.text => AppColors.green400,
      ButtonVariant.glass => AppColors.green400,
    };
  }

  BorderSide? _getBorder(ButtonVariant variant, bool isDisabled) {
    if (variant == ButtonVariant.outline) {
      return BorderSide(
        color: isDisabled ? AppColors.cream200 : AppColors.green400,
        width: 1.5,
      );
    }
    return null;
  }
}