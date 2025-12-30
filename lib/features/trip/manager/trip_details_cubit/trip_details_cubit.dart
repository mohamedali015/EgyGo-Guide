import 'dart:async';
import 'package:egy_go_guide/core/network/socket_service.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/data/repos/trip_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'trip_details_state.dart';

class TripDetailsCubit extends Cubit<TripDetailsState> {
  TripDetailsCubit(this.repo) : super(TripDetailsInitial());

  static TripDetailsCubit get(context) => BlocProvider.of(context);
  final TripRepo repo;
  final SocketService _socketService = SocketService(); // Fresh instance per cubit

  TripModel? currentTrip;
  TripDetailsState? _previousState;
  bool _isSocketInitialized = false;
  Timer? _pollTimer; // Fallback polling timer

  /// Initialize socket connection and listen to status updates
  /// Called when Trip Details screen is mounted
  Future<void> initializeSocket(String tripId) async {
    if (_isSocketInitialized) {
      print('[TripDetailsCubit - Guide] ℹ️ Socket already initialized');
      return;
    }

    print('[TripDetailsCubit - Guide] 🚀 Starting socket initialization for trip: $tripId');
    print('[TripDetailsCubit - Guide] 📍 Current trip status: ${currentTrip?.status}');

    // Start polling immediately as backup
    print('[TripDetailsCubit - Guide] 🔄 Starting polling fallback immediately...');
    _startPollingFallback(tripId);

    try {
      // Step 1: Connect to socket (non-blocking)
      print('[TripDetailsCubit - Guide] 📡 Connecting to socket server (background)...');
      _socketService.connect(); // Don't await - let it connect in background

      // Step 2: Set up event listener immediately (before waiting for connection)
      print('[TripDetailsCubit - Guide] 👂 Setting up event listener...');
      _socketService.onTripStatusUpdated((data) {
        print('[TripDetailsCubit - Guide] 🔔 Received status update callback!');
        _handleTripStatusUpdate(data);
      });

      // Step 3: Try to join room in background (don't block UI)
      print('[TripDetailsCubit - Guide] 🚪 Attempting to join trip room (background)...');
      _socketService.joinTripRoom(tripId).then((_) {
        if (_socketService.isConnected) {
          print('[TripDetailsCubit - Guide] ✅ Socket connected and joined room');
          _isSocketInitialized = true;
        } else {
          print('[TripDetailsCubit - Guide] ⚠️ Socket not connected, polling will handle updates');
        }
      }).catchError((e) {
        print('[TripDetailsCubit - Guide] ❌ Socket join failed: $e');
        print('[TripDetailsCubit - Guide] ℹ️ Polling will continue as fallback');
      });

      print('[TripDetailsCubit - Guide] ✅ Socket setup initiated (non-blocking)');
      print('[TripDetailsCubit - Guide] 🎯 Polling active, socket connecting in background');
    } catch (e, stackTrace) {
      print('[TripDetailsCubit - Guide] ❌ Socket initialization failed: $e');
      print('[TripDetailsCubit - Guide] 📍 Stack trace: $stackTrace');
      print('[TripDetailsCubit - Guide] ℹ️ Polling will handle all updates');
    }
  }

  /// Start polling as fallback mechanism
  /// This ensures status updates are caught even if socket fails
  void _startPollingFallback(String tripId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
      print('[TripDetailsCubit - Guide] 🔄 Polling for trip updates...');
      try {
        final result = await repo.getTripDetails(tripId);
        result.fold(
          (error) {
            print('[TripDetailsCubit - Guide] ⚠️ Polling failed: $error');
            // Don't emit error state during polling to avoid disrupting UI
          },
          (tripDetailsData) {
            final newStatus = tripDetailsData.trip?.status;
            final currentStatus = currentTrip?.status;

            if (newStatus != null && newStatus != currentStatus) {
              print('[TripDetailsCubit - Guide] 🔔 POLLING: Status changed!');
              print('[TripDetailsCubit - Guide]    Old: $currentStatus');
              print('[TripDetailsCubit - Guide]    New: $newStatus');

              currentTrip = tripDetailsData.trip;
              emit(TripDetailsSuccess(tripDetailsData.trip!));
            } else {
              print('[TripDetailsCubit - Guide] ℹ️ No status change detected');
            }
          },
        );
      } catch (e) {
        print('[TripDetailsCubit - Guide] ⚠️ Polling error: $e');
        // Continue polling even if there's an error
      }
    });
    print('[TripDetailsCubit - Guide] ✅ Polling fallback started (15s interval)');
  }

  /// Stop polling timer
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    print('[TripDetailsCubit - Guide] 🛑 Polling stopped');
  }

  /// Handle incoming trip status updates from socket
  /// Verifies tripId and updates UI immediately
  void _handleTripStatusUpdate(Map<String, dynamic> data) {
    try {
      print('[TripDetailsCubit - Guide] ═══════════════════════════════════════════');
      print('[TripDetailsCubit - Guide] 📨 PROCESSING STATUS UPDATE FROM SOCKET');
      print('[TripDetailsCubit - Guide] ═══════════════════════════════════════════');
      print('[TripDetailsCubit - Guide] 📦 Full data received: $data');

      final tripId = data['tripId'] as String?;
      final newStatus = data['status'] as String?;
      final timestamp = data['timestamp'] as String?;

      print('[TripDetailsCubit - Guide] 🔍 Extracted tripId: $tripId');
      print('[TripDetailsCubit - Guide] 🔍 Extracted status: $newStatus');
      print('[TripDetailsCubit - Guide] 🔍 Extracted timestamp: $timestamp');
      print('[TripDetailsCubit - Guide] 🔍 Current trip ID: ${currentTrip?.sId}');
      print('[TripDetailsCubit - Guide] 🔍 Current trip status: ${currentTrip?.status}');

      // Verify tripId matches current trip
      if (tripId == null || tripId != currentTrip?.sId) {
        print('[TripDetailsCubit - Guide] ⚠️ Ignoring update - tripId mismatch!');
        print('[TripDetailsCubit - Guide]    Expected: ${currentTrip?.sId}');
        print('[TripDetailsCubit - Guide]    Received: $tripId');
        return;
      }

      if (newStatus == null || newStatus.isEmpty) {
        print('[TripDetailsCubit - Guide] ❌ Invalid status in update - newStatus is null or empty');
        return;
      }

      print('[TripDetailsCubit - Guide] 🎯 Status update VALID!');
      print('[TripDetailsCubit - Guide] 📊 Updating from "${currentTrip?.status}" to "$newStatus"');

      // Update local trip status immediately
      if (currentTrip != null) {
        final oldStatus = currentTrip!.status;
        currentTrip!.status = newStatus;

        print('[TripDetailsCubit - Guide] ✅ Local trip status updated!');
        print('[TripDetailsCubit - Guide]    Old: $oldStatus');
        print('[TripDetailsCubit - Guide]    New: $newStatus');

        // Update other relevant fields from socket data if available
        if (data['paymentStatus'] != null) {
          currentTrip!.paymentStatus = data['paymentStatus'] as String?;
          print('[TripDetailsCubit - Guide] 💳 Payment status updated: ${data['paymentStatus']}');
        }

        // Trigger UI rebuild with updated trip
        print('[TripDetailsCubit - Guide] 🔄 Emitting TripDetailsSuccess to rebuild UI...');
        emit(TripDetailsSuccess(currentTrip!));

        print('[TripDetailsCubit - Guide] ✅ UI update triggered successfully!');
        print('[TripDetailsCubit - Guide] ═══════════════════════════════════════════');
      } else {
        print('[TripDetailsCubit - Guide] ⚠️ currentTrip is null - cannot update');
        print('[TripDetailsCubit - Guide] ═══════════════════════════════════════════');
      }
    } catch (e, stackTrace) {
      print('[TripDetailsCubit - Guide] ❌ Error handling status update: $e');
      print('[TripDetailsCubit - Guide] 📍 Stack trace: $stackTrace');
      print('[TripDetailsCubit - Guide] ═══════════════════════════════════════════');
    }
  }

  /// Disconnect socket when screen is disposed
  /// Leave the trip room but keep socket connected
  void disposeSocket() {
    if (_isSocketInitialized) {
      _socketService.offTripStatusUpdated();
      _socketService.disconnect();
      _isSocketInitialized = false;
      print('[TripDetailsCubit - Guide] Socket disposed');
    }
    _stopPolling();
  }

  /// Fetch trip details from REST API (initial load only)
  Future<void> fetchTripDetails(String tripId) async {
    emit(TripDetailsLoading());
    final result = await repo.getTripDetails(tripId);
    result.fold(
      (error) {
        emit(TripDetailsFailure(error));
      },
      (tripDetailsData) {
        currentTrip = tripDetailsData.trip;
        emit(TripDetailsSuccess(tripDetailsData.trip!));

        // Initialize socket after successful initial load
        initializeSocket(tripId);
      },
    );
  }

  /// Refresh trip details
  Future<void> refreshTripDetails() async {
    if (currentTrip?.sId != null) {
      await fetchTripDetails(currentTrip!.sId!);
    }
  }

  /// Join an existing call (Guide can only join, not initiate)
  Future<void> joinCall(String callId) async {
    // Cache current state before joining call
    if (state is TripDetailsSuccess) {
      _previousState = state;
    }

    emit(CallJoining());
    final result = await repo.joinCall(callId);
    result.fold(
      (error) {
        // Restore previous state on failure
        restoreTripDetailsState();
        emit(CallJoinFailed(error));
      },
      (callResponse) {
        emit(CallJoinedSuccess(callResponse));
      },
    );
  }

  /// Restore TripDetails state after call operations
  void restoreTripDetailsState() {
    if (currentTrip != null) {
      emit(TripDetailsSuccess(currentTrip!));
    } else if (_previousState != null) {
      emit(_previousState!);
    }
  }

  /// Get the current call ID from trip metadata
  String? getCurrentCallId() {
    if (currentTrip?.meta?.callId != null) {
      return currentTrip!.meta!.callId;
    }

    // Try to get from call sessions
    if (currentTrip?.callSessions != null &&
        currentTrip!.callSessions!.isNotEmpty) {
      final lastSession = currentTrip!.callSessions!.last;
      if (lastSession is Map && lastSession.containsKey('callId')) {
        return lastSession['callId'] as String?;
      }
    }

    return null;
  }

  /// Accept trip proposal (Guide accepts the trip)
  Future<void> acceptProposal(String tripId) async {
    // Cache current state before accepting
    if (state is TripDetailsSuccess) {
      _previousState = state;
    }

    emit(ProposalAccepting());
    final result = await repo.acceptProposal(tripId);
    result.fold(
      (error) {
        // Restore previous state on failure
        restoreTripDetailsState();
        emit(ProposalAcceptFailed(error));
      },
      (proposalResponse) {
        // Check if trip data is returned in response
        if (proposalResponse.trip != null) {
          currentTrip = proposalResponse.trip;
          emit(ProposalAccepted(
            proposalResponse.trip!,
            proposalResponse.message ?? 'Proposal accepted successfully',
          ));
        } else {
          // If trip data not in response, refetch trip details
          print('[TripDetailsCubit] Trip data not in accept response, refetching...');
          _refetchAfterProposalAction(
            tripId,
            proposalResponse.message ?? 'Proposal accepted successfully',
            isAccepted: true,
          );
        }
      },
    );
  }

  /// Reject trip proposal (Guide rejects the trip)
  Future<void> rejectProposal(String tripId) async {
    // Cache current state before rejecting
    if (state is TripDetailsSuccess) {
      _previousState = state;
    }

    emit(ProposalRejecting());
    final result = await repo.rejectProposal(tripId);
    result.fold(
      (error) {
        // Restore previous state on failure
        restoreTripDetailsState();
        emit(ProposalRejectFailed(error));
      },
      (proposalResponse) {
        // Check if trip data is returned in response
        if (proposalResponse.trip != null) {
          currentTrip = proposalResponse.trip;
          emit(ProposalRejected(
            proposalResponse.trip!,
            proposalResponse.message ?? 'Proposal rejected successfully',
          ));
        } else {
          // If trip data not in response, refetch trip details
          print('[TripDetailsCubit] Trip data not in reject response, refetching...');
          _refetchAfterProposalAction(
            tripId,
            proposalResponse.message ?? 'Proposal rejected successfully',
            isAccepted: false,
          );
        }
      },
    );
  }

  /// Helper method to refetch trip after proposal action
  Future<void> _refetchAfterProposalAction(
    String tripId,
    String message, {
    required bool isAccepted,
  }) async {
    final result = await repo.getTripDetails(tripId);
    result.fold(
      (error) {
        // If refetch fails, restore previous state and show error
        restoreTripDetailsState();
        if (isAccepted) {
          emit(ProposalAcceptFailed('Action succeeded but failed to refresh: $error'));
        } else {
          emit(ProposalRejectFailed('Action succeeded but failed to refresh: $error'));
        }
      },
      (tripDetailsData) {
        currentTrip = tripDetailsData.trip;
        if (currentTrip != null) {
          if (isAccepted) {
            emit(ProposalAccepted(currentTrip!, message));
          } else {
            emit(ProposalRejected(currentTrip!, message));
          }
        } else {
          restoreTripDetailsState();
          if (isAccepted) {
            emit(ProposalAcceptFailed('Action succeeded but trip data unavailable'));
          } else {
            emit(ProposalRejectFailed('Action succeeded but trip data unavailable'));
          }
        }
      },
    );
  }

  /// Cancel trip (Guide cancels the trip)
  Future<void> cancelTrip(String tripId, String reason) async {
    // Cache current state before cancelling
    if (state is TripDetailsSuccess) {
      _previousState = state;
    }

    emit(TripCancelling());
    final result = await repo.cancelTrip(tripId, reason);
    result.fold(
      (error) {
        // Restore previous state on failure
        restoreTripDetailsState();
        emit(TripCancelFailed(error));
      },
      (cancelResponse) {
        // Check if trip data is returned in response
        if (cancelResponse.trip != null) {
          currentTrip = cancelResponse.trip;
          emit(TripCancelled(
            cancelResponse.trip!,
            cancelResponse.message ?? 'Trip cancelled successfully',
          ));
        } else {
          // If trip data not in response, refetch trip details
          print('[TripDetailsCubit] Trip data not in cancel response, refetching...');
          _refetchAfterCancelAction(
            tripId,
            cancelResponse.message ?? 'Trip cancelled successfully',
          );
        }
      },
    );
  }

  /// Helper method to refetch trip after cancel action
  Future<void> _refetchAfterCancelAction(String tripId, String message) async {
    final result = await repo.getTripDetails(tripId);
    result.fold(
      (error) {
        // If refetch fails, restore previous state and show error
        restoreTripDetailsState();
        emit(TripCancelFailed('Action succeeded but failed to refresh: $error'));
      },
      (tripDetailsData) {
        currentTrip = tripDetailsData.trip;
        if (currentTrip != null) {
          emit(TripCancelled(currentTrip!, message));
        } else {
          restoreTripDetailsState();
          emit(TripCancelFailed('Action succeeded but trip data unavailable'));
        }
      },
    );
  }

  /// Start trip (Guide starts the trip - moves from upcoming to in_progress)
  /// Shows loading on button, then waits for socket to update status
  Future<void> startTrip(String tripId) async {
    print('[TripDetailsCubit] 🚀 Starting trip: $tripId');

    // Emit loading state to show button loading
    emit(TripStarting());

    final result = await repo.startTrip(tripId);
    result.fold(
      (error) {
        // Only emit error state on failure and restore
        print('[TripDetailsCubit] ❌ Start trip failed: $error');
        restoreTripDetailsState();
        emit(TripStartFailed(error));
      },
      (tripDetailsResponse) {
        // Success - but DON'T update the trip manually
        // Just restore the current state and let socket handle the update
        print('[TripDetailsCubit] ✅ Start trip API succeeded, waiting for socket update...');
        restoreTripDetailsState();

        // Socket will automatically receive trip_status_updated event
        // and call _handleTripStatusUpdate which will update the UI
      },
    );
  }

  /// End trip (Guide ends the trip - moves from in_progress to completed)
  /// Shows loading on button, then waits for socket to update status
  Future<void> endTrip(String tripId) async {
    print('[TripDetailsCubit] 🛑 Ending trip: $tripId');

    // Emit loading state to show button loading
    emit(TripEnding());

    final result = await repo.endTrip(tripId);
    result.fold(
      (error) {
        // Only emit error state on failure and restore
        print('[TripDetailsCubit] ❌ End trip failed: $error');
        restoreTripDetailsState();
        emit(TripEndFailed(error));
      },
      (tripDetailsResponse) {
        // Success - but DON'T update the trip manually
        // Just restore the current state and let socket handle the update
        print('[TripDetailsCubit] ✅ End trip API succeeded, waiting for socket update...');
        restoreTripDetailsState();

        // Socket will automatically receive trip_status_updated event
        // and call _handleTripStatusUpdate which will update the UI
      },
    );
  }

  @override
  Future<void> close() {
    disposeSocket();
    return super.close();
  }
}

// DONE: Guide trip details UI
// DONE: Guide join call
// DONE: Proposal handling
// DONE: Socket integration
