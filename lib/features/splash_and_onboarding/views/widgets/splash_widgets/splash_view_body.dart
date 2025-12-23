import 'package:flutter/material.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../../../../../core/cache/cache_data.dart';
import '../../../../../core/cache/cache_helper.dart';
import '../../../../../core/cache/cache_key.dart';
import '../../../../../core/helper/my_navigator.dart';
import '../../../../../core/helper/my_responsive.dart';
import '../../../../../core/user/manager/user_cubit/user_cubit.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../auth/views/get_started_view.dart';
import '../../on_boarding_view.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      navigate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WidgetAnimator(
      incomingEffect: WidgetTransitionEffects.outgoingScaleUp(
        duration: const Duration(milliseconds: 1200),
      ),
      child: Center(
        child: Image.asset(
          AppAssets.splashImage,
          width: MyResponsive.width(value: 175),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  void navigate(context) async {
    Future.delayed((Duration(milliseconds: 500)), () {
      // navigate to lets start view
      CacheData.firstTime = CacheHelper.getData(key: CacheKeys.firstTime);
      if (CacheData.firstTime != null) {
        // check is logged in
        CacheData.accessToken = CacheHelper.getData(key: CacheKeys.accessToken);
        if (CacheData.accessToken != null) {
          UserCubit.get(context).getUserData().then((bool result) {
            if (result) {
              // ToDo: go to home
              // MyNavigator.goTo(screen: AppHomeView(), isReplace: true);
            } else {
              MyNavigator.goTo(screen: GetStartedView(), isReplace: true);
            }
          });
        } else {
          // goto login
          MyNavigator.goTo(screen: GetStartedView(), isReplace: true);
        }
      } else {
        // first time
        MyNavigator.goTo(screen: OnBoardingView(), isReplace: true);
      }
    });
  }
}
