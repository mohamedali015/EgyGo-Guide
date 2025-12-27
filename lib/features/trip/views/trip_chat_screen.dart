import 'package:egy_go_guide/core/helper/get_it.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/repos/chat_repo.dart';
import 'package:egy_go_guide/features/trip/manager/trip_chat_cubit/trip_chat_cubit.dart';
import 'package:egy_go_guide/features/trip/manager/trip_chat_cubit/trip_chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TripChatScreen extends StatefulWidget {
  const TripChatScreen({
    super.key,
    required this.tripId,
    required this.touristName,
  });

  final String tripId;
  final String touristName;

  static const String routeName = 'tripChat';

  @override
  State<TripChatScreen> createState() => _TripChatScreenState();
}

class _TripChatScreenState extends State<TripChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripChatCubit(getIt<ChatRepo>())
        ..initializeChat(widget.tripId),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.touristName,
                style: AppTextStyles.semiBold18,
              ),
              BlocBuilder<TripChatCubit, TripChatState>(
                builder: (context, state) {
                  final cubit = context.read<TripChatCubit>();
                  final isConnected = cubit.isSocketConnected;
                  return Text(
                    isConnected ? 'Online' : 'Connecting...',
                    style: AppTextStyles.regular12.copyWith(
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: BlocConsumer<TripChatCubit, TripChatState>(
          listener: (context, state) {
            if (state is TripChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is TripChatMessageSendFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is TripChatSocketError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (state is TripChatNewMessageReceived) {
              _scrollToBottom();
            } else if (state is TripChatLoaded) {
              _scrollToBottom();
            }
          },
          builder: (context, state) {
            if (state is TripChatLoading) {
              return Center(child: CircularProgressIndicator());
            }

            final cubit = context.read<TripChatCubit>();
            final messages = cubit.messages;

            return Column(
              children: [
                // Messages List
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: AppTextStyles.medium16.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start a conversation with ${widget.touristName}',
                                style: AppTextStyles.regular14.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => cubit.refreshMessages(),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isGuide = message.isSentByGuide;
                              final showDateHeader = index == 0 ||
                                  !_isSameDay(
                                    messages[index - 1].timestamp,
                                    message.timestamp,
                                  );

                              return Column(
                                children: [
                                  if (showDateHeader)
                                    _buildDateHeader(message.timestamp),
                                  _buildMessageBubble(message, isGuide),
                                ],
                              );
                            },
                          ),
                        ),
                ),

                // Message Input
                _buildMessageInput(context, cubit),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateHeader(DateTime date) {
    String dateText;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMM dd, yyyy').format(date);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: AppTextStyles.regular12.copyWith(
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(message, bool isGuide) {
    return Align(
      alignment: isGuide ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isGuide ? 60 : 0,
          right: isGuide ? 0 : 60,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isGuide ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(isGuide ? 16 : 4),
            bottomRight: Radius.circular(isGuide ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: AppTextStyles.regular14.copyWith(
                color: isGuide ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: AppTextStyles.regular11.copyWith(
                color: isGuide ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, TripChatCubit cubit) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.regular14.copyWith(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            SizedBox(width: 8),
            BlocBuilder<TripChatCubit, TripChatState>(
              builder: (context, state) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      final message = _messageController.text;
                      if (message.trim().isNotEmpty) {
                        cubit.sendMessage(message);
                        _messageController.clear();
                      }
                    },
                    icon: Icon(Icons.send),
                    color: Colors.white,
                    iconSize: 24,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
