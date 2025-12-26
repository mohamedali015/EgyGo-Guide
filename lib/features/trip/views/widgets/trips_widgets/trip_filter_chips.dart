import 'package:egy_go_guide/core/utils/app_colors.dart';
import 'package:egy_go_guide/features/trip/manager/trips_cubit/trips_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripFilterChips extends StatelessWidget {
  const TripFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = TripsCubit.get(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'All',
            value: 'all',
            isSelected: cubit.selectedFilter == 'all',
            onSelected: () => cubit.filterTrips('all'),
          ),
          SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Ongoing',
            value: 'ongoing',
            isSelected: cubit.selectedFilter == 'ongoing',
            onSelected: () => cubit.filterTrips('ongoing'),
          ),
          SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Completed',
            value: 'completed',
            isSelected: cubit.selectedFilter == 'completed',
            onSelected: () => cubit.filterTrips('completed'),
          ),
          SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Cancelled',
            value: 'cancelled',
            isSelected: cubit.selectedFilter == 'cancelled',
            onSelected: () => cubit.filterTrips('cancelled'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

