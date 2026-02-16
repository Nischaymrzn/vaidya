import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

class MedicalRecordAttachmentApiModel {
  final String url;
  final String? publicId;
  final String? type;
  final String? name;
  final int? size;

  const MedicalRecordAttachmentApiModel({
    required this.url,
    required this.publicId,
    required this.type,
    required this.name,
    required this.size,
  });

  factory MedicalRecordAttachmentApiModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordAttachmentApiModel(
      url: _asString(json['url']),
      publicId: json['publicId']?.toString(),
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      size: json['size'] is num ? (json['size'] as num).toInt() : null,
    );
  }

  MedicalRecordAttachmentEntity toEntity() {
    return MedicalRecordAttachmentEntity(
      url: url,
      publicId: publicId,
      type: type,
      name: name,
      size: size,
    );
  }
}

class MedicalRecordApiModel {
  final String id;
  final String userId;
  final String title;
  final String? recordType;
  final String? category;
  final String? provider;
  final String? recordDate;
  final String? visitType;
  final String? diagnosis;
  final String? diagnosisStatus;
  final String? content;
  final String? notes;
  final String? status;
  final bool aiScanned;
  final Map<String, dynamic>? structuredData;
  final List<MedicalRecordAttachmentApiModel> attachments;
  final String? createdAt;
  final String? updatedAt;

  const MedicalRecordApiModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.recordType,
    required this.category,
    required this.provider,
    required this.recordDate,
    required this.visitType,
    required this.diagnosis,
    required this.diagnosisStatus,
    required this.content,
    required this.notes,
    required this.status,
    required this.aiScanned,
    required this.structuredData,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalRecordApiModel.fromJson(Map<String, dynamic> json) {
    final attachmentsRaw = json['attachments'];
    final parsedAttachments = attachmentsRaw is List
        ? attachmentsRaw
              .whereType<Map<String, dynamic>>()
              .map(MedicalRecordAttachmentApiModel.fromJson)
              .toList(growable: false)
        : <MedicalRecordAttachmentApiModel>[];

    final structuredRaw = json['structuredData'];
    final structuredData = structuredRaw is Map<String, dynamic>
        ? structuredRaw
        : null;

    return MedicalRecordApiModel(
      id: _asString(json['_id']),
      userId: _asString(json['userId']),
      title: _asString(json['title'], fallback: 'Untitled record'),
      recordType: json['recordType']?.toString(),
      category: json['category']?.toString(),
      provider: json['provider']?.toString(),
      recordDate: json['recordDate']?.toString(),
      visitType: json['visitType']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      diagnosisStatus: json['diagnosisStatus']?.toString(),
      content: json['content']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString(),
      aiScanned: _asBool(json['aiScanned']),
      structuredData: structuredData,
      attachments: parsedAttachments,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  MedicalRecordEntity toEntity() {
    return MedicalRecordEntity(
      id: id,
      userId: userId,
      title: title,
      recordType: recordType,
      category: category,
      provider: provider,
      recordDate: recordDate,
      visitType: visitType,
      diagnosis: diagnosis,
      diagnosisStatus: diagnosisStatus,
      content: content,
      notes: notes,
      status: status,
      aiScanned: aiScanned,
      structuredData: structuredData,
      attachments: attachments.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class MedicalRecordsPaginationApiModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const MedicalRecordsPaginationApiModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory MedicalRecordsPaginationApiModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordsPaginationApiModel(
      total: _asInt(json['total']),
      page: _asInt(json['page'], fallback: 1),
      limit: _asInt(json['limit'], fallback: 20),
      totalPages: _asInt(json['totalPages'], fallback: 1),
      hasNext: _asBool(json['hasNext']),
      hasPrev: _asBool(json['hasPrev']),
    );
  }

  MedicalRecordsPaginationEntity toEntity() {
    return MedicalRecordsPaginationEntity(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNext: hasNext,
      hasPrev: hasPrev,
    );
  }
}

class MedicalRecordsResultApiModel {
  final List<MedicalRecordApiModel> records;
  final MedicalRecordsPaginationApiModel pagination;

  const MedicalRecordsResultApiModel({
    required this.records,
    required this.pagination,
  });

  factory MedicalRecordsResultApiModel.fromResponse(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final records = dataRaw is List
        ? dataRaw
              .whereType<Map<String, dynamic>>()
              .map(MedicalRecordApiModel.fromJson)
              .toList(growable: false)
        : <MedicalRecordApiModel>[];

    final paginationRaw = json['pagination'];
    final pagination = paginationRaw is Map<String, dynamic>
        ? MedicalRecordsPaginationApiModel.fromJson(paginationRaw)
        : MedicalRecordsPaginationApiModel(
            total: records.length,
            page: 1,
            limit: records.length,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          );

    return MedicalRecordsResultApiModel(
      records: records,
      pagination: pagination,
    );
  }

  MedicalRecordsResultEntity toEntity() {
    return MedicalRecordsResultEntity(
      records: records.map((item) => item.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class AiScanResultApiModel {
  final String? text;
  final String? recordType;
  final String? provider;
  final String? recordDate;
  final String? summary;
  final Map<String, dynamic>? structured;

  const AiScanResultApiModel({
    required this.text,
    required this.recordType,
    required this.provider,
    required this.recordDate,
    required this.summary,
    required this.structured,
  });

  factory AiScanResultApiModel.fromJson(Map<String, dynamic> json) {
    final structuredRaw = json['structured'];
    return AiScanResultApiModel(
      text: json['text']?.toString(),
      recordType: json['recordType']?.toString(),
      provider: json['provider']?.toString(),
      recordDate: json['recordDate']?.toString(),
      summary: json['summary']?.toString(),
      structured: structuredRaw is Map<String, dynamic> ? structuredRaw : null,
    );
  }

  AiScanResultEntity toEntity() {
    return AiScanResultEntity(
      text: text,
      recordType: recordType,
      provider: provider,
      recordDate: recordDate,
      summary: summary,
      structured: structured,
    );
  }
}

