import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/records/data/datasources/records_datasource.dart';
import 'package:vaidya/features/records/data/models/medical_record_api_model.dart';
import 'package:vaidya/features/records/data/models/record_support_api_model.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';

final recordsRemoteDataSourceProvider = Provider<IRecordsRemoteDataSource>((
  ref,
) {
  return RecordsRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class RecordsRemoteDataSource implements IRecordsRemoteDataSource {
  final ApiClient _apiClient;

  RecordsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<MedicalRecordsResultApiModel> getMedicalRecords({
    required int page,
    required int limit,
    String? userId,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (userId != null && userId.trim().isNotEmpty) {
      query['userId'] = userId.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.medicalRecords,
      queryParameters: query,
    );

    if (response.data['success'] == true) {
      final payload = response.data as Map<String, dynamic>;
      return MedicalRecordsResultApiModel.fromResponse(payload);
    }

    throw Exception(
      response.data['message'] ?? 'Failed to fetch medical records',
    );
  }

  @override
  Future<MedicalRecordApiModel> getMedicalRecordById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.medicalRecordById(id));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicalRecordApiModel.fromJson(data);
    }

    throw Exception(
      response.data['message'] ?? 'Failed to fetch medical record',
    );
  }

  @override
  Future<MedicalRecordApiModel> createMedicalRecord(
    MedicalRecordUpsertEntity payload,
  ) async {
    final formData = await _buildMedicalRecordFormData(payload);
    final response = await _apiClient.post(
      ApiEndpoints.medicalRecords,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicalRecordApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to create record');
  }

  @override
  Future<MedicalRecordApiModel> updateMedicalRecord(
    String id,
    MedicalRecordUpsertEntity payload,
  ) async {
    final formData = await _buildMedicalRecordFormData(payload);
    final response = await _apiClient.patch(
      ApiEndpoints.medicalRecordById(id),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicalRecordApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to update record');
  }

  @override
  Future<void> deleteMedicalRecord(String id) async {
    final response = await _apiClient.delete(
      ApiEndpoints.medicalRecordById(id),
    );
    if (response.data['success'] == true) {
      return;
    }
    throw Exception(response.data['message'] ?? 'Failed to delete record');
  }

  @override
  Future<AiScanResultApiModel> scanMedicalImage(String imagePath) async {
    final filename = imagePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: filename),
    });

    final response = await _apiClient.post(
      ApiEndpoints.aiScan,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data =
          (response.data['data'] as Map<String, dynamic>? ??
          <String, dynamic>{});
      return AiScanResultApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to scan image');
  }

  @override
  Future<List<MedicationApiModel>> getMedications({String? userId}) async {
    final query = <String, dynamic>{};
    if (userId != null && userId.trim().isNotEmpty) {
      query['userId'] = userId.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.medications,
      queryParameters: query.isEmpty ? null : query,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(MedicationApiModel.fromJson)
            .toList(growable: false);
      }
      return const [];
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch medications');
  }

  @override
  Future<MedicationApiModel> getMedicationById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.medicationById(id));
    if (response.data['success'] == true) {
      return MedicationApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch medication');
  }

  @override
  Future<MedicationApiModel> createMedication(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.medications,
      data: payload,
    );
    if (response.data['success'] == true) {
      return MedicationApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(response.data['message'] ?? 'Failed to create medication');
  }

  @override
  Future<MedicationApiModel> updateMedication(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.medicationById(id),
      data: payload,
    );
    if (response.data['success'] == true) {
      return MedicationApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(response.data['message'] ?? 'Failed to update medication');
  }

  @override
  Future<void> deleteMedication(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.medicationById(id));
    if (response.data['success'] == true) {
      return;
    }
    throw Exception(response.data['message'] ?? 'Failed to delete medication');
  }

  @override
  Future<List<AllergyApiModel>> getAllergies({String? userId}) async {
    final query = <String, dynamic>{};
    if (userId != null && userId.trim().isNotEmpty) {
      query['userId'] = userId.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.allergies,
      queryParameters: query.isEmpty ? null : query,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AllergyApiModel.fromJson)
            .toList(growable: false);
      }
      return const [];
    }

    throw Exception(response.data['message'] ?? 'Failed to fetch allergies');
  }

  @override
  Future<AllergyApiModel> getAllergyById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.allergyById(id));
    if (response.data['success'] == true) {
      return AllergyApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch allergy');
  }

  @override
  Future<AllergyApiModel> createAllergy(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.allergies,
      data: payload,
    );
    if (response.data['success'] == true) {
      return AllergyApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(response.data['message'] ?? 'Failed to create allergy');
  }

  @override
  Future<AllergyApiModel> updateAllergy(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.allergyById(id),
      data: payload,
    );
    if (response.data['success'] == true) {
      return AllergyApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(response.data['message'] ?? 'Failed to update allergy');
  }

  @override
  Future<void> deleteAllergy(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.allergyById(id));
    if (response.data['success'] == true) {
      return;
    }
    throw Exception(response.data['message'] ?? 'Failed to delete allergy');
  }

  @override
  Future<List<ImmunizationApiModel>> getImmunizations({String? userId}) async {
    final query = <String, dynamic>{};
    if (userId != null && userId.trim().isNotEmpty) {
      query['userId'] = userId.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.immunizations,
      queryParameters: query.isEmpty ? null : query,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ImmunizationApiModel.fromJson)
            .toList(growable: false);
      }
      return const [];
    }

    throw Exception(
      response.data['message'] ?? 'Failed to fetch immunizations',
    );
  }

  @override
  Future<ImmunizationApiModel> getImmunizationById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.immunizationById(id));
    if (response.data['success'] == true) {
      return ImmunizationApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch immunization');
  }

  @override
  Future<ImmunizationApiModel> createImmunization(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.immunizations,
      data: payload,
    );
    if (response.data['success'] == true) {
      return ImmunizationApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(
      response.data['message'] ?? 'Failed to create immunization',
    );
  }

  @override
  Future<ImmunizationApiModel> updateImmunization(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.immunizationById(id),
      data: payload,
    );
    if (response.data['success'] == true) {
      return ImmunizationApiModel.fromJson(
        (response.data['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      );
    }
    throw Exception(
      response.data['message'] ?? 'Failed to update immunization',
    );
  }

  @override
  Future<void> deleteImmunization(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.immunizationById(id));
    if (response.data['success'] == true) {
      return;
    }
    throw Exception(
      response.data['message'] ?? 'Failed to delete immunization',
    );
  }

  Future<FormData> _buildMedicalRecordFormData(
    MedicalRecordUpsertEntity payload,
  ) async {
    final map = <String, dynamic>{'title': payload.title.trim()};

    void addIfHasValue(String key, String? value) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        map[key] = normalized;
      }
    }

    addIfHasValue('recordType', payload.recordType);
    addIfHasValue('category', payload.category);
    addIfHasValue('provider', payload.provider);
    addIfHasValue('recordDate', payload.recordDate);
    addIfHasValue('visitType', payload.visitType);
    addIfHasValue('diagnosis', payload.diagnosis);
    addIfHasValue('content', payload.content);
    addIfHasValue('notes', payload.notes);
    addIfHasValue('status', payload.status);

    if (payload.aiScanned != null) {
      map['aiScanned'] = payload.aiScanned.toString();
    }

    final cleanedStructured = _cleanStructuredData(payload.structuredData);
    if (cleanedStructured.isNotEmpty) {
      map['structuredData'] = jsonEncode(cleanedStructured);
    }

    final domainPayload = _buildDomainPayload(
      recordType: payload.recordType?.trim() ?? '',
      structured: cleanedStructured,
      recordDate: payload.recordDate?.trim(),
    );
    for (final entry in domainPayload.entries) {
      map[entry.key] = jsonEncode(entry.value);
    }

    if (payload.attachmentPaths.isNotEmpty) {
      final files = await Future.wait(
        payload.attachmentPaths.map((path) async {
          final filename = path.split(RegExp(r'[/\\]')).last;
          return MultipartFile.fromFile(path, filename: filename);
        }),
      );
      map['attachments'] = files;
    }

    return FormData.fromMap(map);
  }

  Map<String, String> _cleanStructuredData(Map<String, dynamic>? raw) {
    final cleaned = <String, String>{};
    if (raw == null || raw.isEmpty) return cleaned;

    for (final entry in raw.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      final value = entry.value;
      if (value == null) continue;
      final normalized = value is List
          ? value.map((item) => item.toString().trim()).join(', ')
          : value.toString().trim();
      if (normalized.isNotEmpty) {
        cleaned[key] = normalized;
      }
    }
    return cleaned;
  }

  Map<String, dynamic> _buildDomainPayload({
    required String recordType,
    required Map<String, String> structured,
    required String? recordDate,
  }) {
    final payload = <String, dynamic>{};
    final normalizedType = recordType.trim();
    final trimmedDate = recordDate?.trim();

    void setIf(Map<String, dynamic> target, String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      target[key] = value;
    }

    bool hasAny(Map<String, dynamic> target) => target.isNotEmpty;

    final vitals = <String, dynamic>{};
    setIf(vitals, 'systolicBp', _parseNumber(structured['systolicBp']));
    setIf(vitals, 'diastolicBp', _parseNumber(structured['diastolicBp']));
    setIf(vitals, 'heartRate', _parseNumber(structured['heartRate']));
    setIf(vitals, 'glucoseLevel', _parseNumber(structured['glucoseLevel']));
    setIf(vitals, 'weight', _parseNumber(structured['weight']));
    setIf(vitals, 'height', _parseNumber(structured['height']));
    setIf(vitals, 'bmi', _parseNumber(structured['bmi']));
    if (trimmedDate != null && trimmedDate.isNotEmpty && hasAny(vitals)) {
      setIf(vitals, 'recordedAt', trimmedDate);
    }

    final medications = <String, dynamic>{};
    setIf(medications, 'medicineName', structured['medicineName']?.trim());
    setIf(medications, 'dosage', structured['dosage']?.trim());
    setIf(medications, 'frequency', structured['frequency']?.trim());
    setIf(medications, 'durationDays', _parseNumber(structured['durationDays']));
    setIf(
      medications,
      'startDate',
      structured['startDate']?.trim() ??
          (normalizedType == 'Prescription' ? trimmedDate : null),
    );
    setIf(medications, 'endDate', structured['endDate']?.trim());
    setIf(medications, 'purpose', structured['purpose']?.trim());
    setIf(medications, 'notes', structured['notes']?.trim());
    setIf(medications, 'diagnosis', structured['diagnosis']?.trim());
    setIf(medications, 'disease', structured['disease']?.trim());

    final symptoms = <String, dynamic>{};
    setIf(symptoms, 'symptomList', _parseSymptomList(structured['symptomList']));
    setIf(symptoms, 'severity', structured['severity']?.trim());
    setIf(symptoms, 'durationDays', _parseNumber(structured['durationDays']));
    setIf(symptoms, 'notes', structured['notes']?.trim());
    setIf(symptoms, 'diagnosis', structured['diagnosis']?.trim());
    setIf(symptoms, 'disease', structured['disease']?.trim());
    if (trimmedDate != null && trimmedDate.isNotEmpty && hasAny(symptoms)) {
      setIf(symptoms, 'loggedAt', trimmedDate);
    }

    final allergies = <String, dynamic>{};
    setIf(allergies, 'allergen', structured['allergen']?.trim());
    setIf(allergies, 'type', structured['type']?.trim());
    setIf(allergies, 'reaction', structured['reaction']?.trim());
    setIf(allergies, 'severity', structured['severity']?.trim());
    setIf(allergies, 'status', structured['status']?.trim());
    setIf(allergies, 'onsetDate', structured['onsetDate']?.trim() ?? trimmedDate);
    setIf(
      allergies,
      'recordedAt',
      structured['recordedAt']?.trim() ?? trimmedDate,
    );
    setIf(allergies, 'notes', structured['notes']?.trim());

    final immunizations = <String, dynamic>{};
    setIf(immunizations, 'vaccineName', structured['vaccineName']?.trim());
    setIf(immunizations, 'date', structured['date']?.trim() ?? trimmedDate);
    setIf(
      immunizations,
      'doseNumber',
      _parseNumber(structured['doseNumber']),
    );
    setIf(immunizations, 'series', structured['series']?.trim());
    setIf(immunizations, 'manufacturer', structured['manufacturer']?.trim());
    setIf(immunizations, 'lotNumber', structured['lotNumber']?.trim());
    setIf(immunizations, 'site', structured['site']?.trim());
    setIf(immunizations, 'route', structured['route']?.trim());
    setIf(immunizations, 'provider', structured['provider']?.trim());
    setIf(immunizations, 'nextDue', structured['nextDue']?.trim());
    setIf(immunizations, 'notes', structured['notes']?.trim());

    if (normalizedType == 'Vitals' && hasAny(vitals)) {
      payload['vitals'] = vitals;
    }
    if (normalizedType == 'Prescription' && hasAny(medications)) {
      payload['medications'] = medications;
    }
    if ((normalizedType == 'Diagnosis' || normalizedType == 'Visit') &&
        hasAny(symptoms)) {
      payload['symptoms'] = symptoms;
    }
    if (normalizedType == 'Allergy' && hasAny(allergies)) {
      payload['allergies'] = allergies;
    }
    if (normalizedType == 'Immunization' && hasAny(immunizations)) {
      payload['immunizations'] = immunizations;
    }

    return payload;
  }

  num? _parseNumber(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    return num.tryParse(raw);
  }

  List<String>? _parseSymptomList(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    final result = raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    return result.isEmpty ? null : result;
  }
}
