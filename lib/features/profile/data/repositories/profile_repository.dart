import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:vaidya/features/profile/data/datasources/profile_datasource.dart';
import 'package:vaidya/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:vaidya/features/profile/data/models/profile_user_api_model.dart';
import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
    localDataSource: ref.read(profileLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class ProfileRepository implements IProfileRepository {
  final IProfileRemoteDataSource _remoteDataSource;
  final IProfileLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const ProfileRepository({
    required IProfileRemoteDataSource remoteDataSource,
    required IProfileLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, ProfileUserEntity>> getUserById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getUserById(id);
        await _localDataSource.cacheUser(remote.data);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch profile'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedUser();
    if (cached != null) {
      return Right(ProfileUserApiModel.fromJson(cached).toEntity());
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached profile available.'));
  }

  @override
  Future<Either<Failure, ProfileUserEntity>> updateUser(
    String id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final remote = await _remoteDataSource.updateUser(id, payload, imagePath: imagePath);
      await _localDataSource.cacheUser(remote.data);
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to update profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
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
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to delete profile'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
