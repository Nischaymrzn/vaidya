import 'package:hive/hive.dart';
import 'package:vaidya/core/constants/hive_table_constant.dart';
import 'package:vaidya/features/family_health/data/models/family_group_api_model.dart';

part 'family_group_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.familyGroupTypeId)
class FamilyGroupHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Map<String, dynamic> data;

  FamilyGroupHiveModel({required this.id, required this.data});

  factory FamilyGroupHiveModel.fromApiModel(FamilyGroupApiModel apiModel) {
    return FamilyGroupHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory FamilyGroupHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return FamilyGroupHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  FamilyGroupApiModel toApiModel() {
    return FamilyGroupApiModel(id: id, data: Map<String, dynamic>.from(data));
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

@HiveType(typeId: HiveTableConstant.familyGroupSummaryTypeId)
class FamilyGroupSummaryHiveModel extends HiveObject {
  @HiveField(0)
  final Map<String, dynamic> data;

  FamilyGroupSummaryHiveModel({required this.data});

  factory FamilyGroupSummaryHiveModel.fromApiModel(
    FamilyGroupSummaryApiModel apiModel,
  ) {
    return FamilyGroupSummaryHiveModel(
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory FamilyGroupSummaryHiveModel.fromJson(Map<String, dynamic> json) {
    return FamilyGroupSummaryHiveModel(data: Map<String, dynamic>.from(json));
  }

  FamilyGroupSummaryApiModel toApiModel() {
    return FamilyGroupSummaryApiModel(data: Map<String, dynamic>.from(data));
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}

@HiveType(typeId: HiveTableConstant.familyInviteTypeId)
class FamilyInviteHiveModel extends HiveObject {
  @HiveField(0)
  final String token;

  @HiveField(1)
  final Map<String, dynamic> data;

  FamilyInviteHiveModel({required this.token, required this.data});

  factory FamilyInviteHiveModel.fromApiModel(FamilyInviteApiModel apiModel) {
    return FamilyInviteHiveModel(
      token: apiModel.token,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory FamilyInviteHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return FamilyInviteHiveModel(
      token: (mapped['token'] ?? '').toString(),
      data: mapped,
    );
  }

  FamilyInviteApiModel toApiModel() {
    return FamilyInviteApiModel(
      token: token,
      data: Map<String, dynamic>.from(data),
    );
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}
