import 'package:equatable/equatable.dart';

class MedicationEntity extends Equatable {
  final String id;
  final String userId;
  final String? recordId;
  final String medicineName;
  final String? dosage;
  final String? frequency;
  final int? durationDays;
  final String? startDate;
  final String? endDate;
  final String? purpose;
  final String? diagnosis;
  final String? disease;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const MedicationEntity({
    required this.id,
    required this.userId,
    this.recordId,
    required this.medicineName,
    this.dosage,
    this.frequency,
    this.durationDays,
    this.startDate,
    this.endDate,
    this.purpose,
    this.diagnosis,
    this.disease,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    recordId,
    medicineName,
    dosage,
    frequency,
    durationDays,
    startDate,
    endDate,
    purpose,
    diagnosis,
    disease,
    notes,
    createdAt,
    updatedAt,
  ];
}

class AllergyEntity extends Equatable {
  final String id;
  final String userId;
  final String? recordId;
  final String allergen;
  final String? type;
  final String? reaction;
  final String? severity;
  final String? status;
  final String? onsetDate;
  final String? recordedAt;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const AllergyEntity({
    required this.id,
    required this.userId,
    this.recordId,
    required this.allergen,
    this.type,
    this.reaction,
    this.severity,
    this.status,
    this.onsetDate,
    this.recordedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    recordId,
    allergen,
    type,
    reaction,
    severity,
    status,
    onsetDate,
    recordedAt,
    notes,
    createdAt,
    updatedAt,
  ];
}

class ImmunizationEntity extends Equatable {
  final String id;
  final String userId;
  final String? recordId;
  final String vaccineName;
  final String? date;
  final int? doseNumber;
  final String? series;
  final String? manufacturer;
  final String? lotNumber;
  final String? site;
  final String? route;
  final String? provider;
  final String? nextDue;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const ImmunizationEntity({
    required this.id,
    required this.userId,
    this.recordId,
    required this.vaccineName,
    this.date,
    this.doseNumber,
    this.series,
    this.manufacturer,
    this.lotNumber,
    this.site,
    this.route,
    this.provider,
    this.nextDue,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    recordId,
    vaccineName,
    date,
    doseNumber,
    series,
    manufacturer,
    lotNumber,
    site,
    route,
    provider,
    nextDue,
    notes,
    createdAt,
    updatedAt,
  ];
}

class MedicationUpsertEntity extends Equatable {
  final String medicineName;
  final String? recordId;
  final String? dosage;
  final String? frequency;
  final int? durationDays;
  final String? startDate;
  final String? endDate;
  final String? purpose;
  final String? diagnosis;
  final String? disease;
  final String? notes;

  const MedicationUpsertEntity({
    required this.medicineName,
    this.recordId,
    this.dosage,
    this.frequency,
    this.durationDays,
    this.startDate,
    this.endDate,
    this.purpose,
    this.diagnosis,
    this.disease,
    this.notes,
  });

  @override
  List<Object?> get props => [
    medicineName,
    recordId,
    dosage,
    frequency,
    durationDays,
    startDate,
    endDate,
    purpose,
    diagnosis,
    disease,
    notes,
  ];
}

class AllergyUpsertEntity extends Equatable {
  final String allergen;
  final String? recordId;
  final String? type;
  final String? reaction;
  final String? severity;
  final String? status;
  final String? onsetDate;
  final String? recordedAt;
  final String? notes;

  const AllergyUpsertEntity({
    required this.allergen,
    this.recordId,
    this.type,
    this.reaction,
    this.severity,
    this.status,
    this.onsetDate,
    this.recordedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
    allergen,
    recordId,
    type,
    reaction,
    severity,
    status,
    onsetDate,
    recordedAt,
    notes,
  ];
}

class ImmunizationUpsertEntity extends Equatable {
  final String vaccineName;
  final String? recordId;
  final String? date;
  final int? doseNumber;
  final String? series;
  final String? manufacturer;
  final String? lotNumber;
  final String? site;
  final String? route;
  final String? provider;
  final String? nextDue;
  final String? notes;

  const ImmunizationUpsertEntity({
    required this.vaccineName,
    this.recordId,
    this.date,
    this.doseNumber,
    this.series,
    this.manufacturer,
    this.lotNumber,
    this.site,
    this.route,
    this.provider,
    this.nextDue,
    this.notes,
  });

  @override
  List<Object?> get props => [
    vaccineName,
    recordId,
    date,
    doseNumber,
    series,
    manufacturer,
    lotNumber,
    site,
    route,
    provider,
    nextDue,
    notes,
  ];
}
