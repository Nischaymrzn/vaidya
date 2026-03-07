import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

int? _asNullableInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

class MedicationApiModel {
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

  const MedicationApiModel({
    required this.id,
    required this.userId,
    required this.recordId,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.purpose,
    required this.diagnosis,
    required this.disease,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationApiModel.fromJson(Map<String, dynamic> json) {
    return MedicationApiModel(
      id: _asString(json['_id']),
      userId: _asString(json['userId']),
      recordId: json['recordId']?.toString(),
      medicineName: _asString(json['medicineName'], fallback: 'Unknown'),
      dosage: json['dosage']?.toString(),
      frequency: json['frequency']?.toString(),
      durationDays: _asNullableInt(json['durationDays']),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      purpose: json['purpose']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      disease: json['disease']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'userId': userId,
    'recordId': recordId,
    'medicineName': medicineName,
    'dosage': dosage,
    'frequency': frequency,
    'durationDays': durationDays,
    'startDate': startDate,
    'endDate': endDate,
    'purpose': purpose,
    'diagnosis': diagnosis,
    'disease': disease,
    'notes': notes,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  MedicationEntity toEntity() {
    return MedicationEntity(
      id: id,
      userId: userId,
      recordId: recordId,
      medicineName: medicineName,
      dosage: dosage,
      frequency: frequency,
      durationDays: durationDays,
      startDate: startDate,
      endDate: endDate,
      purpose: purpose,
      diagnosis: diagnosis,
      disease: disease,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class AllergyApiModel {
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

  const AllergyApiModel({
    required this.id,
    required this.userId,
    required this.recordId,
    required this.allergen,
    required this.type,
    required this.reaction,
    required this.severity,
    required this.status,
    required this.onsetDate,
    required this.recordedAt,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AllergyApiModel.fromJson(Map<String, dynamic> json) {
    return AllergyApiModel(
      id: _asString(json['_id']),
      userId: _asString(json['userId']),
      recordId: json['recordId']?.toString(),
      allergen: _asString(json['allergen'], fallback: 'Unknown'),
      type: json['type']?.toString(),
      reaction: json['reaction']?.toString(),
      severity: json['severity']?.toString(),
      status: json['status']?.toString(),
      onsetDate: json['onsetDate']?.toString(),
      recordedAt: json['recordedAt']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'userId': userId,
    'recordId': recordId,
    'allergen': allergen,
    'type': type,
    'reaction': reaction,
    'severity': severity,
    'status': status,
    'onsetDate': onsetDate,
    'recordedAt': recordedAt,
    'notes': notes,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  AllergyEntity toEntity() {
    return AllergyEntity(
      id: id,
      userId: userId,
      recordId: recordId,
      allergen: allergen,
      type: type,
      reaction: reaction,
      severity: severity,
      status: status,
      onsetDate: onsetDate,
      recordedAt: recordedAt,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ImmunizationApiModel {
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

  const ImmunizationApiModel({
    required this.id,
    required this.userId,
    required this.recordId,
    required this.vaccineName,
    required this.date,
    required this.doseNumber,
    required this.series,
    required this.manufacturer,
    required this.lotNumber,
    required this.site,
    required this.route,
    required this.provider,
    required this.nextDue,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ImmunizationApiModel.fromJson(Map<String, dynamic> json) {
    return ImmunizationApiModel(
      id: _asString(json['_id']),
      userId: _asString(json['userId']),
      recordId: json['recordId']?.toString(),
      vaccineName: _asString(json['vaccineName'], fallback: 'Unknown'),
      date: json['date']?.toString(),
      doseNumber: _asNullableInt(json['doseNumber']),
      series: json['series']?.toString(),
      manufacturer: json['manufacturer']?.toString(),
      lotNumber: json['lotNumber']?.toString(),
      site: json['site']?.toString(),
      route: json['route']?.toString(),
      provider: json['provider']?.toString(),
      nextDue: json['nextDue']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    '_id': id,
    'userId': userId,
    'recordId': recordId,
    'vaccineName': vaccineName,
    'date': date,
    'doseNumber': doseNumber,
    'series': series,
    'manufacturer': manufacturer,
    'lotNumber': lotNumber,
    'site': site,
    'route': route,
    'provider': provider,
    'nextDue': nextDue,
    'notes': notes,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  ImmunizationEntity toEntity() {
    return ImmunizationEntity(
      id: id,
      userId: userId,
      recordId: recordId,
      vaccineName: vaccineName,
      date: date,
      doseNumber: doseNumber,
      series: series,
      manufacturer: manufacturer,
      lotNumber: lotNumber,
      site: site,
      route: route,
      provider: provider,
      nextDue: nextDue,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
