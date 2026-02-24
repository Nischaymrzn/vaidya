import 'package:vaidya/features/intelligence/data/models/prediction_api_model.dart';

class PredictionHiveModel {
  final String type;
  final Map<String, dynamic> data;

  const PredictionHiveModel({required this.type, required this.data});

  factory PredictionHiveModel.fromApiModel(PredictionApiModel apiModel) {
    return PredictionHiveModel(
      type: apiModel.type,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory PredictionHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return PredictionHiveModel(
      type: (mapped['type'] ?? '').toString(),
      data: Map<String, dynamic>.from(
        mapped['data'] is Map ? mapped['data'] as Map : <String, dynamic>{},
      ),
    );
  }

  PredictionApiModel toApiModel() => PredictionApiModel(
    type: type,
    data: Map<String, dynamic>.from(data),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'data': Map<String, dynamic>.from(data),
  };
}
