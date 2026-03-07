import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/symptoms/data/datasources/symptoms_datasource.dart';
import 'package:vaidya/features/symptoms/data/datasources/local/symptoms_local_datasource.dart';
import 'package:vaidya/features/symptoms/data/datasources/remote/symptoms_remote_datasource.dart';
import 'package:vaidya/features/symptoms/data/models/symptom_api_model.dart';
import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:vaidya/features/symptoms/domain/repositories/symptoms_repository.dart';

final symptomsRepositoryProvider = Provider<ISymptomsRepository>((ref) {
  return SymptomsRepository(
    remoteDataSource: ref.read(symptomsRemoteDataSourceProvider),
    localDataSource: ref.read(symptomsLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class SymptomsRepository implements ISymptomsRepository {
  final ISymptomsRemoteDataSource _remoteDataSource;
  final ISymptomsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const SymptomsRepository({
    required ISymptomsRemoteDataSource remoteDataSource,
    required ISymptomsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<SymptomEntity>>> getSymptoms() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getSymptoms();
        await _localDataSource.cacheSymptoms(remote);
        return Right(remote.map((e) => e.toEntity()).toList(growable: false));
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch symptoms'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedSymptoms();
    if (cached.isNotEmpty) {
      return Right(cached.map((item) => item.toEntity()).toList(growable: false));
    }
    return const Left(ApiFailure(message: 'No internet connection and no cached data available.'));
  }

  @override
  Future<Either<Failure, SymptomEntity>> createSymptom(Map<String, dynamic> payload) async {
    if (!await _networkInfo.isConnected) {
      final now = DateTime.now().toUtc().toIso8601String();
      final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
      final localPayload = <String, dynamic>{
        ...payload,
        '_id': localId,
        'id': localId,
        'createdAt': now,
        'updatedAt': now,
      };
      final saved = await _localDataSource.upsertSymptom(
        SymptomApiModel.fromJson(localPayload),
      );
      return Right(saved.toEntity());
    }
    try {
      final created = await _remoteDataSource.createSymptom(payload);
      await _localDataSource.upsertSymptom(created);
      return Right(created.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to create symptom'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, SymptomEntity>> updateSymptom(String id, Map<String, dynamic> payload) async {
    if (!await _networkInfo.isConnected) {
      final existing =
          (await _localDataSource.getCachedSymptomById(id))?.data ??
          <String, dynamic>{};
      final now = DateTime.now().toUtc().toIso8601String();
      final merged = <String, dynamic>{
        ...existing,
        ...payload,
        '_id': id,
        'id': id,
        'updatedAt': now,
        'createdAt': existing['createdAt'] ?? now,
      };
      final saved = await _localDataSource.upsertSymptom(
        SymptomApiModel.fromJson(merged),
      );
      return Right(saved.toEntity());
    }
    try {
      final updated = await _remoteDataSource.updateSymptom(id, payload);
      await _localDataSource.upsertSymptom(updated);
      return Right(updated.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to update symptom'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSymptom(String id) async {
    if (!await _networkInfo.isConnected) {
      final removed = await _localDataSource.removeSymptomById(id);
      if (removed) {
        return const Right(true);
      }
      return const Left(ApiFailure(message: 'No internet connection and symptom is not cached.'));
    }
    try {
      await _remoteDataSource.deleteSymptom(id);
      await _localDataSource.removeSymptomById(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to delete symptom'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, SymptomsSummaryEntity>> getSymptomsSummary() async {
    if (await _networkInfo.isConnected) {
      try {
        final summary = await _remoteDataSource.getSymptomsSummary();
        await _localDataSource.cacheSymptomsSummary(summary);
        return Right(SymptomsSummaryEntity(data: summary));
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch summary'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedSymptomsSummary();
    if (cached != null) {
      return Right(SymptomsSummaryEntity(data: cached));
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached summary available.'));
  }
}
