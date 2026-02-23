import 'package:vaidya/features/analytics/data/models/analytics_summary_api_model.dart';

class AnalyticsSummaryHiveModel {
  final Map<String, dynamic> data;

  const AnalyticsSummaryHiveModel({required this.data});

  factory AnalyticsSummaryHiveModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryHiveModel(data: Map<String, dynamic>.from(json));
  }

  factory AnalyticsSummaryHiveModel.fromApiModel(
    AnalyticsSummaryApiModel summary,
  ) {
    return AnalyticsSummaryHiveModel(
      data: Map<String, dynamic>.from(summary.data),
    );
  }

  AnalyticsSummaryApiModel toApiModel() {
    return AnalyticsSummaryApiModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(data);
  }
}
