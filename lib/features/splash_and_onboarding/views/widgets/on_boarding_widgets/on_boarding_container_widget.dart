import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import '../../../../../core/cache/cache_data.dart';
import '../../../../../core/cache/cache_helper.dart';
import '../../../../../core/cache/cache_key.dart';
import '../../../../../core/helper/my_responsive.dart';
import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../auth/views/get_started_view.dart';
import '../../../manager/on_boarding_cubit/on_boarding_cubit.dart';

class OnBoardingContainerWidget extends StatelessWidget {
  const OnBoardingContainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = OnBoardingCubit.get(context);
    return Container(
      height: MyResponsive.height(value: 260),
      padding: MyResponsive.paddingSymmetric(
        horizontal: 18,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MyResponsive.radius(value: 16)),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          Text(
            cubit.items[cubit.currentIndex]['title']!,
            style: AppTextStyles.bold20,
          ),
          SizedBox(
            height: MyResponsive.height(value: 8),
          ),
          Padding(
            padding: MyResponsive.paddingSymmetric(horizontal: 5),
            child: Text(
              cubit.items[cubit.currentIndex]['subTitle']!,
              style: AppTextStyles.regular14
                  .copyWith(color: AppColors.black.withValues(alpha: .5)),
              textAlign: TextAlign.center,
            ),
          ),
          // SizedBox(
          //   height: MyResponsive.height(value: 16),
          // ),
          Spacer(),
          DotsIndicator(
            dotsCount: cubit.items.length,
            position: cubit.currentIndex.toDouble(),
            decorator: DotsDecorator(
              activeColor: AppColors.primary,
              color: AppColors.primary.withValues(alpha: 0.5),
              size: Size(
                MyResponsive.width(value: 8),
                MyResponsive.height(value: 8),
              ),
              activeSize: Size(
                MyResponsive.width(value: 24),
                MyResponsive.height(value: 8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(MyResponsive.radius(value: 12)),
              ),
              activeShape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(MyResponsive.radius(value: 12)),
              ),
            ),
          ),
          SizedBox(
            height: MyResponsive.height(value: 20),
          ),
          CustomButton(
            title: cubit.currentIndex == cubit.items.length - 1
                ? AppStrings.getStarted
                : AppStrings.next,
            onPressed: () {
              if (cubit.currentIndex == cubit.items.length - 1) {
                CacheHelper.saveData(key: CacheKeys.firstTime, value: true);
                CacheData.firstTime = true;
                Navigator.pushNamedAndRemoveUntil(
                    context, GetStartedView.routeName, (route) => false);
              } else {
                cubit.nextPage();
              }
            },
          )
        ],
      ),
    );
  }
}
