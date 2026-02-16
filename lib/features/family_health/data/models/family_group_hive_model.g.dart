// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_group_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FamilyGroupHiveModelAdapter extends TypeAdapter<FamilyGroupHiveModel> {
  @override
  final int typeId = 6;

  @override
  FamilyGroupHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyGroupHiveModel(
      id: fields[0] as String,
      data: (fields[1] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FamilyGroupHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyGroupHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FamilyGroupSummaryHiveModelAdapter
    extends TypeAdapter<FamilyGroupSummaryHiveModel> {
  @override
  final int typeId = 7;

  @override
  FamilyGroupSummaryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyGroupSummaryHiveModel(
      data: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FamilyGroupSummaryHiveModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyGroupSummaryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FamilyInviteHiveModelAdapter extends TypeAdapter<FamilyInviteHiveModel> {
  @override
  final int typeId = 8;

  @override
  FamilyInviteHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyInviteHiveModel(
      token: fields[0] as String,
      data: (fields[1] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, FamilyInviteHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.token)
      ..writeByte(1)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyInviteHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
