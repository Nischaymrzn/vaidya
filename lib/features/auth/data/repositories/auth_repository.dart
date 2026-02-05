import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/core/services/storage/token_service.dart';
import 'package:vaidya/features/auth/data/datasources/auth_datasource.dart';
import 'package:vaidya/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vaidya/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:vaidya/features/auth/data/models/auth_api_model.dart';
import 'package:vaidya/features/auth/data/models/auth_hive_model.dart';
import 'package:vaidya/features/auth/domain/entities/auth_entity.dart';
import 'package:vaidya/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
    tokenService: tokenService,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDatasource;
  final NetworkInfo _networkInfo;
  final TokenService _tokenService;

  AuthRepository({
    required IAuthLocalDataSource authDatasource,
    required IAuthRemoteDataSource authRemoteDatasource,
    required NetworkInfo networkInfo,
    required TokenService tokenService,
  }) : _authDataSource = authDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo,
       _tokenService = tokenService;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDatasource.register(apiModel);
        return Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Registration failed",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        // Check if email already exists
        final existingUser = await _authDataSource.getUserByEmail(user.email);
        if (existingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered"),
          );
        }

        final authModel = AuthHiveModel.fromEntity(user);
        final result = await _authDataSource.register(authModel);

        if (result) {
          return const Right(true);
        }

        return Left(LocalDatabaseFailure(message: "Failed to register user"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDatasource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }

        return const Left(ApiFailure(message: "Invalid credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? "Login failed",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDataSource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(message: "Invalid email or password"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginWithGoogle() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final token = await _authRemoteDatasource.getGoogleAccessToken();
      if (token == null || token.trim().isEmpty) {
        return const Left(ApiFailure(message: "Google authentication failed"));
      }

      return loginWithGoogleToken(token);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? "Google login failed",
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ApiFailure(message: message));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginWithGoogleToken(String token) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    if (token.trim().isEmpty) {
      return const Left(ApiFailure(message: "Google authentication failed"));
    }

    try {
      await _tokenService.saveToken(token);
      final apiUser = await _authRemoteDatasource.getCurrentUser();
      if (apiUser != null) {
        return Right(apiUser.toEntity());
      }

      await _authDataSource.logout();
      await _tokenService.removeToken();
      return const Left(ApiFailure(message: "Google authentication failed"));
    } on DioException catch (e) {
      await _authDataSource.logout();
      await _tokenService.removeToken();
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? "Google login failed",
        ),
      );
    } catch (e) {
      await _authDataSource.logout();
      await _tokenService.removeToken();
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isGoogleLoginConfigured() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final configured = await _authRemoteDatasource.isGoogleLoginConfigured();
      return Right(configured);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ?? "Unable to check Google login",
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPasswordReset(String email) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }

    try {
      final sent = await _authRemoteDatasource.requestPasswordReset(email);
      if (sent) {
        return const Right(true);
      }
      return const Left(ApiFailure(message: "Failed to send reset email"));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              "Failed to send password reset email",
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    final token = await _tokenService.getToken();
    if (token == null || token.isEmpty) {
      await _authDataSource.logout();
      await _tokenService.removeToken();
      return const Left(ApiFailure(message: "Session expired. Please login."));
    }

    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      await _authDataSource.logout();
      await _tokenService.removeToken();
      return const Left(
        ApiFailure(message: "Unable to verify session. Please login again."),
      );
    }

    try {
      final apiUser = await _authRemoteDatasource.getCurrentUser();
      if (apiUser != null) {
        return Right(apiUser.toEntity());
      }

      await _authDataSource.logout();
      await _tokenService.removeToken();
      return const Left(ApiFailure(message: "Session expired. Please login."));
    } on DioException catch (e) {
      await _authDataSource.logout();
      await _tokenService.removeToken();
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              "Unable to verify session. Please login again.",
        ),
      );
    } catch (e) {
      await _authDataSource.logout();
      await _tokenService.removeToken();
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final loggedOut = await _authDataSource.logout();
      await _tokenService.removeToken();
      if (loggedOut) {
        return const Right(true);
      }

      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile(
    String userId, {
    String? name,
    String? email,
    int? number,
    String? imagePath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: "No internet connection"));
    }
    try {
      final File? image = imagePath != null ? File(imagePath) : null;
      final updated = await _authRemoteDatasource.updateProfile(
        userId,
        image: image,
        name: name,
        email: email,
        number: number,
      );
      if (updated != null) {
        return Right(updated.toEntity());
      }
      return const Left(ApiFailure(message: "Update profile failed"));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? "Update profile failed",
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
