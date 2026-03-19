import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'glass_container.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final GlassType type;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final bool isInteractive;

  const GlassCard({
    required this.child,
    this.type = GlassType.neutral,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.width,
    this.height,
    this.isInteractive = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = GlassContainer(
      type: type,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      child: child,
    );

    if (onTap != null && isInteractive) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: _getBaseColor().withOpacity(0.1),
          highlightColor: _getBaseColor().withOpacity(0.05),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  Color _getBaseColor() {
    switch (type) {
      case GlassType.primary:
        return const Color(0xFF4A9E60);
      case GlassType.secondary:
        return const Color(0xFFE8884A);
      case GlassType.accent:
        return const Color(0xFFD4A420);
      case GlassType.success:
        return const Color(0xFF4A9E60);
      case GlassType.warning:
        return const Color(0xFFD4A420);
      case GlassType.error:
        return const Color(0xFFD04848);
      case GlassType.info:
        return const Color(0xFFE8884A);
      case GlassType.neutral:
        return const Color(0xFFA09080);
    }
  }
}