import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/analytics/data/datasources/analytics_datasource.dart';
import 'package:vaidya/features/analytics/data/datasources/local/analytics_local_datasource.dart';
import 'package:vaidya/features/analytics/data/datasources/remote/analytics_remote_datasource.dart';
import 'package:vaidya/features/analytics/domain/entities/analytics_summary_entity.dart';
import 'package:vaidya/features/analytics/domain/repositories/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  return AnalyticsRepository(
    remoteDataSource: ref.read(analyticsRemoteDataSourceProvider),
    localDataSource: ref.read(analyticsLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AnalyticsRepository implements IAnalyticsRepository {
  final IAnalyticsRemoteDataSource _remoteDataSource;
  final IAnalyticsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const AnalyticsRepository({
    required IAnalyticsRemoteDataSource remoteDataSource,
    required IAnalyticsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AnalyticsSummaryEntity>> getSummary({
    int? months,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final summary = await _remoteDataSource.getSummary(months: months);
        await _localDataSource.saveSummary(summary);
        return Right(summary.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ??
                'Failed to fetch analytics summary',
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }

    final cached = await _localDataSource.getSummary();
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(
      ApiFailure(
        message: 'No internet connection and no cached analytics summary.',
      ),
    );
  }
}
