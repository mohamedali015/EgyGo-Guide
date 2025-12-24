import 'package:egy_go_guide/core/user/manager/user_cubit/user_cubit.dart';
import 'package:egy_go_guide/features/guide_application/presentation/views/apply_guide_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helper/get_it.dart';
import '../../../core/helper/my_navigator.dart';
import '../../../core/helper/my_snackbar.dart';
import '../../../core/shared_widgets/custom_progress_hud.dart';
import '../data/repo/auth_repo.dart';
import '../manager/login_cubit/login_cubit.dart';
import '../manager/login_cubit/login_state.dart';
import 'register_otp_view.dart';
import 'widgets/login_widgets/login_view_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const String routeName = 'LoginView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        getIt<AuthRepo>(),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          body: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                if (state.user.role != 'guide') {
                  MySnackbar.error(context,
                      "You are not authorized to access this app.\nDownload the user app instead.");
                } else if (state.user.isEmailVerified != true) {
                  MyNavigator.goTo(
                    screen: RegisterOtpView(
                      email: state.user.email!,
                    ),
                    isReplace: true,
                  );
                } else {
                  MySnackbar.success(context, 'Login Successful');
                  UserCubit.get(context).getUserData();
                  MyNavigator.goTo(screen: ApplyGuideScreen());
                  //ToDo: Navigate to Home View
                  // Navigator.pushNamedAndRemoveUntil(
                  //     context, AppHomeView.routeName, (route) => false);
                }
              }
              if (state is LoginFailure) {
                MySnackbar.error(context, state.errorMessage);
              }
            },
            builder: (context, state) {
              return CustomProgressHud(
                isLoading: state is LoginLoading ? true : false,
                child: LoginViewBody(),
              );
            },
          ),
        ),
      ),
    );
  }
}
