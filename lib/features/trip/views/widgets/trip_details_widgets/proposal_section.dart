import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProposalSection extends StatelessWidget {
  const ProposalSection({super.key, required this.trip});

  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    // Check both locations: root level (new flow) and meta (old flow)
    final negotiatedPrice = trip.negotiatedPrice ?? trip.meta?.negotiatedPrice;
    final cubit = context.read<TripDetailsCubit>();
    final tourist = trip.tourist;

    // Debug logging to see what we have
    print('🔍 [ProposalSection] Trip ID: ${trip.sId}');
    print('🔍 [ProposalSection] Negotiated Price (root): ${trip.negotiatedPrice}');
    print('🔍 [ProposalSection] Negotiated Price (meta): ${trip.meta?.negotiatedPrice}');
    print('🔍 [ProposalSection] Final Negotiated Price: $negotiatedPrice');

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
                Icons.pending_actions,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Pending Confirmation',
                style: AppTextStyles.bold18,
              ),
            ],
          ),
          SizedBox(height: MyResponsive.height(value: 16)),

          // Tourist Offer Details
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tourist Offer Details',
                      style: AppTextStyles.semiBold16.copyWith(color: Colors.blue.shade800),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                if (tourist != null) ...[
                  _buildDetailRow('Tourist Name:', tourist.name ?? 'N/A'),
                  SizedBox(height: 8),
                  _buildDetailRow('Contact:', tourist.phone ?? tourist.email ?? 'N/A'),
                  SizedBox(height: 8),
                ],
                _buildDetailRow('Meeting Location:', trip.meetingAddress ?? 'Not specified'),
                SizedBox(height: 8),
                _buildDetailRow('Duration:', '${trip.totalDurationMinutes ?? 0} minutes'),
                SizedBox(height: 8),
                _buildDetailRow('Start Date:', _formatDate(trip.startAt)),
                // Always show price section - even if 0 or null, show it for visibility
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Offered Price:',
                      style: AppTextStyles.semiBold14.copyWith(color: Colors.blue.shade800),
                    ),
                    Text(
                      negotiatedPrice != null
                          ? '\$${negotiatedPrice.toStringAsFixed(2)}'
                          : '\$0.00 (Not set)',
                      style: AppTextStyles.bold18.copyWith(
                        color: negotiatedPrice != null && negotiatedPrice > 0
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Instructions
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The tourist is waiting for your response. Accept to confirm the trip or reject if you cannot proceed.',
                    style: AppTextStyles.regular14.copyWith(color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MyResponsive.height(value: 16)),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showRejectDialog(context, cubit);
                  },
                  icon: Icon(Icons.close, color: Colors.red),
                  label: Text(
                    'Reject',
                    style: AppTextStyles.semiBold14.copyWith(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAcceptDialog(context, cubit);
                  },
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    'Accept',
                    style: AppTextStyles.semiBold14.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, TripDetailsCubit cubit) {
    // Check both locations: root level (new flow) and meta (old flow)
    final negotiatedPrice = trip.negotiatedPrice ?? trip.meta?.negotiatedPrice;
    final tourist = trip.tourist;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Accept Proposal'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Offer Details',
                style: AppTextStyles.semiBold16,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tourist != null) ...[
                      _buildDetailRow(
                        'Tourist:',
                        tourist.name ?? 'Unknown',
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow(
                        'Contact:',
                        tourist.phone ?? tourist.email ?? 'N/A',
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                    ],
                    _buildDetailRow(
                      'Meeting Location:',
                      trip.meetingAddress ?? 'Not specified',
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow(
                      'Duration:',
                      '${trip.totalDurationMinutes ?? 0} minutes',
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow(
                      'Start Date:',
                      _formatDate(trip.startAt),
                    ),
                    // Always show price
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Offered Price:',
                          style: AppTextStyles.semiBold14,
                        ),
                        Text(
                          negotiatedPrice != null
                              ? '\$${negotiatedPrice.toStringAsFixed(2)}'
                              : '\$0.00',
                          style: AppTextStyles.bold18.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'By accepting this proposal, you confirm your participation as the guide for this trip.',
                style: AppTextStyles.regular14.copyWith(color: AppColors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (trip.sId != null) {
                cubit.acceptProposal(trip.sId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Accept Proposal',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, TripDetailsCubit cubit) {
    // Check both locations: root level (new flow) and meta (old flow)
    final negotiatedPrice = trip.negotiatedPrice ?? trip.meta?.negotiatedPrice;
    final tourist = trip.tourist;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Reject Proposal'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Offer Details',
                style: AppTextStyles.semiBold16,
              ),
              SizedBox(height: 12),
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
                    if (tourist != null) ...[
                      _buildDetailRow(
                        'Tourist:',
                        tourist.name ?? 'Unknown',
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow(
                        'Contact:',
                        tourist.phone ?? tourist.email ?? 'N/A',
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                    ],
                    _buildDetailRow(
                      'Meeting Location:',
                      trip.meetingAddress ?? 'Not specified',
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow(
                      'Duration:',
                      '${trip.totalDurationMinutes ?? 0} minutes',
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow(
                      'Start Date:',
                      _formatDate(trip.startAt),
                    ),
                    // Always show price
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Offered Price:',
                          style: AppTextStyles.semiBold14,
                        ),
                        Text(
                          negotiatedPrice != null
                              ? '\$${negotiatedPrice.toStringAsFixed(2)}'
                              : '\$0.00',
                          style: AppTextStyles.bold18.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Are you sure you want to reject this proposal? This action cannot be undone and the tourist will be notified.',
                style: AppTextStyles.regular14.copyWith(color: Colors.red.shade700),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (trip.sId != null) {
                cubit.rejectProposal(trip.sId!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Reject Proposal',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.medium12.copyWith(color: AppColors.grey),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.semiBold14,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not set';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
