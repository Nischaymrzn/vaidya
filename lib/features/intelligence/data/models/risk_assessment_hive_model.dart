import 'package:vaidya/features/intelligence/data/models/risk_assessment_api_model.dart';

class RiskAssessmentHiveModel {
  final String id;
  final Map<String, dynamic> data;

  const RiskAssessmentHiveModel({required this.id, required this.data});

  factory RiskAssessmentHiveModel.fromApiModel(RiskAssessmentApiModel apiModel) {
    return RiskAssessmentHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory RiskAssessmentHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return RiskAssessmentHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  RiskAssessmentApiModel toApiModel() => RiskAssessmentApiModel.fromJson(data);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}
