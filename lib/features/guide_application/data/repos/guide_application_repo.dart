import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:egy_go_guide/core/cache/cache_data.dart';
import 'package:egy_go_guide/core/network/api_helper.dart';
import 'package:egy_go_guide/core/network/api_response.dart';
import 'package:egy_go_guide/core/network/end_points.dart';

class GuideApplicationRepo {
  final ApiHelper apiHelper;

  GuideApplicationRepo({required this.apiHelper});

  Future<Either<String, String>> applyAsGuide({
    required String idDocument,
    required String photo,
    required String isLicensed,
    required List<String> languages,
    required List<String> governorateIds,
    required String pricePerHour,
    required String bio,
    String? tourismCard,
    String? englishCertificate,
  }) async {
    try {
      Map<String, dynamic> formDataMap = {
        'languages': languages.join(','),
        'provinces': governorateIds.join(','),
        'pricePerHour': pricePerHour,
        'bio': bio,
        'isLicensed': isLicensed,
        'idDocument': await MultipartFile.fromFile(idDocument),
        'photo': await MultipartFile.fromFile(photo),
      };

      if (tourismCard != null) {
        formDataMap['tourismCard'] = await MultipartFile.fromFile(tourismCard);
      }

      if (englishCertificate != null) {
        formDataMap['englishCertificate'] =
            await MultipartFile.fromFile(englishCertificate);
      }

      ApiResponse response = await apiHelper.dio
          .post(
            EndPoints.applyAsGuide,
            data: FormData.fromMap(formDataMap),
            options: Options(headers: {
              'Authorization': 'Bearer ${CacheData.accessToken}',
            }),
          )
          .then((response) => ApiResponse.fromResponse(response));

      if (response.success == false) {
        throw Exception(response.message);
      }

      return Right(response.message);
    } catch (e) {
      ApiResponse apiResponse = ApiResponse.fromError(e);
      return Left(apiResponse.message);
    }
  }
}
