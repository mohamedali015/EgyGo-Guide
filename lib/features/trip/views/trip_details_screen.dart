import 'package:egy_go_guide/core/helper/get_it.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/trip/data/repos/trip_repo.dart';
import 'package:egy_go_guide/features/trip/manager/trip_details_cubit/trip_details_cubit.dart';
import 'package:egy_go_guide/features/trip/views/widgets/trip_details_widgets/trip_details_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({
    super.key,
    required this.tripId,
    this.onTripUpdated, // Callback to refresh trips list
  });

  final String tripId;
  final VoidCallback? onTripUpdated; // Called when socket updates trip

  static const String routeName = "tripDetails";

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  TripDetailsCubit? _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _cubit = TripDetailsCubit(
          getIt<TripRepo>(),
          onTripUpdated: widget.onTripUpdated, // Pass callback to cubit
        )..fetchTripDetails(widget.tripId);
        return _cubit!;
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            // When back button is pressed, return whether socket updates occurred
            final shouldRefresh = _cubit?.hasReceivedSocketUpdate ?? false;
            Navigator.of(context).pop(shouldRefresh);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Trip Details',
              style: AppTextStyles.semiBold20,
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // When back arrow is pressed, return whether socket updates occurred
                final shouldRefresh = _cubit?.hasReceivedSocketUpdate ?? false;
                Navigator.of(context).pop(shouldRefresh);
              },
            ),
          ),
          body: TripDetailsViewBody(),
        ),
      ),
    );
  }
}
