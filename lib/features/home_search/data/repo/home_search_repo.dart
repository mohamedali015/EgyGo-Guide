import 'package:dartz/dartz.dart';

import '../../../places/data/models/places_response_model.dart';

abstract class HomeSearchRepo {
  Future<Either<String, List<Place>>> fetchHomeSearchPlaces({
    required String search,
  });
}
