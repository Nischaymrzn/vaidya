import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';

class PredictionApiModel {
  final String type;
  final Map<String, dynamic> data;

  const PredictionApiModel({required this.type, required this.data});

  factory PredictionApiModel.fromJson(String type, Map<String, dynamic> json) {
    return PredictionApiModel(type: type, data: Map<String, dynamic>.from(json));
  }

  PredictionEntity toEntity() => PredictionEntity(type: type, data: data);
}
