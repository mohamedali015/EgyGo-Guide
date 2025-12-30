import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_cubit.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Trip Lifecycle Section
/// Displays status-appropriate banners and action buttons for the guide
/// Implements the new trip lifecycle: confirmed -> upcoming -> in_progress -> completed
class TripLifecycleSection extends StatelessWidget {
  const TripLifecycleSection({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    final status = trip.status?.toLowerCase();

    // Only show this section for relevant statuses
    if (status == null ||
        !['confirmed', 'upcoming', 'in_progress', 'completed'].contains(status)) {
      return SizedBox.shrink();
    }

    return Container(
      padding: MyResponsive.paddingSymmetric(horizontal: 16, vertical: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MyResponsive.radius(value: 12)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Banner
          _buildStatusBanner(status),

          // Action Button (if applicable)
          if (_shouldShowActionButton(status)) ...[
            SizedBox(height: MyResponsive.height(value: 16)),
            _buildActionButton(context, status),
          ],
        ],
      ),
    );
  }

  /// Build status-specific banner
  Widget _buildStatusBanner(String status) {
    Color bannerColor;
    IconData bannerIcon;
    String bannerText;

    switch (status) {
      case 'confirmed':
        bannerColor = Colors.blue;
        bannerIcon = Icons.check_circle_outline;
        bannerText = 'Trip confirmed. Wait for start time.';
        break;
      case 'upcoming':
        bannerColor = Colors.purple;
        bannerIcon = Icons.schedule;
        bannerText = 'Trip is upcoming. Start when ready.';
        break;
      case 'in_progress':
        bannerColor = Colors.green;
        bannerIcon = Icons.directions_walk;
        bannerText = 'Trip in progress.';
        break;
      case 'completed':
        bannerColor = Colors.teal;
        bannerIcon = Icons.check_circle;
        bannerText = 'Trip completed.';
        break;
      default:
        bannerColor = Colors.grey;
        bannerIcon = Icons.info_outline;
        bannerText = 'Status: $status';
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              bannerText,
              style: AppTextStyles.medium14.copyWith(
                color: bannerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Determine if action button should be shown
  bool _shouldShowActionButton(String status) {
    // Show Start button for upcoming
    // Show End button for in_progress
    // No button for confirmed or completed
    return status == 'upcoming' || status == 'in_progress';
  }

  /// Build action button based on status
  Widget _buildActionButton(BuildContext context, String status) {
    if (status == 'upcoming') {
      // Start Trip Button
      return BlocBuilder<TripDetailsCubit, TripDetailsState>(
        builder: (context, state) {
          final isLoading = state is TripStarting;

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _showStartTripDialog(context),
              icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                isLoading ? 'Starting...' : 'Start Trip',
                style: AppTextStyles.semiBold16.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.green.withValues(alpha: 0.6),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      );
    } else if (status == 'in_progress') {
      // End Trip Button
      return BlocBuilder<TripDetailsCubit, TripDetailsState>(
        builder: (context, state) {
          final isLoading = state is TripEnding;

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _showEndTripDialog(context),
              icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.stop, color: Colors.white),
              label: Text(
                isLoading ? 'Ending...' : 'End Trip',
                style: AppTextStyles.semiBold16.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.orange.withValues(alpha: 0.6),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      );
    }

    return SizedBox.shrink();
  }

  /// Show confirmation dialog before starting trip
  void _showStartTripDialog(BuildContext context) {
    final cubit = context.read<TripDetailsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Start Trip'),
          ],
        ),
        content: Text(
          'Are you ready to start this trip? The tourist will be notified.',
          style: AppTextStyles.medium14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (trip.sId != null) {
                cubit.startTrip(trip.sId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Start Trip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog before ending trip
  void _showEndTripDialog(BuildContext context) {
    final cubit = context.read<TripDetailsCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.stop, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('End Trip'),
          ],
        ),
        content: Text(
          'Are you sure you want to end this trip? The trip will be marked as completed.',
          style: AppTextStyles.medium14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (trip.sId != null) {
                cubit.endTrip(trip.sId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'End Trip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
