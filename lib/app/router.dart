
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:casaly/features/auth/presentation/providers/auth_providers.dart';
import 'package:casaly/features/auth/presentation/screens/login_screen.dart';
import 'package:casaly/features/auth/presentation/screens/signup_screen.dart';
import 'package:casaly/features/app/presentation/screens/app_router_screen.dart';
import 'package:casaly/features/dorm/presentation/screens/create_dorm_screen.dart';
import 'package:casaly/features/dorm/presentation/screens/dorm_dashboard_screen.dart';
import 'package:casaly/features/app/presentation/screens/main_shell_screen.dart';
import 'package:casaly/features/dorm/presentation/screens/dorm_selection_screen.dart';
import 'package:casaly/features/dorm/presentation/screens/join_dorm_screen.dart';
import 'package:casaly/features/user_profile/presentation/screens/user_profile_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) {
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppRouterScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/create-dorm',
        builder: (context, state) => const CreateDormScreen(),
      ),
      GoRoute(
        path: '/join-dorm',
        builder: (context, state) => const JoinDormScreen(),
      ),
      GoRoute(
        path: '/dorm-selection',
        builder: (context, state) => const DormSelectionScreen(),
      ),
      GoRoute(
        path: '/dorm',
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.asData?.value != null;
      final user = authState.asData?.value;

      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isDormSelection = state.matchedLocation == '/dorm-selection';
      final isDormDashboard = state.matchedLocation == '/dorm';

      print('ROUTER_DEBUG: Path: ${state.matchedLocation}, Auth: $isAuthenticated, User: ${user?.uid}');

      if (!isAuthenticated && !isLoggingIn && !isSigningUp) {
        print('ROUTER_DEBUG: Not authenticated, redirecting to login');
        return '/login';
      }

      if (isAuthenticated && (isLoggingIn || isSigningUp)) {
        print('ROUTER_DEBUG: Authenticated user on auth page, redirecting to dorm selection');
        return '/dorm-selection';
      }

      print('ROUTER_DEBUG: No redirect needed');
      return null;
    },
  );
});
