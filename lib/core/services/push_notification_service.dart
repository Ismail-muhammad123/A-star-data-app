import 'dart:convert';
import 'package:app/core/app_router.dart';
import 'package:app/core/constants/notification_channels.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await PushNotificationService.instance.showLocalNotification(message);
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize({
    required void Function(RemoteMessage message) onForegroundMessage,
    required void Function(RemoteMessage message) onMessageOpenedApp,
    required Future<void> Function(String token) onTokenRefresh,
  }) async {
    if (!_isInitialized) {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Initialize Local Notifications
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            try {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              _handlePayloadRouting(data);
            } catch (e) {
              debugPrint("PushNotificationService: Error parsing payload: $e");
              router.push('/notifications');
            }
          }
        },
      );

      // Create Android Channels
      await _createNotificationChannels();

      // Firebase configurations
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((message) {
        showLocalNotification(message);
        onForegroundMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleRemoteMessageRouting(message);
        onMessageOpenedApp(message);
      });

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        onTokenRefresh(token);
      });

      _isInitialized = true;
    }

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessageRouting(initialMessage);
      onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _createNotificationChannels() async {
    final List<AndroidNotificationChannel> channels = [
      const AndroidNotificationChannel(
        NotificationChannels.generalId,
        NotificationChannels.generalName,
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        NotificationChannels.transactionId,
        NotificationChannels.transactionName,
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        NotificationChannels.supportId,
        NotificationChannels.supportName,
        importance: Importance.max,
      ),
      const AndroidNotificationChannel(
        NotificationChannels.walletId,
        NotificationChannels.walletName,
        importance: Importance.max,
      ),
    ];

    for (var channel in channels) {
      await _localPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final channel = message.data['channel']?.toString();
    final channelId = NotificationChannels.channelIdForChannel(channel);

    await _localPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          NotificationChannels.generalName, // Fallback name if needed
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleRemoteMessageRouting(RemoteMessage message) {
    _handlePayloadRouting(message.data);
  }

  void _handlePayloadRouting(Map<String, dynamic> data) {
    final channel = data['channel']?.toString();
    final id = data['id']?.toString();
    final route = NotificationChannels.routeForChannel(channel, extraId: id);

    if (route != null) {
      router.push(route);
    } else {
      router.push('/notifications');
    }
  }

  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint("PushNotificationService: Failed to get FCM token: $e");
      return null;
    }
  }
}
