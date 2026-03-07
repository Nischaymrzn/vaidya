import 'package:vaidya/features/intelligence/data/models/health_insight_api_model.dart';

class HealthInsightHiveModel {
  final String id;
  final Map<String, dynamic> data;

  const HealthInsightHiveModel({required this.id, required this.data});

  factory HealthInsightHiveModel.fromApiModel(HealthInsightApiModel apiModel) {
    return HealthInsightHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory HealthInsightHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return HealthInsightHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  HealthInsightApiModel toApiModel() {
    return HealthInsightApiModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(data);
  }
}
