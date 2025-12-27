import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/views/trip_chat_screen.dart';
import 'package:flutter/material.dart';

class ChatSection extends StatelessWidget {
  const ChatSection({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    // Show chat for all states EXCEPT cancelled and rejected
    final status = trip.status?.toLowerCase();
    final showChat = status != 'cancelled' &&
                     status != 'rejected' &&
                     status != null &&
                     status.isNotEmpty;

    if (!showChat) {
      return SizedBox.shrink();
    }

    return Container(
      margin: MyResponsive.paddingSymmetric(vertical: 8),
      padding: MyResponsive.paddingAll(value: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Chat',
                style: AppTextStyles.semiBold18,
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Communicate with ${trip.tourist?.name ?? 'tourist'} in real-time',
            style: AppTextStyles.regular14.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  TripChatScreen.routeName,
                  arguments: {
                    'tripId': trip.sId,
                    'touristName': trip.tourist?.name ?? 'Tourist',
                  },
                );
              },
              icon: Icon(Icons.message),
              label: Text('Open Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
