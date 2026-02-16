import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:vaidya/features/dashboard/data/datasources/remote/dashboard_remote_datasource.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  final remoteDatasource = ref.read(dashboardRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return DashboardRepository(
    dashboardRemoteDataSource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class DashboardRepository implements IDashboardRepository {
  final IDashboardRemoteDataSource _dashboardRemoteDataSource;
  final NetworkInfo _networkInfo;

  DashboardRepository({
    required IDashboardRemoteDataSource dashboardRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _dashboardRemoteDataSource = dashboardRemoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, DashboardSummaryEntity>> getDashboardSummary() async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(
          message: 'No internet connection. Unable to load dashboard.',
        ),
      );
    }

    try {
      final summaryModel = await _dashboardRemoteDataSource
          .getDashboardSummary();
      return Right(summaryModel.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              'Failed to fetch dashboard summary',
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ApiFailure(message: message));
    }
  }
}
