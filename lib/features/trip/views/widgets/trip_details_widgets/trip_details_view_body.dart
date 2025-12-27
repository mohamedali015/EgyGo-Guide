import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/shared_widgets/custom_loading_indicator.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_cubit.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_state.dart';
import 'package:egy_go_guide/features/trip/views/agora_call_screen.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trip_details_widgets/trip_info_section.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trip_details_widgets/tourist_section.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trip_details_widgets/call_section.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trip_details_widgets/proposal_section.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trip_details_widgets/chat_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripDetailsViewBody extends StatefulWidget {
  const TripDetailsViewBody({super.key});

  @override
  State<TripDetailsViewBody> createState() => _TripDetailsViewBodyState();
}

class _TripDetailsViewBodyState extends State<TripDetailsViewBody> {
  TripDetailsCubit? _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save cubit reference early in lifecycle for safe disposal
    _cubit ??= context.read<TripDetailsCubit>();
  }

  @override
  void dispose() {
    // Dispose socket using saved cubit reference (safe after widget deactivation)
    _cubit?.disposeSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripDetailsCubit, TripDetailsState>(
      listener: (context, state) {
        if (state is TripDetailsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CallJoinedSuccess) {
          // Navigate to Agora call screen
          final callData = state.callResponse.data;
          if (callData != null &&
              callData.appId != null &&
              callData.channelName != null &&
              callData.token != null &&
              callData.uid != null &&
              callData.callId != null) {
            // Extract tripId as string
            String tripIdStr = '';
            if (callData.tripId is String) {
              tripIdStr = callData.tripId as String;
            } else if (callData.tripId is Map && callData.tripId['_id'] != null) {
              tripIdStr = callData.tripId['_id'] as String;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AgoraCallScreen(
                  appId: callData.appId!,
                  channelName: callData.channelName!,
                  token: callData.token!,
                  uid: callData.uid!,
                  callId: callData.callId!,
                  tripId: tripIdStr,
                ),
              ),
            ).then((_) {
              // Restore TripDetails state after returning from call screen
              final cubit = TripDetailsCubit.get(context);
              cubit.restoreTripDetailsState();

              // Refresh trip details to get updated status
              cubit.refreshTripDetails();
            });
          }
        } else if (state is CallJoinFailed) {
          // State already restored in cubit, just show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProposalAccepted) {
          // Show success message - STAY on trip details screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          // DO NOT navigate back - stay on trip details
        } else if (state is ProposalRejected) {
          // Show success message - STAY on trip details screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          // DO NOT navigate back - stay on trip details
        } else if (state is ProposalAcceptFailed) {
          // State already restored in cubit, just show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ProposalRejectFailed) {
          // State already restored in cubit, just show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is TripCancelled) {
          // Show success message and navigate back to trips list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          // Navigate back to trips screen
          Navigator.pop(context);
        } else if (state is TripCancelFailed) {
          // State already restored in cubit, just show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Remove ProposalAccepting and ProposalRejecting from loading states
        // Show UI with inline loading instead
        if (state is TripDetailsLoading || state is CallJoining) {
          return CustomLoadingIndicator();
        } else if (state is TripDetailsFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final cubit = TripDetailsCubit.get(context);
                    cubit.refreshTripDetails();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is TripDetailsSuccess ||
            state is CallJoinedSuccess ||
            state is CallJoinFailed ||
            state is ProposalAccepted ||
            state is ProposalRejected ||
            state is ProposalAcceptFailed ||
            state is ProposalRejectFailed ||
            state is ProposalAccepting ||  // Show UI while accepting
            state is ProposalRejecting ||  // Show UI while rejecting
            state is TripCancelling) {
          final cubit = TripDetailsCubit.get(context);
          final trip = cubit.currentTrip;

          if (trip == null) {
            return Center(child: Text('Trip data not available'));
          }

          // Check if we're processing proposal action
          final isProcessingProposal = state is ProposalAccepting || state is ProposalRejecting;

          return RefreshIndicator(
            onRefresh: () async {
              await cubit.refreshTripDetails();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: MyResponsive.paddingSymmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MyResponsive.height(value: 16)),

                  // Show loading banner if processing proposal
                  if (isProcessingProposal)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state is ProposalAccepting
                                ? 'Accepting proposal...'
                                : 'Rejecting proposal...',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Trip Information Section
                  TripInfoSection(trip: trip),

                  SizedBox(height: MyResponsive.height(value: 16)),

                  // Tourist Information Section
                  TouristSection(trip: trip),

                  SizedBox(height: MyResponsive.height(value: 16)),

                  // Call Section (IN_CALL status)
                  if (_shouldShowCallSection(trip))
                    CallSection(trip: trip),

                  if (_shouldShowCallSection(trip))
                    SizedBox(height: MyResponsive.height(value: 16)),

                  // Proposal Section (WAITING status)
                  if (_shouldShowProposalSection(trip))
                    ProposalSection(trip: trip),

                  if (_shouldShowProposalSection(trip))
                    SizedBox(height: MyResponsive.height(value: 16)),

                  // Chat Section (if available)
                  if (_shouldShowChatSection(trip))
                    ChatSection(trip: trip),

                  if (_shouldShowChatSection(trip))
                    SizedBox(height: MyResponsive.height(value: 16)),

                  SizedBox(height: MyResponsive.height(value: 24)),
                ],
              ),
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  bool _shouldShowCallSection(trip) {
    // Show call section ONLY when status is IN_CALL (not awaiting_call)
    final status = trip.status?.toLowerCase();
    return status == 'in_call';
  }

  bool _shouldShowProposalSection(trip) {
    // Show proposal section when status is WAITING or PENDING_CONFIRMATION
    final status = trip.status?.toLowerCase();
    return status == 'pending_confirmation' || status == 'awaiting_confirmation';
  }

  bool _shouldShowChatSection(trip) {
    // Show chat section for all states EXCEPT cancelled and rejected
    final status = trip.status?.toLowerCase();
    return status != 'cancelled' &&
           status != 'rejected' &&
           status != null &&
           status.isNotEmpty;
  }
}
