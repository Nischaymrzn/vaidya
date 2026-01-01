import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/auth/data/datasources/auth_datasource.dart';
import 'package:vaidya/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vaidya/features/auth/data/models/auth_hive_model.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  return AuthRepository(authDatasource: authDatasource);
});

class AuthRepository implements IAuthRepository {
  final IAuthDataSource _authDataSource;

  AuthRepository({required IAuthDataSource authDatasource})
    : _authDataSource = authDatasource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    try {
      final existingUser = await _authDataSource.getUserByEmail(user.email);
      if (existingUser != null) {
        return const Left(
          LocalDatabaseFailure(
            message: "This email has already been registered!",
          ),
        );
      }

      final authModel = AuthHiveModel.fromEntity(user);
      final result = await _authDataSource.register(authModel);

      if (result) {
        return const Right(true);
      }

      return Left(
        LocalDatabaseFailure(
          message: "Failed to register user, please try again!",
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDataSource.login(email, password);

      if (user != null) {
        final userEntity = user.toEntity();
        return Right(userEntity);
      }

      return const Left(
        LocalDatabaseFailure(
          message: "Invalid email or password, please try again!",
        ),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();

      if (user != null) {
        final userEntity = user.toEntity();
        return Right(userEntity);
      }

      return const Left(LocalDatabaseFailure(message: "No any user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final loggedOut = await _authDataSource.logout();
      if (loggedOut) {
        return const Right(true);
      }

      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
