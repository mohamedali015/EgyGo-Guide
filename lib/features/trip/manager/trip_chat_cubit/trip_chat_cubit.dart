import 'package:egy_go_guide/core/network/chat_socket_service.dart';
import 'package:egy_go_guide/features/trip/data/models/chat_message_model.dart';
import 'package:egy_go_guide/features/trip/data/repos/chat_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_chat_state.dart';

class TripChatCubit extends Cubit<TripChatState> {
  TripChatCubit(this.chatRepo) : super(TripChatInitial());

  final ChatRepo chatRepo;
  final ChatSocketService _chatSocketService = ChatSocketService();

  List<ChatMessageModel> _messages = [];
  String? _currentTripId;

  List<ChatMessageModel> get messages => _messages;
  bool get isSocketConnected => _chatSocketService.isConnected;

  /// Initialize chat for a trip
  Future<void> initializeChat(String tripId) async {
    _currentTripId = tripId;
    emit(TripChatLoading());

    try {
      // 1. Load chat history from API
      final result = await chatRepo.getChatHistory(tripId);

      result.fold(
        (error) {
          print('[TripChatCubit - Guide] ❌ Failed to load chat history: $error');
          emit(TripChatError(error));
        },
        (chatHistory) async {
          _messages = chatHistory.messages;
          print('[TripChatCubit - Guide] ✅ Loaded ${_messages.length} messages');
          emit(TripChatLoaded(_messages));

          // 2. Connect to socket for real-time messages
          await _initializeSocket(tripId);
        },
      );
    } catch (e) {
      print('[TripChatCubit - Guide] ❌ Error initializing chat: $e');
      emit(TripChatError('Failed to initialize chat: $e'));
    }
  }

  /// Initialize socket connection and join chat room
  Future<void> _initializeSocket(String tripId) async {
    try {
      emit(TripChatSocketConnecting());

      // Connect to socket
      await _chatSocketService.connect();
      print('[TripChatCubit - Guide] ✅ Socket connected');

      // Join trip chat room
      await _chatSocketService.joinTripChat(tripId);
      print('[TripChatCubit - Guide] ✅ Joined chat room for trip: $tripId');

      emit(TripChatSocketConnected());

      // Listen for new messages
      _chatSocketService.onNewMessage((data) {
        _handleNewMessage(data);
      });

      // Listen for chat errors
      _chatSocketService.onChatError((error) {
        print('[TripChatCubit - Guide] ❌ Chat error: $error');
        emit(TripChatSocketError(error));
      });
    } catch (e) {
      print('[TripChatCubit - Guide] ❌ Socket initialization failed: $e');
      emit(TripChatSocketError('Failed to connect to chat: $e'));
    }
  }

  /// Handle incoming message from socket
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      print('[TripChatCubit - Guide] 📨 Processing new message: $data');

      final newMessage = ChatMessageModel.fromJson(data);

      // Add message to list if not duplicate
      if (!_messages.any((msg) => msg.id == newMessage.id)) {
        _messages.add(newMessage);
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        print('[TripChatCubit - Guide] ✅ Added new message to list');
        emit(TripChatNewMessageReceived(newMessage));
        emit(TripChatLoaded(_messages));
      }
    } catch (e) {
      print('[TripChatCubit - Guide] ❌ Error handling new message: $e');
    }
  }

  /// Send a message
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (_currentTripId == null) {
      emit(TripChatMessageSendFailed('No trip selected'));
      return;
    }

    try {
      print('[TripChatCubit - Guide] 📤 Sending message...');

      // Send message via socket
      _chatSocketService.sendMessage(_currentTripId!, message.trim());

      print('[TripChatCubit - Guide] ✅ Message sent');
      emit(TripChatMessageSent());

      // Note: The message will be added to the list when we receive it back from the socket
      // This ensures consistency with the server

    } catch (e) {
      print('[TripChatCubit - Guide] ❌ Failed to send message: $e');
      emit(TripChatMessageSendFailed('Failed to send message: $e'));
      emit(TripChatLoaded(_messages)); // Restore state
    }
  }

  /// Refresh chat messages
  Future<void> refreshMessages() async {
    if (_currentTripId == null) return;

    try {
      final result = await chatRepo.getChatHistory(_currentTripId!);

      result.fold(
        (error) {
          print('[TripChatCubit - Guide] ❌ Failed to refresh messages: $error');
        },
        (chatHistory) {
          _messages = chatHistory.messages;
          print('[TripChatCubit - Guide] ✅ Refreshed ${_messages.length} messages');
          emit(TripChatLoaded(_messages));
        },
      );
    } catch (e) {
      print('[TripChatCubit - Guide] ❌ Error refreshing messages: $e');
    }
  }

  /// Dispose socket connection
  Future<void> disposeSocket() async {
    print('[TripChatCubit - Guide] 🔌 Disposing socket connection');
    await _chatSocketService.disconnect();
    emit(TripChatSocketDisconnected());
  }

  @override
  Future<void> close() {
    disposeSocket();
    return super.close();
  }
}
