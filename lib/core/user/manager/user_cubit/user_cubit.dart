import 'package:egy_go_guide/core/services/notification_service.dart';
import 'package:egy_go_guide/core/user/data/models/user_model.dart';
import 'package:egy_go_guide/features/places/data/models/places_response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/cache/cache_helper.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/helper/my_navigator.dart';
import '../../../../features/auth/views/get_started_view.dart';
import '../../data/repo/user_repo.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this.userRepo) : super(UserInitial());

  static UserCubit get(context) => BlocProvider.of(context);

  /// Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Data
  UserModel userModel = UserModel();
  List<Place> favoritePlaces = [];

  final UserRepo userRepo;

  /// get user data
  Future<bool> getUserData() async {
    emit(UserLoading());
    var response = await userRepo.getUserData();
    return response.fold(
      (error) {
        emit(UserGetError(error: error));
        return false;
      },
      (user) async {
        userModel = user;

        nameController.text = userModel.name ?? '';
        phoneController.text = userModel.phone ?? '';

        emit(UserGetSuccess(userModel: user));

        // Debug: Print fcmTokens status
        print('[UserCubit] 🔍 User data loaded');
        print('[UserCubit] 🔍 fcmTokens field: ${userModel.fcmTokens}');
        print('[UserCubit] 🔍 Is null? ${userModel.fcmTokens == null}');
        print('[UserCubit] 🔍 Is empty? ${userModel.fcmTokens?.isEmpty}');

        // Register FCM token if not already registered - with delay to ensure service is ready
        Future.delayed(const Duration(seconds: 1), () async {
          try {
            if (userModel.fcmTokens == null || userModel.fcmTokens!.isEmpty) {
              print('[UserCubit] 📤 No FCM tokens found in user data, registering now...');
              final success = await NotificationService().registerToken();
              if (success) {
                print('[UserCubit] ✅ FCM token registration completed successfully');
              } else {
                print('[UserCubit] ❌ FCM token registration failed');
              }
            } else {
              print('[UserCubit] ✅ FCM tokens already registered: ${userModel.fcmTokens!.length} token(s)');
            }
          } catch (e, stackTrace) {
            print('[UserCubit] ❌ Exception during FCM token registration: $e');
            print('[UserCubit] Stack trace: $stackTrace');
          }
        });

        return true;
      },
    );
  }

  // /// update user data
  // Future<void> updateUserData() async {
  //   if (formKey.currentState!.validate()) {
  //     emit(UserUpdateLoading());
  //     var result = await userRepo.updateUserData(
  //       name: nameController.text,
  //       phone: phoneController.text,
  //       imageFile: imageFile,
  //     );
  //
  //     result.fold(
  //           (String error) {
  //         emit(UserUpdateError(error: error));
  //       },
  //           (message) async {
  //         await getUserData();
  //         emit(UserUpdateSuccess(message: message));
  //       },
  //     );
  //   } else {
  //     emit(UserUpdateError(error: TranslationKeys.fillAllFields.tr));
  //   }
  // }
  //
  // /// delete user account
  // Future<void> deleteUserAccount() async {
  //   emit(UserDeleteLoading());
  //   var result = await userRepo.deleteUserData();
  //   result.fold(
  //         (String error) {
  //       emit(UserDeleteError(error: error));
  //     },
  //         (message) {
  //       logout();
  //       emit(UserDeleteSuccess(message: message));
  //     },
  //   );
  // }

  /// logout
  Future<void> logout() async {
    // Remove FCM token from backend before logout
    try {
      await NotificationService().removeToken();
      print('[UserCubit] ✅ FCM token removed on logout');
    } catch (e) {
      print('[UserCubit] ⚠️ Failed to remove FCM token: $e');
      // Continue with logout even if token removal fails
    }

    await CacheHelper.removeData(key: CacheKeys.accessToken);
    await CacheHelper.removeData(key: CacheKeys.refreshToken);
    MyNavigator.goTo(screen: GetStartedView(), isReplace: true);
  }

  Position? userPosition;

  void saveUserLocation(Position position) {
    userPosition = position;
  }

  Future<Position> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. هل اللوكيشن شغال أصلاً؟
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // 2. هل فيه permission؟
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied, please enable it from profile',
      );
    }

    // 3. هات اللوكيشن
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
