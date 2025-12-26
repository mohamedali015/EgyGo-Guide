import 'package:egy_go_guide/features/trip/data/models/trips_response_model.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trips_widgets/trip_item.dart';
import 'package:flutter/material.dart';

class TripListView extends StatelessWidget {
  const TripListView({super.key, required this.trips});

  final List<TripModel> trips;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        return TripItem(trip: trips[index]);
      },
    );
  }
}

