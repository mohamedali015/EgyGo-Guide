import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/helper/get_it.dart';
import '../../../core/helper/my_snackbar.dart';
import '../../../core/shared_widgets/custom_progress_hud.dart';
import '../data/repo/auth_repo.dart';
import '../manager/register_cubit/register_cubit.dart';
import '../manager/register_cubit/register_state.dart';
import 'login_view.dart';
import 'widgets/register_widgets/register_view_body.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  static const String routeName = 'RegisterView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(
        getIt<AuthRepo>(),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          body: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
              if (state is RegisterSuccess) {
                MySnackbar.success(context,
                    'Registration successful! Please log in to verify your email.');

                Navigator.pushReplacementNamed(context, LoginView.routeName);
              }
              if (state is RegisterError) {
                MySnackbar.error(context, state.error);
              }
            },
            builder: (context, state) {
              return CustomProgressHud(
                isLoading: state is RegisterLoading,
                child: RegisterViewBody(),
              );
            },
          ),
        ),
      ),
    );
  }
}
