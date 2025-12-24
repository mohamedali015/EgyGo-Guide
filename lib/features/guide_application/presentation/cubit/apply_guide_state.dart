abstract class ApplyGuideState {}

class ApplyGuideInitial extends ApplyGuideState {}

class ApplyGuideLoading extends ApplyGuideState {}

class ApplyGuideSuccess extends ApplyGuideState {
  final String message;

  ApplyGuideSuccess({required this.message});
}

class ApplyGuideError extends ApplyGuideState {
  final String error;

  ApplyGuideError({required this.error});
}

class ApplyGuideToggle extends ApplyGuideState {}
