import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String name;
  final String email;
  final String? number;
  final String? role;
  final bool? isPremium;
  final String? password;
  final String? confirmPassword;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.name,
    required this.email,
    this.number,
    this.role,
    this.isPremium,
    this.password,
    this.confirmPassword,
    this.profilePicture,
  });

  // toJSON
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "name": name,
      "email": email,
      "number": number,
      "username": role,
      "password": password,
      "confirmPassword": password,
    };
    if (profilePicture != null) {
      map["profilePicture"] = profilePicture;
    }
    if (isPremium != null) {
      map["isPremium"] = isPremium;
    }
    return map;
  }

  // fromJSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] ?? json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      number: json['number'] as String?,
      role: json['role'] as String?,
      isPremium: json['isPremium'] as bool?,
      profilePicture: (json['profilePicture'] ?? json['profileUrl']) as String?,
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
      isPremium: isPremium,
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
      isPremium: entity.isPremium,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }
}
