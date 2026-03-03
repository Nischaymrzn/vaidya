import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/services/connectivity/network_info.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:vaidya/features/profile/data/datasources/profile_datasource.dart';
import 'package:vaidya/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:vaidya/features/profile/domain/entities/profile_payment_status_entity.dart';
import 'package:vaidya/features/profile/domain/entities/profile_user_entity.dart';
import 'package:vaidya/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
    localDataSource: ref.read(profileLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class ProfileRepository implements IProfileRepository {
  final IProfileRemoteDataSource _remoteDataSource;
  final IProfileLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final UserSessionService _userSessionService;

  const ProfileRepository({
    required IProfileRemoteDataSource remoteDataSource,
    required IProfileLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required UserSessionService userSessionService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, ProfileUserEntity>> getUserById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getUserById(id);
        await _localDataSource.saveUser(remote);
        await _syncSessionFromProfileData(remote.data);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data['message'] ?? 'Failed to fetch profile',
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }

    final cached = await _localDataSource.getUser();
    if (cached != null) {
      return Right(cached.toEntity());
    }

    return const Left(
      ApiFailure(
        message: 'No internet connection and no cached profile available.',
      ),
    );
  }

  @override
  Future<Either<Failure, ProfileUserEntity>> updateUser(
    String id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final remote = await _remoteDataSource.updateUser(
        id,
        payload,
        imagePath: imagePath,
      );
      await _localDataSource.saveUser(remote);
      await _syncSessionFromProfileData(remote.data);
      return Right(remote.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to update profile',
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      await _remoteDataSource.deleteUser(id);
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message: e.response?.data['message'] ?? 'Failed to delete profile',
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, ProfilePaymentStatusEntity>> getPaymentStatus() async {
    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getPaymentStatus();
        await _localDataSource.savePaymentStatus(remote);
        await _userSessionService.setCurrentUserIsPremium(remote.isPremium);
        return Right(remote.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data['message'] ?? 'Failed to fetch premium status',
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }

    final cached = await _localDataSource.getPaymentStatus();
    if (cached != null) {
      return Right(cached.toEntity());
    }
    return const Left(
      ApiFailure(
        message:
            'No internet connection and no cached premium status available.',
      ),
    );
  }

  @override
  Future<Either<Failure, String>> createCheckoutSession() async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection.'));
    }

    try {
      final remote = await _remoteDataSource.createCheckoutSession();
      final url = remote.checkoutUrl.trim();
      if (url.isEmpty) {
        return const Left(
          ApiFailure(message: 'Checkout URL was not returned by server.'),
        );
      }
      return Right(url);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message'] ??
              'Failed to create checkout session',
        ),
      );
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString().replaceFirst('Exception: ', '')),
      );
    }
  }

  Future<void> _syncSessionFromProfileData(Map<String, dynamic> data) async {
    final currentUserId = _userSessionService.getCurrentUserId();
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      return;
    }

    final userId = (data['_id'] ?? data['id'] ?? currentUserId).toString();
    final email =
        (data['email'] ?? _userSessionService.getCurrentUserEmail() ?? '')
            .toString();
    final name =
        (data['name'] ?? _userSessionService.getCurrentUserFullName() ?? 'User')
            .toString();
    final number =
        (data['number'] ?? _userSessionService.getCurrentUserPhoneNumber())
            ?.toString();
    final role = (data['role'] ?? _userSessionService.getCurrentUserRole())
        ?.toString();
    final profilePicture =
        (data['profilePicture'] ??
                _userSessionService.getCurrentUserProfilePicture())
            ?.toString();
    final isPremium =
        (data['isPremium'] as bool?) ??
        _userSessionService.getCurrentUserIsPremium();

    await _userSessionService.saveUserSession(
      userId: userId,
      email: email,
      name: name,
      role: role,
      number: number,
      profilePicture: profilePicture,
      isPremium: isPremium,
    );
  }
}
