import 'package:vaidya/features/symptoms/data/models/symptom_api_model.dart';

class SymptomHiveModel {
  final String id;
  final Map<String, dynamic> data;

  const SymptomHiveModel({required this.id, required this.data});

  factory SymptomHiveModel.fromApiModel(SymptomApiModel apiModel) {
    return SymptomHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory SymptomHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return SymptomHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  SymptomApiModel toApiModel() => SymptomApiModel.fromJson(data);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

class SymptomsSummaryHiveModel {
  final Map<String, dynamic> data;

  const SymptomsSummaryHiveModel({required this.data});

  factory SymptomsSummaryHiveModel.fromJson(Map<String, dynamic> json) {
    return SymptomsSummaryHiveModel(data: Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

