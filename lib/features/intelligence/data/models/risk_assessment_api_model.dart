import 'package:vaidya/features/intelligence/domain/entities/risk_assessment_entity.dart';

class RiskAssessmentApiModel {
  final String id;
  final Map<String, dynamic> data;

  const RiskAssessmentApiModel({required this.id, required this.data});

  factory RiskAssessmentApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return RiskAssessmentApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  RiskAssessmentEntity toEntity() => RiskAssessmentEntity(id: id, data: data);

  static List<RiskAssessmentApiModel> fromJsonList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => RiskAssessmentApiModel.fromJson(item.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);
  }
}

class RiskAssessmentGenerateApiModel {
  final Map<String, dynamic> data;

  const RiskAssessmentGenerateApiModel({required this.data});

  factory RiskAssessmentGenerateApiModel.fromJson(Map<String, dynamic> json) {
    return RiskAssessmentGenerateApiModel(data: Map<String, dynamic>.from(json));
  }

  RiskAssessmentGenerateEntity toEntity() => RiskAssessmentGenerateEntity(data: data);
}
