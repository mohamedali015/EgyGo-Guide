import 'package:dartz/dartz.dart';

import '../models/user_model.dart';

abstract class UserRepo {
  // get user data
  Future<Either<String, UserModel>> getUserData();
}
