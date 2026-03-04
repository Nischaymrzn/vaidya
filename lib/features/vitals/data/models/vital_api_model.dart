import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';

class VitalApiModel {
  final String id;
  final Map<String, dynamic> data;

  const VitalApiModel({required this.id, required this.data});

  factory VitalApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return VitalApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  VitalEntity toEntity() => VitalEntity(id: id, data: data);

  static List<VitalApiModel> fromJsonList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => VitalApiModel.fromJson(item.map((k, v) => MapEntry(k.toString(), v))))
        .toList(growable: false);
  }
}
