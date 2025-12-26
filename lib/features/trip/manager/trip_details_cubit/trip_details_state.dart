import 'package:egy_go_guide/features/trip/data/models/join_call_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';

abstract class TripDetailsState {}

class TripDetailsInitial extends TripDetailsState {}

class TripDetailsLoading extends TripDetailsState {}

class TripDetailsSuccess extends TripDetailsState {
  final TripModel trip;

  TripDetailsSuccess(this.trip);
}

class TripDetailsFailure extends TripDetailsState {
  final String errorMessage;

  TripDetailsFailure(this.errorMessage);
}

class CallJoining extends TripDetailsState {}

class CallJoinedSuccess extends TripDetailsState {
  final JoinCallResponseModel callResponse;

  CallJoinedSuccess(this.callResponse);
}

class CallJoinFailed extends TripDetailsState {
  final String errorMessage;

  CallJoinFailed(this.errorMessage);
}

class ProposalAccepting extends TripDetailsState {}

class ProposalAccepted extends TripDetailsState {
  final TripModel trip;
  final String message;

  ProposalAccepted(this.trip, this.message);
}

class ProposalAcceptFailed extends TripDetailsState {
  final String errorMessage;

  ProposalAcceptFailed(this.errorMessage);
}

class ProposalRejecting extends TripDetailsState {}

class ProposalRejected extends TripDetailsState {
  final TripModel trip;
  final String message;

  ProposalRejected(this.trip, this.message);
}

class ProposalRejectFailed extends TripDetailsState {
  final String errorMessage;

  ProposalRejectFailed(this.errorMessage);
}

// Cancel Trip States
class TripCancelling extends TripDetailsState {}

class TripCancelled extends TripDetailsState {
  final TripModel trip;
  final String message;

  TripCancelled(this.trip, this.message);
}

class TripCancelFailed extends TripDetailsState {
  final String errorMessage;

  TripCancelFailed(this.errorMessage);
}
