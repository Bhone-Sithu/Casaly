import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/casaly_button.dart';

class DormSelectionScreen extends ConsumerWidget {
  const DormSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cream50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo/App name area
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.home,
                      size: 48,
                      color: AppColors.green400,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Casaly',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.green400,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Shared living made simple',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.green600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              Text(
                'Get started',
                style: AppTypography.h2.copyWith(color: AppColors.cream800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create a new dorm or join an existing one to start coordinating with your housemates.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              CasalyButton(
                text: 'Join Existing Dorm',
                icon: Icons.group_add,
                onPressed: () => context.go('/join-dorm'),
                variant: ButtonVariant.primary,
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              CasalyButton(
                text: 'Create New Dorm',
                icon: Icons.add_home,
                onPressed: () => context.go('/create-dorm'),
                variant: ButtonVariant.outline,
              ),
              
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}