import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/dorm/presentation/providers/dorm_providers.dart';
import '../../features/user_profile/presentation/providers/user_profile_providers.dart';
import '../services/notification_service.dart';

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for initializing notifications
final notificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(notificationServiceProvider);
  await service.initialize();
});

/// Provider for FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return await service.getToken();
});

/// Provider for subscribing to dorm notifications
final dormNotificationSubscriptionProvider = Provider.family<void, String>((ref, dormId) {
  final service = ref.read(notificationServiceProvider);
  service.subscribeToDorm(dormId);
  
  // Cleanup subscription when provider is disposed
  ref.onDispose(() {
    service.unsubscribeFromDorm(dormId);
  });
  
  return;
});

/// Boots push notifications: token sync + dorm topic subscription.
///
/// Watch this once near the app root (e.g. in `MyApp`) to enable push behavior.
final pushNotificationsBootstrapProvider = Provider<void>((ref) {
  // Ensure permission + listeners are set up.
  ref.watch(notificationInitProvider);

  final auth = FirebaseAuth.instance;
  final notificationService = ref.read(notificationServiceProvider);

  String? lastDormId;
  String? lastSavedToken;

  Future<void> syncToken() async {
    final user = auth.currentUser;
    if (user == null) return;

    final token = await notificationService.getToken();
    if (token == lastSavedToken) return;

    lastSavedToken = token;
    ref.read(
      updateFcmTokenProvider(
        UpdateFcmTokenParams(uid: user.uid, fcmToken: token),
      ),
    );
  }

  // Sync token once when this provider is first created.
  // (Also handled on refresh below.)
  syncToken();

  // Keep Firestore token updated.
  final tokenSub = notificationService.onTokenRefresh.listen((token) {
    final user = auth.currentUser;
    if (user == null) return;
    if (token == lastSavedToken) return;
    lastSavedToken = token;
    ref.read(
      updateFcmTokenProvider(
        UpdateFcmTokenParams(uid: user.uid, fcmToken: token),
      ),
    );
  });

  // Subscribe/unsubscribe to dorm topics based on current dorm.
  ref.listen(currentUserDormProvider, (previous, next) {
    final dorm = next.asData?.value;
    final newDormId = dorm?.id;

    if (lastDormId == newDormId) return;

    if (lastDormId != null) {
      notificationService.unsubscribeFromDorm(lastDormId!);
    }
    if (newDormId != null) {
      notificationService.subscribeToDorm(newDormId);
    }

    lastDormId = newDormId;
  });

  // On dispose, clean up listener and subscriptions.
  ref.onDispose(() async {
    await tokenSub.cancel();
    if (lastDormId != null) {
      await notificationService.unsubscribeFromDorm(lastDormId!);
    }
  });
});