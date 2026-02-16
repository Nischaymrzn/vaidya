import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/intelligence/data/datasources/local/risk_assessments_local_datasource.dart';
import 'package:vaidya/features/intelligence/data/datasources/remote/risk_assessments_remote_datasource.dart';
import 'package:vaidya/features/intelligence/data/datasources/risk_assessments_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/risk_assessment_api_model.dart';
import 'package:vaidya/features/intelligence/domain/entities/risk_assessment_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/risk_assessments_repository.dart';

final riskAssessmentsRepositoryProvider = Provider<IRiskAssessmentsRepository>((ref) {
  return RiskAssessmentsRepository(
    remoteDataSource: ref.read(riskAssessmentsRemoteDataSourceProvider),
    localDataSource: ref.read(riskAssessmentsLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class RiskAssessmentsRepository implements IRiskAssessmentsRepository {
  final IRiskAssessmentsRemoteDataSource _remoteDataSource;
  final IRiskAssessmentsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const RiskAssessmentsRepository({
    required IRiskAssessmentsRemoteDataSource remoteDataSource,
    required IRiskAssessmentsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<RiskAssessmentEntity>>> getAssessments() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getAssessments();
        await _localDataSource.cacheAssessments(
          remote.map((e) => e.data).toList(growable: false),
        );
        return Right(remote.map((e) => e.toEntity()).toList(growable: false));
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch risk assessments'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedAssessments();
    if (cached.isNotEmpty) {
      return Right(
        cached
            .map((item) => RiskAssessmentEntity(id: (item['_id'] ?? item['id'] ?? '').toString(), data: item))
            .toList(growable: false),
      );
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached risk assessments available.'));
  }

  @override
  Future<Either<Failure, RiskAssessmentEntity>> getAssessmentById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getAssessmentById(id);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to fetch risk assessment'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedAssessments();
    final match = cached.where((item) => (item['_id'] ?? item['id'] ?? '').toString() == id).cast<Map<String, dynamic>>().toList(growable: false);
    if (match.isNotEmpty) {
      return Right(RiskAssessmentApiModel.fromJson(match.first).toEntity());
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached risk assessment found.'));
  }

  @override
  Future<Either<Failure, RiskAssessmentGenerateEntity>> generateAssessment(Map<String, dynamic> payload) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final remote = await _remoteDataSource.generateAssessment(payload);
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to generate risk assessment'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
