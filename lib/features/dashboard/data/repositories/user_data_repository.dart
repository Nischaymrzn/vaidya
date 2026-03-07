import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/dashboard/data/datasources/local/user_data_local_datasource.dart';
import 'package:vaidya/features/dashboard/data/datasources/remote/user_data_remote_datasource.dart';
import 'package:vaidya/features/dashboard/data/datasources/user_data_datasource.dart';
import 'package:vaidya/features/dashboard/domain/entities/user_data_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/user_data_repository.dart';

final userDataRepositoryProvider = Provider<IUserDataRepository>((ref) {
  return UserDataRepository(
    remoteDataSource: ref.read(userDataRemoteDataSourceProvider),
    localDataSource: ref.read(userDataLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class UserDataRepository implements IUserDataRepository {
  final IUserDataRemoteDataSource _remoteDataSource;
  final IUserDataLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const UserDataRepository({
    required IUserDataRemoteDataSource remoteDataSource,
    required IUserDataLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UserDataEntity>> getUserData() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getUserData();
        await _localDataSource.cacheUserData(remote);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to fetch user data',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedUserData();
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached user data available.'));
  }

  @override
  Future<Either<Failure, UserDataEntity>> updateUserData(Map<String, dynamic> payload) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final remote = await _remoteDataSource.updateUserData(payload);
      await _localDataSource.cacheUserData(remote);
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to update user data',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
