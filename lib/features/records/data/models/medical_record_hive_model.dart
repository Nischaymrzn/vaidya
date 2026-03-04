import 'package:hive/hive.dart';
import 'package:vaidya/core/constants/hive_table_constant.dart';
import 'package:vaidya/features/records/data/models/medical_record_api_model.dart';

part 'medical_record_hive_model.g.dart';

int _intValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _boolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

@HiveType(typeId: HiveTableConstant.recordAttachmentTypeId)
class MedicalRecordAttachmentHiveModel extends HiveObject {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final String? publicId;

  @HiveField(2)
  final String? type;

  @HiveField(3)
  final String? name;

  @HiveField(4)
  final int? size;

  MedicalRecordAttachmentHiveModel({
    required this.url,
    required this.publicId,
    required this.type,
    required this.name,
    required this.size,
  });

  factory MedicalRecordAttachmentHiveModel.fromApiModel(
    MedicalRecordAttachmentApiModel apiModel,
  ) {
    return MedicalRecordAttachmentHiveModel(
      url: apiModel.url,
      publicId: apiModel.publicId,
      type: apiModel.type,
      name: apiModel.name,
      size: apiModel.size,
    );
  }

  factory MedicalRecordAttachmentHiveModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordAttachmentHiveModel(
      url: (json['url'] ?? '').toString(),
      publicId: json['publicId']?.toString(),
      type: json['type']?.toString(),
      name: json['name']?.toString(),
      size: json['size'] is num ? (json['size'] as num).toInt() : null,
    );
  }

  MedicalRecordAttachmentApiModel toApiModel() {
    return MedicalRecordAttachmentApiModel(
      url: url,
      publicId: publicId,
      type: type,
      name: name,
      size: size,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'publicId': publicId,
      'type': type,
      'name': name,
      'size': size,
    };
  }
}

@HiveType(typeId: HiveTableConstant.recordsTypeId)
class MedicalRecordHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? recordType;

  @HiveField(4)
  final String? category;

  @HiveField(5)
  final String? provider;

  @HiveField(6)
  final String? recordDate;

  @HiveField(7)
  final String? visitType;

  @HiveField(8)
  final String? diagnosis;

  @HiveField(9)
  final String? diagnosisStatus;

  @HiveField(10)
  final String? content;

  @HiveField(11)
  final String? notes;

  @HiveField(12)
  final String? status;

  @HiveField(13)
  final bool aiScanned;

  @HiveField(14)
  final Map<String, dynamic>? structuredData;

  @HiveField(15)
  final List<MedicalRecordAttachmentHiveModel> attachments;

  @HiveField(16)
  final String? createdAt;

  @HiveField(17)
  final String? updatedAt;

  MedicalRecordHiveModel({
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

  factory MedicalRecordHiveModel.fromApiModel(MedicalRecordApiModel apiModel) {
    return MedicalRecordHiveModel(
      id: apiModel.id,
      userId: apiModel.userId,
      title: apiModel.title,
      recordType: apiModel.recordType,
      category: apiModel.category,
      provider: apiModel.provider,
      recordDate: apiModel.recordDate,
      visitType: apiModel.visitType,
      diagnosis: apiModel.diagnosis,
      diagnosisStatus: apiModel.diagnosisStatus,
      content: apiModel.content,
      notes: apiModel.notes,
      status: apiModel.status,
      aiScanned: apiModel.aiScanned,
      structuredData: apiModel.structuredData == null
          ? null
          : Map<String, dynamic>.from(apiModel.structuredData!),
      attachments: apiModel.attachments
          .map(MedicalRecordAttachmentHiveModel.fromApiModel)
          .toList(growable: false),
      createdAt: apiModel.createdAt,
      updatedAt: apiModel.updatedAt,
    );
  }

  factory MedicalRecordHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    final attachmentsRaw = mapped['attachments'];
    final mappedAttachments = attachmentsRaw is List
        ? attachmentsRaw
              .whereType<Map>()
              .map(
                (item) => MedicalRecordAttachmentHiveModel.fromJson(
                  item.map((k, v) => MapEntry(k.toString(), v)),
                ),
              )
              .toList(growable: false)
        : <MedicalRecordAttachmentHiveModel>[];

    final structuredRaw = mapped['structuredData'];
    final mappedStructured = structuredRaw is Map
        ? structuredRaw.map((k, v) => MapEntry(k.toString(), v))
        : null;

    return MedicalRecordHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      userId: (mapped['userId'] ?? '').toString(),
      title: (mapped['title'] ?? 'Untitled record').toString(),
      recordType: mapped['recordType']?.toString(),
      category: mapped['category']?.toString(),
      provider: mapped['provider']?.toString(),
      recordDate: mapped['recordDate']?.toString(),
      visitType: mapped['visitType']?.toString(),
      diagnosis: mapped['diagnosis']?.toString(),
      diagnosisStatus: mapped['diagnosisStatus']?.toString(),
      content: mapped['content']?.toString(),
      notes: mapped['notes']?.toString(),
      status: mapped['status']?.toString(),
      aiScanned: _boolValue(mapped['aiScanned']),
      structuredData: mappedStructured,
      attachments: mappedAttachments,
      createdAt: mapped['createdAt']?.toString(),
      updatedAt: mapped['updatedAt']?.toString(),
    );
  }

  MedicalRecordApiModel toApiModel() {
    return MedicalRecordApiModel(
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
      attachments: attachments
          .map((item) => item.toApiModel())
          .toList(growable: false),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      '_id': id,
      'userId': userId,
      'title': title,
      'recordType': recordType,
      'category': category,
      'provider': provider,
      'recordDate': recordDate,
      'visitType': visitType,
      'diagnosis': diagnosis,
      'diagnosisStatus': diagnosisStatus,
      'content': content,
      'notes': notes,
      'status': status,
      'aiScanned': aiScanned,
      'structuredData': structuredData,
      'attachments': attachments
          .map((attachment) => attachment.toJson())
          .toList(growable: false),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

@HiveType(typeId: HiveTableConstant.recordsPaginationTypeId)
class MedicalRecordsPaginationHiveModel extends HiveObject {
  @HiveField(0)
  final int total;

  @HiveField(1)
  final int page;

  @HiveField(2)
  final int limit;

  @HiveField(3)
  final int totalPages;

  @HiveField(4)
  final bool hasNext;

  @HiveField(5)
  final bool hasPrev;

  MedicalRecordsPaginationHiveModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory MedicalRecordsPaginationHiveModel.fromApiModel(
    MedicalRecordsPaginationApiModel apiModel,
  ) {
    return MedicalRecordsPaginationHiveModel(
      total: apiModel.total,
      page: apiModel.page,
      limit: apiModel.limit,
      totalPages: apiModel.totalPages,
      hasNext: apiModel.hasNext,
      hasPrev: apiModel.hasPrev,
    );
  }

  factory MedicalRecordsPaginationHiveModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordsPaginationHiveModel(
      total: _intValue(json['total']),
      page: _intValue(json['page'], fallback: 1),
      limit: _intValue(json['limit'], fallback: 20),
      totalPages: _intValue(json['totalPages'], fallback: 1),
      hasNext: _boolValue(json['hasNext']),
      hasPrev: _boolValue(json['hasPrev']),
    );
  }

  MedicalRecordsPaginationApiModel toApiModel() {
    return MedicalRecordsPaginationApiModel(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNext: hasNext,
      hasPrev: hasPrev,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}

@HiveType(typeId: HiveTableConstant.recordsResultTypeId)
class MedicalRecordsResultHiveModel extends HiveObject {
  @HiveField(0)
  final List<MedicalRecordHiveModel> records;

  @HiveField(1)
  final MedicalRecordsPaginationHiveModel pagination;

  MedicalRecordsResultHiveModel({
    required this.records,
    required this.pagination,
  });

  factory MedicalRecordsResultHiveModel.fromApiModel(
    MedicalRecordsResultApiModel apiModel,
  ) {
    return MedicalRecordsResultHiveModel(
      records: apiModel.records
          .map(MedicalRecordHiveModel.fromApiModel)
          .toList(growable: false),
      pagination: MedicalRecordsPaginationHiveModel.fromApiModel(
        apiModel.pagination,
      ),
    );
  }

  factory MedicalRecordsResultHiveModel.fromResponse(Map<String, dynamic> json) {
    final recordsRaw = json['data'];
    final records = recordsRaw is List
        ? recordsRaw
              .whereType<Map>()
              .map(
                (item) => MedicalRecordHiveModel.fromJson(
                  item.map((k, v) => MapEntry(k.toString(), v)),
                ),
              )
              .toList(growable: false)
        : <MedicalRecordHiveModel>[];

    final paginationRaw = json['pagination'];
    final pagination = paginationRaw is Map
        ? MedicalRecordsPaginationHiveModel.fromJson(
            paginationRaw.map((k, v) => MapEntry(k.toString(), v)),
          )
        : MedicalRecordsPaginationHiveModel(
            total: records.length,
            page: 1,
            limit: records.length,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          );

    return MedicalRecordsResultHiveModel(records: records, pagination: pagination);
  }

  MedicalRecordsResultApiModel toApiModel() {
    return MedicalRecordsResultApiModel(
      records: records.map((item) => item.toApiModel()).toList(growable: false),
      pagination: pagination.toApiModel(),
    );
  }

  Map<String, dynamic> toResponseJson() {
    return <String, dynamic>{
      'data': records.map((item) => item.toJson()).toList(growable: false),
      'pagination': pagination.toJson(),
    };
  }
}

@HiveType(typeId: HiveTableConstant.aiScanResultTypeId)
class AiScanResultHiveModel extends HiveObject {
  @HiveField(0)
  final String? text;

  @HiveField(1)
  final String? recordType;

  @HiveField(2)
  final String? provider;

  @HiveField(3)
  final String? recordDate;

  @HiveField(4)
  final String? summary;

  @HiveField(5)
  final Map<String, dynamic>? structured;

  AiScanResultHiveModel({
    required this.text,
    required this.recordType,
    required this.provider,
    required this.recordDate,
    required this.summary,
    required this.structured,
  });

  factory AiScanResultHiveModel.fromApiModel(AiScanResultApiModel apiModel) {
    return AiScanResultHiveModel(
      text: apiModel.text,
      recordType: apiModel.recordType,
      provider: apiModel.provider,
      recordDate: apiModel.recordDate,
      summary: apiModel.summary,
      structured: apiModel.structured == null
          ? null
          : Map<String, dynamic>.from(apiModel.structured!),
    );
  }

  factory AiScanResultHiveModel.fromJson(Map<String, dynamic> json) {
    final structuredRaw = json['structured'];
    final mappedStructured = structuredRaw is Map
        ? structuredRaw.map((k, v) => MapEntry(k.toString(), v))
        : null;
    return AiScanResultHiveModel(
      text: json['text']?.toString(),
      recordType: json['recordType']?.toString(),
      provider: json['provider']?.toString(),
      recordDate: json['recordDate']?.toString(),
      summary: json['summary']?.toString(),
      structured: mappedStructured,
    );
  }

  AiScanResultApiModel toApiModel() {
    return AiScanResultApiModel(
      text: text,
      recordType: recordType,
      provider: provider,
      recordDate: recordDate,
      summary: summary,
      structured: structured,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      'recordType': recordType,
      'provider': provider,
      'recordDate': recordDate,
      'summary': summary,
      'structured': structured,
    };
  }
}
