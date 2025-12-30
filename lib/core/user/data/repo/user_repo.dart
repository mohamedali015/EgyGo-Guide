import 'package:dartz/dartz.dart';

import '../models/user_model.dart';

abstract class UserRepo {
  // get user data
  Future<Either<String, UserModel>> getUserData();

  // update profile
  Future<Either<String, String>> updateProfile({
    required List<String> languages,
    required double pricePerHour,
    required String bio,
    required List<String> provinces,
  });
}
