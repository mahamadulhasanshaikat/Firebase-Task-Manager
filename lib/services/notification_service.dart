import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Background notification received: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _highPriorityChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Priority Notifications',
    description: 'Channel for urgent task updates',
    importance: Importance.max,
    playSound: true,
  );

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
    'default_channel',
    'General Notifications',
    description: 'Channel for standard tasks',
    importance: Importance.defaultImportance,
  );

  Future<void> initialize() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _navigateToTaskDetailPage(response.payload!);
        }
      },
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_highPriorityChannel);
    await androidPlugin?.createNotificationChannel(_defaultChannel);

    String? token = await _fcm.getToken();
    debugPrint("================ FCM TOKEN ================");
    debugPrint(token);
    debugPrint("===========================================");

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message received: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    // Background click handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final taskId = message.data['taskId'];
      if (taskId != null) {
        _navigateToTaskDetailPage(taskId);
      }
    });

    // Terminated state handler
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      final taskId = initialMessage.data['taskId'];
      if (taskId != null) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          _navigateToTaskDetailPage(taskId);
        });
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final priority = message.data['priority'] ?? 'medium';
    final taskId = message.data['taskId'] ?? '';

    final channel = (priority == 'high') ? _highPriorityChannel : _defaultChannel;

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: priority == 'high' ? Priority.max : Priority.defaultPriority,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      notification.hashCode,
      notification?.title ?? message.data['title'] ?? 'Task Alert',
      notification?.body ?? message.data['body'] ?? 'You have a new task update.',
      platformDetails,
      payload: taskId,
    );
  }

  void _navigateToTaskDetailPage(String taskId) {
    navigatorKey.currentState?.pushNamed('/task_detail', arguments: taskId);
  }
}