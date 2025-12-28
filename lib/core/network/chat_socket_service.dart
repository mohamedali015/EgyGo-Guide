import 'package:egy_go_guide/core/cache/cache_helper.dart';
import 'package:egy_go_guide/core/cache/cache_key.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Socket.io Service for Trip Chat
/// Handles real-time messaging between guide and tourist
class ChatSocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentTripId;

  bool get isConnected => _isConnected;

  String? get currentTripId => _currentTripId;

  /// Get socket base URL
  String get _socketUrl {
    const baseUrl = 'https://egygo-backend-production.up.railway.app';
    return baseUrl;
  }

  /// Connect to socket server with JWT authentication
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      print('[ChatSocketService - Guide] Already connected');
      return;
    }

    try {
      final token = CacheHelper.getData(key: CacheKeys.accessToken);
      if (token == null) {
        print('[ChatSocketService - Guide] ❌ No auth token found');
        throw Exception('Authentication required');
      }

      print('[ChatSocketService - Guide] 🔌 Connecting to: $_socketUrl');

      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableForceNew()
            .setAuth({'token': token})
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        print('[ChatSocketService - Guide] ✅ Connected - Socket ID: ${_socket!.id}');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        _currentTripId = null;
        print('[ChatSocketService - Guide] ❌ Disconnected from server');
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        print('[ChatSocketService - Guide] ❌ Connection error: $error');
      });

      _socket!.onError((error) {
        print('[ChatSocketService - Guide] ⚠️ Socket error: $error');
      });

      // Wait for connection
      int retries = 0;
      while (!_isConnected && retries < 20) {
        await Future.delayed(Duration(milliseconds: 500));
        retries++;
      }

      if (!_isConnected) {
        throw Exception('Failed to connect to chat server');
      }
    } catch (e) {
      print('[ChatSocketService - Guide] ❌ Failed to initialize socket: $e');
      rethrow;
    }
  }

  /// Join trip chat room
  Future<void> joinTripChat(String tripId) async {
    if (_socket == null || !_isConnected) {
      throw Exception('Socket not connected');
    }

    if (_currentTripId == tripId) {
      print('[ChatSocketService - Guide] ℹ️ Already in chat room: $tripId');
      return;
    }

    // Leave previous room if exists
    if (_currentTripId != null) {
      await leaveTripChat();
    }

    print('[ChatSocketService - Guide] 🚪 Joining trip chat: $tripId');
    _socket!.emit('join_trip_chat', {'tripId': tripId});
    _currentTripId = tripId;

    // Wait a bit for join confirmation
    await Future.delayed(Duration(milliseconds: 500));
  }

  /// Leave trip chat room
  Future<void> leaveTripChat() async {
    if (_socket == null || _currentTripId == null) {
      return;
    }

    print('[ChatSocketService - Guide] 🚪 Leaving trip chat: $_currentTripId');
    _socket!.emit('leave_trip_chat', {'tripId': _currentTripId});
    _currentTripId = null;
  }

  /// Send a message
  void sendMessage(String tripId, String message) {
    if (_socket == null || !_isConnected) {
      throw Exception('Socket not connected');
    }

    print('[ChatSocketService - Guide] 📤 Sending message to trip: $tripId');
    _socket!.emit('send_message', {
      'tripId': tripId,
      'message': message,
    });
  }

  /// Listen for new messages
  void onNewMessage(Function(Map<String, dynamic>) callback) {
    if (_socket == null) return;

    // Remove any existing listeners first to avoid duplicates
    _socket!.off('new_message');

    _socket!.on('new_message', (data) {
      print('[ChatSocketService - Guide] 📨 New message received: $data');
      if (data is Map<String, dynamic>) {
        callback(data);
      }
    });
  }

  /// Listen for chat errors
  void onChatError(Function(String) callback) {
    if (_socket == null) return;

    // Remove any existing listeners first to avoid duplicates
    _socket!.off('chat_error');

    _socket!.on('chat_error', (data) {
      print('[ChatSocketService - Guide] ❌ Chat error: $data');
      final errorMessage =
          data is Map ? data['message'] ?? 'Chat error' : 'Chat error';
      callback(errorMessage.toString());
    });
  }

  /// Disconnect from socket
  Future<void> disconnect() async {
    if (_currentTripId != null) {
      await leaveTripChat();
    }

    if (_socket != null) {
      print('[ChatSocketService - Guide] 🔌 Disconnecting socket');
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }
}
