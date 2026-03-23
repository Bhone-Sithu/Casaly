
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:casaly/app/router.dart';
import 'package:casaly/core/theme/app_theme.dart';
import 'package:casaly/firebase_options.dart';

void main() async {
  print('🚀 DEBUG: App starting up - debug logging is working!');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('🚀 DEBUG: Firebase initialized');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'Casaly',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
