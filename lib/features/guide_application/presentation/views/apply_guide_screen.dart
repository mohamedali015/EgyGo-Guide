import 'package:egy_go_guide/core/helper/get_it.dart';
import 'package:egy_go_guide/core/helper/my_navigator.dart';
import 'package:egy_go_guide/core/helper/my_snackbar.dart';
import 'package:egy_go_guide/core/shared_widgets/custom_button.dart';
import 'package:egy_go_guide/core/shared_widgets/custom_progress_hud.dart';
import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/core/utils/app_text_styles.dart';
import 'package:egy_go_guide/features/guide_application/data/repos/guide_application_repo.dart';
import 'package:egy_go_guide/features/guide_application/presentation/cubit/apply_guide_cubit.dart';
import 'package:egy_go_guide/features/guide_application/presentation/cubit/apply_guide_state.dart';
import 'package:egy_go_guide/features/governorates/manager/governorates_cubit/governorates_cubit.dart';
import 'package:egy_go_guide/features/governorates/manager/governorates_cubit/governorates_state.dart';
import 'package:egy_go_guide/features/home/views/app_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplyGuideScreen extends StatelessWidget {
  const ApplyGuideScreen({super.key});

  static const String routeName = 'ApplyGuideScreen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApplyGuideCubit(getIt<GuideApplicationRepo>()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Apply as Guide',
            style: AppTextStyles.semiBold20,
          ),
        ),
        body: BlocConsumer<ApplyGuideCubit, ApplyGuideState>(
          listener: (context, state) {
            if (state is ApplyGuideSuccess) {
              MySnackbar.success(context, state.message);
              MyNavigator.goTo(screen: AppHomeView(), isReplace: true);
            }
            if (state is ApplyGuideError) {
              MySnackbar.error(context, state.error);
            }
          },
          builder: (context, state) {
            final cubit = ApplyGuideCubit.get(context);
            return CustomProgressHud(
              isLoading: state is ApplyGuideLoading,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete your guide application by uploading the required documents.',
                      style: AppTextStyles.regular14.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildFilePickerTile(
                      context: context,
                      title: 'National ID or Passport',
                      subtitle: 'Required',
                      file: cubit.idDocument,
                      onTap: cubit.pickIdDocument,
                    ),
                    SizedBox(height: 16),
                    _buildFilePickerTile(
                      context: context,
                      title: 'Profile Photo',
                      subtitle: 'Required',
                      file: cubit.photo,
                      onTap: cubit.pickPhoto,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: cubit.isLicensed,
                          onChanged: (value) => cubit.toggleLicensed(),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            'I have a tourism license',
                            style: AppTextStyles.regular14,
                          ),
                        ),
                      ],
                    ),
                    if (cubit.isLicensed) ...[
                      SizedBox(height: 16),
                      _buildFilePickerTile(
                        context: context,
                        title: 'Tourism License Card',
                        subtitle: 'Required if licensed',
                        file: cubit.tourismCard,
                        onTap: cubit.pickTourismCard,
                      ),
                    ],
                    SizedBox(height: 16),
                    _buildFilePickerTile(
                      context: context,
                      title: 'Language Proficiency Certificate',
                      subtitle: 'Optional',
                      file: cubit.englishCertificate,
                      onTap: cubit.pickEnglishCertificate,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Languages',
                      style: AppTextStyles.semiBold16,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select languages you speak (Required)',
                      style: AppTextStyles.regular12.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildLanguagesSelector(context, cubit),
                    SizedBox(height: 24),
                    Text(
                      'Governorates',
                      style: AppTextStyles.semiBold16,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select governorates where you can guide (Required)',
                      style: AppTextStyles.regular12.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildGovernoratesSelector(context, cubit),
                    SizedBox(height: 24),
                    Text(
                      'Price per Hour',
                      style: AppTextStyles.semiBold16,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: cubit.pricePerHourController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter your hourly rate',
                        hintStyle: AppTextStyles.regular14
                            .copyWith(color: AppColors.grey),
                        filled: true,
                        fillColor: AppColors.fill,
                        prefixIcon:
                            Icon(Icons.attach_money, color: AppColors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.grey.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.grey.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Bio',
                      style: AppTextStyles.semiBold16,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: cubit.bioController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Tell us about yourself and your experience as a guide',
                        hintStyle: AppTextStyles.regular14
                            .copyWith(color: AppColors.grey),
                        filled: true,
                        fillColor: AppColors.fill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.grey.withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppColors.grey.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    CustomButton(
                      title: 'Submit Application',
                      onPressed: cubit.applyAsGuide,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguagesSelector(BuildContext context, ApplyGuideCubit cubit) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cubit.availableLanguages.map((language) {
        final isSelected = cubit.selectedLanguages.contains(language);
        return FilterChip(
          label: Text(language),
          selected: isSelected,
          onSelected: (selected) {
            cubit.toggleLanguage(language);
          },
          selectedColor: AppColors.primary,
          checkmarkColor: AppColors.white,
          labelStyle: AppTextStyles.regular14.copyWith(
            color: isSelected ? AppColors.white : AppColors.black,
          ),
          backgroundColor: AppColors.fill,
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withValues(alpha: 0.3),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGovernoratesSelector(
      BuildContext context, ApplyGuideCubit cubit) {
    return BlocBuilder<GovernoratesCubit, GovernoratesState>(
      builder: (context, state) {
        if (state is GovernoratesLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is GovernoratesSuccess) {
          if (state.governorates.isEmpty) {
            return Center(
              child: Text(
                'No governorates available',
                style: AppTextStyles.regular14.copyWith(color: AppColors.grey),
              ),
            );
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.governorates.map((governorate) {
              final isSelected =
                  cubit.selectedGovernorates.contains(governorate);
              return FilterChip(
                label: Text(governorate.name ?? 'Unknown'),
                selected: isSelected,
                onSelected: (selected) {
                  cubit.toggleGovernorate(governorate);
                },
                selectedColor: AppColors.primary,
                checkmarkColor: AppColors.white,
                labelStyle: AppTextStyles.regular14.copyWith(
                  color: isSelected ? AppColors.white : AppColors.black,
                ),
                backgroundColor: AppColors.fill,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.grey.withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          );
        } else if (state is GovernoratesFailure) {
          return Center(
            child: Text(
              'Failed to load governorates',
              style: AppTextStyles.regular14.copyWith(color: AppColors.grey),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildFilePickerTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required dynamic file,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.semiBold16,
        ),
        subtitle: Text(
          file != null ? 'File selected' : subtitle,
          style: AppTextStyles.regular14.copyWith(
            color: file != null ? AppColors.primary : AppColors.grey,
          ),
        ),
        trailing: Icon(
          file != null ? Icons.check_circle : Icons.upload_file,
          color: file != null ? AppColors.primary : AppColors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
