import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:vaidya/features/records/data/models/medical_record_domain_payload_builder.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';

class MedicalRecordUpsertApiModel {
  final String title;
  final String? recordType;
  final String? category;
  final String? provider;
  final String? recordDate;
  final String? visitType;
  final String? diagnosis;
  final String? content;
  final String? notes;
  final String? status;
  final bool? aiScanned;
  final Map<String, dynamic>? structuredData;
  final List<String> attachmentPaths;

  const MedicalRecordUpsertApiModel({
    required this.title,
    required this.recordType,
    required this.category,
    required this.provider,
    required this.recordDate,
    required this.visitType,
    required this.diagnosis,
    required this.content,
    required this.notes,
    required this.status,
    required this.aiScanned,
    required this.structuredData,
    required this.attachmentPaths,
  });

  factory MedicalRecordUpsertApiModel.fromEntity(
    MedicalRecordUpsertEntity entity,
  ) {
    return MedicalRecordUpsertApiModel(
      title: entity.title,
      recordType: entity.recordType,
      category: entity.category,
      provider: entity.provider,
      recordDate: entity.recordDate,
      visitType: entity.visitType,
      diagnosis: entity.diagnosis,
      content: entity.content,
      notes: entity.notes,
      status: entity.status,
      aiScanned: entity.aiScanned,
      structuredData: entity.structuredData,
      attachmentPaths: entity.attachmentPaths,
    );
  }

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{'title': title.trim()};

    void addIfHasValue(String key, String? value) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        map[key] = normalized;
      }
    }

    addIfHasValue('recordType', recordType);
    addIfHasValue('category', category);
    addIfHasValue('provider', provider);
    addIfHasValue('recordDate', recordDate);
    addIfHasValue('visitType', visitType);
    addIfHasValue('diagnosis', diagnosis);
    addIfHasValue('content', content);
    addIfHasValue('notes', notes);
    addIfHasValue('status', status);

    if (aiScanned != null) {
      map['aiScanned'] = aiScanned.toString();
    }

    final cleanedStructured = _cleanStructuredData(structuredData);
    if (cleanedStructured.isNotEmpty) {
      map['structuredData'] = jsonEncode(cleanedStructured);
    }

    final domainPayload = _buildDomainPayload(
      recordType: recordType?.trim() ?? '',
      structured: cleanedStructured,
      recordDate: recordDate?.trim(),
    );
    for (final entry in domainPayload.entries) {
      map[entry.key] = jsonEncode(entry.value);
    }

    if (attachmentPaths.isNotEmpty) {
      final files = await Future.wait(
        attachmentPaths.map((path) async {
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
    return MedicalRecordDomainPayloadBuilder.build(
      recordType: recordType,
      structured: structured,
      recordDate: recordDate,
    );
  }
}
