import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../features/home/views/app_home_view.dart';
import '../../features/trip/views/trip_chat_screen.dart';
import '../../features/trip/views/trip_details_screen.dart';
import '../cache/cache_helper.dart';
import '../cache/cache_key.dart';
import '../network/api_helper.dart';
import '../network/end_points.dart';
import '../helper/get_it.dart';

/// Notification Service for Firebase Push Notifications
/// Handles foreground, background, and terminated app states
/// Routes notifications to appropriate screens based on type
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[NotificationService] Already initialized');
      return;
    }

    try {
      // Request notification permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('[NotificationService] ✅ Notification permission granted');
      } else {
        print('[NotificationService] ❌ Notification permission denied');
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('[NotificationService] 🔑 FCM Token: $_fcmToken');

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('[NotificationService] 🔄 Token refreshed: $newToken');
        _fcmToken = newToken;
        // Auto-register new token if user is logged in
        _autoRegisterToken();
      });

      // Set foreground notification options (iOS)
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      _isInitialized = true;
      print('[NotificationService] ✅ Initialized successfully');
    } catch (e) {
      print('[NotificationService] ❌ Initialization error: $e');
    }
  }

  /// Initialize Flutter Local Notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'egygo_guide_channel',
      'EgyGo Guide Notifications',
      description: 'Notifications for trip updates and messages',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Setup message handlers for different app states
  void setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/Terminated - notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Handle foreground messages - show local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('[NotificationService] 📨 Foreground message received');
    print('[NotificationService] Title: ${message.notification?.title}');
    print('[NotificationService] Body: ${message.notification?.body}');
    print('[NotificationService] Data: ${message.data}');

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'egygo_guide_channel',
      'EgyGo Guide Notifications',
      channelDescription: 'Notifications for trip updates and messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'EgyGo Guide',
      message.notification?.body ?? '',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap from background/terminated state
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('[NotificationService] 👆 Notification tapped (background/terminated)');
    print('[NotificationService] Data: ${message.data}');

    await _navigateBasedOnNotificationType(message.data);
  }

  /// Handle notification tap from local notification
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    print('[NotificationService] 👆 Local notification tapped');

    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        print('[NotificationService] Payload data: $data');
        await _navigateBasedOnNotificationType(data);
      } catch (e) {
        print('[NotificationService] ❌ Error parsing payload: $e');
      }
    }
  }

  /// Navigate to appropriate screen based on notification type
  Future<void> _navigateBasedOnNotificationType(Map<String, dynamic> data) async {
    final String? type = data['type'];
    final String? notificationId = data['notificationId'];

    if (type == null) {
      print('[NotificationService] ⚠️ No notification type provided');
      return;
    }

    print('[NotificationService] 🧭 Navigating for type: $type, ID: $notificationId');

    // Wait a bit to ensure the app is ready
    await Future.delayed(const Duration(milliseconds: 500));

    switch (type) {
      case 'guide_selected':
        // Navigate to Trips Screen (Bottom Navigation - Trips Tab)
        _navigateToTripsScreen();
        break;

      case 'trip_pending_confirmation':
        // Navigate to Trip Details Screen
        if (notificationId != null) {
          _navigateToTripDetails(notificationId);
        } else {
          print('[NotificationService] ⚠️ No tripId for trip_pending_confirmation');
        }
        break;

      case 'NEW_MESSAGE':
        // Navigate to Chat Screen
        if (notificationId != null) {
          _navigateToChatScreen(notificationId);
        } else {
          print('[NotificationService] ⚠️ No chatId for NEW_MESSAGE');
        }
        break;

      default:
        print('[NotificationService] ⚠️ Unknown notification type: $type');
        break;
    }
  }

  /// Navigate to Trips Screen (Bottom Navigation - index 1)
  void _navigateToTripsScreen() {
    print('[NotificationService] → Navigating to Trips Screen');
    Get.offAll(
      () => const AppHomeView(initialIndex: 1),
      transition: Transition.fadeIn,
    );
  }

  /// Navigate to Trip Details Screen
  void _navigateToTripDetails(String tripId) {
    print('[NotificationService] → Navigating to Trip Details: $tripId');
    Get.to(
      () => TripDetailsScreen(tripId: tripId),
      transition: Transition.rightToLeft,
    );
  }

  /// Navigate to Chat Screen
  void _navigateToChatScreen(String chatId) {
    print('[NotificationService] → Navigating to Chat Screen: $chatId');
    Get.to(
      () => TripChatScreen(
        tripId: chatId,
        touristName: 'Tourist',
      ),
      transition: Transition.rightToLeft,
    );
  }

  /// Check for initial notification when app starts from terminated state
  Future<void> checkInitialNotification() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      print('[NotificationService] 🚀 App opened from terminated state via notification');
      print('[NotificationService] Data: ${initialMessage.data}');

      await Future.delayed(const Duration(seconds: 2));
      await _handleNotificationTap(initialMessage);
    }
  }

  /// Register FCM token with backend (call after login)
  Future<bool> registerToken() async {
    // Wait for token if not available yet
    int retries = 0;
    while (_fcmToken == null && retries < 10) {
      print('[NotificationService] ⏳ Waiting for FCM token... (${retries + 1}/10)');
      await Future.delayed(const Duration(milliseconds: 500));
      retries++;
    }

    if (_fcmToken == null) {
      print('[NotificationService] ❌ FCM token not available after waiting');
      return false;
    }

    try {
      print('[NotificationService] 📤 Attempting to register FCM token');
      print('[NotificationService] Token: ${_fcmToken!.substring(0, 50)}...');

      final apiHelper = getIt<ApiHelper>();

      // Check if we have auth token
      final authToken = CacheHelper.getData(key: CacheKeys.accessToken);
      if (authToken == null) {
        print('[NotificationService] ❌ No auth token found in cache');
        return false;
      }
      print('[NotificationService] ✅ Auth token found: ${authToken.toString().substring(0, 20)}...');

      final response = await apiHelper.postRequest(
        endPoint: EndPoints.registerFcmToken,
        data: {'token': _fcmToken},
        isProtected: true,
      );

      print('[NotificationService] Response status: ${response.success}');
      print('[NotificationService] Response message: ${response.message}');

      if (response.success) {
        print('[NotificationService] ✅ FCM token registered with backend');
        return true;
      } else {
        print('[NotificationService] ❌ Failed to register token');
        print('[NotificationService] Error: ${response.message}');
        print('[NotificationService] Data: ${response.data}');
        return false;
      }
    } catch (e, stackTrace) {
      print('[NotificationService] ❌ Exception during token registration: $e');
      print('[NotificationService] Stack trace: $stackTrace');
      return false;
    }
  }

  /// Remove FCM token from backend (call on logout)
  Future<bool> removeToken() async {
    if (_fcmToken == null) {
      print('[NotificationService] ⚠️ No token to remove');
      return true;
    }

    try {
      print('[NotificationService] 🗑️ Removing FCM token from backend');
      final apiHelper = getIt<ApiHelper>();
      final response = await apiHelper.deleteRequest(
        endPoint: EndPoints.removeFcmToken,
        data: {'token': _fcmToken},
        isFormData: false,  // Send as JSON, not FormData
        isProtected: true,  // CRITICAL: Must be true to send auth token
      );

      if (response.success) {
        print('[NotificationService] ✅ FCM token removed from backend');
        return true;
      } else {
        print('[NotificationService] ❌ Failed to remove token: ${response.message}');
        return false;
      }
    } catch (e) {
      print('[NotificationService] ❌ Error removing token: $e');
      return false;
    }
  }

  /// Auto-register token if user is logged in
  Future<void> _autoRegisterToken() async {
    final token = CacheHelper.getData(key: CacheKeys.accessToken);
    if (token != null) {
      await registerToken();
    }
  }

  /// Delete FCM token from device
  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    _fcmToken = null;
    print('[NotificationService] 🗑️ FCM token deleted from device');
  }
}
