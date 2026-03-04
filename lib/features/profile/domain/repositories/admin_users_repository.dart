import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/profile/domain/entities/admin_user_entity.dart';

abstract interface class IAdminUsersRepository {
  Future<Either<Failure, AdminUsersResultEntity>> getUsers({required int page, required int limit});
  Future<Either<Failure, AdminUserEntity>> getUserById(String id);
  Future<Either<Failure, AdminUserEntity>> createUser(Map<String, dynamic> payload, {String? imagePath});
  Future<Either<Failure, AdminUserEntity>> updateUser(String id, Map<String, dynamic> payload, {String? imagePath});
  Future<Either<Failure, bool>> deleteUser(String id);
}
