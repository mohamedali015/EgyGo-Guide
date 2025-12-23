import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'reset_password_verify_email_state.dart';

class ResetPasswordVerifyEmailCubit
    extends Cubit<ResetPasswordVerifyEmailState> {
  ResetPasswordVerifyEmailCubit() : super(ResetPasswordVerifyEmailInitial());

  static ResetPasswordVerifyEmailCubit get(context) => BlocProvider.of(context);

  TextEditingController emailController = TextEditingController();

  void submitEmail() {
    emit(ResetPasswordVerifyEmailLoading());
    // Simulate a network call or any async operation
    Future.delayed(Duration(seconds: 1), () {
      emit(ResetPasswordVerifyEmailSuccess(emailController.text));
    });
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }
}
