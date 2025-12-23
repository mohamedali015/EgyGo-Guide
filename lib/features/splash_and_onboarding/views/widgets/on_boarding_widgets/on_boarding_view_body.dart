import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/helper/my_responsive.dart';
import '../../../manager/on_boarding_cubit/on_boarding_cubit.dart';
import '../../../manager/on_boarding_cubit/on_boarding_state.dart';
import 'on_boarding_container_widget.dart';
import 'on_boarding_page_view.dart';

class OnBoardingViewBody extends StatelessWidget {
  const OnBoardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OnBoardingPageView(),
        Padding(
          padding: MyResponsive.paddingSymmetric(horizontal: 20),
          child: Column(
            children: [
              Spacer(),
              BlocBuilder<OnBoardingCubit, OnBoardingState>(
                builder: (context, state) {
                  return OnBoardingContainerWidget();
                },
              ),
              SizedBox(
                height: MyResponsive.height(value: 30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
