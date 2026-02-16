import 'package:vaidya/features/dashboard/domain/entities/user_data_entity.dart';

class UserDataApiModel {
  final String id;
  final Map<String, dynamic> data;

  const UserDataApiModel({required this.id, required this.data});

  factory UserDataApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return UserDataApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? mapped['userId'] ?? '').toString(),
      data: mapped,
    );
  }

  UserDataEntity toEntity() => UserDataEntity(id: id, data: data);
}
