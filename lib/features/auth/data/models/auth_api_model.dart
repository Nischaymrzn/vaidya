import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String name;
  final String email;
  final int? number;
  final String? role;
  final String? password;
  final String? confirmPassword;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.name,
    required this.email,
    this.number,
    this.role,
    this.password,
    this.confirmPassword,
    this.profilePicture,
  });

  // toJSON
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "number": number,
      "username": role,
      "password": password,
      "confirmPassword": confirmPassword,
      "profilePicture": profilePicture,
    };
  }

  // fromJSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      number: json['number'] as int?,
      role: json['role'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  // toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: id,
      name: name,
      email: email,
      number: number,
      role: role,
      profilePicture: profilePicture,
    );
  }

  // fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      name: entity.name,
      email: entity.email,
      number: entity.number,
      role: entity.role,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }
}
