import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/data/repos/trip_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  TripsCubit(this.repo) : super(TripsInitial());

  static TripsCubit get(context) => BlocProvider.of(context);
  final TripRepo repo;

  List<TripModel> allTrips = [];
  List<TripModel> filteredTrips = [];
  String selectedFilter = 'all';

  Future<void> fetchTrips() async {
    emit(TripsLoading());
    final result = await repo.getMyTrips();
    result.fold(
      (error) {
        emit(TripsFailure(error));
      },
      (tripsData) {
        allTrips.clear();
        if (tripsData.trips != null) {
          allTrips.addAll(tripsData.trips!);
        }
        filteredTrips = List.from(allTrips);
        emit(TripsSuccess(filteredTrips));
      },
    );
  }

  void filterTrips(String filter) {
    selectedFilter = filter;

    if (filter == 'all') {
      filteredTrips = List.from(allTrips);
    } else if (filter == 'ongoing') {
      filteredTrips = allTrips.where((trip) {
        return trip.status != 'cancelled' &&
               trip.status != 'completed' &&
               trip.status != 'rejected';
      }).toList();
    } else if (filter == 'completed') {
      filteredTrips = allTrips.where((trip) => trip.status == 'completed').toList();
    } else if (filter == 'cancelled') {
      filteredTrips = allTrips.where((trip) =>
        trip.status == 'cancelled' || trip.status == 'rejected'
      ).toList();
    }

    emit(TripsSuccess(filteredTrips));
  }
}

// DONE: Guide trips list
// DONE: Socket integration for trips list
