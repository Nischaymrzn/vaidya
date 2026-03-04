import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';

num? _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) {
    return num.tryParse(value);
  }
  return null;
}

int _asInt(dynamic value, {int fallback = 0}) {
  final parsed = _asNum(value);
  return parsed?.round() ?? fallback;
}

class DashboardVitalPointApiModel {
  final String day;
  final num? heartRate;
  final num? systolic;
  final num? glucose;

  DashboardVitalPointApiModel({
    required this.day,
    required this.heartRate,
    required this.systolic,
    required this.glucose,
  });

  factory DashboardVitalPointApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardVitalPointApiModel(
      day: (json['day'] ?? '').toString(),
      heartRate: _asNum(json['heartRate']),
      systolic: _asNum(json['systolic']),
      glucose: _asNum(json['glucose']),
    );
  }

  DashboardVitalPointEntity toEntity() {
    return DashboardVitalPointEntity(
      day: day,
      heartRate: heartRate,
      systolic: systolic,
      glucose: glucose,
    );
  }
}

class DashboardHealthScorePointApiModel {
  final String day;
  final int score;

  DashboardHealthScorePointApiModel({required this.day, required this.score});

  factory DashboardHealthScorePointApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardHealthScorePointApiModel(
      day: (json['day'] ?? '').toString(),
      score: _asInt(json['score']),
    );
  }

  DashboardHealthScorePointEntity toEntity() {
    return DashboardHealthScorePointEntity(day: day, score: score);
  }
}

class DashboardSymptomPointApiModel {
  final String name;
  final int frequency;

  DashboardSymptomPointApiModel({required this.name, required this.frequency});

  factory DashboardSymptomPointApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardSymptomPointApiModel(
      name: (json['name'] ?? '').toString(),
      frequency: _asInt(json['frequency']),
    );
  }

  DashboardSymptomPointEntity toEntity() {
    return DashboardSymptomPointEntity(name: name, frequency: frequency);
  }
}

class DashboardMedicationItemApiModel {
  final String name;
  final String dose;
  final int adherence;
  final String? meta;

  DashboardMedicationItemApiModel({
    required this.name,
    required this.dose,
    required this.adherence,
    required this.meta,
  });

  factory DashboardMedicationItemApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardMedicationItemApiModel(
      name: (json['name'] ?? '').toString(),
      dose: (json['dose'] ?? '--').toString(),
      adherence: _asInt(json['adherence']),
      meta: json['meta']?.toString(),
    );
  }

  DashboardMedicationItemEntity toEntity() {
    return DashboardMedicationItemEntity(
      name: name,
      dose: dose,
      adherence: adherence,
      meta: meta,
    );
  }
}

class DashboardTimelineItemApiModel {
  final String date;
  final String title;
  final String meta;

  DashboardTimelineItemApiModel({
    required this.date,
    required this.title,
    required this.meta,
  });

  factory DashboardTimelineItemApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardTimelineItemApiModel(
      date: (json['date'] ?? '--').toString(),
      title: (json['title'] ?? '').toString(),
      meta: (json['meta'] ?? '').toString(),
    );
  }

  DashboardTimelineItemEntity toEntity() {
    return DashboardTimelineItemEntity(date: date, title: title, meta: meta);
  }
}

class DashboardRiskFactorApiModel {
  final String label;
  final String level;
  final int score;

  DashboardRiskFactorApiModel({
    required this.label,
    required this.level,
    required this.score,
  });

  factory DashboardRiskFactorApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardRiskFactorApiModel(
      label: (json['label'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      score: _asInt(json['score']),
    );
  }

  DashboardRiskFactorEntity toEntity() {
    return DashboardRiskFactorEntity(label: label, level: level, score: score);
  }
}

class DashboardInsightApiModel {
  final String title;
  final String body;

  DashboardInsightApiModel({required this.title, required this.body});

  factory DashboardInsightApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardInsightApiModel(
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
    );
  }

  DashboardInsightEntity toEntity() {
    return DashboardInsightEntity(title: title, body: body);
  }
}

class DashboardClinicalItemApiModel {
  final String label;
  final String value;
  final String meta;
  final String bg;

  DashboardClinicalItemApiModel({
    required this.label,
    required this.value,
    required this.meta,
    required this.bg,
  });

  factory DashboardClinicalItemApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardClinicalItemApiModel(
      label: (json['label'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      meta: (json['meta'] ?? '').toString(),
      bg: (json['bg'] ?? 'bg-white').toString(),
    );
  }

  DashboardClinicalItemEntity toEntity() {
    return DashboardClinicalItemEntity(
      label: label,
      value: value,
      meta: meta,
      bg: bg,
    );
  }
}

class DashboardSummaryCardApiModel {
  final String title;
  final String value;
  final String note;

  DashboardSummaryCardApiModel({
    required this.title,
    required this.value,
    required this.note,
  });

  factory DashboardSummaryCardApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryCardApiModel(
      title: (json['title'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
    );
  }

  DashboardSummaryCardEntity toEntity() {
    return DashboardSummaryCardEntity(title: title, value: value, note: note);
  }
}

class DashboardVitalStatApiModel {
  final String label;
  final String value;
  final String note;

  DashboardVitalStatApiModel({
    required this.label,
    required this.value,
    required this.note,
  });

  factory DashboardVitalStatApiModel.fromJson(Map<String, dynamic> json) {
    return DashboardVitalStatApiModel(
      label: (json['label'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
    );
  }

  DashboardVitalStatEntity toEntity() {
    return DashboardVitalStatEntity(label: label, value: value, note: note);
  }
}

class DashboardSummaryApiModel {
  final String userName;
  final num? vaidyaScore;
  final List<DashboardSummaryCardApiModel> summaryCards;
  final List<DashboardVitalPointApiModel> vitalsData;
  final List<DashboardVitalStatApiModel> vitalStats;
  final List<DashboardSymptomPointApiModel> symptomData;
  final String symptomPattern;
  final List<DashboardMedicationItemApiModel> medications;
  final List<String> allergies;
  final List<DashboardClinicalItemApiModel> clinicalItems;
  final List<DashboardRiskFactorApiModel> riskFactors;
  final List<DashboardInsightApiModel> insights;
  final List<DashboardTimelineItemApiModel> timelineItems;
  final List<DashboardHealthScorePointApiModel> healthScoreTrend;

  DashboardSummaryApiModel({
    required this.userName,
    required this.vaidyaScore,
    required this.summaryCards,
    required this.vitalsData,
    required this.vitalStats,
    required this.symptomData,
    required this.symptomPattern,
    required this.medications,
    required this.allergies,
    required this.clinicalItems,
    required this.riskFactors,
    required this.insights,
    required this.timelineItems,
    required this.healthScoreTrend,
  });

  factory DashboardSummaryApiModel.fromJson(Map<String, dynamic> json) {
    List<T> listFromJson<T>(
      dynamic source,
      T Function(Map<String, dynamic>) map,
    ) {
      if (source is! List) return <T>[];
      return source
          .whereType<Map<String, dynamic>>()
          .map(map)
          .toList(growable: false);
    }

    final allergiesList = (json['allergies'] is List)
        ? (json['allergies'] as List)
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList(growable: false)
        : <String>[];

    return DashboardSummaryApiModel(
      userName: (json['userName'] ?? '').toString(),
      vaidyaScore: _asNum(json['vaidyaScore']),
      summaryCards: listFromJson(
        json['summaryCards'],
        DashboardSummaryCardApiModel.fromJson,
      ),
      vitalsData: listFromJson(
        json['vitalsData'],
        DashboardVitalPointApiModel.fromJson,
      ),
      vitalStats: listFromJson(
        json['vitalStats'],
        DashboardVitalStatApiModel.fromJson,
      ),
      symptomData: listFromJson(
        json['symptomData'],
        DashboardSymptomPointApiModel.fromJson,
      ),
      symptomPattern: (json['symptomPattern'] ?? '').toString(),
      medications: listFromJson(
        json['medications'],
        DashboardMedicationItemApiModel.fromJson,
      ),
      allergies: allergiesList,
      clinicalItems: listFromJson(
        json['clinicalItems'],
        DashboardClinicalItemApiModel.fromJson,
      ),
      riskFactors: listFromJson(
        json['riskFactors'],
        DashboardRiskFactorApiModel.fromJson,
      ),
      insights: listFromJson(
        json['insights'],
        DashboardInsightApiModel.fromJson,
      ),
      timelineItems: listFromJson(
        json['timelineItems'],
        DashboardTimelineItemApiModel.fromJson,
      ),
      healthScoreTrend: listFromJson(
        json['healthScoreTrend'],
        DashboardHealthScorePointApiModel.fromJson,
      ),
    );
  }

  DashboardSummaryEntity toEntity() {
    return DashboardSummaryEntity(
      userName: userName,
      vaidyaScore: vaidyaScore,
      summaryCards: summaryCards.map((item) => item.toEntity()).toList(),
      vitalsData: vitalsData.map((item) => item.toEntity()).toList(),
      vitalStats: vitalStats.map((item) => item.toEntity()).toList(),
      symptomData: symptomData.map((item) => item.toEntity()).toList(),
      symptomPattern: symptomPattern,
      medications: medications.map((item) => item.toEntity()).toList(),
      allergies: allergies,
      clinicalItems: clinicalItems.map((item) => item.toEntity()).toList(),
      riskFactors: riskFactors.map((item) => item.toEntity()).toList(),
      insights: insights.map((item) => item.toEntity()).toList(),
      timelineItems: timelineItems.map((item) => item.toEntity()).toList(),
      healthScoreTrend: healthScoreTrend
          .map((item) => item.toEntity())
          .toList(),
    );
  }
}
