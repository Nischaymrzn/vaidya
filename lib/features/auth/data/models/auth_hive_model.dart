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
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final int? number;

  @HiveField(4)
  final String? role;

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final String? profilePicture;

  AuthHiveModel({
    String? userId,
    required this.name,
    required this.email,
    this.number,
    this.role,
    this.password,
    this.profilePicture,
  }) : userId = userId ?? const Uuid().v4();

  // To Entity
  AuthEntity toEntity({AuthEntity? auth}) {
    return AuthEntity(
      userId: userId,
      name: name,
      email: email,
      number: number,
      role: role,
      password: password,
      profilePicture: profilePicture,
    );
  }

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      number: entity.number,
      role: entity.role,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
