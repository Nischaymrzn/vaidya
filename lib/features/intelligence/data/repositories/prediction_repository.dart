import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/intelligence/data/datasources/local/prediction_local_datasource.dart';
import 'package:vaidya/features/intelligence/data/datasources/prediction_datasource.dart';
import 'package:vaidya/features/intelligence/data/datasources/remote/prediction_remote_datasource.dart';
import 'package:vaidya/features/intelligence/data/models/prediction_api_model.dart';
import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/prediction_repository.dart';

final predictionRepositoryProvider = Provider<IPredictionRepository>((ref) {
  return PredictionRepository(
    remoteDataSource: ref.read(predictionRemoteDataSourceProvider),
    localDataSource: ref.read(predictionLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class PredictionRepository implements IPredictionRepository {
  final IPredictionRemoteDataSource _remoteDataSource;
  final IPredictionLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const PredictionRepository({
    required IPredictionRemoteDataSource remoteDataSource,
    required IPredictionLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, PredictionEntity>> predictSymptom(
    List<String> symptoms,
  ) {
    return _runPrediction(
      saveKey: 'symptom',
      runRemote: () => _remoteDataSource.predictSymptom(symptoms),
      offlineMessage:
          'No internet connection and no cached symptom prediction available.',
    );
  }

  @override
  Future<Either<Failure, PredictionEntity>> predictHeartDisease(
    Map<String, dynamic> payload,
  ) {
    return _runPrediction(
      saveKey: 'heart_disease',
      runRemote: () => _remoteDataSource.predictHeartDisease(payload),
      offlineMessage:
          'No internet connection and no cached heart disease prediction available.',
    );
  }

  @override
  Future<Either<Failure, PredictionEntity>> predictDiabetes(
    Map<String, dynamic> payload,
  ) {
    return _runPrediction(
      saveKey: 'diabetes',
      runRemote: () => _remoteDataSource.predictDiabetes(payload),
      offlineMessage:
          'No internet connection and no cached diabetes prediction available.',
    );
  }

  @override
  Future<Either<Failure, PredictionEntity>> predictBrainTumor(
    String imagePath,
  ) {
    return _runPrediction(
      saveKey: 'brain_tumor',
      runRemote: () => _remoteDataSource.predictBrainTumor(imagePath),
      offlineMessage:
          'No internet connection and no cached brain tumor prediction available.',
    );
  }

  @override
  Future<Either<Failure, PredictionEntity>> predictTuberculosis(
    String imagePath,
  ) {
    return _runPrediction(
      saveKey: 'tuberculosis',
      runRemote: () => _remoteDataSource.predictTuberculosis(imagePath),
      offlineMessage:
          'No internet connection and no cached tuberculosis prediction available.',
    );
  }

  Future<Either<Failure, PredictionEntity>> _runPrediction({
    required String saveKey,
    required Future<PredictionApiModel> Function() runRemote,
    required String offlineMessage,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await runRemote();
        await _localDataSource.saveResult(saveKey, remote);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Prediction failed',
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }

    final cached = await _localDataSource.getResult(saveKey);
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return Left(ApiFailure(message: offlineMessage));
  }
}
