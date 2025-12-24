import 'package:dartz/dartz.dart';

import '../../models/places_response_model.dart';

abstract class PlacesRepo {
  Future<Either<String, List<Place>>> getPlaces();

  Future<Either<String, List<Place>>> getPlacesByCategory(
      {required String category, required String governorate});
}
