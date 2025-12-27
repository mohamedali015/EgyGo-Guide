import 'package:dartz/dartz.dart';
import 'package:egy_go_guide/features/trip/data/models/chat_message_model.dart';

abstract class ChatRepo {
  /// Fetch chat history for a trip
  Future<Either<String, ChatHistoryResponseModel>> getChatHistory(String tripId);
}

