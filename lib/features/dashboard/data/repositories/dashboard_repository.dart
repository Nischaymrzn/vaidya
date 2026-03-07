import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:vaidya/features/dashboard/data/datasources/local/dashboard_local_datasource.dart';
import 'package:vaidya/features/dashboard/data/datasources/remote/dashboard_remote_datasource.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  final remoteDatasource = ref.read(dashboardRemoteDataSourceProvider);
  final localDatasource = ref.read(dashboardLocalDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return DashboardRepository(
    dashboardRemoteDataSource: remoteDatasource,
    dashboardLocalDataSource: localDatasource,
    networkInfo: networkInfo,
  );
});

class DashboardRepository implements IDashboardRepository {
  final IDashboardRemoteDataSource _dashboardRemoteDataSource;
  final IDashboardLocalDataSource _dashboardLocalDataSource;
  final NetworkInfo _networkInfo;

  DashboardRepository({
    required IDashboardRemoteDataSource dashboardRemoteDataSource,
    required IDashboardLocalDataSource dashboardLocalDataSource,
    required NetworkInfo networkInfo,
  }) : _dashboardRemoteDataSource = dashboardRemoteDataSource,
       _dashboardLocalDataSource = dashboardLocalDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, DashboardSummaryEntity>> getDashboardSummary() async {
    if (await _networkInfo.isConnected) {
      try {
        final summaryModel = await _dashboardRemoteDataSource.getDashboardSummary();
        await _dashboardLocalDataSource.cacheDashboardSummary(summaryModel);
        return Right(summaryModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to fetch dashboard summary',
          ),
        );
      } catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');
        return Left(ApiFailure(message: message));
      }
    }

    final cached = await _dashboardLocalDataSource.getCachedDashboardSummary();
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(
      ApiFailure(message: 'No internet connection and no cached dashboard is available.'),
    );
  }

}
