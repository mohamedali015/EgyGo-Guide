import 'package:flutter/material.dart';

import '../../../core/utils/app_text_styles.dart';
import '../data/models/governorates_response_model.dart';
import '../manager/governorates_cubit/governorates_cubit.dart';
import 'widgets/governorates_category_widgets/governorates_category_view_body.dart';

class GovernoratesCategoryView extends StatelessWidget {
  const GovernoratesCategoryView({super.key});

  static const String routeName = 'governoratesCategoryView';

  @override
  Widget build(BuildContext context) {
    var cubit = GovernoratesCubit.get(context);
    Governorate governorate = cubit.selectedGovernorate!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          governorate.name ?? '',
          style: AppTextStyles.semiBold28.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: GovernoratesCategoryViewBody(),
    );
  }
}
