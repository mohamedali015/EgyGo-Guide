import 'package:egy_go_guide/core/cache/cache_helper.dart';
import 'package:egy_go_guide/core/cache/cache_key.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Socket.io Service for real-time trip status updates (Guide App)
/// STRICTLY follows backend contract - DO NOT modify events or room names
/// NOT a singleton - creates fresh instances for each screen
class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentTripId;
  bool _isJoinedToRoom = false;

  bool get isConnected => _isConnected;
  String? get currentTripId => _currentTripId;
  bool get isJoinedToRoom => _isJoinedToRoom;

  /// Get socket base URL from API base URL
  String get _socketUrl {
    const baseUrl = 'https://1p1jgw5z-5001.euw.devtunnels.ms';
    return baseUrl;
  }

  /// Initialize socket connection with JWT auth
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      print('[SocketService - Guide] Already connected');
      return;
    }

    try {
      final token = CacheHelper.getData(key: CacheKeys.accessToken);
      if (token == null) {
        print('[SocketService - Guide] ❌ No auth token found');
        return;
      }

      print('[SocketService - Guide] 🔌 Connecting to: $_socketUrl');
      print('[SocketService - Guide] 🔑 Using token: ${token.toString().substring(0, 20)}...');

      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .enableForceNew()
            .setAuth({
              'token': token,
            })
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        print('[SocketService - Guide] ✅ Connected successfully - Socket ID: ${_socket!.id}');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        _currentTripId = null;
        _isJoinedToRoom = false;
        print('[SocketService - Guide] ❌ Disconnected from server');
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        print('[SocketService - Guide] ❌ Connection error: $error');
      });

      _socket!.onError((error) {
        print('[SocketService - Guide] ⚠️ Socket error: $error');
      });

      // Add debug listeners for all events
      _socket!.onAny((event, data) {
        print('[SocketService - Guide] 📡 Event received: $event with data: $data');
      });

      // Listen for room join confirmation
      _socket!.on('trip_room_joined', (data) {
        print('[SocketService - Guide] ✅ Room join confirmed: $data');
        _isJoinedToRoom = true;
      });

      _socket!.on('trip_room_left', (data) {
        print('[SocketService - Guide] ✅ Room leave confirmed: $data');
        _isJoinedToRoom = false;
      });

      // Add listeners for all possible status update event variations
      _socket!.on('tripStatusUpdated', (data) {
        print('[SocketService - Guide] 🔔 Received tripStatusUpdated (camelCase): $data');
      });

      _socket!.on('status_updated', (data) {
        print('[SocketService - Guide] 🔔 Received status_updated: $data');
      });

      _socket!.on('trip_updated', (data) {
        print('[SocketService - Guide] 🔔 Received trip_updated: $data');
      });

      _socket!.on('error', (data) {
        print('[SocketService - Guide] ❌ Error event: $data');
      });

      _socket!.on('message', (data) {
        print('[SocketService - Guide] 📨 Message event: $data');
      });
    } catch (e) {
      print('[SocketService - Guide] ❌ Failed to initialize socket: $e');
    }
  }

  /// Join trip room after successful connection
  /// Room identifier: "trip:{tripId}" - DO NOT change this format
  Future<void> joinTripRoom(String tripId) async {
    if (_socket == null) {
      print('[SocketService - Guide] ❌ Cannot join room - socket not initialized');
      return;
    }

    // Wait for connection to be established
    int retries = 0;
    while (!_isConnected && retries < 20) {
      print('[SocketService - Guide] ⏳ Waiting for connection... (${retries + 1}/20)');
      await Future.delayed(Duration(milliseconds: 500));
      retries++;
    }

    if (!_isConnected) {
      print('[SocketService - Guide] ❌ Cannot join room - not connected after waiting');
      return;
    }

    if (_currentTripId == tripId) {
      print('[SocketService - Guide] ℹ️ Already in trip room: $tripId');
      return;
    }

    // Leave previous room if exists
    if (_currentTripId != null) {
      await leaveTripRoom();
    }

    final roomId = 'trip:$tripId';
    print('[SocketService - Guide] 🚪 Joining room: $roomId');
    print('[SocketService - Guide] 📤 Emitting join_trip_room event with tripId: $tripId');
    print('[SocketService - Guide] 📤 Socket ID: ${_socket!.id}');

    _socket!.emit('join_trip_room', {'tripId': tripId});
    _currentTripId = tripId;
    _isJoinedToRoom = false; // Will be set to true when confirmation arrives

    // Wait a bit for join confirmation
    await Future.delayed(Duration(milliseconds: 1000));

    print('[SocketService - Guide] ✅ Room join request sent for: $roomId');
    print('[SocketService - Guide] ℹ️ Join confirmed: $_isJoinedToRoom');
  }

  /// Leave trip room before socket disconnect
  Future<void> leaveTripRoom() async {
    if (_socket == null || _currentTripId == null) {
      return;
    }

    print('[SocketService - Guide] 🚪 Leaving room: trip:$_currentTripId');
    _socket!.emit('leave_trip_room', {'tripId': _currentTripId});
    _currentTripId = null;
    _isJoinedToRoom = false;
  }

  /// Listen to trip_status_updated event
  /// Payload: {tripId: string, status: string, timestamp: string}
  void onTripStatusUpdated(Function(Map<String, dynamic>) callback) {
    if (_socket == null) {
      print('[SocketService - Guide] ❌ Cannot listen - socket not initialized');
      return;
    }

    print('[SocketService - Guide] 👂 Setting up listener for trip_status_updated');

    // Remove any existing listeners first to avoid duplicates
    _socket!.off('trip_status_updated');

    _socket!.on('trip_status_updated', (data) {
      print('[SocketService - Guide] 🔔🔔🔔 RECEIVED trip_status_updated EVENT! 🔔🔔🔔');
      print('[SocketService - Guide] 📦 Raw data: $data');
      print('[SocketService - Guide] 📦 Data type: ${data.runtimeType}');

      try {
        if (data is Map<String, dynamic>) {
          print('[SocketService - Guide] ✅ Valid data format - calling callback');
          print('[SocketService - Guide] 📋 TripId: ${data['tripId']}');
          print('[SocketService - Guide] 📋 Status: ${data['status']}');
          callback(data);
        } else if (data is List && data.isNotEmpty) {
          print('[SocketService - Guide] ✅ Data is list - extracting first element');
          final firstElement = data[0];
          if (firstElement is Map<String, dynamic>) {
            print('[SocketService - Guide] 📋 TripId: ${firstElement['tripId']}');
            print('[SocketService - Guide] 📋 Status: ${firstElement['status']}');
            callback(firstElement);
          } else {
            print('[SocketService - Guide] ⚠️ First element is not a Map: ${firstElement.runtimeType}');
          }
        } else {
          print('[SocketService - Guide] ⚠️ Invalid data format: $data');
        }
      } catch (e) {
        print('[SocketService - Guide] ❌ Error processing event: $e');
      }
    });

    print('[SocketService - Guide] ✅ Listener registered successfully');
  }

  /// Remove listener for trip_status_updated
  void offTripStatusUpdated() {
    _socket?.off('trip_status_updated');
  }

  /// Disconnect socket immediately when screen is disposed
  void disconnect() {
    if (_socket == null) {
      return;
    }

    print('[SocketService - Guide] Disconnecting socket');

    // Leave room before disconnect
    if (_currentTripId != null) {
      leaveTripRoom();
    }

    _socket!.disconnect();
    _socket!.dispose();
    _socket = null;
    _isConnected = false;
    _currentTripId = null;
    _isJoinedToRoom = false;
  }
}

// DONE: Socket integration
