import 'package:flutter_bloc/flutter_bloc.dart';

import 'slider_state.dart';

class SliderCubit extends Cubit<SliderState> {
  SliderCubit() : super(SliderInitial());

  static SliderCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  void changeSliderIndex(int index) {
    currentIndex = index;
    emit(SliderIndexChanged(currentIndex: currentIndex));
  }
}
