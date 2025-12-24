import 'package:dartz/dartz.dart';

import '../../../../core/network/api_helper.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/end_points.dart';
import '../../../places/data/models/places_response_model.dart';
import '../models/search_response_model.dart';
import 'home_search_repo.dart';

class HomeSearchRepoImpl extends HomeSearchRepo {
  HomeSearchRepoImpl({required this.apiHelper});

  final ApiHelper apiHelper;

  @override
  Future<Either<String, List<Place>>> fetchHomeSearchPlaces({
    required String search,
  }) async {
    try {
      ApiResponse response =
          await apiHelper.getRequest(endPoint: EndPoints.searchHome(search));
      HomeSearchResponseModel searchResponseModel =
          HomeSearchResponseModel.fromJson(response.data);
      if (searchResponseModel.success != null &&
          searchResponseModel.success == true) {
        if (searchResponseModel.data != null) {
          return Right(searchResponseModel.data!);
        } else {
          throw Exception("No Places found.");
        }
      } else {
        throw Exception("Search failed.");
      }
    } catch (e) {
      ApiResponse errorResponse = ApiResponse.fromError(e);
      return Left(errorResponse.message);
    }
  }
}
