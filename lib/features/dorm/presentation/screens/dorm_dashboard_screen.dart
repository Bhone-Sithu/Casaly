import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/casaly_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../user_profile/presentation/widgets/settings_drawer.dart';
import '../providers/dorm_providers.dart';

class DormDashboardScreen extends ConsumerWidget {
  const DormDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          // User not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Watch user's dorm
        print('DASHBOARD_DEBUG: Watching dorm for user: ${user.uid}');
        final userDormAsync = ref.watch(userDormProvider(user.uid));
        
        return userDormAsync.when(
          data: (dorm) {
            print('DASHBOARD_DEBUG: Dorm data received: ${dorm?.name ?? 'null'}');
            if (dorm == null) {
              print('DASHBOARD_DEBUG: No dorm found, redirecting to dorm selection');
              // User has no dorm, redirect to dorm selection
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/dorm-selection');
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // User has a dorm, show dashboard
            return Scaffold(
              backgroundColor: AppColors.cream50,
              appBar: AppBar(
                title: Text(
                  dorm.name,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.green400,
                  ),
                ),
                backgroundColor: AppColors.cream50,
                elevation: 0,
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.settings, color: AppColors.green400),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              ),
              endDrawer: const SettingsDrawer(),
              body: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Dorm info card
                    Card(
                      color: AppColors.green50,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.home,
                              size: 48,
                              color: AppColors.green400,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Welcome to ${dorm.name}!',
                              style: AppTypography.h2.copyWith(
                                color: AppColors.green400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Invite Code: ',
                                  style: AppTypography.bodyLg.copyWith(
                                    color: AppColors.green600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.cream100,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    border: Border.all(
                                      color: AppColors.green200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        dorm.inviteCode,
                                        style: AppTypography.bodyLg.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.green600,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      GestureDetector(
                                        onTap: () => _copyInviteCode(context, dorm.inviteCode),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: AppColors.green400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${dorm.memberCount} member${dorm.memberCount == 1 ? '' : 's'}',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.green600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xxxl),
                    
                    // Quick actions
                    Text(
                      'Quick Actions',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.green400,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.cleaning_services, color: AppColors.green400),
                        title: Text('Cleaning Schedule', style: AppTypography.bodyLg),
                        subtitle: Text('Coming soon', style: AppTypography.bodyMd),
                        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.cream400),
                        onTap: () {
                          // TODO: Navigate to cleaning schedule
                        },
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_laundry_service, color: AppColors.green400),
                        title: Text('Laundry Management', style: AppTypography.bodyLg),
                        subtitle: Text('Coming soon', style: AppTypography.bodyMd),
                        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.cream400),
                        onTap: () {
                          // TODO: Navigate to laundry management
                        },
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.people, color: AppColors.green400),
                        title: Text('Dorm Members', style: AppTypography.bodyLg),
                        subtitle: Text('View and manage members', style: AppTypography.bodyMd),
                        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.cream400),
                        onTap: () {
                          // TODO: Navigate to member management
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Scaffold(
            backgroundColor: AppColors.cream50,
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            backgroundColor: AppColors.cream50,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Error loading dorm',
                    style: AppTypography.h3.copyWith(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    error.toString(),
                    style: AppTypography.bodyMd,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CasalyButton(
                    text: 'Go to Dorm Selection',
                    onPressed: () => context.go('/dorm-selection'),
                    variant: ButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.cream50,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.cream50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Authentication Error',
                style: AppTypography.h3.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.lg),
              CasalyButton(
                text: 'Go to Login',
                onPressed: () => context.go('/login'),
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaveDormDialog(BuildContext context, WidgetRef ref, String dormId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Dorm', style: AppTypography.h3),
        content: Text(
          'Are you sure you want to leave this dorm? You\'ll need an invite code to rejoin.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await ref.read(dormRepositoryProvider).leaveDorm(dormId);
              
              result.fold(
                (failure) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to leave dorm: ${failure.message}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                (_) {
                  if (context.mounted) {
                    context.go('/dorm-selection');
                  }
                },
              );
            },
            child: Text(
              'Leave',
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _copyInviteCode(BuildContext context, String inviteCode) async {
    try {
      await Clipboard.setData(ClipboardData(text: inviteCode));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Invite code copied to clipboard!',
                  style: AppTypography.bodyMd.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.green400,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to copy invite code',
              style: AppTypography.bodyMd.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}