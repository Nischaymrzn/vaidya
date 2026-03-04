import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/dashboard/domain/entities/user_data_entity.dart';

abstract interface class IUserDataRepository {
  Future<Either<Failure, UserDataEntity>> getUserData();
  Future<Either<Failure, UserDataEntity>> updateUserData(Map<String, dynamic> payload);
}
