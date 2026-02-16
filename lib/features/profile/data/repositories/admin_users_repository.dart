import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/profile/data/datasources/admin_users_datasource.dart';
import 'package:vaidya/features/profile/data/datasources/local/admin_users_local_datasource.dart';
import 'package:vaidya/features/profile/data/datasources/remote/admin_users_remote_datasource.dart';
import 'package:vaidya/features/profile/data/models/admin_user_api_model.dart';
import 'package:vaidya/features/profile/domain/entities/admin_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/admin_users_repository.dart';

final adminUsersRepositoryProvider = Provider<IAdminUsersRepository>((ref) {
  return AdminUsersRepository(
    remoteDataSource: ref.read(adminUsersRemoteDataSourceProvider),
    localDataSource: ref.read(adminUsersLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AdminUsersRepository implements IAdminUsersRepository {
  final IAdminUsersRemoteDataSource _remoteDataSource;
  final IAdminUsersLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const AdminUsersRepository({
    required IAdminUsersRemoteDataSource remoteDataSource,
    required IAdminUsersLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AdminUsersResultEntity>> getUsers({required int page, required int limit}) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getUsers(page: page, limit: limit);
        await _localDataSource.cacheUsers(remote.items.map((e) => e.data).toList(growable: false));
        await _localDataSource.cachePagination(remote.pagination.toJson());
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch admin users'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cachedUsers = await _localDataSource.getCachedUsers();
    final cachedPagination = await _localDataSource.getCachedPagination();
    if (cachedUsers.isNotEmpty) {
      final pagination = AdminUsersPaginationApiModel.fromJson(cachedPagination ?? <String, dynamic>{});
      return Right(
        AdminUsersResultEntity(
          users: cachedUsers.map((e) => AdminUserEntity(id: (e['_id'] ?? e['id'] ?? '').toString(), data: e)).toList(growable: false),
          pagination: pagination.toEntity(),
        ),
      );
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached admin users available.'));
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getUserById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getUserById(id);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch admin user'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cachedUsers = await _localDataSource.getCachedUsers();
    final match = cachedUsers.where((item) => (item['_id'] ?? item['id'] ?? '').toString() == id).cast<Map<String, dynamic>>().toList(growable: false);
    if (match.isNotEmpty) {
      return Right(AdminUserApiModel.fromJson(match.first).toEntity());
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached admin user found.'));
  }

  @override
  Future<Either<Failure, AdminUserEntity>> createUser(Map<String, dynamic> payload, {String? imagePath}) {
    return _runUserMutation(() => _remoteDataSource.createUser(payload, imagePath: imagePath), 'Failed to create admin user');
  }

  @override
  Future<Either<Failure, AdminUserEntity>> updateUser(String id, Map<String, dynamic> payload, {String? imagePath}) {
    return _runUserMutation(() => _remoteDataSource.updateUser(id, payload, imagePath: imagePath), 'Failed to update admin user');
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      await _remoteDataSource.deleteUser(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to delete admin user'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<Either<Failure, AdminUserEntity>> _runUserMutation(
    Future<AdminUserApiModel> Function() run,
    String fallbackMessage,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final remote = await run();
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? fallbackMessage));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
