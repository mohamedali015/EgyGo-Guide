import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/places_cubit/places_cubit.dart';
import '../manager/places_cubit/places_state.dart';
import 'widgets/places_view_body.dart';

class PlacesView extends StatelessWidget {
  const PlacesView({super.key});

  static const String routeName = 'PlacesView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<PlacesCubit, PlacesState>(
        builder: (context, state) {
          return PlacesViewBody();
        },
      ),
    );
  }
}
