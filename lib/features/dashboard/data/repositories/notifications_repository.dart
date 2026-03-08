import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/features/dashboard/data/datasources/local/notifications_local_datasource.dart';
import 'package:vaidya/features/dashboard/data/datasources/notifications_datasource.dart';
import 'package:vaidya/features/dashboard/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:vaidya/features/dashboard/data/models/notification_api_model.dart';
import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<INotificationsRepository>((
  ref,
) {
  return NotificationsRepository(
    remoteDataSource: ref.read(notificationsRemoteDataSourceProvider),
    localDataSource: ref.read(notificationsLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class NotificationsRepository implements INotificationsRepository {
  final INotificationsRemoteDataSource _remoteDataSource;
  final INotificationsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const NotificationsRepository({
    required INotificationsRemoteDataSource remoteDataSource,
    required INotificationsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, NotificationsResultEntity>> getNotifications({
    required int page,
    required int limit,
    required bool unreadOnly,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getNotifications(
          page: page,
          limit: limit,
          unreadOnly: unreadOnly,
        );

        await _localDataSource.saveNotifications(remote.items);
        await _localDataSource.savePagination(remote.pagination);

        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ?? 'Failed to fetch notifications',
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }

    final cachedItems = await _localDataSource.getNotifications();
    final cachedPagination = await _localDataSource.getPagination();

    if (cachedItems.isNotEmpty) {
      final pagination =
          cachedPagination ??
          const NotificationsPaginationApiModel(
            total: 0,
            page: 1,
            limit: 20,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          );
      return Right(
        NotificationsResultEntity(
          notifications: cachedItems
              .map((e) => e.toEntity())
              .toList(growable: false),
          pagination: pagination.toEntity(),
        ),
      );
    }

    return const Left(
      ApiFailure(
        message:
            'No internet connection and no cached notifications available.',
      ),
    );
  }

  @override
  Future<Either<Failure, NotificationEntity>> markRead(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final result = await _remoteDataSource.markRead(id);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              'Failed to mark notification as read',
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> markAllRead() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      await _remoteDataSource.markAllRead();
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              'Failed to mark all notifications as read',
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }
}
