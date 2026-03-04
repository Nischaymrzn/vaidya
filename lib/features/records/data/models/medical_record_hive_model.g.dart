// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_record_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalRecordAttachmentHiveModelAdapter
    extends TypeAdapter<MedicalRecordAttachmentHiveModel> {
  @override
  final int typeId = 2;

  @override
  MedicalRecordAttachmentHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalRecordAttachmentHiveModel(
      url: fields[0] as String,
      publicId: fields[1] as String?,
      type: fields[2] as String?,
      name: fields[3] as String?,
      size: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalRecordAttachmentHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.publicId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordAttachmentHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicalRecordHiveModelAdapter
    extends TypeAdapter<MedicalRecordHiveModel> {
  @override
  final int typeId = 1;

  @override
  MedicalRecordHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalRecordHiveModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      recordType: fields[3] as String?,
      category: fields[4] as String?,
      provider: fields[5] as String?,
      recordDate: fields[6] as String?,
      visitType: fields[7] as String?,
      diagnosis: fields[8] as String?,
      diagnosisStatus: fields[9] as String?,
      content: fields[10] as String?,
      notes: fields[11] as String?,
      status: fields[12] as String?,
      aiScanned: fields[13] as bool,
      structuredData: (fields[14] as Map?)?.cast<String, dynamic>(),
      attachments:
          (fields[15] as List).cast<MedicalRecordAttachmentHiveModel>(),
      createdAt: fields[16] as String?,
      updatedAt: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalRecordHiveModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.recordType)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.provider)
      ..writeByte(6)
      ..write(obj.recordDate)
      ..writeByte(7)
      ..write(obj.visitType)
      ..writeByte(8)
      ..write(obj.diagnosis)
      ..writeByte(9)
      ..write(obj.diagnosisStatus)
      ..writeByte(10)
      ..write(obj.content)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.aiScanned)
      ..writeByte(14)
      ..write(obj.structuredData)
      ..writeByte(15)
      ..write(obj.attachments)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicalRecordsPaginationHiveModelAdapter
    extends TypeAdapter<MedicalRecordsPaginationHiveModel> {
  @override
  final int typeId = 3;

  @override
  MedicalRecordsPaginationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalRecordsPaginationHiveModel(
      total: fields[0] as int,
      page: fields[1] as int,
      limit: fields[2] as int,
      totalPages: fields[3] as int,
      hasNext: fields[4] as bool,
      hasPrev: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalRecordsPaginationHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.total)
      ..writeByte(1)
      ..write(obj.page)
      ..writeByte(2)
      ..write(obj.limit)
      ..writeByte(3)
      ..write(obj.totalPages)
      ..writeByte(4)
      ..write(obj.hasNext)
      ..writeByte(5)
      ..write(obj.hasPrev);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordsPaginationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicalRecordsResultHiveModelAdapter
    extends TypeAdapter<MedicalRecordsResultHiveModel> {
  @override
  final int typeId = 4;

  @override
  MedicalRecordsResultHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalRecordsResultHiveModel(
      records: (fields[0] as List).cast<MedicalRecordHiveModel>(),
      pagination: fields[1] as MedicalRecordsPaginationHiveModel,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalRecordsResultHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.records)
      ..writeByte(1)
      ..write(obj.pagination);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordsResultHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AiScanResultHiveModelAdapter extends TypeAdapter<AiScanResultHiveModel> {
  @override
  final int typeId = 5;

  @override
  AiScanResultHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiScanResultHiveModel(
      text: fields[0] as String?,
      recordType: fields[1] as String?,
      provider: fields[2] as String?,
      recordDate: fields[3] as String?,
      summary: fields[4] as String?,
      structured: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, AiScanResultHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.recordType)
      ..writeByte(2)
      ..write(obj.provider)
      ..writeByte(3)
      ..write(obj.recordDate)
      ..writeByte(4)
      ..write(obj.summary)
      ..writeByte(5)
      ..write(obj.structured);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiScanResultHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
