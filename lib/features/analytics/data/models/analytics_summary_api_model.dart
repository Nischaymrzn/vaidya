import 'package:vaidya/features/analytics/domain/entities/analytics_summary_entity.dart';

class AnalyticsSummaryApiModel {
  final Map<String, dynamic> data;

  const AnalyticsSummaryApiModel({required this.data});

  factory AnalyticsSummaryApiModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryApiModel(data: Map<String, dynamic>.from(json));
  }

  AnalyticsSummaryEntity toEntity() => AnalyticsSummaryEntity(data: data);
}
