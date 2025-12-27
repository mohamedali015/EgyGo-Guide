/// Chat Message Model
class ChatMessageModel {
  final String id;
  final String tripId;
  final String senderId;
  final String senderRole; // 'guide' or 'tourist'
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.tripId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  /// Check if message is sent by guide
  bool get isSentByGuide => senderRole.toLowerCase() == 'guide';

  /// Check if message is sent by tourist
  bool get isSentByTourist => senderRole.toLowerCase() == 'tourist';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Backend returns messages in this format:
    // {
    //   "_id": "...",
    //   "sender": {"user": "userId", "role": "tourist"},
    //   "receiver": {"user": "userId", "role": "guide"},
    //   "message": "text",
    //   "createdAt": "..."
    // }

    final senderId = json['sender']?['user'] ?? json['senderId'] ?? '';
    final senderRole = json['sender']?['role'] ?? json['senderRole'] ?? '';
    final tripId = json['tripId'] ?? json['trip'] ?? '';

    return ChatMessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      tripId: tripId,
      senderId: senderId,
      senderRole: senderRole,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tripId': tripId,
      'senderId': senderId,
      'senderRole': senderRole,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? tripId,
    String? senderId,
    String? senderRole,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Chat History Response Model
class ChatHistoryResponseModel {
  final bool success;
  final List<ChatMessageModel> messages;
  final String? message;

  ChatHistoryResponseModel({
    required this.success,
    required this.messages,
    this.message,
  });

  factory ChatHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    print('[ChatHistoryResponseModel] 📨 Parsing messages response');
    print('[ChatHistoryResponseModel] - Success: ${json['success']}');

    // The API returns: {success: true, data: {messages: [...], total: 4, limit: 100, skip: 0}}
    // So we need to access json['data']['messages']
    final messagesList = json['data']?['messages'] as List? ?? [];
    print('[ChatHistoryResponseModel] - Found ${messagesList.length} messages');

    final parsedMessages = messagesList.map((msg) {
      try {
        return ChatMessageModel.fromJson(msg as Map<String, dynamic>);
      } catch (e) {
        print('[ChatHistoryResponseModel] ❌ Error parsing message: $e');
        print('[ChatHistoryResponseModel] - Message data: $msg');
        rethrow;
      }
    }).toList();

    print('[ChatHistoryResponseModel] - Successfully parsed ${parsedMessages.length} messages');

    return ChatHistoryResponseModel(
      success: json['success'] ?? false,
      messages: parsedMessages,
      message: json['message'],
    );
  }
}
