import 'package:egy_go_guide/core/cache/cache_helper.dart';
import 'package:egy_go_guide/core/cache/cache_key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../features/home/views/app_home_view.dart';
import '../../features/trip/views/trip_chat_screen.dart';
import '../../features/trip/views/trip_details_screen.dart';

/// Global Socket Service for Guide Notifications
/// Listens for guide_selected and new_message events
/// Handles in-app navigation when app is open (complementary to Firebase)
class GlobalSocketService {
  static final GlobalSocketService _instance = GlobalSocketService._internal();
  factory GlobalSocketService() => _instance;
  GlobalSocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isInitialized = false;

  bool get isConnected => _isConnected;

  /// Get socket base URL
  String get _socketUrl {
    const baseUrl = 'https://egygo-backend-production.up.railway.app';
    return baseUrl;
  }

  /// Initialize and connect to socket server
  Future<void> initialize() async {
    if (_isInitialized) {
      print('[GlobalSocketService] Already initialized');
      return;
    }

    try {
      final token = CacheHelper.getData(key: CacheKeys.accessToken);
      if (token == null) {
        print('[GlobalSocketService] ⚠️ No auth token - skipping socket initialization');
        return;
      }

      print('[GlobalSocketService] 🔌 Initializing global socket connection');

      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setAuth({'token': token})
            .build(),
      );

      _setupListeners();
      _isInitialized = true;

      print('[GlobalSocketService] ✅ Initialized successfully');
    } catch (e) {
      print('[GlobalSocketService] ❌ Initialization error: $e');
    }
  }

  /// Setup all socket listeners
  void _setupListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      print('[GlobalSocketService] ✅ Connected - Socket ID: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('[GlobalSocketService] ❌ Disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      print('[GlobalSocketService] ❌ Connection error: $error');
    });

    // Listen for guide selection event
    _socket!.on('guide_selected', (data) {
      print('[GlobalSocketService] 🎉 GUIDE SELECTED EVENT RECEIVED!');
      print('[GlobalSocketService] Data: $data');
      _handleGuideSelected(data);
    });

    // Listen for new message event
    _socket!.on('new_message', (data) {
      print('[GlobalSocketService] 💬 NEW MESSAGE EVENT RECEIVED!');
      print('[GlobalSocketService] Data: $data');
      _handleNewMessage(data);
    });

    // Listen for trip status update
    _socket!.on('trip_status_updated', (data) {
      print('[GlobalSocketService] 📋 TRIP STATUS UPDATED EVENT!');
      print('[GlobalSocketService] Data: $data');
      _handleTripStatusUpdate(data);
    });

    // Debug: Log all events
    _socket!.onAny((event, data) {
      print('[GlobalSocketService] 📡 Event: $event | Data: $data');
    });
  }

  /// Handle guide selected event
  void _handleGuideSelected(dynamic data) {
    try {
      Map<String, dynamic> eventData;

      if (data is List && data.isNotEmpty) {
        eventData = data[0] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        eventData = data;
      } else {
        print('[GlobalSocketService] ⚠️ Invalid data format for guide_selected');
        return;
      }

      final tripId = eventData['tripId'] ?? eventData['notificationId'];

      if (tripId != null) {
        print('[GlobalSocketService] 🧭 Navigating to Trips Screen for trip: $tripId');

        // Show in-app notification
        Get.snackbar(
          '🎉 New Trip Assigned!',
          'You have been selected as a guide',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          onTap: (_) => _navigateToTripsScreen(),
        );

        // Auto-navigate after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          _navigateToTripsScreen();
        });
      }
    } catch (e) {
      print('[GlobalSocketService] ❌ Error handling guide_selected: $e');
    }
  }

  /// Handle new message event
  void _handleNewMessage(dynamic data) {
    try {
      Map<String, dynamic> eventData;

      if (data is List && data.isNotEmpty) {
        eventData = data[0] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        eventData = data;
      } else {
        print('[GlobalSocketService] ⚠️ Invalid data format for new_message');
        return;
      }

      final tripId = eventData['tripId'] ?? eventData['chatId'];
      final message = eventData['message'] ?? eventData['content'] ?? 'New message';
      final senderName = eventData['senderName'] ?? eventData['touristName'] ?? 'Tourist';

      if (tripId != null) {
        print('[GlobalSocketService] 💬 New message from $senderName in trip: $tripId');

        // Show in-app notification
        Get.snackbar(
          '💬 New message from $senderName',
          message.toString().length > 50
            ? '${message.toString().substring(0, 47)}...'
            : message.toString(),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          onTap: (_) => _navigateToChatScreen(tripId, senderName),
        );
      }
    } catch (e) {
      print('[GlobalSocketService] ❌ Error handling new_message: $e');
    }
  }

  /// Handle trip status update event
  void _handleTripStatusUpdate(dynamic data) {
    try {
      Map<String, dynamic> eventData;

      if (data is List && data.isNotEmpty) {
        eventData = data[0] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        eventData = data;
      } else {
        print('[GlobalSocketService] ⚠️ Invalid data format for trip_status_updated');
        return;
      }

      final tripId = eventData['tripId'] ?? eventData['notificationId'];
      final status = eventData['status'] ?? 'updated';

      if (tripId != null) {
        print('[GlobalSocketService] 📋 Trip $tripId status: $status');

        // Show in-app notification
        Get.snackbar(
          '📋 Trip Status Updated',
          'Trip status: $status',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          onTap: (_) => _navigateToTripDetails(tripId),
        );
      }
    } catch (e) {
      print('[GlobalSocketService] ❌ Error handling trip_status_updated: $e');
    }
  }

  /// Navigate to Trips Screen
  void _navigateToTripsScreen() {
    print('[GlobalSocketService] → Navigating to Trips Screen');
    Get.offAll(
      () => const AppHomeView(initialIndex: 1),
      transition: Transition.fadeIn,
    );
  }

  /// Navigate to Trip Details
  void _navigateToTripDetails(String tripId) {
    print('[GlobalSocketService] → Navigating to Trip Details: $tripId');
    Get.to(
      () => TripDetailsScreen(tripId: tripId),
      transition: Transition.rightToLeft,
    );
  }

  /// Navigate to Chat Screen
  void _navigateToChatScreen(String tripId, String touristName) {
    print('[GlobalSocketService] → Navigating to Chat: $tripId');
    Get.to(
      () => TripChatScreen(
        tripId: tripId,
        touristName: touristName,
      ),
      transition: Transition.rightToLeft,
    );
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket != null) {
      print('[GlobalSocketService] Disconnecting...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _isInitialized = false;
    }
  }

  /// Reconnect with new token (e.g., after login)
  Future<void> reconnect() async {
    disconnect();
    _isInitialized = false;
    await initialize();
  }
}
