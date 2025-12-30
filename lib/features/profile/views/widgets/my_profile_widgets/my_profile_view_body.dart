import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/helper/my_navigator.dart';
import '../../../../../core/helper/my_responsive.dart';
import '../../../../../core/helper/my_snackbar.dart';
import '../../../../../core/shared_widgets/custom_button.dart';
import '../../../../../core/user/manager/user_cubit/user_cubit.dart';
import '../../../../../core/user/manager/user_cubit/user_state.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../features/governorates/manager/governorates_cubit/governorates_cubit.dart';
import '../../../../../features/governorates/manager/governorates_cubit/governorates_state.dart';
import 'showing_dialog_widget.dart';

class MyProfileViewBody extends StatelessWidget {
  const MyProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var userCubit = UserCubit.get(context);
    var governoratesCubit = GovernoratesCubit.get(context);

    // Fetch governorates if not already loaded
    if (governoratesCubit.governorates.isEmpty) {
      governoratesCubit.fetchGovernorates();
    }

    return Form(
        key: userCubit.formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: MyResponsive.paddingSymmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: MyResponsive.height(value: 25)),
                // CircleAvatar(
                //   radius: MyResponsive.width(value: 50),
                //   backgroundColor: Colors.transparent,
                //   child: ImageManagerView(
                //     onPicked: (XFile imageFile) {
                //       userCubit.imageFile = imageFile;
                //     },
                //     pickedBody: (XFile imageFile) {
                //       return ProfileImageWidget(
                //         imagePath: imageFile.path,
                //         isLocalFile: true,
                //         width: MyResponsive.width(value: 100),
                //       );
                //     },
                //     unPickedBody: ProfileImageWidget(
                //         imagePath: userCubit.userModel.imagePath,
                //         width: MyResponsive.width(value: 100)),
                //   ),
                // ),
                SizedBox(height: MyResponsive.height(value: 25)),

                // Guide-specific fields
                if (userCubit.userModel.role == 'guide') ...[
                  // Active/Inactive Toggle
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: userCubit.isGuideActive
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: userCubit.isGuideActive
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Profile Status',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: userCubit.isGuideActive
                                          ? AppColors.primary
                                          : AppColors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: userCubit.isGuideActive
                                          ? AppColors.primary
                                          : AppColors.grey,
                                    ),
                                    child: Text(
                                      userCubit.isGuideActive
                                          ? 'You are currently active'
                                          : 'You are currently inactive',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: userCubit.isGuideActive,
                              onChanged: (value) {
                                userCubit.toggleGuideActiveStatus();
                              },
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: MyResponsive.height(value: 20)),

                  // Bio field
                  TextFormField(
                    controller: userCubit.bioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your bio';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MyResponsive.height(value: 15)),

                  // Price per hour field
                  TextFormField(
                    controller: userCubit.pricePerHourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price Per Hour (EGP)',
                      hintText: 'Enter your hourly rate',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your price per hour';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MyResponsive.height(value: 15)),

                  // Languages field
                  BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      return Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Languages *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildLanguageChip(
                                    context, userCubit, 'English'),
                                _buildLanguageChip(
                                    context, userCubit, 'Arabic'),
                                _buildLanguageChip(
                                    context, userCubit, 'Spanish'),
                                _buildLanguageChip(
                                    context, userCubit, 'French'),
                                _buildLanguageChip(
                                    context, userCubit, 'German'),
                                _buildLanguageChip(
                                    context, userCubit, 'Italian'),
                                _buildLanguageChip(
                                    context, userCubit, 'Chinese'),
                                _buildLanguageChip(
                                    context, userCubit, 'Japanese'),
                                _buildLanguageChip(
                                    context, userCubit, 'Russian'),
                                _buildLanguageChip(
                                    context, userCubit, 'Portuguese'),
                                _buildLanguageChip(
                                    context, userCubit, 'Turkish'),
                                _buildLanguageChip(
                                    context, userCubit, 'Korean'),
                                _buildLanguageChip(context, userCubit, 'Hindi'),
                                _buildLanguageChip(context, userCubit, 'Dutch'),
                                _buildLanguageChip(context, userCubit, 'Greek'),
                              ],
                            ),
                            if (userCubit.selectedLanguages.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Please select at least one language',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: MyResponsive.height(value: 15)),

                  // Governorates field
                  BlocBuilder<GovernoratesCubit, GovernoratesState>(
                    builder: (context, govState) {
                      if (govState is GovernoratesLoading) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return BlocBuilder<UserCubit, UserState>(
                        builder: (context, userState) {
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Governorates *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                if (governoratesCubit.governorates.isEmpty)
                                  Text(
                                    'No governorates available',
                                    style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 14,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: governoratesCubit.governorates
                                        .map((gov) {
                                      return _buildGovernorateChip(context,
                                          userCubit, gov.sId!, gov.name!);
                                    }).toList(),
                                  ),
                                if (userCubit.selectedProvinces.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Please select at least one governorate',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],

                SizedBox(height: MyResponsive.height(value: 40)),
                BlocListener<UserCubit, UserState>(
                  listener: (context, state) {
                    if (state is UserDeleteSuccess) {
                      MySnackbar.success(context, state.message);
                    } else if (state is UserUpdateSuccess) {
                      MySnackbar.success(context, state.message);
                      MyNavigator.pop();
                    } else if (state is UserUpdateError) {
                      MySnackbar.error(context, state.error);
                    } else if (state is UserDeleteError) {
                      MySnackbar.error(context, state.error);
                    }
                  },
                  child: BlocBuilder<UserCubit, UserState>(
                    builder: (context, state) {
                      return CustomButton(
                        title: AppStrings.save,
                        onPressed: state is UserUpdateLoading
                            ? null
                            : userCubit.updateProfile,
                        foregroundColor: AppColors.white,
                      );
                    },
                  ),
                ),
                SizedBox(height: MyResponsive.height(value: 200)),
                CustomButton(
                  title: AppStrings.deleteAccount,
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => const ShowingDialogWidget(),
                    );
                  },
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                ),
                SizedBox(height: MyResponsive.height(value: 50)),
              ],
            ),
          ),
        ));
  }

  Widget _buildLanguageChip(
      BuildContext context, UserCubit userCubit, String language) {
    final isSelected = userCubit.selectedLanguages.contains(language);
    return FilterChip(
      label: Text(language),
      selected: isSelected,
      onSelected: (selected) {
        userCubit.toggleLanguage(language);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.grey,
      ),
    );
  }

  Widget _buildGovernorateChip(BuildContext context, UserCubit userCubit,
      String provinceId, String name) {
    final isSelected = userCubit.selectedProvinces.contains(provinceId);
    return FilterChip(
      label: Text(name),
      selected: isSelected,
      onSelected: (selected) {
        userCubit.toggleProvince(provinceId);
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.grey,
      ),
    );
  }
}
