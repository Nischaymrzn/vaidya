import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';

class SymptomApiModel {
  final String id;
  final Map<String, dynamic> data;

  const SymptomApiModel({required this.id, required this.data});

  factory SymptomApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return SymptomApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  SymptomEntity toEntity() => SymptomEntity(id: id, data: data);

  static List<SymptomApiModel> fromJsonList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => SymptomApiModel.fromJson(item.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);
  }
}
