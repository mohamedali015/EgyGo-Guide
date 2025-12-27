import 'package:egy_go_guide/features/trip/data/models/chat_message_model.dart';

abstract class TripChatState {}

class TripChatInitial extends TripChatState {}

class TripChatLoading extends TripChatState {}

class TripChatLoaded extends TripChatState {
  final List<ChatMessageModel> messages;

  TripChatLoaded(this.messages);
}

class TripChatError extends TripChatState {
  final String errorMessage;

  TripChatError(this.errorMessage);
}

class TripChatMessageSending extends TripChatState {}

class TripChatMessageSent extends TripChatState {}

class TripChatMessageSendFailed extends TripChatState {
  final String errorMessage;

  TripChatMessageSendFailed(this.errorMessage);
}

class TripChatNewMessageReceived extends TripChatState {
  final ChatMessageModel message;

  TripChatNewMessageReceived(this.message);
}

class TripChatSocketConnecting extends TripChatState {}

class TripChatSocketConnected extends TripChatState {}

class TripChatSocketDisconnected extends TripChatState {}

class TripChatSocketError extends TripChatState {
  final String errorMessage;

  TripChatSocketError(this.errorMessage);
}

