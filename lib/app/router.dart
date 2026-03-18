
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:myapp/features/auth/presentation/screens/login_screen.dart';
import 'package:myapp/features/auth/presentation/screens/signup_screen.dart';
import 'package:myapp/features/home/presentation/home_screen.dart';
import 'package:myapp/features/laundry/presentation/screens/laundry_screen.dart';

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
        builder: (context, state) => const HomeScreen(),
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
        path: '/laundry',
        builder: (context, state) => const LaundryScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.asData?.value != null;

      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';

      if (!isAuthenticated && !isLoggingIn && !isSigningUp) {
        return '/login';
      }

      if (isAuthenticated && (isLoggingIn || isSigningUp)) {
        return '/';
      }

      return null;
    },
  );
});
