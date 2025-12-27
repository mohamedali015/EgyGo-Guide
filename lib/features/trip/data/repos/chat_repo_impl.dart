import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:egy_go_guide/core/network/api_helper.dart';
import 'package:egy_go_guide/core/network/end_points.dart';
import 'package:egy_go_guide/features/trip/data/models/chat_message_model.dart';
import 'package:egy_go_guide/features/trip/data/repos/chat_repo.dart';

class ChatRepoImpl implements ChatRepo {
  final ApiHelper apiHelper;

  ChatRepoImpl({required this.apiHelper});

  @override
  Future<Either<String, ChatHistoryResponseModel>> getChatHistory(
      String tripId) async {
    try {
      final response = await apiHelper.getRequest(
        endPoint: EndPoints.getChatHistory(tripId),
        isProtected: true,
      );

      if (response.success) {
        return Right(ChatHistoryResponseModel.fromJson(response.data));
      } else {
        return Left(response.message ?? 'Failed to load chat history');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(
            e.response?.data['message'] ?? 'Failed to load chat history');
      }
      return Left('Network error: ${e.message}');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }
}

