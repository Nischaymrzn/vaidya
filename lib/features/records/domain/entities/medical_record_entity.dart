import 'package:equatable/equatable.dart';

class MedicalRecordAttachmentEntity extends Equatable {
  final String url;
  final String? publicId;
  final String? type;
  final String? name;
  final int? size;

  const MedicalRecordAttachmentEntity({
    required this.url,
    this.publicId,
    this.type,
    this.name,
    this.size,
  });

  bool get isPdf {
    final normalizedType = (type ?? '').toLowerCase();
    final normalizedUrl = url.toLowerCase();
    return normalizedType == 'application/pdf' ||
        normalizedUrl.contains('.pdf');
  }

  bool get isImage {
    final normalizedType = (type ?? '').toLowerCase();
    final normalizedUrl = url.toLowerCase();
    return normalizedType.startsWith('image/') ||
        normalizedUrl.contains('.png') ||
        normalizedUrl.contains('.jpg') ||
        normalizedUrl.contains('.jpeg') ||
        normalizedUrl.contains('.webp');
  }

  @override
  List<Object?> get props => [url, publicId, type, name, size];
}

class MedicalRecordEntity extends Equatable {
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
  final List<MedicalRecordAttachmentEntity> attachments;
  final String? createdAt;
  final String? updatedAt;

  const MedicalRecordEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.recordType,
    this.category,
    this.provider,
    this.recordDate,
    this.visitType,
    this.diagnosis,
    this.diagnosisStatus,
    this.content,
    this.notes,
    this.status,
    required this.aiScanned,
    this.structuredData,
    required this.attachments,
    this.createdAt,
    this.updatedAt,
  });

  String get effectiveDate => recordDate ?? updatedAt ?? createdAt ?? '';
  String get effectiveStatus =>
      status?.trim().isNotEmpty == true ? status!.trim() : 'Processed';

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    recordType,
    category,
    provider,
    recordDate,
    visitType,
    diagnosis,
    diagnosisStatus,
    content,
    notes,
    status,
    aiScanned,
    structuredData,
    attachments,
    createdAt,
    updatedAt,
  ];
}

class MedicalRecordsPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const MedicalRecordsPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  const MedicalRecordsPaginationEntity.empty()
    : total = 0,
      page = 1,
      limit = 20,
      totalPages = 1,
      hasNext = false,
      hasPrev = false;

  @override
  List<Object?> get props => [total, page, limit, totalPages, hasNext, hasPrev];
}

class MedicalRecordsResultEntity extends Equatable {
  final List<MedicalRecordEntity> records;
  final MedicalRecordsPaginationEntity pagination;

  const MedicalRecordsResultEntity({
    required this.records,
    required this.pagination,
  });

  const MedicalRecordsResultEntity.empty()
    : records = const [],
      pagination = const MedicalRecordsPaginationEntity.empty();

  @override
  List<Object?> get props => [records, pagination];
}

class MedicalRecordUpsertEntity extends Equatable {
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

  const MedicalRecordUpsertEntity({
    required this.title,
    this.recordType,
    this.category,
    this.provider,
    this.recordDate,
    this.visitType,
    this.diagnosis,
    this.content,
    this.notes,
    this.status,
    this.aiScanned,
    this.structuredData,
    this.attachmentPaths = const [],
  });

  @override
  List<Object?> get props => [
    title,
    recordType,
    category,
    provider,
    recordDate,
    visitType,
    diagnosis,
    content,
    notes,
    status,
    aiScanned,
    structuredData,
    attachmentPaths,
  ];
}

class AiScanResultEntity extends Equatable {
  final String? text;
  final String? recordType;
  final String? provider;
  final String? recordDate;
  final String? summary;
  final Map<String, dynamic>? structured;

  const AiScanResultEntity({
    this.text,
    this.recordType,
    this.provider,
    this.recordDate,
    this.summary,
    this.structured,
  });

  @override
  List<Object?> get props => [
    text,
    recordType,
    provider,
    recordDate,
    summary,
    structured,
  ];
}
