import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helper/my_responsive.dart';
import '../../../../core/shared_widgets/custom_error_widget.dart';
import '../../../../core/shared_widgets/custom_loading_indicator.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../home/views/widgets/place_item.dart';
import '../../manager/home_search_cubit/home_search_cubit.dart';
import '../../manager/home_search_cubit/home_search_state.dart';

class SearchResultListView extends StatelessWidget {
  const SearchResultListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeSearchCubit, HomeSearchState>(
        builder: (context, state) {
      if (state is HomeSearchSuccess) {
        if (state.places.isEmpty) {
          return CustomErrorWidget(errorMessage: "No Places found.");
        } else {
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return PlaceItem(
                place: state.places[index],
                index: index,
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: MyResponsive.height(value: 16),
              );
            },
            itemCount: state.places.length,
          );
        }
      } else if (state is HomeSearchFailure) {
        return SizedBox(
          height: MyResponsive.height(value: 210),
          child: CustomErrorWidget(errorMessage: state.errorMessage),
        );
      } else if (state is HomeSearchLoading) {
        return SizedBox(
          height: MyResponsive.height(value: 210),
          child: const CustomLoadingIndicator(),
        );
      } else {
        return CustomErrorWidget(errorMessage: AppStrings.noResults);
      }
    });
  }
}
