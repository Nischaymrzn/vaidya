import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';

abstract interface class INotificationsRepository {
  Future<Either<Failure, NotificationsResultEntity>> getNotifications({
    required int page,
    required int limit,
    required bool unreadOnly,
  });

  Future<Either<Failure, NotificationEntity>> markRead(String id);
  Future<Either<Failure, bool>> markAllRead();
}
