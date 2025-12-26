import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallSection extends StatelessWidget {
  const CallSection({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TripDetailsCubit>();
    final callId = cubit.getCurrentCallId();

    return Container(
      padding: MyResponsive.paddingSymmetric(horizontal: 16, vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MyResponsive.radius(value: 12)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
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
                Icons.call,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Active Call Session',
                style: AppTextStyles.bold18,
              ),
            ],
          ),
          SizedBox(height: MyResponsive.height(value: 16)),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'A call session is currently active. You can join the call to communicate with the tourist.',
                    style: AppTextStyles.regular14.copyWith(color: Colors.green.shade700),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MyResponsive.height(value: 16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: callId != null
                  ? () {
                      // Join the existing call
                      cubit.joinCall(callId);
                    }
                  : null,
              icon: Icon(Icons.video_call, color: Colors.white),
              label: Text(
                'Join Call',
                style: AppTextStyles.semiBold16.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (callId == null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Call ID not available',
                style: AppTextStyles.regular12.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
