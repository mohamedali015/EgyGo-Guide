import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';

class ProposalResponseModel {
  bool? success;
  String? message;
  TripModel? trip;

  ProposalResponseModel({this.success, this.message, this.trip});

  ProposalResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    trip = json['data'] != null ? TripModel.fromJson(json['data']) : null;
  }
}

