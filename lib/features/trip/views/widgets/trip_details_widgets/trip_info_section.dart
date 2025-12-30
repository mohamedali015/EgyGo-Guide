import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/governorates/manager/governorates_cubit/governorates_cubit.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TripInfoSection extends StatelessWidget {
  const TripInfoSection({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Information',
                style: AppTextStyles.bold18,
              ),
              _buildStatusBadge(),
            ],
          ),
          SizedBox(height: MyResponsive.height(value: 16)),
          _buildInfoRow(
            icon: Icons.location_city,
            label: 'Province',
            value: _getProvinceName(context),
          ),
          SizedBox(height: MyResponsive.height(value: 12)),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Start Date',
            value: _formatDate(trip.startAt),
          ),
          SizedBox(height: MyResponsive.height(value: 12)),
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Duration',
            value: '${trip.totalDurationMinutes ?? 0} minutes',
          ),
          SizedBox(height: MyResponsive.height(value: 12)),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Meeting Address',
            value: trip.meetingAddress ?? 'Not specified',
          ),
          if (trip.paymentStatus != null) ...[
            SizedBox(height: MyResponsive.height(value: 12)),
            _buildInfoRow(
              icon: Icons.payment,
              label: 'Payment Status',
              value: _formatPaymentStatus(trip.paymentStatus),
            ),
          ],

          // Show cancellation info if trip is cancelled
          if (trip.status?.toLowerCase() == 'cancelled') ...[
            SizedBox(height: MyResponsive.height(value: 16)),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Trip Cancelled',
                        style: AppTextStyles.semiBold14.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                  if (trip.cancellationReason != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Reason: ${trip.cancellationReason}',
                      style: AppTextStyles.regular14,
                    ),
                  ],
                  if (trip.cancelledBy != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Cancelled by: ${trip.cancelledBy}',
                      style: AppTextStyles.regular12.copyWith(color: AppColors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Cancel Trip Button - Visible in specific states only
          if (_shouldShowCancelButton()) ...[
            SizedBox(height: MyResponsive.height(value: 16)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelTripDialog(context),
                icon: Icon(Icons.cancel_outlined, color: Colors.red),
                label: Text(
                  'Cancel Trip',
                  style: AppTextStyles.semiBold14.copyWith(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowCancelButton() {
    final status = trip.status?.toLowerCase();
    // Hide cancel button ONLY for: cancelled, completed, awaiting_payment, rejected
    // Show for all other states
    return status != 'cancelled' &&
           status != 'completed' &&
           status != 'awaiting_payment' &&
           status != 'rejected';
  }

  void _showCancelTripDialog(BuildContext context) {
    String? selectedReason;
    final cubit = context.read<TripDetailsCubit>();

    final cancelReasons = [
      'Emergency',
      'Schedule Conflict',
      'Health Issues',
      'Weather Conditions',
      'Tourist Request',
      'Other',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Cancel Trip'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to cancel this trip?',
                  style: AppTextStyles.medium14,
                ),
                SizedBox(height: 16),
                Text(
                  'Please select a reason for cancellation:',
                  style: AppTextStyles.semiBold14.copyWith(color: Colors.red.shade700),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      hint: Text('Select reason *', style: AppTextStyles.regular14),
                      isExpanded: true,
                      items: cancelReasons.map((String reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason, style: AppTextStyles.regular14),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedReason = newValue;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone. The tourist will be notified.',
                          style: AppTextStyles.regular12.copyWith(color: Colors.orange.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      if (trip.sId != null) {
                        cubit.cancelTrip(trip.sId!, selectedReason!);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                disabledBackgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Confirm Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.regular12.copyWith(color: AppColors.grey),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.medium14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText = _getStatusText();

    switch (trip.status?.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        break;
      case 'upcoming':
        statusColor = Colors.purple;
        break;
      case 'in_progress':
        statusColor = Colors.green;
        break;
      case 'in_call':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.teal;
        break;
      case 'cancelled':
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'awaiting_payment':
        statusColor = Colors.amber;
        break;
      case 'pending_confirmation':
      case 'awaiting_confirmation':
        statusColor = Colors.deepOrange;
        break;
      case 'approved':
      case 'accepted':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
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

  String _getStatusText() {
    switch (trip.status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'upcoming':
        return 'Upcoming';
      case 'in_progress':
        return 'In Progress';
      case 'in_call':
        return 'In Call';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'awaiting_payment':
        return 'Awaiting Payment';
      case 'pending_confirmation':
        return 'Pending Confirmation';
      case 'awaiting_confirmation':
        return 'Awaiting Confirmation';
      case 'approved':
      case 'accepted':
        return 'Approved';
      default:
        return trip.status ?? 'Unknown';
    }
  }

  String _getProvinceName(BuildContext context) {
    if (trip.provinceId == null) return 'Unknown Province';

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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date not set';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatPaymentStatus(String? status) {
    if (status == null) return 'Unknown';
    return status.replaceAll('_', ' ').toUpperCase();
  }
}
