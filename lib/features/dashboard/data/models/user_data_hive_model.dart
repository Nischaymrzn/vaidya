import 'package:vaidya/features/dashboard/data/models/user_data_api_model.dart';

class UserDataHiveModel {
  final String id;
  final Map<String, dynamic> data;

  const UserDataHiveModel({required this.id, required this.data});

  factory UserDataHiveModel.fromApiModel(UserDataApiModel apiModel) {
    return UserDataHiveModel(
      id: apiModel.id,
      data: Map<String, dynamic>.from(apiModel.data),
    );
  }

  factory UserDataHiveModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return UserDataHiveModel(
      id: (mapped['_id'] ?? mapped['id'] ?? mapped['userId'] ?? '').toString(),
      data: mapped,
    );
  }

  UserDataApiModel toApiModel() {
    return UserDataApiModel.fromJson(data);
  }

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(data);
  }
}
