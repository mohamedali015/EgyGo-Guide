import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:flutter/material.dart';

class TouristSection extends StatelessWidget {
  const TouristSection({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    if (trip.tourist == null) {
      return SizedBox.shrink();
    }

    final tourist = trip.tourist!;

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
          Text(
            'Tourist Information',
            style: AppTextStyles.bold18,
          ),
          SizedBox(height: MyResponsive.height(value: 16)),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tourist.name ?? 'Unknown Tourist',
                      style: AppTextStyles.semiBold16,
                    ),
                    SizedBox(height: 4),
                    if (tourist.email != null)
                      Text(
                        tourist.email!,
                        style: AppTextStyles.regular14
                            .copyWith(color: AppColors.grey),
                      ),
                    if (tourist.phone != null) ...[
                      SizedBox(height: 4),
                      Text(
                        tourist.phone!,
                        style: AppTextStyles.regular14
                            .copyWith(color: AppColors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

