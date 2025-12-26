import 'package:egy_go_guide/core/helper/my_responsive.dart';
import 'package:egy_go_guide/core/shared_widgets/custom_loading_indicator.dart';
import 'package:egy_go_guide/features/trip/manager/trips_cubit/trips_cubit.dart';
import 'package:egy_go_guide/features/trip/manager/trips_cubit/trips_state.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trips_widgets/trip_filter_chips.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trips_widgets/trip_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripsViewBody extends StatelessWidget {
  const TripsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripsCubit, TripsState>(
      builder: (context, state) {
        if (state is TripsLoading) {
          return CustomLoadingIndicator();
        } else if (state is TripsFailure) {
          return Center(
            child: Text(state.errorMessage),
          );
        } else if (state is TripsSuccess) {
          final cubit = TripsCubit.get(context);

          if (cubit.allTrips.isEmpty) {
            return Center(
              child: Text('No trips found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await cubit.fetchTrips();
            },
            child: Column(
              children: [
                SizedBox(height: MyResponsive.height(value: 16)),
                TripFilterChips(),
                SizedBox(height: MyResponsive.height(value: 16)),
                Expanded(
                  child: cubit.filteredTrips.isEmpty
                      ? Center(
                          child: Text('No trips in this category'),
                        )
                      : TripListView(trips: cubit.filteredTrips),
                ),
              ],
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}
