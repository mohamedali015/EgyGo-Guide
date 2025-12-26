import 'package:dartz/dartz.dart';
import 'package:egy_go_guide/core/network/api_helper.dart';
import 'package:egy_go_guide/core/network/api_response.dart';
import 'package:egy_go_guide/core/network/end_points.dart';
import 'package:egy_go_guide/features/trip/data/models/cancel_trip_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/join_call_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/proposal_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/trip_details_response_model.dart';
import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/data/repos/trip_repo.dart';

class TripRepoImpl implements TripRepo {
  final ApiHelper apiHelper;

  TripRepoImpl({required this.apiHelper});

  @override
  Future<Either<String, TripsResponseModel>> getMyTrips() async {
    try {
      ApiResponse response = await apiHelper.getRequest(
        endPoint: EndPoints.getMyTrips,
        isProtected: true,
      );
      TripsResponseModel tripsResponseModel =
          TripsResponseModel.fromJson(response.data);
      if (tripsResponseModel.success != null &&
          tripsResponseModel.success == true) {
        return Right(tripsResponseModel);
      } else {
        throw Exception("Failed to fetch trips.");
      }
    } catch (e) {
      ApiResponse errorResponse = ApiResponse.fromError(e);
      return Left(errorResponse.message);
    }
  }

  @override
  Future<Either<String, TripDetailsResponseModel>> getTripDetails(
      String tripId) async {
    try {
      ApiResponse response = await apiHelper.getRequest(
        endPoint: EndPoints.getTripDetails(tripId),
        isProtected: true,
      );
      TripDetailsResponseModel tripDetailsResponseModel =
          TripDetailsResponseModel.fromJson(response.data);
      if (tripDetailsResponseModel.success != null &&
          tripDetailsResponseModel.success == true) {
        return Right(tripDetailsResponseModel);
      } else {
        throw Exception("Failed to fetch trip details.");
      }
    } catch (e) {
      ApiResponse errorResponse = ApiResponse.fromError(e);
      return Left(errorResponse.message);
    }
  }

  @override
  Future<Either<String, JoinCallResponseModel>> joinCall(String callId) async {
    try {
      ApiResponse response = await apiHelper.getRequest(
        endPoint: EndPoints.joinCall(callId),
        isProtected: true,
      );
      JoinCallResponseModel joinCallResponseModel =
          JoinCallResponseModel.fromJson(response.data);
      if (joinCallResponseModel.success != null &&
          joinCallResponseModel.success == true) {
        return Right(joinCallResponseModel);
      } else {
        throw Exception("Failed to join call.");
      }
    } catch (e) {
      ApiResponse errorResponse = ApiResponse.fromError(e);
      return Left(errorResponse.message);
    }
  }

  @override
  Future<Either<String, ProposalResponseModel>> acceptProposal(
      String tripId) async {
    try {
      ApiResponse response = await apiHelper.putRequest(
        endPoint: EndPoints.acceptTrip(tripId),
        isProtected: true,
      );
      ProposalResponseModel proposalResponseModel =
          ProposalResponseModel.fromJson(response.data);
      if (proposalResponseModel.success != null &&
          proposalResponseModel.success == true) {
        return Right(proposalResponseModel);
      } else {
        throw Exception("Failed to accept proposal.");
      }
    } catch (e) {
      ApiResponse errorResponse = ApiResponse.fromError(e);
      return Left(errorResponse.message);
    }
  }

  @override
  Future<Either<String, ProposalResponseModel>> rejectProposal(
      String tripId) async {
    try {
      ApiResponse response = await apiHelper.putRequest(
        endPoint: EndPoints.rejectTrip(tripId),
        isProtected: true,
      );
      ProposalResponseModel proposalResponseModel =
          ProposalResponseModel.fromJson(response.data);
      if (proposalResponseModel.success != null &&
          proposalResponseModel.success == true) {
        return Right(proposalResponseModel);
      } else {
        throw Exception("Failed to reject proposal.");
      }
    } catch (e) {
      ApiResponse errorResponse = ApiResponse.fromError(e);
      return Left(errorResponse.message);
    }
  }

  @override
  Future<Either<String, CancelTripResponseModel>> cancelTrip(
      String tripId, String reason) async {
    try {
      ApiResponse response = await apiHelper.putRequest(
        endPoint: EndPoints.cancelTrip(tripId),
        isProtected: true,
        data: {
          'reason': reason,
        },
      );
      CancelTripResponseModel cancelTripResponseModel =
          CancelTripResponseModel.fromJson(response.data);
      if (cancelTripResponseModel.success != null &&
          cancelTripResponseModel.success == true) {
        return Right(cancelTripResponseModel);
      } else {
        throw Exception("Failed to cancel trip.");
      }
    } catch (e) {
      ApiResponse errorResponse = ApiResponse.fromError(e);
      return Left(errorResponse.message);
    }
  }
}
