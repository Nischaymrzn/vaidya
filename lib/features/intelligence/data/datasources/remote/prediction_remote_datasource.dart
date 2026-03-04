import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/intelligence/data/datasources/prediction_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/prediction_api_model.dart';

final predictionRemoteDataSourceProvider = Provider<IPredictionRemoteDataSource>((ref) {
  return PredictionRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class PredictionRemoteDataSource implements IPredictionRemoteDataSource {
  final ApiClient _apiClient;

  const PredictionRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<PredictionApiModel> predictSymptom(List<String> symptoms) {
    return _postJson(
      type: 'symptom',
      endpoint: ApiEndpoints.predictSymptom,
      payload: {'symptoms': symptoms},
      fallbackMessage: 'Failed to predict disease from symptoms',
    );
  }

  @override
  Future<PredictionApiModel> predictHeartDisease(Map<String, dynamic> payload) {
    return _postJson(
      type: 'heart_disease',
      endpoint: ApiEndpoints.predictHeartDisease,
      payload: payload,
      fallbackMessage: 'Failed to predict heart disease risk',
    );
  }

  @override
  Future<PredictionApiModel> predictDiabetes(Map<String, dynamic> payload) {
    return _postJson(
      type: 'diabetes',
      endpoint: ApiEndpoints.predictDiabetes,
      payload: payload,
      fallbackMessage: 'Failed to predict diabetes risk',
    );
  }

  @override
  Future<PredictionApiModel> predictBrainTumor(String imagePath) {
    return _postMultipart(
      type: 'brain_tumor',
      endpoint: ApiEndpoints.predictBrainTumor,
      imagePath: imagePath,
      fallbackMessage: 'Failed to predict brain tumor',
    );
  }

  @override
  Future<PredictionApiModel> predictTuberculosis(String imagePath) {
    return _postMultipart(
      type: 'tuberculosis',
      endpoint: ApiEndpoints.predictTuberculosis,
      imagePath: imagePath,
      fallbackMessage: 'Failed to predict tuberculosis',
    );
  }

  Future<PredictionApiModel> _postJson({
    required String type,
    required String endpoint,
    required Map<String, dynamic> payload,
    required String fallbackMessage,
  }) async {
    final response = await _apiClient.post(endpoint, data: payload);

    if (response.data['success'] == true) {
      final raw = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return PredictionApiModel.fromJson(type, raw);
    }

    throw Exception(response.data['message'] ?? fallbackMessage);
  }

  Future<PredictionApiModel> _postMultipart({
    required String type,
    required String endpoint,
    required String imagePath,
    required String fallbackMessage,
  }) async {
    final filename = imagePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: filename),
    });

    final response = await _apiClient.post(
      endpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final raw = response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return PredictionApiModel.fromJson(type, raw);
    }

    throw Exception(response.data['message'] ?? fallbackMessage);
  }
}
