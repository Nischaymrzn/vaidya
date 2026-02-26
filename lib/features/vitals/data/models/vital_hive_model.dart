import 'package:vaidya/features/vitals/data/models/vital_api_model.dart';

class VitalHiveModel {
  final String id;
  final Map<String, dynamic> data;

  const VitalHiveModel({required this.id, required this.data});

  factory VitalHiveModel.fromApiModel(VitalApiModel apiModel) {
    return VitalHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory VitalHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return VitalHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  VitalApiModel toApiModel() => VitalApiModel.fromJson(data);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

class VitalsSummaryHiveModel {
  final Map<String, dynamic> data;

  const VitalsSummaryHiveModel({required this.data});

  factory VitalsSummaryHiveModel.fromJson(Map<String, dynamic> json) {
    return VitalsSummaryHiveModel(data: Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

