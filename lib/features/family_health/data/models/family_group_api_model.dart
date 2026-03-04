import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';

class FamilyGroupApiModel {
  final String id;
  final Map<String, dynamic> data;

  const FamilyGroupApiModel({required this.id, required this.data});

  factory FamilyGroupApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return FamilyGroupApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  FamilyGroupEntity toEntity() => FamilyGroupEntity(id: id, data: data);
}

class FamilyGroupSummaryApiModel {
  final Map<String, dynamic> data;

  const FamilyGroupSummaryApiModel({required this.data});

  factory FamilyGroupSummaryApiModel.fromJson(Map<String, dynamic> json) {
    return FamilyGroupSummaryApiModel(data: Map<String, dynamic>.from(json));
  }

  FamilyGroupSummaryEntity toEntity() => FamilyGroupSummaryEntity(data: data);
}

class FamilyInviteApiModel {
  final String token;
  final Map<String, dynamic> data;

  const FamilyInviteApiModel({required this.token, required this.data});

  factory FamilyInviteApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return FamilyInviteApiModel(
      token: (mapped['token'] ?? '').toString(),
      data: mapped,
    );
  }

  FamilyInviteEntity toEntity() => FamilyInviteEntity(token: token, data: data);
}
