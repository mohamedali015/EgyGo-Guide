import 'package:egy_go_guide/core/helper/get_it.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/repos/trip_repo.dart';
import 'package:egy_go_guide/features/trip/manager/trips_cubit/trips_cubit.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trips_widgets/trips_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripsView extends StatelessWidget {
  const TripsView({super.key});

  static const String routeName = "trips";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripsCubit(getIt<TripRepo>())..fetchTrips(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Trips',
            style: AppTextStyles.semiBold20,
          ),
          centerTitle: true,
        ),
        body: TripsViewBody(),
      ),
    );
  }
}

