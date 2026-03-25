import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'casaly_default',
    'Casaly notifications',
    description: 'General notifications from Casaly',
    importance: Importance.high,
  );

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted notification permissions');
      } else {
        log('User declined or has not accepted notification permissions');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // iOS: allow showing notifications while app is foregrounded
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Configure FCM
      await _configureFCM();

      _isInitialized = true;
      log('NotificationService initialized successfully');
    } catch (e) {
      log('Error initializing NotificationService: $e');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Handle foreground messages by showing a local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotificationTap);

    // Check for notification that opened the app from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundNotificationTap(initialMessage);
    }
  }

  /// Handle foreground notifications by showing local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Received foreground message: ${message.messageId}');
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  /// Handle notification tap from local notifications
  void _handleNotificationTap(NotificationResponse response) {
    log('Local notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on notification type
  }

  /// Handle notification tap from background FCM
  void _handleBackgroundNotificationTap(RemoteMessage message) {
    log('Background notification tapped: ${message.messageId}');
    // TODO: Navigate to appropriate screen based on notification type
  }

  /// Get FCM token for this device
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  /// Stream of token refresh events
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  /// Subscribe to a topic for receiving notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Subscribe to dorm-specific notifications
  Future<void> subscribeToDorm(String dormId) async {
    await subscribeToTopic('dorm_$dormId');
    await subscribeToTopic('dorm_${dormId}_chat');
    await subscribeToTopic('dorm_${dormId}_laundry');
    await subscribeToTopic('dorm_${dormId}_cleaning');
  }

  /// Unsubscribe from dorm-specific notifications
  Future<void> unsubscribeFromDorm(String dormId) async {
    await unsubscribeFromTopic('dorm_$dormId');
    await unsubscribeFromTopic('dorm_${dormId}_chat');
    await unsubscribeFromTopic('dorm_${dormId}_laundry');
    await unsubscribeFromTopic('dorm_${dormId}_cleaning');
  }

  /// Send notification to specific topic (server-side function)
  static Map<String, dynamic> createChatNotification({
    required String dormId,
    required String senderName,
    required String message,
  }) {
    return {
      'topic': 'dorm_${dormId}_chat',
      'notification': {
        'title': 'New message from $senderName',
        'body': message.length > 50 ? '${message.substring(0, 50)}...' : message,
      },
      'data': {
        'type': 'chat',
        'dormId': dormId,
        'senderName': senderName,
      },
    };
  }

  /// Create laundry notification data
  static Map<String, dynamic> createLaundryNotification({
    required String dormId,
    required String type, // 'started', 'finished', 'collected'
    required String machineName,
    required String userName,
  }) {
    String title;
    String body;

    switch (type) {
      case 'started':
        title = 'Washing machine started';
        body = '$userName started $machineName';
        break;
      case 'finished':
        title = 'Washing machine finished';
        body = '$machineName cycle completed - ready for collection';
        break;
      case 'collected':
        title = 'Machine available';
        body = '$userName collected from $machineName - machine is now available';
        break;
      default:
        title = 'Laundry update';
        body = 'Laundry status changed';
    }

    return {
      'topic': 'dorm_${dormId}_laundry',
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        'type': 'laundry',
        'laundryType': type,
        'dormId': dormId,
        'machineName': machineName,
        'userName': userName,
      },
    };
  }

  /// Create cleaning notification data
  static Map<String, dynamic> createCleaningNotification({
    required String dormId,
    required String type, // 'assigned', 'reminder', 'completed'
    required String message,
    String? groupName,
    String? weekDate,
  }) {
    String title;

    switch (type) {
      case 'assigned':
        title = 'New cleaning assignment';
        break;
      case 'reminder':
        title = 'Cleaning reminder';
        break;
      case 'completed':
        title = 'Cleaning completed';
        break;
      default:
        title = 'Cleaning update';
    }

    return {
      'topic': 'dorm_${dormId}_cleaning',
      'notification': {
        'title': title,
        'body': message,
      },
      'data': {
        'type': 'cleaning',
        'cleaningType': type,
        'dormId': dormId,
        'groupName': groupName,
        'weekDate': weekDate,
      },
    };
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');
}