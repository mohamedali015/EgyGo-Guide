import 'package:dartz/dartz.dart';
import 'package:egy_go_guide/features/trip/data/models/cancel_trip_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/join_call_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/proposal_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/trip_details_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';

abstract class TripRepo {
  Future<Either<String, TripsResponseModel>> getMyTrips();
  Future<Either<String, TripDetailsResponseModel>> getTripDetails(String tripId);
  Future<Either<String, JoinCallResponseModel>> joinCall(String callId);
  Future<Either<String, ProposalResponseModel>> acceptProposal(String tripId);
  Future<Either<String, ProposalResponseModel>> rejectProposal(String tripId);
  Future<Either<String, CancelTripResponseModel>> cancelTrip(String tripId, String reason);
  Future<Either<String, TripDetailsResponseModel>> startTrip(String tripId);
  Future<Either<String, TripDetailsResponseModel>> endTrip(String tripId);
}
