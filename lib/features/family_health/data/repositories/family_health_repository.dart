import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/family_health/data/datasources/family_health_datasource.dart';
import 'package:vaidya/features/family_health/data/datasources/local/family_health_local_datasource.dart';
import 'package:vaidya/features/family_health/data/datasources/remote/family_health_remote_datasource.dart';
import 'package:vaidya/features/family_health/data/models/family_group_api_model.dart';
import 'package:vaidya/features/family_health/domain/entities/family_group_entity.dart';
import 'package:vaidya/features/family_health/domain/repositories/family_health_repository.dart';

final familyHealthRepositoryProvider = Provider<IFamilyHealthRepository>((ref) {
  return FamilyHealthRepository(
    remoteDataSource: ref.read(familyHealthRemoteDataSourceProvider),
    localDataSource: ref.read(familyHealthLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class FamilyHealthRepository implements IFamilyHealthRepository {
  final IFamilyHealthRemoteDataSource _remoteDataSource;
  final IFamilyHealthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const FamilyHealthRepository({
    required IFamilyHealthRemoteDataSource remoteDataSource,
    required IFamilyHealthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, FamilyGroupEntity>> getMyGroup() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getMyGroup();
        await _localDataSource.cacheGroup(remote.data);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch family group'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedGroup();
    if (cached != null) {
      return Right(FamilyGroupApiModel.fromJson(cached).toEntity());
    }
    return const Left(ApiFailure(message: 'No internet connection and no cached family group available.'));
  }

  @override
  Future<Either<Failure, FamilyGroupSummaryEntity>> getMyGroupSummary() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getMyGroupSummary();
        await _localDataSource.cacheSummary(remote.data);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch family summary'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedSummary();
    if (cached != null) {
      return Right(FamilyGroupSummaryApiModel.fromJson(cached).toEntity());
    }
    return const Left(ApiFailure(message: 'No internet connection and no cached family summary available.'));
  }

  @override
  Future<Either<Failure, FamilyGroupEntity>> createGroup(Map<String, dynamic> payload) {
    return _performGroupMutation(() => _remoteDataSource.createGroup(payload), 'Failed to create family group');
  }

  @override
  Future<Either<Failure, FamilyInviteEntity>> createInvite(String groupId, Map<String, dynamic> payload) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final result = await _remoteDataSource.createInvite(groupId, payload);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to create invite link'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, FamilyGroupEntity>> addMember(String groupId, Map<String, dynamic> payload) {
    return _performGroupMutation(() => _remoteDataSource.addMember(groupId, payload), 'Failed to add family member');
  }

  @override
  Future<Either<Failure, FamilyGroupEntity>> updateMemberRelation(
    String groupId,
    String memberId,
    Map<String, dynamic> payload,
  ) {
    return _performGroupMutation(
      () => _remoteDataSource.updateMemberRelation(groupId, memberId, payload),
      'Failed to update family member relation',
    );
  }

  @override
  Future<Either<Failure, FamilyGroupEntity>> joinWithInvite(String token, Map<String, dynamic> payload) {
    return _performGroupMutation(() => _remoteDataSource.joinWithInvite(token, payload), 'Failed to join family group');
  }

  Future<Either<Failure, FamilyGroupEntity>> _performGroupMutation(
    Future<FamilyGroupApiModel> Function() run,
    String fallbackMessage,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final result = await run();
      await _localDataSource.cacheGroup(result.data);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? fallbackMessage));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
