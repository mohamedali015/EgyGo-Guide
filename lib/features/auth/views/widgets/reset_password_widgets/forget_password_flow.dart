import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/helper/get_it.dart';
import '../../../data/repo/auth_repo.dart';
import '../../../manager/reset_password_new_password_cubit/reset_password_new_password_cubit.dart';
import '../../../manager/reset_password_otp_cubit/reset_password_otp_cubit.dart';
import '../../../manager/reset_password_verify_email_cubit/reset_password_verify_email_cubit.dart';
import '../../reset_password_new_pass_view.dart';
import '../../reset_password_otp_view.dart';
import '../../reset_password_verify_email_view.dart';

class ForgetPasswordFlow extends StatelessWidget {
  static const String routeName = 'forgetPasswordFlow';

  const ForgetPasswordFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ResetPasswordVerifyEmailCubit()),
        BlocProvider(create: (_) => ResetPasswordOtpCubit(getIt<AuthRepo>())),
        BlocProvider(
            create: (_) => ResetPasswordNewPasswordCubit(getIt<AuthRepo>())),
      ],
      child: Navigator(
        initialRoute: ResetPasswordVerifyEmailView.routeName,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case ResetPasswordVerifyEmailView.routeName:
              return MaterialPageRoute(
                  builder: (_) => ResetPasswordVerifyEmailView());
            case ResetPasswordOtpView.routeName:
              return MaterialPageRoute(
                builder: (_) => ResetPasswordOtpView(
                  email: ResetPasswordVerifyEmailCubit.get(context)
                      .emailController
                      .text,
                ),
              );
            case ResetPasswordNewPassView.routeName:
              return MaterialPageRoute(
                  builder: (_) => ResetPasswordNewPassView(
                        email: ResetPasswordVerifyEmailCubit.get(context)
                            .emailController
                            .text,
                      ));
            default:
              return MaterialPageRoute(
                  builder: (_) => ResetPasswordVerifyEmailView());
          }
        },
      ),
    );
  }
}
