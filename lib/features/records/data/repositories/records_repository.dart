import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/records/data/datasources/records_datasource.dart';
import 'package:vaidya/features/records/data/datasources/local/records_local_datasource.dart';
import 'package:vaidya/features/records/data/datasources/remote/records_remote_datasource.dart';
import 'package:vaidya/features/records/data/models/medical_record_api_model.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/data/models/record_support_api_model.dart';
import 'package:vaidya/features/records/domain/entities/record_support_entity.dart';
import 'package:vaidya/features/records/domain/repositories/records_repository.dart';

final recordsRepositoryProvider = Provider<IRecordsRepository>((ref) {
  return RecordsRepository(
    recordsRemoteDataSource: ref.read(recordsRemoteDataSourceProvider),
    recordsLocalDataSource: ref.read(recordsLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class RecordsRepository implements IRecordsRepository {
  static const String _opActionCreate = 'create';
  static const String _opActionUpdate = 'update';
  static const String _opActionDelete = 'delete';

  final IRecordsRemoteDataSource _recordsRemoteDataSource;
  final IRecordsLocalDataSource _recordsLocalDataSource;
  final NetworkInfo _networkInfo;
  final UserSessionService _userSessionService;

  RecordsRepository({
    required IRecordsRemoteDataSource recordsRemoteDataSource,
    required IRecordsLocalDataSource recordsLocalDataSource,
    required NetworkInfo networkInfo,
    required UserSessionService userSessionService,
  }) : _recordsRemoteDataSource = recordsRemoteDataSource,
       _recordsLocalDataSource = recordsLocalDataSource,
       _networkInfo = networkInfo,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, MedicalRecordsResultEntity>> getMedicalRecords({
    required int page,
    required int limit,
    String? userId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        await _syncPendingMedicalRecordOperations();
        final result = await _recordsRemoteDataSource.getMedicalRecords(
          page: page,
          limit: limit,
          userId: userId,
        );
        await _recordsLocalDataSource.saveMedicalRecords(result);
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(_dioFailure(e, 'Failed to fetch records'));
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    final cached = await _recordsLocalDataSource.getMedicalRecords();
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(
      ApiFailure(message: 'No internet connection. Unable to load records.'),
    );
  }

  @override
  Future<Either<Failure, MedicalRecordEntity>> getMedicalRecordById(
    String id,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _recordsRemoteDataSource.getMedicalRecordById(id);
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(_dioFailure(e, 'Failed to fetch record'));
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    final cached = await _recordsLocalDataSource.getMedicalRecordById(id);
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(
      ApiFailure(message: 'No internet connection and record is not cached.'),
    );
  }

  @override
  Future<Either<Failure, MedicalRecordEntity>> createMedicalRecord(
    MedicalRecordUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      try {
        final now = DateTime.now().toUtc().toIso8601String();
        final localRecord = _buildOfflineMedicalRecord(
          payload: payload,
          createdAt: now,
          updatedAt: now,
        );
        final saved = await _recordsLocalDataSource.upsertMedicalRecord(
          localRecord,
        );
        await _recordsLocalDataSource
            .enqueuePendingMedicalRecordOperation(<String, dynamic>{
              'opId': _newLocalId(),
              'action': _opActionCreate,
              'recordId': saved.id,
              'payload': _serializeMedicalRecordPayload(payload),
              'createdAt': now,
            });
        return Right(saved.toEntity());
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    try {
      final result = await _recordsRemoteDataSource.createMedicalRecord(
        payload,
      );
      await _recordsLocalDataSource.upsertMedicalRecord(result);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to create record'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, MedicalRecordEntity>> updateMedicalRecord(
    String id,
    MedicalRecordUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      try {
        final existing = await _recordsLocalDataSource.getMedicalRecordById(id);
        final now = DateTime.now().toUtc().toIso8601String();
        final merged = _buildOfflineMedicalRecord(
          id: id,
          payload: payload,
          existing: existing,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        );
        final saved = await _recordsLocalDataSource.upsertMedicalRecord(merged);
        await _recordsLocalDataSource
            .enqueuePendingMedicalRecordOperation(<String, dynamic>{
              'opId': _newLocalId(),
              'action': _opActionUpdate,
              'recordId': id,
              'payload': _serializeMedicalRecordPayload(payload),
              'createdAt': now,
            });
        return Right(saved.toEntity());
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    try {
      final result = await _recordsRemoteDataSource.updateMedicalRecord(
        id,
        payload,
      );
      await _recordsLocalDataSource.upsertMedicalRecord(result);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to update record'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMedicalRecord(String id) async {
    if (!await _networkInfo.isConnected) {
      final removed = await _recordsLocalDataSource.removeMedicalRecordById(id);
      if (removed) {
        await _recordsLocalDataSource
            .enqueuePendingMedicalRecordOperation(<String, dynamic>{
              'opId': _newLocalId(),
              'action': _opActionDelete,
              'recordId': id,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            });
        return const Right(true);
      }
      return const Left(
        ApiFailure(message: 'No internet connection and record is not cached.'),
      );
    }

    try {
      await _recordsRemoteDataSource.deleteMedicalRecord(id);
      await _recordsLocalDataSource.removeMedicalRecordById(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to delete record'));
    } catch (e) {
      return Left(_exceptionFailure(e));
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
      return Left(_dioFailure(e, 'Failed to scan image'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MedicationEntity>>> getMedications({
    String? userId,
  }) async {
    return _readThroughCacheList<MedicationApiModel, MedicationEntity>(
      isConnected: await _networkInfo.isConnected,
      remoteLoader: () =>
          _recordsRemoteDataSource.getMedications(userId: userId),
      saveWriter: _recordsLocalDataSource.saveMedications,
      saveReader: _recordsLocalDataSource.getMedications,
      mapper: (item) => item.toEntity(),
      errorMessage: 'Failed to fetch medications',
      offlineMessage:
          'No internet connection and no cached medications available.',
    );
  }

  @override
  Future<Either<Failure, MedicationEntity>> getMedicationById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _recordsRemoteDataSource.getMedicationById(id);
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(_dioFailure(e, 'Failed to fetch medication'));
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    final cached = await _recordsLocalDataSource.getMedicationById(id);
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(
      ApiFailure(
        message: 'No internet connection and medication is not cached.',
      ),
    );
  }

  @override
  Future<Either<Failure, MedicationEntity>> createMedication(
    MedicationUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      try {
        final local = _buildOfflineMedication(payload: payload);
        final saved = await _recordsLocalDataSource.upsertMedication(local);
        return Right(saved.toEntity());
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    try {
      final result = await _recordsRemoteDataSource.createMedication(
        _medicationUpsertPayload(payload),
      );
      await _recordsLocalDataSource.upsertMedication(result);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to create medication'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, MedicationEntity>> updateMedication(
    String id,
    MedicationUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      try {
        final existing = await _recordsLocalDataSource.getMedicationById(id);
        final local = _buildOfflineMedication(
          id: id,
          payload: payload,
          existing: existing,
        );
        final saved = await _recordsLocalDataSource.upsertMedication(local);
        return Right(saved.toEntity());
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    try {
      final result = await _recordsRemoteDataSource.updateMedication(
        id,
        _medicationUpsertPayload(payload),
      );
      await _recordsLocalDataSource.upsertMedication(result);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to update medication'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMedication(String id) async {
    if (!await _networkInfo.isConnected) {
      final removed = await _recordsLocalDataSource.removeMedicationById(id);
      if (removed) {
        return const Right(true);
      }
      return const Left(
        ApiFailure(
          message: 'No internet connection and medication is not cached.',
        ),
      );
    }

    try {
      await _recordsRemoteDataSource.deleteMedication(id);
      await _recordsLocalDataSource.removeMedicationById(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to delete medication'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<AllergyEntity>>> getAllergies({
    String? userId,
  }) async {
    return _readThroughCacheList<AllergyApiModel, AllergyEntity>(
      isConnected: await _networkInfo.isConnected,
      remoteLoader: () => _recordsRemoteDataSource.getAllergies(userId: userId),
      saveWriter: _recordsLocalDataSource.saveAllergies,
      saveReader: _recordsLocalDataSource.getAllergies,
      mapper: (item) => item.toEntity(),
      errorMessage: 'Failed to fetch allergies',
      offlineMessage:
          'No internet connection and no cached allergies available.',
    );
  }

  @override
  Future<Either<Failure, AllergyEntity>> getAllergyById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _recordsRemoteDataSource.getAllergyById(id);
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(_dioFailure(e, 'Failed to fetch allergy'));
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    final cached = await _recordsLocalDataSource.getAllergyById(id);
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(
      ApiFailure(message: 'No internet connection and allergy is not cached.'),
    );
  }

  @override
  Future<Either<Failure, AllergyEntity>> createAllergy(
    AllergyUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      try {
        final local = _buildOfflineAllergy(payload: payload);
        final saved = await _recordsLocalDataSource.upsertAllergy(local);
        return Right(saved.toEntity());
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    try {
      final result = await _recordsRemoteDataSource.createAllergy(
        _allergyUpsertPayload(payload),
      );
      await _recordsLocalDataSource.upsertAllergy(result);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to create allergy'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, AllergyEntity>> updateAllergy(
    String id,
    AllergyUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      try {
        final existing = await _recordsLocalDataSource.getAllergyById(id);
        final local = _buildOfflineAllergy(
          id: id,
          payload: payload,
          existing: existing,
        );
        final saved = await _recordsLocalDataSource.upsertAllergy(local);
        return Right(saved.toEntity());
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    try {
      final result = await _recordsRemoteDataSource.updateAllergy(
        id,
        _allergyUpsertPayload(payload),
      );
      await _recordsLocalDataSource.upsertAllergy(result);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to update allergy'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllergy(String id) async {
    if (!await _networkInfo.isConnected) {
      final removed = await _recordsLocalDataSource.removeAllergyById(id);
      if (removed) {
        return const Right(true);
      }
      return const Left(
        ApiFailure(
          message: 'No internet connection and allergy is not cached.',
        ),
      );
    }

    try {
      await _recordsRemoteDataSource.deleteAllergy(id);
      await _recordsLocalDataSource.removeAllergyById(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to delete allergy'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ImmunizationEntity>>> getImmunizations({
    String? userId,
  }) async {
    return _readThroughCacheList<ImmunizationApiModel, ImmunizationEntity>(
      isConnected: await _networkInfo.isConnected,
      remoteLoader: () =>
          _recordsRemoteDataSource.getImmunizations(userId: userId),
      saveWriter: _recordsLocalDataSource.saveImmunizations,
      saveReader: _recordsLocalDataSource.getImmunizations,
      mapper: (item) => item.toEntity(),
      errorMessage: 'Failed to fetch immunizations',
      offlineMessage:
          'No internet connection and no cached immunizations available.',
    );
  }

  @override
  Future<Either<Failure, ImmunizationEntity>> getImmunizationById(
    String id,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _recordsRemoteDataSource.getImmunizationById(id);
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(_dioFailure(e, 'Failed to fetch immunization'));
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    final cached = await _recordsLocalDataSource.getImmunizationById(id);
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(
      ApiFailure(
        message: 'No internet connection and immunization is not cached.',
      ),
    );
  }

  @override
  Future<Either<Failure, ImmunizationEntity>> createImmunization(
    ImmunizationUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      try {
        final local = _buildOfflineImmunization(payload: payload);
        final saved = await _recordsLocalDataSource.upsertImmunization(local);
        return Right(saved.toEntity());
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    try {
      final result = await _recordsRemoteDataSource.createImmunization(
        _immunizationUpsertPayload(payload),
      );
      await _recordsLocalDataSource.upsertImmunization(result);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to create immunization'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, ImmunizationEntity>> updateImmunization(
    String id,
    ImmunizationUpsertEntity payload,
  ) async {
    if (!await _networkInfo.isConnected) {
      try {
        final existing = await _recordsLocalDataSource.getImmunizationById(id);
        final local = _buildOfflineImmunization(
          id: id,
          payload: payload,
          existing: existing,
        );
        final saved = await _recordsLocalDataSource.upsertImmunization(local);
        return Right(saved.toEntity());
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    try {
      final result = await _recordsRemoteDataSource.updateImmunization(
        id,
        _immunizationUpsertPayload(payload),
      );
      await _recordsLocalDataSource.upsertImmunization(result);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to update immunization'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteImmunization(String id) async {
    if (!await _networkInfo.isConnected) {
      final removed = await _recordsLocalDataSource.removeImmunizationById(id);
      if (removed) {
        return const Right(true);
      }
      return const Left(
        ApiFailure(
          message: 'No internet connection and immunization is not cached.',
        ),
      );
    }

    try {
      await _recordsRemoteDataSource.deleteImmunization(id);
      await _recordsLocalDataSource.removeImmunizationById(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(_dioFailure(e, 'Failed to delete immunization'));
    } catch (e) {
      return Left(_exceptionFailure(e));
    }
  }

  Future<void> _syncPendingMedicalRecordOperations() async {
    final pending = await _recordsLocalDataSource
        .getPendingMedicalRecordOperations();
    if (pending.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    final localToRemoteId = <String, String>{};

    for (final operation in pending) {
      final action = operation['action']?.toString() ?? '';
      final originalRecordId = operation['recordId']?.toString() ?? '';
      final resolvedRecordId =
          localToRemoteId[originalRecordId] ?? originalRecordId;

      try {
        if (action == _opActionCreate) {
          final payloadJson = operation['payload'];
          if (payloadJson is! Map<String, dynamic>) {
            continue;
          }

          final payload = _deserializeMedicalRecordPayload(payloadJson);
          final created = await _recordsRemoteDataSource.createMedicalRecord(
            payload,
          );

          await _recordsLocalDataSource.upsertMedicalRecord(created);
          if (originalRecordId.isNotEmpty && originalRecordId != created.id) {
            await _recordsLocalDataSource.removeMedicalRecordById(
              originalRecordId,
            );
            localToRemoteId[originalRecordId] = created.id;
          }
          continue;
        }

        if (action == _opActionUpdate) {
          final payloadJson = operation['payload'];
          if (payloadJson is! Map<String, dynamic>) {
            continue;
          }

          if (resolvedRecordId.trim().isEmpty ||
              resolvedRecordId.startsWith('local_')) {
            remaining.add(operation);
            continue;
          }

          final payload = _deserializeMedicalRecordPayload(payloadJson);
          final updated = await _recordsRemoteDataSource.updateMedicalRecord(
            resolvedRecordId,
            payload,
          );
          await _recordsLocalDataSource.upsertMedicalRecord(updated);
          continue;
        }

        if (action == _opActionDelete) {
          if (resolvedRecordId.trim().isEmpty) {
            continue;
          }

          if (resolvedRecordId.startsWith('local_')) {
            await _recordsLocalDataSource.removeMedicalRecordById(
              resolvedRecordId,
            );
            continue;
          }

          await _recordsRemoteDataSource.deleteMedicalRecord(resolvedRecordId);
          await _recordsLocalDataSource.removeMedicalRecordById(
            resolvedRecordId,
          );
          continue;
        }
      } catch (_) {
        remaining.add(operation);
      }
    }

    if (remaining.isEmpty) {
      await _recordsLocalDataSource.clearPendingMedicalRecordOperations();
      return;
    }

    await _recordsLocalDataSource.savePendingMedicalRecordOperations(remaining);
  }

  Map<String, dynamic> _serializeMedicalRecordPayload(
    MedicalRecordUpsertEntity payload,
  ) {
    return <String, dynamic>{
      'title': payload.title,
      'recordType': payload.recordType,
      'category': payload.category,
      'provider': payload.provider,
      'recordDate': payload.recordDate,
      'visitType': payload.visitType,
      'diagnosis': payload.diagnosis,
      'content': payload.content,
      'notes': payload.notes,
      'status': payload.status,
      'aiScanned': payload.aiScanned,
      'structuredData': payload.structuredData,
      'attachmentPaths': payload.attachmentPaths,
    };
  }

  MedicalRecordUpsertEntity _deserializeMedicalRecordPayload(
    Map<String, dynamic> json,
  ) {
    final pathsRaw = json['attachmentPaths'];
    final paths = pathsRaw is List
        ? pathsRaw
              .map((item) => item.toString())
              .where((item) => item.trim().isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    final structuredRaw = json['structuredData'];
    final structured = structuredRaw is Map
        ? structuredRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;

    return MedicalRecordUpsertEntity(
      title: (json['title'] ?? '').toString(),
      recordType: json['recordType']?.toString(),
      category: json['category']?.toString(),
      provider: json['provider']?.toString(),
      recordDate: json['recordDate']?.toString(),
      visitType: json['visitType']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      content: json['content']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString(),
      aiScanned: json['aiScanned'] is bool ? json['aiScanned'] as bool : null,
      structuredData: structured,
      attachmentPaths: paths,
    );
  }

  Future<Either<Failure, List<TOut>>> _readThroughCacheList<TIn, TOut>({
    required bool isConnected,
    required Future<List<TIn>> Function() remoteLoader,
    required Future<void> Function(List<TIn> items) saveWriter,
    required Future<List<TIn>> Function() saveReader,
    required TOut Function(TIn item) mapper,
    required String errorMessage,
    required String offlineMessage,
  }) async {
    if (isConnected) {
      try {
        final remote = await remoteLoader();
        await saveWriter(remote);
        return Right(remote.map(mapper).toList(growable: false));
      } on DioException catch (e) {
        return Left(_dioFailure(e, errorMessage));
      } catch (e) {
        return Left(_exceptionFailure(e));
      }
    }

    final cached = await saveReader();
    if (cached.isNotEmpty) {
      return Right(cached.map(mapper).toList(growable: false));
    }

    return Left(ApiFailure(message: offlineMessage));
  }

  MedicalRecordApiModel _buildOfflineMedicalRecord({
    String? id,
    required MedicalRecordUpsertEntity payload,
    MedicalRecordApiModel? existing,
    required String createdAt,
    required String updatedAt,
  }) {
    final recordId = id ?? existing?.id ?? _newLocalId();
    final userId =
        _userSessionService.getCurrentUserId()?.trim().isNotEmpty == true
        ? _userSessionService.getCurrentUserId()!.trim()
        : (existing?.userId.isNotEmpty == true
              ? existing!.userId
              : 'local-user');

    final attachments = payload.attachmentPaths.isNotEmpty
        ? payload.attachmentPaths
              .map(
                (path) => <String, dynamic>{
                  'url': path,
                  'name': path.split(RegExp(r'[/\\]')).last,
                  'type': '',
                  'size': 0,
                },
              )
              .toList(growable: false)
        : existing?.attachments
                  .map(
                    (item) => <String, dynamic>{
                      'url': item.url,
                      'publicId': item.publicId,
                      'type': item.type,
                      'name': item.name,
                      'size': item.size,
                    },
                  )
                  .toList(growable: false) ??
              const <Map<String, dynamic>>[];

    return MedicalRecordApiModel.fromJson(<String, dynamic>{
      '_id': recordId,
      'userId': userId,
      'title': payload.title.trim(),
      'recordType': payload.recordType ?? existing?.recordType,
      'category': payload.category ?? existing?.category,
      'provider': payload.provider ?? existing?.provider,
      'recordDate': payload.recordDate ?? existing?.recordDate,
      'visitType': payload.visitType ?? existing?.visitType,
      'diagnosis': payload.diagnosis ?? existing?.diagnosis,
      'diagnosisStatus': existing?.diagnosisStatus,
      'content': payload.content ?? existing?.content,
      'notes': payload.notes ?? existing?.notes,
      'status': payload.status ?? existing?.status ?? 'offline',
      'aiScanned': payload.aiScanned ?? existing?.aiScanned ?? false,
      'structuredData': payload.structuredData ?? existing?.structuredData,
      'attachments': attachments,
      'createdAt': existing?.createdAt ?? createdAt,
      'updatedAt': updatedAt,
    });
  }

  Map<String, dynamic> _medicationUpsertPayload(
    MedicationUpsertEntity payload,
  ) {
    final map = <String, dynamic>{'medicineName': payload.medicineName.trim()};

    void putString(String key, String? value) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        map[key] = normalized;
      }
    }

    putString('recordId', payload.recordId);
    putString('dosage', payload.dosage);
    putString('frequency', payload.frequency);
    if (payload.durationDays != null) {
      map['durationDays'] = payload.durationDays;
    }
    putString('startDate', payload.startDate);
    putString('endDate', payload.endDate);
    putString('purpose', payload.purpose);
    putString('diagnosis', payload.diagnosis);
    putString('disease', payload.disease);
    putString('notes', payload.notes);

    return map;
  }

  Map<String, dynamic> _allergyUpsertPayload(AllergyUpsertEntity payload) {
    final map = <String, dynamic>{'allergen': payload.allergen.trim()};

    void putString(String key, String? value) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        map[key] = normalized;
      }
    }

    putString('recordId', payload.recordId);
    putString('type', payload.type);
    putString('reaction', payload.reaction);
    putString('severity', payload.severity);
    putString('status', payload.status);
    putString('onsetDate', payload.onsetDate);
    putString('recordedAt', payload.recordedAt);
    putString('notes', payload.notes);
    return map;
  }

  Map<String, dynamic> _immunizationUpsertPayload(
    ImmunizationUpsertEntity payload,
  ) {
    final map = <String, dynamic>{'vaccineName': payload.vaccineName.trim()};

    void putString(String key, String? value) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        map[key] = normalized;
      }
    }

    putString('recordId', payload.recordId);
    putString('date', payload.date);
    if (payload.doseNumber != null) {
      map['doseNumber'] = payload.doseNumber;
    }
    putString('series', payload.series);
    putString('manufacturer', payload.manufacturer);
    putString('lotNumber', payload.lotNumber);
    putString('site', payload.site);
    putString('route', payload.route);
    putString('provider', payload.provider);
    putString('nextDue', payload.nextDue);
    putString('notes', payload.notes);
    return map;
  }

  MedicationApiModel _buildOfflineMedication({
    String? id,
    required MedicationUpsertEntity payload,
    MedicationApiModel? existing,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final medicationId = id ?? existing?.id ?? _newLocalId();
    final userId =
        _userSessionService.getCurrentUserId()?.trim().isNotEmpty == true
        ? _userSessionService.getCurrentUserId()!.trim()
        : (existing?.userId.isNotEmpty == true
              ? existing!.userId
              : 'local-user');

    final base = existing?.toJson() ?? <String, dynamic>{};
    base.addAll(_medicationUpsertPayload(payload));
    base['_id'] = medicationId;
    base['userId'] = userId;
    base['createdAt'] = existing?.createdAt ?? now;
    base['updatedAt'] = now;
    return MedicationApiModel.fromJson(base);
  }

  AllergyApiModel _buildOfflineAllergy({
    String? id,
    required AllergyUpsertEntity payload,
    AllergyApiModel? existing,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final allergyId = id ?? existing?.id ?? _newLocalId();
    final userId =
        _userSessionService.getCurrentUserId()?.trim().isNotEmpty == true
        ? _userSessionService.getCurrentUserId()!.trim()
        : (existing?.userId.isNotEmpty == true
              ? existing!.userId
              : 'local-user');

    final base = existing?.toJson() ?? <String, dynamic>{};
    base.addAll(_allergyUpsertPayload(payload));
    base['_id'] = allergyId;
    base['userId'] = userId;
    base['createdAt'] = existing?.createdAt ?? now;
    base['updatedAt'] = now;
    return AllergyApiModel.fromJson(base);
  }

  ImmunizationApiModel _buildOfflineImmunization({
    String? id,
    required ImmunizationUpsertEntity payload,
    ImmunizationApiModel? existing,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    final immunizationId = id ?? existing?.id ?? _newLocalId();
    final userId =
        _userSessionService.getCurrentUserId()?.trim().isNotEmpty == true
        ? _userSessionService.getCurrentUserId()!.trim()
        : (existing?.userId.isNotEmpty == true
              ? existing!.userId
              : 'local-user');

    final base = existing?.toJson() ?? <String, dynamic>{};
    base.addAll(_immunizationUpsertPayload(payload));
    base['_id'] = immunizationId;
    base['userId'] = userId;
    base['createdAt'] = existing?.createdAt ?? now;
    base['updatedAt'] = now;
    return ImmunizationApiModel.fromJson(base);
  }

  String _newLocalId() => 'local_${DateTime.now().microsecondsSinceEpoch}';

  ApiFailure _dioFailure(DioException e, String fallback) {
    final data = e.response?.data;
    String? message;
    if (data is Map<String, dynamic>) {
      message = data['message']?.toString();
    } else if (data is Map) {
      message = data['message']?.toString();
    }
    return ApiFailure(
      statusCode: e.response?.statusCode,
      message: message ?? fallback,
    );
  }

  ApiFailure _exceptionFailure(Object e) {
    final message = e.toString().replaceFirst('Exception: ', '');
    return ApiFailure(message: message);
  }
}
