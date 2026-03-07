import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/intelligence/data/datasources/intelligence_datasource.dart';
import 'package:vaidya/features/intelligence/data/datasources/local/intelligence_local_datasource.dart';
import 'package:vaidya/features/intelligence/data/datasources/remote/intelligence_remote_datasource.dart';
import 'package:vaidya/features/intelligence/domain/entities/intelligence_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/intelligence_repository.dart';

final intelligenceRepositoryProvider = Provider<IIntelligenceRepository>((ref) {
  return IntelligenceRepository(
    remoteDataSource: ref.read(intelligenceRemoteDataSourceProvider),
    localDataSource: ref.read(intelligenceLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class IntelligenceRepository implements IIntelligenceRepository {
  final IIntelligenceRemoteDataSource _remoteDataSource;
  final IIntelligenceLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const IntelligenceRepository({
    required IIntelligenceRemoteDataSource remoteDataSource,
    required IIntelligenceLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<AiInsightEntity>>> generateInsights({
    required String input,
    required int maxItems,
    required bool force,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.generateInsights(
          input: input,
          maxItems: maxItems,
          force: force,
        );
        await _localDataSource.cacheInsights(remote);
        return Right(remote.map((e) => e.toEntity()).toList(growable: false));
      } on DioException catch (e) {
        return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to generate AI insights'));
      } catch (e) {
        return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
      }
    }

    final cached = await _localDataSource.getCachedInsights();
    if (cached.isNotEmpty) {
      return Right(cached.map((e) => e.toEntity()).toList(growable: false));
    }

    return const Left(ApiFailure(message: 'No internet connection and no cached AI insights available.'));
  }

  @override
  Future<Either<Failure, AiChatReplyEntity>> chat({
    required List<Map<String, String>> messages,
    String? doctor,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final remote = await _remoteDataSource.chat(messages: messages, doctor: doctor);
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(statusCode: e.response?.statusCode, message: e.response?.data['message'] ?? 'Failed to get AI reply'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
