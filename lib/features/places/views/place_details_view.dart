import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/slider_cubit/slider_cubit.dart';
import 'widgets/place_details_widgets/place_details_view_body.dart';

class PlaceDetailsView extends StatelessWidget {
  const PlaceDetailsView({super.key});

  static const String routeName = 'placeDetailsView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SliderCubit(),
      child: Scaffold(
        body: PlaceDetailsViewBody(),
      ),
    );
  }
}
