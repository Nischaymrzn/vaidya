import 'package:vaidya/features/intelligence/data/models/prediction_api_model.dart';

abstract interface class IPredictionRemoteDataSource {
  Future<PredictionApiModel> predictSymptom(List<String> symptoms);
  Future<PredictionApiModel> predictHeartDisease(Map<String, dynamic> payload);
  Future<PredictionApiModel> predictDiabetes(Map<String, dynamic> payload);
  Future<PredictionApiModel> predictBrainTumor(String imagePath);
  Future<PredictionApiModel> predictTuberculosis(String imagePath);
}

abstract interface class IPredictionLocalDataSource {
  Future<void> cacheResult(String key, Map<String, dynamic> result);
  Future<Map<String, dynamic>?> getCachedResult(String key);
}
