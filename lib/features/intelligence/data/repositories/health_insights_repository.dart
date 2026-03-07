import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/intelligence/data/datasources/health_insights_datasource.dart';
import 'package:vaidya/features/intelligence/data/datasources/local/health_insights_local_datasource.dart';
import 'package:vaidya/features/intelligence/data/datasources/remote/health_insights_remote_datasource.dart';
import 'package:vaidya/features/intelligence/domain/entities/health_insight_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/health_insights_repository.dart';

final healthInsightsRepositoryProvider = Provider<IHealthInsightsRepository>((ref) {
  return HealthInsightsRepository(
    remoteDataSource: ref.read(healthInsightsRemoteDataSourceProvider),
    localDataSource: ref.read(healthInsightsLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class HealthInsightsRepository implements IHealthInsightsRepository {
  final IHealthInsightsRemoteDataSource _remoteDataSource;
  final IHealthInsightsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const HealthInsightsRepository({
    required IHealthInsightsRemoteDataSource remoteDataSource,
    required IHealthInsightsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<HealthInsightEntity>>> getInsights({String? riskId}) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getInsights(riskId: riskId);
        await _localDataSource.cacheInsights(remote);
        return Right(remote.map((e) => e.toEntity()).toList(growable: false));
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch health insights'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedInsights();
    if (cached.isNotEmpty) {
      return Right(cached.map((item) => item.toEntity()).toList(growable: false));
    }

    return const Right(<HealthInsightEntity>[]);
  }

  @override
  Future<Either<Failure, HealthInsightEntity>> getInsightById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getInsightById(id);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch health insight'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedInsights();
    final match = cached
        .where((item) => item.id == id)
        .toList(growable: false);
    if (match.isNotEmpty) {
      return Right(match.first.toEntity());
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached health insight found.'));
  }
}
