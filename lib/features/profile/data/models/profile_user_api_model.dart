import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';

class ProfileUserApiModel {
  final String id;
  final Map<String, dynamic> data;

  const ProfileUserApiModel({required this.id, required this.data});

  factory ProfileUserApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return ProfileUserApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  ProfileUserEntity toEntity() => ProfileUserEntity(id: id, data: data);
}
