import 'package:vaidya/features/intelligence/data/models/intelligence_api_model.dart';

class AiInsightHiveModel {
  final String id;
  final Map<String, dynamic> data;

  const AiInsightHiveModel({required this.id, required this.data});

  factory AiInsightHiveModel.fromApiModel(AiInsightApiModel apiModel) {
    return AiInsightHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory AiInsightHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return AiInsightHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  AiInsightApiModel toApiModel() => AiInsightApiModel.fromJson(data, fallbackId: id);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}
