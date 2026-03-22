import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'glass_container.dart';

class GlassCard extends StatefulWidget {
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
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.margin,
    this.width,
    this.height,
    this.isInteractive = true,
    super.key,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98, // Tactile scale effect
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidget = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: GlassContainer(
          type: widget.type,
          padding: widget.padding,
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null && widget.isInteractive) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          borderRadius: BorderRadius.circular(AppRadius.card),
          splashColor: _getBaseColor().withValues(alpha: 0.1),
          highlightColor: _getBaseColor().withValues(alpha: 0.05),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  Color _getBaseColor() {
    switch (widget.type) {
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
        return AppColors.outline;
    }
  }
}