import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/records/data/datasources/records_datasource.dart';
import 'package:vaidya/features/records/data/datasources/remote/records_remote_datasource.dart';
import 'package:vaidya/features/records/data/models/medical_record_upsert_api_model.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final recordsRepositoryProvider = Provider<IRecordsRepository>((ref) {
  return RecordsRepository(
    recordsRemoteDataSource: ref.read(recordsRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class RecordsRepository implements IRecordsRepository {
  final IRecordsRemoteDataSource _recordsRemoteDataSource;
  final NetworkInfo _networkInfo;

  RecordsRepository({
    required IRecordsRemoteDataSource recordsRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _recordsRemoteDataSource = recordsRemoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, MedicalRecordsResultEntity>> getMedicalRecords({
    required int page,
    required int limit,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'No internet connection. Unable to load records.'),
      );
    }

    try {
      final result = await _recordsRemoteDataSource.getMedicalRecords(
        page: page,
        limit: limit,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to fetch records',
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ApiFailure(message: message));
    }
  }

  @override
  Future<Either<Failure, MedicalRecordEntity>> getMedicalRecordById(
    String id,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(
          message: 'No internet connection. Unable to load record details.',
        ),
      );
    }

    try {
      final result = await _recordsRemoteDataSource.getMedicalRecordById(id);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to fetch record',
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ApiFailure(message: message));
    }
  }

  @override
  Future<Either<Failure, MedicalRecordEntity>> createMedicalRecord(
    MedicalRecordUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'No internet connection. Unable to create record.'),
      );
    }

    try {
      final result = await _recordsRemoteDataSource.createMedicalRecord(
        MedicalRecordUpsertApiModel.fromEntity(payload),
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to create record',
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ApiFailure(message: message));
    }
  }

  @override
  Future<Either<Failure, MedicalRecordEntity>> updateMedicalRecord(
    String id,
    MedicalRecordUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'No internet connection. Unable to update record.'),
      );
    }

    try {
      final result = await _recordsRemoteDataSource.updateMedicalRecord(
        id,
        MedicalRecordUpsertApiModel.fromEntity(payload),
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to update record',
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ApiFailure(message: message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMedicalRecord(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'No internet connection. Unable to delete record.'),
      );
    }

    try {
      await _recordsRemoteDataSource.deleteMedicalRecord(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to delete record',
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ApiFailure(message: message));
    }
  }

  @override
  Future<Either<Failure, AiScanResultEntity>> scanMedicalImage(
    String imagePath,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        ApiFailure(message: 'No internet connection. Unable to scan file.'),
      );
    }

    try {
      final result = await _recordsRemoteDataSource.scanMedicalImage(imagePath);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to scan image',
        ),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      return Left(ApiFailure(message: message));
    }
  }
}

