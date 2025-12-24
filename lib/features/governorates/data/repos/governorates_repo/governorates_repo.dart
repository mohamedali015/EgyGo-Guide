import 'package:dartz/dartz.dart';

import '../../models/governorates_response_model.dart';

abstract class GovernoratesRepo {
  Future<Either<String, List<Governorate>>> getGovernorates();
}
