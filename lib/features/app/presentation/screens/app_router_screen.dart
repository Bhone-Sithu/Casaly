import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';

/// Smart routing screen that checks user's dorm status and routes accordingly
class AppRouterScreen extends ConsumerWidget {
  const AppRouterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          // Not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/login');
          });
          return const _LoadingScreen();
        }

        print('APP_ROUTER_DEBUG: Authenticated user: ${user.uid}');
        
        // User is authenticated, check if they have a dorm
        final userDormAsync = ref.watch(userDormProvider(user.uid));
        
        return userDormAsync.when(
          data: (dorm) {
            print('APP_ROUTER_DEBUG: Dorm check result: ${dorm?.name ?? 'null'}');
            
            if (dorm != null) {
              // User has a dorm, go to dashboard
              print('APP_ROUTER_DEBUG: User has dorm, redirecting to dashboard');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/dorm');
              });
            } else {
              // User has no dorm, go to dorm selection
              print('APP_ROUTER_DEBUG: User has no dorm, redirecting to dorm selection');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/dorm-selection');
              });
            }
            
            return const _LoadingScreen();
          },
          loading: () {
            print('APP_ROUTER_DEBUG: Loading dorm information...');
            return const _LoadingScreen();
          },
          error: (error, stack) {
            print('APP_ROUTER_DEBUG: Error loading dorm: $error');
            // On error, default to dorm selection
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/dorm-selection');
            });
            return const _LoadingScreen();
          },
        );
      },
      loading: () {
        print('APP_ROUTER_DEBUG: Loading authentication state...');
        return const _LoadingScreen();
      },
      error: (error, stack) {
        print('APP_ROUTER_DEBUG: Auth error: $error');
        // On auth error, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/login');
        });
        return const _LoadingScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cream50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.green400,
            ),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: AppColors.green400,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}