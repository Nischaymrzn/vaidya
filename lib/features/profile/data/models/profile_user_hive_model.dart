import 'package:vaidya/features/profile/data/models/profile_user_api_model.dart';

class ProfileUserHiveModel {
  final String id;
  final Map<String, dynamic> data;

  const ProfileUserHiveModel({required this.id, required this.data});

  factory ProfileUserHiveModel.fromApiModel(ProfileUserApiModel apiModel) {
    return ProfileUserHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory ProfileUserHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return ProfileUserHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? '').toString(),
      data: mapped,
    );
  }

  ProfileUserApiModel toApiModel() => ProfileUserApiModel.fromJson(data);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(data);
}
