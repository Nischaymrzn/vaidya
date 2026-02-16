import 'package:equatable/equatable.dart';

class DashboardVitalPointEntity extends Equatable {
  final String day;
  final num? heartRate;
  final num? systolic;
  final num? glucose;

  const DashboardVitalPointEntity({
    required this.day,
    this.heartRate,
    this.systolic,
    this.glucose,
  });

  @override
  List<Object?> get props => [day, heartRate, systolic, glucose];
}

class DashboardHealthScorePointEntity extends Equatable {
  final String day;
  final int score;

  const DashboardHealthScorePointEntity({
    required this.day,
    required this.score,
  });

  @override
  List<Object?> get props => [day, score];
}

class DashboardSymptomPointEntity extends Equatable {
  final String name;
  final int frequency;

  const DashboardSymptomPointEntity({
    required this.name,
    required this.frequency,
  });

  @override
  List<Object?> get props => [name, frequency];
}

class DashboardMedicationItemEntity extends Equatable {
  final String name;
  final String dose;
  final int adherence;
  final String? meta;

  const DashboardMedicationItemEntity({
    required this.name,
    required this.dose,
    required this.adherence,
    this.meta,
  });

  @override
  List<Object?> get props => [name, dose, adherence, meta];
}

class DashboardTimelineItemEntity extends Equatable {
  final String date;
  final String title;
  final String meta;

  const DashboardTimelineItemEntity({
    required this.date,
    required this.title,
    required this.meta,
  });

  @override
  List<Object?> get props => [date, title, meta];
}

class DashboardRiskFactorEntity extends Equatable {
  final String label;
  final String level;
  final int score;

  const DashboardRiskFactorEntity({
    required this.label,
    required this.level,
    required this.score,
  });

  @override
  List<Object?> get props => [label, level, score];
}

class DashboardInsightEntity extends Equatable {
  final String title;
  final String body;

  const DashboardInsightEntity({required this.title, required this.body});

  @override
  List<Object?> get props => [title, body];
}

class DashboardClinicalItemEntity extends Equatable {
  final String label;
  final String value;
  final String meta;
  final String bg;

  const DashboardClinicalItemEntity({
    required this.label,
    required this.value,
    required this.meta,
    required this.bg,
  });

  @override
  List<Object?> get props => [label, value, meta, bg];
}

class DashboardSummaryCardEntity extends Equatable {
  final String title;
  final String value;
  final String note;

  const DashboardSummaryCardEntity({
    required this.title,
    required this.value,
    required this.note,
  });

  @override
  List<Object?> get props => [title, value, note];
}

class DashboardVitalStatEntity extends Equatable {
  final String label;
  final String value;
  final String note;

  const DashboardVitalStatEntity({
    required this.label,
    required this.value,
    required this.note,
  });

  @override
  List<Object?> get props => [label, value, note];
}

class DashboardSummaryEntity extends Equatable {
  final String userName;
  final num? vaidyaScore;
  final List<DashboardSummaryCardEntity> summaryCards;
  final List<DashboardVitalPointEntity> vitalsData;
  final List<DashboardVitalStatEntity> vitalStats;
  final List<DashboardSymptomPointEntity> symptomData;
  final String symptomPattern;
  final List<DashboardMedicationItemEntity> medications;
  final List<String> allergies;
  final List<DashboardClinicalItemEntity> clinicalItems;
  final List<DashboardRiskFactorEntity> riskFactors;
  final List<DashboardInsightEntity> insights;
  final List<DashboardTimelineItemEntity> timelineItems;
  final List<DashboardHealthScorePointEntity> healthScoreTrend;

  const DashboardSummaryEntity({
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

  const DashboardSummaryEntity.empty()
    : userName = '',
      vaidyaScore = null,
      summaryCards = const [],
      vitalsData = const [],
      vitalStats = const [],
      symptomData = const [],
      symptomPattern = '',
      medications = const [],
      allergies = const [],
      clinicalItems = const [],
      riskFactors = const [],
      insights = const [],
      timelineItems = const [],
      healthScoreTrend = const [];

  @override
  List<Object?> get props => [
    userName,
    vaidyaScore,
    summaryCards,
    vitalsData,
    vitalStats,
    symptomData,
    symptomPattern,
    medications,
    allergies,
    clinicalItems,
    riskFactors,
    insights,
    timelineItems,
    healthScoreTrend,
  ];
}
