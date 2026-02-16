import 'package:vaidya/features/intelligence/domain/entities/health_insight_entity.dart';

class HealthInsightApiModel {
  final String id;
  final Map<String, dynamic> data;

  const HealthInsightApiModel({required this.id, required this.data});

  factory HealthInsightApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return HealthInsightApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  HealthInsightEntity toEntity() => HealthInsightEntity(id: id, data: data);

  static List<HealthInsightApiModel> fromJsonList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => HealthInsightApiModel.fromJson(item.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);
  }
}
