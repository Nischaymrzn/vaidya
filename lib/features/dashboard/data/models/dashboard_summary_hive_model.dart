import 'package:vaidya/features/dashboard/data/models/dashboard_summary_api_model.dart';

class DashboardSummaryHiveModel {
  final Map<String, dynamic> data;

  const DashboardSummaryHiveModel({required this.data});

  factory DashboardSummaryHiveModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryHiveModel(
      data: Map<String, dynamic>.from(json),
    );
  }

  factory DashboardSummaryHiveModel.fromApiModel(DashboardSummaryApiModel summary) {
    Map<String, dynamic> encodeVitalPoint(DashboardVitalPointApiModel item) => <String, dynamic>{
      'day': item.day,
      'heartRate': item.heartRate,
      'systolic': item.systolic,
      'glucose': item.glucose,
    };

    Map<String, dynamic> encodeHealthScorePoint(DashboardHealthScorePointApiModel item) => <String, dynamic>{
      'day': item.day,
      'score': item.score,
    };

    Map<String, dynamic> encodeSymptomPoint(DashboardSymptomPointApiModel item) => <String, dynamic>{
      'name': item.name,
      'frequency': item.frequency,
    };

    Map<String, dynamic> encodeMedication(DashboardMedicationItemApiModel item) => <String, dynamic>{
      'name': item.name,
      'dose': item.dose,
      'adherence': item.adherence,
      'meta': item.meta,
    };

    Map<String, dynamic> encodeTimeline(DashboardTimelineItemApiModel item) => <String, dynamic>{
      'date': item.date,
      'title': item.title,
      'meta': item.meta,
    };

    Map<String, dynamic> encodeRiskFactor(DashboardRiskFactorApiModel item) => <String, dynamic>{
      'label': item.label,
      'level': item.level,
      'score': item.score,
    };

    Map<String, dynamic> encodeInsight(DashboardInsightApiModel item) => <String, dynamic>{
      'title': item.title,
      'body': item.body,
    };

    Map<String, dynamic> encodeClinical(DashboardClinicalItemApiModel item) => <String, dynamic>{
      'label': item.label,
      'value': item.value,
      'meta': item.meta,
      'bg': item.bg,
    };

    Map<String, dynamic> encodeSummaryCard(DashboardSummaryCardApiModel item) => <String, dynamic>{
      'title': item.title,
      'value': item.value,
      'note': item.note,
    };

    Map<String, dynamic> encodeVitalStat(DashboardVitalStatApiModel item) => <String, dynamic>{
      'label': item.label,
      'value': item.value,
      'note': item.note,
    };

    return DashboardSummaryHiveModel(
      data: <String, dynamic>{
        'userName': summary.userName,
        'vaidyaScore': summary.vaidyaScore,
        'summaryCards': summary.summaryCards.map(encodeSummaryCard).toList(growable: false),
        'vitalsData': summary.vitalsData.map(encodeVitalPoint).toList(growable: false),
        'vitalStats': summary.vitalStats.map(encodeVitalStat).toList(growable: false),
        'symptomData': summary.symptomData.map(encodeSymptomPoint).toList(growable: false),
        'symptomPattern': summary.symptomPattern,
        'medications': summary.medications.map(encodeMedication).toList(growable: false),
        'allergies': summary.allergies,
        'clinicalItems': summary.clinicalItems.map(encodeClinical).toList(growable: false),
        'riskFactors': summary.riskFactors.map(encodeRiskFactor).toList(growable: false),
        'insights': summary.insights.map(encodeInsight).toList(growable: false),
        'timelineItems': summary.timelineItems.map(encodeTimeline).toList(growable: false),
        'healthScoreTrend': summary.healthScoreTrend.map(encodeHealthScorePoint).toList(growable: false),
      },
    );
  }

  DashboardSummaryApiModel toApiModel() {
    return DashboardSummaryApiModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(data);
  }
}
