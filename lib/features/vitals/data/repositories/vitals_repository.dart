import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/vitals/data/datasources/vitals_datasource.dart';
import 'package:vaidya/features/vitals/data/datasources/local/vitals_local_datasource.dart';
import 'package:vaidya/features/vitals/data/datasources/remote/vitals_remote_datasource.dart';
import 'package:vaidya/features/vitals/data/models/vital_api_model.dart';
import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';
import 'package:vaidya/features/vitals/domain/repositories/vitals_repository.dart';

final vitalsRepositoryProvider = Provider<IVitalsRepository>((ref) {
  return VitalsRepository(
    remoteDataSource: ref.read(vitalsRemoteDataSourceProvider),
    localDataSource: ref.read(vitalsLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class VitalsRepository implements IVitalsRepository {
  final IVitalsRemoteDataSource _remoteDataSource;
  final IVitalsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const VitalsRepository({
    required IVitalsRemoteDataSource remoteDataSource,
    required IVitalsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<VitalEntity>>> getVitals() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getVitals();
        await _localDataSource.saveVitals(remote);
        return Right(remote.map((e) => e.toEntity()).toList(growable: false));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to fetch vitals',
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }

    final cached = await _localDataSource.getVitals();
    if (cached.isNotEmpty) {
      return Right(
        cached.map((item) => item.toEntity()).toList(growable: false),
      );
    }
    return const Left(
      ApiFailure(
        message: 'No internet connection and no cached data available.',
      ),
    );
  }

  @override
  Future<Either<Failure, VitalEntity>> createVital(
    Map<String, dynamic> payload,
  ) async {
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
      final saved = await _localDataSource.upsertVital(
        VitalApiModel.fromJson(localPayload),
      );
      return Right(saved.toEntity());
    }
    try {
      final created = await _remoteDataSource.createVital(payload);
      await _localDataSource.upsertVital(created);
      return Right(created.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to create vital',
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, VitalEntity>> updateVital(
    String id,
    Map<String, dynamic> payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      final existing =
          (await _localDataSource.getVitalById(id))?.data ??
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
      final saved = await _localDataSource.upsertVital(
        VitalApiModel.fromJson(merged),
      );
      return Right(saved.toEntity());
    }
    try {
      final updated = await _remoteDataSource.updateVital(id, payload);
      await _localDataSource.upsertVital(updated);
      return Right(updated.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to update vital',
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteVital(String id) async {
    if (!await _networkInfo.isConnected) {
      final removed = await _localDataSource.removeVitalById(id);
      if (removed) {
        return const Right(true);
      }
      return const Left(
        ApiFailure(message: 'No internet connection and vital is not cached.'),
      );
    }
    try {
      await _remoteDataSource.deleteVital(id);
      await _localDataSource.removeVitalById(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to delete vital',
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, VitalsSummaryEntity>> getVitalsSummary() async {
    if (await _networkInfo.isConnected) {
      try {
        final summary = await _remoteDataSource.getVitalsSummary();
        await _localDataSource.saveVitalsSummary(summary);
        return Right(VitalsSummaryEntity(data: summary));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to fetch summary',
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }

    final cached = await _localDataSource.getVitalsSummary();
    if (cached != null) {
      return Right(VitalsSummaryEntity(data: cached));
    }

    return const Left(
      ApiFailure(
        message: 'No internet connection and no cached summary available.',
      ),
    );
  }
}
