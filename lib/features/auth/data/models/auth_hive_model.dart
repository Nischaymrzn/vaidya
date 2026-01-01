import 'package:hive/hive.dart';
import 'package:vaidya/core/constants/hive_table_constant.dart';
import 'package:uuid/uuid.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? username;

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final String? profilePicture;

  AuthHiveModel({
    String? userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.username,
    this.password,
    this.profilePicture,
  }) : userId = userId ?? const Uuid().v4();

  // To Entity
  AuthEntity toEntity({AuthEntity? auth}) {
    return AuthEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      profilePicture: profilePicture,
    );
  }

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
