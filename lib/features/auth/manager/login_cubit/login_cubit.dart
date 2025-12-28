import 'package:egy_go_guide/features/auth/data/repo/auth_repo.dart';
import 'package:egy_go_guide/features/auth/manager/login_cubit/login_state.dart';
import 'package:egy_go_guide/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.repo) : super(LoginInitial());

  static LoginCubit get(context) => BlocProvider.of(context);
  AuthRepo repo;

  // Removed GlobalKey<FormState> from cubit to avoid duplicate key usage across widgets
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obsecureText = true;

  void login() async {
    emit(LoginLoading());
    var result = await repo.login(
      email: emailController.text,
      password: passwordController.text,
    );

    result.fold(
      (error) => emit(LoginFailure(error)),
      (user) async {
        emit(LoginSuccess(user));

        // Add delay to ensure FCM token is ready
        print('[LoginCubit] 🔄 Waiting for FCM token to be ready...');
        await Future.delayed(const Duration(seconds: 2));

        // Register FCM token after successful login
        try {
          final registered = await NotificationService().registerToken();
          if (registered) {
            print('[LoginCubit] ✅ FCM token registered after login');
          } else {
            print('[LoginCubit] ⚠️ FCM token registration returned false');
            // Retry once more after another delay
            await Future.delayed(const Duration(seconds: 2));
            final retryResult = await NotificationService().registerToken();
            if (retryResult) {
              print('[LoginCubit] ✅ FCM token registered after retry');
            } else {
              print('[LoginCubit] ❌ FCM token registration failed after retry');
            }
          }
        } catch (e) {
          print('[LoginCubit] ❌ Failed to register FCM token: $e');
        }
      },
    );
  }

  void changeObsecureText() {
    obsecureText = !obsecureText;
    emit(LoginToggled());
  }
}
