import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helper/my_responsive.dart';
import '../../../core/shared_widgets/svg_wrapper.dart';
import '../../../core/user/manager/user_cubit/user_cubit.dart';
import '../../../core/user/manager/user_cubit/user_state.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';
import '../../../core/utils/app_text_styles.dart';
import 'favorite_view.dart';
import 'my_profile_view.dart';
import 'widgets/profile_row_widget.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    var userCubit = UserCubit.get(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profile),
        centerTitle: true,
      ),
      body: Padding(
        padding: MyResponsive.paddingSymmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(
              height: MyResponsive.height(value: 40),
            ),
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                // Get image URL from guide photo if available
                String? imageUrl = userCubit.userModel.guide?.photo?.url;

                return ClipOval(
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: MyResponsive.width(value: 150),
                          height: MyResponsive.width(value: 150),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to default image if network image fails
                            return Image.asset(
                              AppAssets.profileImage,
                              width: MyResponsive.width(value: 150),
                              height: MyResponsive.width(value: 150),
                              fit: BoxFit.cover,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: MyResponsive.width(value: 150),
                              height: MyResponsive.width(value: 150),
                              decoration: BoxDecoration(
                                color: AppColors.grey.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          AppAssets.profileImage,
                          width: MyResponsive.width(value: 150),
                          height: MyResponsive.width(value: 150),
                          fit: BoxFit.cover,
                        ),
                );
              },
            ),
            SizedBox(
              height: MyResponsive.height(value: 20),
            ),
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                return Text(
                  userCubit.userModel.name ?? 'User',
                  style: AppTextStyles.semiBold18.copyWith(
                    color: AppColors.primary,
                  ),
                );
              },
            ),
            SizedBox(height: MyResponsive.height(value: 100)),
            ProfileRowWidget(
              title: AppStrings.myProfile,
              imagePath: AppAssets.profilePerson,
              goTo: MyProfileView(),
            ),
            SizedBox(height: MyResponsive.height(value: 38)),
            ProfileRowWidget(
              title: AppStrings.myTrips,
              imagePath: AppAssets.trips,
              goTo: Placeholder(),
            ),
            SizedBox(height: MyResponsive.height(value: 38)),
            ProfileRowWidget(
              title: AppStrings.myFavorites,
              imagePath: AppAssets.profileFavorite,
              goTo: FavoriteView(),
            ),
            SizedBox(height: MyResponsive.height(value: 38)),
            Divider(
              color: AppColors.primary,
              thickness: 1,
            ),
            SizedBox(height: MyResponsive.height(value: 42)),
            InkWell(
              onTap: UserCubit.get(context).logout,
              child: Row(
                children: [
                  SvgWrapper(path: AppAssets.profileLogout),
                  SizedBox(width: MyResponsive.width(value: 20)),
                  Text(
                    AppStrings.logout,
                    style: AppTextStyles.medium18,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
