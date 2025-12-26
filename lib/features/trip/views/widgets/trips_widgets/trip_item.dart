import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/governorates/manager/governorates_cubit/governorates_cubit.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/views/trip_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TripItem extends StatelessWidget {
  const TripItem({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: MyResponsive.paddingSymmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (trip.sId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsScreen(tripId: trip.sId!),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: MyResponsive.paddingAll(value: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getTripName(),
                      style: AppTextStyles.semiBold16,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              SizedBox(height: MyResponsive.height(value: 12)),
              _buildInfoRow(
                icon: Icons.calendar_today,
                text: _formatDate(trip.startAt),
              ),
              SizedBox(height: MyResponsive.height(value: 8)),
              _buildInfoRow(
                icon: Icons.location_on,
                text: _getProvinceName(context),
              ),
              SizedBox(height: MyResponsive.height(value: 8)),
              _buildInfoRow(
                icon: Icons.access_time,
                text: '${trip.totalDurationMinutes ?? 0} minutes',
              ),
              if (trip.tourist?.name != null) ...[
                SizedBox(height: MyResponsive.height(value: 8)),
                _buildInfoRow(
                  icon: Icons.person,
                  text: 'Tourist: ${trip.tourist!.name}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.regular14.copyWith(color: AppColors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText = trip.status ?? 'Unknown';

    switch (trip.status?.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'Confirmed';
        break;
      case 'in_progress':
        statusColor = Colors.green;
        statusText = 'In Progress';
        break;
      case 'completed':
        statusColor = Colors.teal;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      case 'awaiting_payment':
        statusColor = Colors.amber;
        statusText = 'Awaiting Payment';
        break;
      case 'pending_confirmation':
        statusColor = Colors.deepOrange;
        statusText = 'Pending Confirmation';
        break;
      case 'approved':
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      default:
        statusColor = Colors.grey;
        statusText = trip.status ?? 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.regular12.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTripName() {
    if (trip.meetingAddress != null && trip.meetingAddress!.isNotEmpty) {
      return 'Trip to ${trip.meetingAddress}';
    }
    return 'Trip #${trip.sId?.substring(0, 8) ?? 'Unknown'}';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date not set';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getProvinceName(BuildContext context) {
    if (trip.provinceId == null) return 'Province not set';

    try {
      final governoratesCubit = context.read<GovernoratesCubit>();
      final governorate = governoratesCubit.governorates.firstWhere(
        (gov) => gov.sId == trip.provinceId,
        orElse: () => throw Exception(),
      );
      return governorate.name ?? 'Unknown Province';
    } catch (e) {
      return trip.meetingAddress ?? 'Unknown Province';
    }
  }
}
