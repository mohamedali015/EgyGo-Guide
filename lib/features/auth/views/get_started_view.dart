import 'package:flutter/material.dart';

import 'widgets/get_started_widgets/get_started_view_body.dart';

class GetStartedView extends StatelessWidget {
  const GetStartedView({super.key});

  static const String routeName = 'get_started';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GetStartedViewBody(),
      ),
    );
  }
}
