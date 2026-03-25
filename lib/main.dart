
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:casaly/app/router.dart';
import 'package:casaly/core/theme/app_theme.dart';
import 'package:casaly/core/services/notification_service.dart';
import 'package:casaly/core/providers/notification_providers.dart';
import 'package:casaly/firebase_options.dart';

void main() async {
  print('DEBUG: App starting up - debug logging is working!');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  print('DEBUG: Firebase and FCM initialized');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    // Initialize notifications
    ref.watch(notificationInitProvider);
    // Boot push notifications (token sync + dorm topic subscriptions)
    ref.watch(pushNotificationsBootstrapProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      title: 'Casaly',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
