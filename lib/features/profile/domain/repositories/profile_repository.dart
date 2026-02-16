import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, ProfileUserEntity>> getUserById(String id);
  Future<Either<Failure, ProfileUserEntity>> updateUser(
    String id,
    Map<String, dynamic> payload, {
    String? imagePath,
  });
  Future<Either<Failure, bool>> deleteUser(String id);
}
