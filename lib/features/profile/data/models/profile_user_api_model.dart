import 'package:dio/dio.dart';
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

  static Future<FormData> buildUpdateFormData(
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    final map = Map<String, dynamic>.from(payload);
    final trimmedPath = imagePath?.trim();
    if (trimmedPath != null && trimmedPath.isNotEmpty) {
      final filename = trimmedPath.split(RegExp(r'[/\\]')).last;
      map['image'] = await MultipartFile.fromFile(
        trimmedPath,
        filename: filename,
      );
    }
    return FormData.fromMap(map);
  }
}
