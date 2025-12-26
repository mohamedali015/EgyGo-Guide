import 'package:egy_go_guide/core/helper/get_it.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/repos/trip_repo.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_cubit.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trip_details_widgets/trip_details_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key, required this.tripId});

  final String tripId;

  static const String routeName = "tripDetails";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TripDetailsCubit(getIt<TripRepo>())..fetchTripDetails(tripId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Trip Details',
            style: AppTextStyles.semiBold20,
          ),
          centerTitle: true,
        ),
        body: TripDetailsViewBody(),
      ),
    );
  }
}

